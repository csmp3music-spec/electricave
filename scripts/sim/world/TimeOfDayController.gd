extends Node
class_name TimeOfDayController

signal calendar_changed(payload: Dictionary)

@export var sun_path: NodePath
@export var environment_path: NodePath
@export var economy_path: NodePath
@export var historical_events_path: NodePath
@export var start_year := 1900
@export_range(1, 12, 1) var start_month := 5
@export_range(1, 31, 1) var start_day := 1
@export_range(0.0, 23.99, 0.01) var start_hour := 6.5
@export var game_minutes_per_real_second := 0.4
@export var day_light_energy := 1.9
@export var night_light_energy := 0.08
@export var ambient_day_energy := 1.0
@export var ambient_night_energy := 0.22
@export var dawn_color := Color(1.0, 0.80, 0.64, 1.0)
@export var noon_color := Color(1.0, 0.97, 0.90, 1.0)
@export var night_color := Color(0.45, 0.56, 0.76, 1.0)
@export var dawn_sky := Color(0.80, 0.71, 0.58, 1.0)
@export var noon_sky := Color(0.68, 0.77, 0.88, 1.0)
@export var night_sky := Color(0.07, 0.10, 0.18, 1.0)

var _current_year := 1900
var _current_month := 1
var _current_day := 1
var _minutes_into_day := 0.0

@onready var _sun: DirectionalLight3D = _resolve_node(sun_path) as DirectionalLight3D
@onready var _world_environment: WorldEnvironment = _resolve_node(environment_path) as WorldEnvironment
@onready var _economy: Node = _resolve_node(economy_path)
@onready var _historical_events: Node = _resolve_node(historical_events_path)

func _ready() -> void:
	_current_year = start_year
	_current_month = start_month
	_current_day = start_day
	_minutes_into_day = clampf(start_hour, 0.0, 23.99) * 60.0
	if _historical_events != null and _has_property(_historical_events, "current_year"):
		_historical_events.set("current_year", _current_year)
	if _economy != null and _economy.has_method("set_reporting_period"):
		_economy.call("set_reporting_period", _current_year, _current_month)
	_apply_lighting()
	emit_signal("calendar_changed", get_time_payload())

func _process(delta: float) -> void:
	if delta <= 0.0:
		return
	_advance_minutes(delta * game_minutes_per_real_second)
	_apply_lighting()

func get_time_payload() -> Dictionary:
	var hour := int(floor(_minutes_into_day / 60.0))
	var minute := int(floor(fmod(_minutes_into_day, 60.0)))
	return {
		"year": _current_year,
		"month": _current_month,
		"day": _current_day,
		"hour": hour,
		"minute": minute,
		"clock_text": "%02d:%02d" % [hour, minute],
		"date_text": "%s %d, %d" % [_month_name(_current_month), _current_day, _current_year],
		"hud_text": "%s  %s" % ["%02d:%02d" % [hour, minute], "%s %d, %d" % [_month_name(_current_month), _current_day, _current_year]]
	}

func get_hud_time_text() -> String:
	return String(get_time_payload().get("hud_text", ""))

func _advance_minutes(game_minutes: float) -> void:
	_minutes_into_day += game_minutes
	while _minutes_into_day >= 1440.0:
		_minutes_into_day -= 1440.0
		_advance_day()
	emit_signal("calendar_changed", get_time_payload())

func _advance_day() -> void:
	_current_day += 1
	var days_in_month := _days_in_month(_current_month, _current_year)
	if _current_day <= days_in_month:
		return
	var closing_year := _current_year
	var closing_month := _current_month
	_current_day = 1
	if _economy != null and _economy.has_method("end_month"):
		if _economy.has_method("set_reporting_period"):
			_economy.call("set_reporting_period", closing_year, closing_month)
		_economy.call("end_month")
	_current_month += 1
	if _current_month <= 12:
		if _economy != null and _economy.has_method("set_reporting_period"):
			_economy.call("set_reporting_period", _current_year, _current_month)
		return
	_current_month = 1
	_current_year += 1
	if _economy != null and _economy.has_method("set_reporting_period"):
		_economy.call("set_reporting_period", _current_year, _current_month)
	if _historical_events != null and _historical_events.has_method("advance_year"):
		_historical_events.call("advance_year")

func _apply_lighting() -> void:
	var day_phase := _minutes_into_day / 1440.0
	var solar_angle := (day_phase - 0.25) * TAU
	var sun_height := sin(solar_angle)
	var daylight := smoothstep(-0.12, 0.16, sun_height)
	var noonness := clampf(1.0 - absf((day_phase - 0.5) * 2.0), 0.0, 1.0)
	var warmness := daylight * (1.0 - noonness)
	if _sun != null:
		var pitch_deg := lerpf(10.0, -78.0, clampf((sun_height + 1.0) * 0.5, 0.0, 1.0))
		var yaw_deg := 42.0 + cos(day_phase * TAU) * 18.0
		_sun.rotation = Vector3(deg_to_rad(pitch_deg), deg_to_rad(yaw_deg), 0.0)
		_sun.light_energy = lerpf(night_light_energy, day_light_energy, daylight)
		var lit_color := noon_color.lerp(dawn_color, warmness)
		_sun.light_color = night_color.lerp(lit_color, daylight)
	if _world_environment == null or _world_environment.environment == null:
		return
	var env := _world_environment.environment
	env.background_color = night_sky.lerp(noon_sky.lerp(dawn_sky, warmness), daylight)
	env.ambient_light_color = night_color.lerp(noon_color.lerp(dawn_color, warmness), daylight)
	env.ambient_light_energy = lerpf(ambient_night_energy, ambient_day_energy, daylight)
	env.fog_enabled = daylight < 0.18
	env.fog_light_energy = lerpf(0.35, 0.0, daylight)
	env.fog_light_color = night_color.lerp(dawn_color, daylight)

func _resolve_node(path: NodePath) -> Node:
	if path == NodePath(""):
		return null
	return get_node_or_null(path)

func _days_in_month(month: int, year: int) -> int:
	match month:
		1, 3, 5, 7, 8, 10, 12:
			return 31
		4, 6, 9, 11:
			return 30
		2:
			var leap := year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)
			return 29 if leap else 28
	return 30

func _month_name(month: int) -> String:
	var names := [
		"", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
		"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
	]
	if month < 1 or month >= names.size():
		return "Month"
	return names[month]

func _has_property(target: Object, prop_name: String) -> bool:
	if target == null:
		return false
	for prop in target.get_property_list():
		if String(prop.get("name", "")) == prop_name:
			return true
	return false
