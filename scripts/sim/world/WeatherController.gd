extends Node
class_name WeatherController

signal weather_changed(payload: Dictionary)

@export var time_controller_path: NodePath
@export var environment_path: NodePath
@export var rare_coastal_storm_chance := 0.003
@export var heavy_rain_portal_threshold := 0.82
@export var rain_fog_boost := 0.012
@export var snow_fog_boost := 0.018
@export var hurricane_1938_damage_days := 6

var _payload := {
	"state": "CLEAR",
	"intensity": 0.0,
	"hud_text": "Weather: Clear",
	"portal_flooding": false,
	"snow_active": false,
	"rain_active": false,
	"rare_storm": false,
	"damage_active": false,
	"closed_lines": {},
	"flooded_portals": []
}
var _last_stamp := ""

@onready var _time_controller: Node = _resolve_node(time_controller_path)
@onready var _world_environment: WorldEnvironment = _resolve_node(environment_path) as WorldEnvironment

func _ready() -> void:
	if _time_controller != null and _time_controller.has_signal("calendar_changed"):
		_time_controller.connect("calendar_changed", Callable(self, "_on_calendar_changed"))
	var seed_payload := {}
	if _time_controller != null and _time_controller.has_method("get_time_payload"):
		seed_payload = _time_controller.call("get_time_payload")
	_on_calendar_changed(seed_payload)

func get_weather_payload() -> Dictionary:
	return _payload.duplicate(true)

func get_hud_text() -> String:
	return String(_payload.get("hud_text", "Weather: Clear"))

func is_line_portal_closed(line_id: String) -> bool:
	if not bool(_payload.get("portal_flooding", false)):
		return false
	return line_id in ["atlantic", "blue"]

func get_line_closure_reason(line_id: String) -> String:
	var closed_lines: Dictionary = _payload.get("closed_lines", {})
	return String(closed_lines.get(line_id, ""))

func _on_calendar_changed(calendar_payload: Dictionary) -> void:
	var stamp := "%s-%s-%s" % [int(calendar_payload.get("year", 1900)), int(calendar_payload.get("month", 1)), int(calendar_payload.get("day", 1))]
	if stamp == _last_stamp:
		return
	_last_stamp = stamp
	_resample_weather(calendar_payload)
	_apply_environment_weather()
	emit_signal("weather_changed", get_weather_payload())

func _resample_weather(calendar_payload: Dictionary) -> void:
	var year := int(calendar_payload.get("year", 1900))
	var month := int(calendar_payload.get("month", 1))
	var day := int(calendar_payload.get("day", 1))
	var base_noise := _daily_noise(year, month, day, "base")
	var intensity_noise := _daily_noise(year, month, day, "intensity")
	var storm_noise := _daily_noise(year, month, day, "storm")
	var state := "CLEAR"
	var intensity := 0.0
	var rare_storm := false
	var hurricane_1938_landfall := year == 1938 and month == 9 and day == 21
	var hurricane_1938_damage_active := year == 1938 and month == 9 and day > 21 and day <= 21 + hurricane_1938_damage_days
	if hurricane_1938_landfall:
		state = "COASTAL STORM"
		intensity = 1.0
		rare_storm = true
	elif hurricane_1938_damage_active:
		state = "RAIN" if base_noise > 0.22 else "CLEAR"
		intensity = maxf(0.46, 0.35 + intensity_noise * 0.4)
		rare_storm = true
	elif month in [12, 1, 2, 3]:
		if base_noise > 0.60:
			state = "SNOW"
			intensity = 0.35 + intensity_noise * 0.6
		elif base_noise > 0.42:
			state = "RAIN"
			intensity = 0.25 + intensity_noise * 0.45
	elif month in [4, 5, 10, 11]:
		if base_noise > 0.68:
			state = "RAIN"
			intensity = 0.35 + intensity_noise * 0.55
	elif month in [6, 7, 8, 9] and storm_noise > 1.0 - rare_coastal_storm_chance:
		state = "COASTAL STORM"
		intensity = 0.82 + intensity_noise * 0.18
		rare_storm = true
	elif base_noise > 0.74:
		state = "RAIN"
		intensity = 0.25 + intensity_noise * 0.5
	var portal_flooding := state == "COASTAL STORM" or (state == "RAIN" and intensity >= heavy_rain_portal_threshold)
	var closed_lines := {}
	var flooded_portals := []
	if portal_flooding:
		closed_lines["blue"] = "Harbor tunnel portals closed by coastal flooding"
		closed_lines["atlantic"] = "Waterfront elevated approaches closed by flooding"
		flooded_portals.append({"line_id": "blue", "name": "Aquarium-Maverick harbor tunnel"})
		flooded_portals.append({"line_id": "atlantic", "name": "Atlantic Avenue waterfront"})
	if hurricane_1938_landfall or hurricane_1938_damage_active:
		closed_lines["blue"] = "North Shore service disabled by 1938 hurricane coastal damage"
		closed_lines["atlantic"] = "Atlantic Avenue Elevated disabled by 1938 hurricane damage"
		flooded_portals.append({"line_id": "blue", "name": "North Shore seawall washout and tunnel damage"})
		flooded_portals.append({"line_id": "atlantic", "name": "Atlantic Avenue structural storm damage"})
	_payload = {
		"state": state,
		"intensity": intensity,
		"hud_text": _hud_text_for_state(state, intensity, portal_flooding, hurricane_1938_landfall or hurricane_1938_damage_active),
		"portal_flooding": portal_flooding,
		"snow_active": state == "SNOW",
		"rain_active": state == "RAIN" or state == "COASTAL STORM",
		"rare_storm": rare_storm,
		"damage_active": hurricane_1938_landfall or hurricane_1938_damage_active,
		"closed_lines": closed_lines,
		"flooded_portals": flooded_portals
	}

func _hud_text_for_state(state: String, intensity: float, portal_flooding: bool, damage_active: bool) -> String:
	var suffix := ""
	if portal_flooding:
		suffix = " | Coastal portals closed"
	if damage_active:
		suffix += " | 1938 hurricane damage"
	match state:
		"SNOW":
			return "Weather: Snow %.0f%%%s" % [int(round(intensity * 100.0)), suffix]
		"RAIN":
			return "Weather: Rain %.0f%%%s" % [int(round(intensity * 100.0)), suffix]
		"COASTAL STORM":
			return "Weather: Coastal storm%s" % suffix
	return "Weather: Clear"

func _apply_environment_weather() -> void:
	if _world_environment == null or _world_environment.environment == null:
		return
	var env := _world_environment.environment
	var state := String(_payload.get("state", "CLEAR"))
	var intensity := float(_payload.get("intensity", 0.0))
	if state == "SNOW":
		env.fog_enabled = true
		env.fog_density = 0.012 + snow_fog_boost * intensity
		env.background_color = env.background_color.lerp(Color(0.79, 0.82, 0.86, 1.0), 0.35)
	elif state == "RAIN":
		env.fog_enabled = true
		env.fog_density = 0.008 + rain_fog_boost * intensity
		env.background_color = env.background_color.lerp(Color(0.44, 0.48, 0.56, 1.0), 0.28)
	elif state == "COASTAL STORM":
		env.fog_enabled = true
		env.fog_density = 0.024
		env.background_color = env.background_color.lerp(Color(0.20, 0.24, 0.30, 1.0), 0.42)
	else:
		env.fog_density = maxf(0.0, env.fog_density * 0.6)

func _daily_noise(year: int, month: int, day: int, salt: String) -> float:
	var key := "%d-%d-%d-%s" % [year, month, day, salt]
	var hash_value: int = abs(key.hash()) % 10000
	return float(hash_value) / 9999.0

func _resolve_node(path: NodePath) -> Node:
	if path == NodePath(""):
		return null
	return get_node_or_null(path)
