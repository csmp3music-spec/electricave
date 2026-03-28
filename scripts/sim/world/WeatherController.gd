extends Node
class_name WeatherController

signal weather_changed(payload: Dictionary)

const BostonLatitude := 42.3601
const BostonLongitude := -71.0589

@export var time_controller_path: NodePath
@export var environment_path: NodePath
@export var use_nws_boston_live_data := true
@export var nws_latitude := BostonLatitude
@export var nws_longitude := BostonLongitude
@export var nws_station_id := "KBOS"
@export var nws_alert_area := "MA"
@export var nws_refresh_seconds := 900.0
@export var nws_user_agent := "Electric Avenue Boston weather feed (local@test)"
@export var rare_coastal_storm_chance := 0.003
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
	"flooded_portals": [],
	"cloud_cover": 0.08,
	"surface_wetness": 0.0,
	"snow_cover": 0.0,
	"storminess": 0.0,
	"wind_speed_mps": 0.0,
	"temperature_c": 14.0,
	"humidity": 0.45,
	"alert_names": [],
	"source": "simulated"
}
var _last_stamp := ""
var _nws_refresh_accum := 99999.0
var _nws_refresh_in_progress := false
var _nws_points_url := ""
var _nws_forecast_hourly_url := ""
var _nws_observation_url := ""
var _nws_alerts_url := ""
var _nws_points_payload := {}
var _nws_forecast_payload := {}
var _nws_observation_payload := {}
var _nws_alerts_payload := {"features": []}
var _nws_live_active := false

@onready var _time_controller: Node = _resolve_node(time_controller_path)
@onready var _world_environment: WorldEnvironment = _resolve_node(environment_path) as WorldEnvironment
@onready var _points_request: HTTPRequest = _make_requester("NWSPointsRequest", "_on_nws_points_request_completed")
@onready var _forecast_request: HTTPRequest = _make_requester("NWSForecastRequest", "_on_nws_forecast_request_completed")
@onready var _observation_request: HTTPRequest = _make_requester("NWSObservationRequest", "_on_nws_observation_request_completed")
@onready var _alerts_request: HTTPRequest = _make_requester("NWSAlertsRequest", "_on_nws_alerts_request_completed")

func _ready() -> void:
	if _time_controller != null and _time_controller.has_signal("calendar_changed"):
		_time_controller.connect("calendar_changed", Callable(self, "_on_calendar_changed"))
	var seed_payload := {}
	if _time_controller != null and _time_controller.has_method("get_time_payload"):
		seed_payload = _time_controller.call("get_time_payload")
	_on_calendar_changed(seed_payload)

func _process(delta: float) -> void:
	if not use_nws_boston_live_data:
		return
	_nws_refresh_accum += delta
	if _nws_refresh_accum >= maxf(60.0, nws_refresh_seconds):
		_request_nws_refresh()

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

func force_refresh_live_weather() -> void:
	if use_nws_boston_live_data:
		_request_nws_refresh(true)

func _on_calendar_changed(calendar_payload: Dictionary) -> void:
	var stamp := "%s-%s-%s" % [
		int(calendar_payload.get("year", 1900)),
		int(calendar_payload.get("month", 1)),
		int(calendar_payload.get("day", 1))
	]
	if stamp == _last_stamp and _nws_live_active:
		return
	_last_stamp = stamp
	if not _nws_live_active:
		_resample_weather(calendar_payload)
	_apply_environment_weather()
	emit_signal("weather_changed", get_weather_payload())
	if use_nws_boston_live_data:
		_request_nws_refresh()

func _request_nws_refresh(force: bool = false) -> void:
	if _nws_refresh_in_progress and not force:
		return
	_nws_refresh_accum = 0.0
	_nws_refresh_in_progress = true
	_nws_points_payload.clear()
	_nws_forecast_payload.clear()
	_nws_observation_payload.clear()
	_nws_alerts_payload = {"features": []}
	_nws_points_url = "https://api.weather.gov/points/%.4f,%.4f" % [nws_latitude, nws_longitude]
	_nws_observation_url = "https://api.weather.gov/stations/%s/observations/latest" % nws_station_id.strip_edges()
	_nws_alerts_url = "https://api.weather.gov/alerts/active?area=%s" % nws_alert_area.strip_edges()
	_request_json(_points_request, _nws_points_url)
	_request_json(_observation_request, _nws_observation_url)
	_request_json(_alerts_request, _nws_alerts_url)

func _make_requester(node_name: String, callback_name: String) -> HTTPRequest:
	var existing := get_node_or_null(node_name) as HTTPRequest
	if existing != null:
		return existing
	var requester := HTTPRequest.new()
	requester.name = node_name
	add_child(requester)
	requester.request_completed.connect(Callable(self, callback_name))
	return requester

func _request_json(requester: HTTPRequest, url: String) -> void:
	if requester == null or url == "":
		return
	var headers := PackedStringArray([
		"User-Agent: %s" % nws_user_agent,
		"Accept: application/geo+json, application/ld+json, application/json"
	])
	var err := requester.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		_nws_refresh_in_progress = false

func _on_nws_points_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		_nws_refresh_in_progress = false
		return
	_nws_points_payload = _parse_json_dictionary(body)
	var props: Dictionary = _nws_points_payload.get("properties", {})
	_nws_forecast_hourly_url = String(props.get("forecastHourly", ""))
	if _nws_forecast_hourly_url != "":
		_request_json(_forecast_request, _nws_forecast_hourly_url)
	else:
		_nws_refresh_in_progress = false

func _on_nws_forecast_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		_nws_refresh_in_progress = false
		return
	_nws_forecast_payload = _parse_json_dictionary(body)
	_try_commit_live_payload()

func _on_nws_observation_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		_nws_refresh_in_progress = false
		return
	_nws_observation_payload = _parse_json_dictionary(body)
	_try_commit_live_payload()

func _on_nws_alerts_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300:
		_nws_alerts_payload = _parse_json_dictionary(body)
	_try_commit_live_payload()

func _try_commit_live_payload() -> void:
	if _nws_points_payload.is_empty() or _nws_forecast_payload.is_empty() or _nws_observation_payload.is_empty():
		return
	_payload = _build_live_payload()
	_nws_live_active = true
	_nws_refresh_in_progress = false
	_apply_environment_weather()
	emit_signal("weather_changed", get_weather_payload())

func _build_live_payload() -> Dictionary:
	var observation_props: Dictionary = _nws_observation_payload.get("properties", {})
	var forecast_props: Dictionary = _nws_forecast_payload.get("properties", {})
	var forecast_periods: Array = forecast_props.get("periods", [])
	var current_period: Dictionary = forecast_periods[0] if not forecast_periods.is_empty() else {}
	var observation_text := String(observation_props.get("textDescription", ""))
	var forecast_text := String(current_period.get("shortForecast", ""))
	var weather_text := ("%s %s" % [observation_text, forecast_text]).strip_edges()
	var alerts: Array = _nws_alerts_payload.get("features", [])
	var alert_names := _alert_titles(alerts)
	var cloud_cover := _cloud_cover_from_nws(observation_props, current_period)
	var temperature_c := _temperature_c_from_nws(observation_props, current_period)
	var humidity := clampf(_value_fraction(observation_props.get("relativeHumidity", {}), 100.0), 0.0, 1.0)
	var precip_probability := clampf(_value_fraction(current_period.get("probabilityOfPrecipitation", {}), 100.0), 0.0, 1.0)
	var wind_speed_mps := maxf(
		_quantity_to_mps(observation_props.get("windSpeed", {})),
		_quantity_to_mps(observation_props.get("windGust", {}))
	)
	var live_state := _live_state_from_terms(weather_text, temperature_c, alert_names)
	var rare_storm := _alerts_match_keywords(alerts, PackedStringArray(["hurricane", "coastal flood", "tropical storm", "severe thunderstorm", "blizzard", "high wind"]))
	var hurricane_alert := _alerts_match_keywords(alerts, PackedStringArray(["hurricane", "tropical storm"]))
	var coastal_flood_alert := _alerts_match_keywords(alerts, PackedStringArray(["coastal flood", "storm surge", "flood warning", "flash flood"]))
	var storminess := clampf(maxf(precip_probability, wind_speed_mps / 24.0), 0.0, 1.0)
	if live_state in ["COASTAL STORM", "HURRICANE"]:
		storminess = maxf(storminess, 0.78)
	if hurricane_alert:
		storminess = 1.0
	var intensity := clampf(maxf(storminess, cloud_cover * 0.72), 0.0, 1.0)
	var snow_cover := 0.0
	if live_state == "SNOW":
		snow_cover = clampf(0.22 + maxf(intensity, precip_probability) * 0.72, 0.0, 1.0)
	var surface_wetness := clampf(humidity * 0.28 + precip_probability * 0.72 + storminess * 0.24, 0.0, 1.0)
	if live_state == "CLEAR":
		surface_wetness = humidity * 0.18
	var portal_flooding := coastal_flood_alert or hurricane_alert or (live_state == "COASTAL STORM" and rare_storm and intensity >= 0.84)
	var closed_lines := {}
	var flooded_portals := []
	if portal_flooding:
		closed_lines["blue"] = "Boston Harbor portals closed by NWS coastal flooding"
		closed_lines["atlantic"] = "Waterfront approaches closed by NWS storm flooding"
		flooded_portals.append({"line_id": "blue", "name": "Aquarium-Maverick harbor tunnel"})
		flooded_portals.append({"line_id": "atlantic", "name": "Atlantic Avenue waterfront"})
	return {
		"state": live_state,
		"intensity": intensity,
		"hud_text": _live_hud_text(live_state, observation_text, forecast_text, portal_flooding, nws_station_id),
		"portal_flooding": portal_flooding,
		"snow_active": live_state == "SNOW",
		"rain_active": live_state in ["RAIN", "COASTAL STORM", "HURRICANE"],
		"rare_storm": rare_storm,
		"damage_active": hurricane_alert,
		"closed_lines": closed_lines,
		"flooded_portals": flooded_portals,
		"cloud_cover": cloud_cover,
		"surface_wetness": surface_wetness,
		"snow_cover": snow_cover,
		"storminess": storminess,
		"wind_speed_mps": wind_speed_mps,
		"temperature_c": temperature_c,
		"humidity": humidity,
		"alert_names": alert_names,
		"source": "nws_boston_live"
	}

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
		state = "HURRICANE"
		intensity = 1.0
		rare_storm = true
	elif hurricane_1938_damage_active:
		state = "COASTAL STORM"
		intensity = 0.82
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
	var cloud_cover := clampf(0.10 + intensity * 0.82 + (0.08 if state == "CLEAR" and base_noise > 0.36 else 0.0), 0.0, 1.0)
	var surface_wetness := 0.0 if state == "CLEAR" else clampf(0.24 + intensity * 0.72, 0.0, 1.0)
	var snow_cover := clampf((0.22 + intensity * 0.7) if state == "SNOW" else 0.0, 0.0, 1.0)
	var portal_flooding := state in ["COASTAL STORM", "HURRICANE"]
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
		"rain_active": state in ["RAIN", "COASTAL STORM", "HURRICANE"],
		"rare_storm": rare_storm,
		"damage_active": hurricane_1938_landfall or hurricane_1938_damage_active,
		"closed_lines": closed_lines,
		"flooded_portals": flooded_portals,
		"cloud_cover": cloud_cover,
		"surface_wetness": surface_wetness,
		"snow_cover": snow_cover,
		"storminess": intensity if state in ["COASTAL STORM", "HURRICANE"] else 0.0,
		"wind_speed_mps": lerpf(2.0, 22.0, intensity if rare_storm else intensity * 0.55),
		"temperature_c": 8.0 if month in [12, 1, 2, 3] else 18.0,
		"humidity": clampf(0.38 + intensity * 0.5, 0.0, 1.0),
		"alert_names": [],
		"source": "simulated"
	}

func _live_hud_text(state: String, observation_text: String, forecast_text: String, portal_flooding: bool, station_id: String) -> String:
	var source_text := "NWS Boston %s" % station_id
	var summary := observation_text if observation_text != "" else forecast_text
	if summary == "":
		summary = state.capitalize()
	if portal_flooding:
		summary += " | Coastal portals closed"
	return "%s: %s" % [source_text, summary]

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
		"HURRICANE":
			return "Weather: Hurricane%s" % suffix
	return "Weather: Clear"

func _apply_environment_weather() -> void:
	if _world_environment == null or _world_environment.environment == null:
		return
	var env := _world_environment.environment
	var state := String(_payload.get("state", "CLEAR"))
	var intensity := float(_payload.get("intensity", 0.0))
	var cloud_cover := float(_payload.get("cloud_cover", 0.0))
	if state == "SNOW":
		env.fog_enabled = true
		env.fog_density = 0.010 + snow_fog_boost * maxf(intensity, cloud_cover)
		env.background_color = env.background_color.lerp(Color(0.79, 0.82, 0.86, 1.0), 0.35)
	elif state == "RAIN":
		env.fog_enabled = true
		env.fog_density = 0.007 + rain_fog_boost * maxf(intensity, cloud_cover)
		env.background_color = env.background_color.lerp(Color(0.44, 0.48, 0.56, 1.0), 0.28)
	elif state == "COASTAL STORM":
		env.fog_enabled = true
		env.fog_density = 0.020 + intensity * 0.01
		env.background_color = env.background_color.lerp(Color(0.22, 0.25, 0.30, 1.0), 0.46)
	elif state == "HURRICANE":
		env.fog_enabled = true
		env.fog_density = 0.028
		env.background_color = env.background_color.lerp(Color(0.16, 0.18, 0.23, 1.0), 0.58)
	elif cloud_cover > 0.42:
		env.fog_enabled = true
		env.fog_density = 0.004 + cloud_cover * 0.004
	else:
		env.fog_density = maxf(0.0, env.fog_density * 0.55)

func _parse_json_dictionary(body: PackedByteArray) -> Dictionary:
	if body.is_empty():
		return {}
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if parsed is Dictionary:
		return parsed
	return {}

func _cloud_cover_from_nws(observation_props: Dictionary, current_period: Dictionary) -> float:
	var layers: Array = observation_props.get("cloudLayers", [])
	var strongest := 0.0
	for layer_variant in layers:
		if not (layer_variant is Dictionary):
			continue
		var layer: Dictionary = layer_variant
		strongest = maxf(strongest, _cloud_amount_fraction(String(layer.get("amount", ""))))
	if strongest > 0.0:
		return strongest
	var icon := String(observation_props.get("icon", ""))
	var combined := ("%s %s" % [icon, String(current_period.get("shortForecast", ""))]).to_lower()
	if combined.find("ovc") != -1 or combined.find("overcast") != -1:
		return 0.95
	if combined.find("bkn") != -1 or combined.find("mostly cloudy") != -1:
		return 0.75
	if combined.find("sct") != -1 or combined.find("partly cloudy") != -1 or combined.find("partly sunny") != -1:
		return 0.48
	if combined.find("few") != -1 or combined.find("mostly clear") != -1:
		return 0.22
	return 0.05

func _cloud_amount_fraction(amount_code: String) -> float:
	match amount_code:
		"OVC":
			return 1.0
		"BKN":
			return 0.78
		"SCT":
			return 0.52
		"FEW":
			return 0.24
		"CLR", "SKC":
			return 0.04
		_:
			return 0.0

func _temperature_c_from_nws(observation_props: Dictionary, current_period: Dictionary) -> float:
	var observed := _quantity_value(observation_props.get("temperature", {}))
	if is_finite(observed):
		return observed
	var temp_f := float(current_period.get("temperature", 50.0))
	return (temp_f - 32.0) * (5.0 / 9.0)

func _value_fraction(value_dict: Dictionary, divisor: float) -> float:
	var raw := _quantity_value(value_dict)
	if not is_finite(raw):
		return 0.0
	return raw / maxf(1.0, divisor)

func _quantity_to_mps(value_dict: Dictionary) -> float:
	var raw := _quantity_value(value_dict)
	if not is_finite(raw):
		return 0.0
	var unit_code := String(value_dict.get("unitCode", ""))
	if unit_code.find("km_h-1") != -1:
		return raw / 3.6
	if unit_code.find("m_s-1") != -1:
		return raw
	if unit_code.find("mi_h-1") != -1:
		return raw * 0.44704
	return raw

func _quantity_value(value_dict: Dictionary) -> float:
	if value_dict.is_empty():
		return INF
	var raw: Variant = value_dict.get("value", null)
	if raw == null:
		return INF
	return float(raw)

func _live_state_from_terms(weather_text: String, temperature_c: float, alert_names: Array) -> String:
	var combined := weather_text.to_lower()
	for alert_name_variant in alert_names:
		combined += " " + String(alert_name_variant).to_lower()
	if _contains_any(combined, PackedStringArray(["hurricane", "tropical storm"])):
		return "HURRICANE"
	if _contains_any(combined, PackedStringArray(["coastal flood", "flash flood", "severe thunderstorm", "thunderstorm", "storm", "squall"])):
		return "COASTAL STORM"
	if _contains_any(combined, PackedStringArray(["snow", "flurries", "sleet", "ice pellets", "wintry mix", "blizzard"])):
		return "SNOW"
	if _contains_any(combined, PackedStringArray(["rain", "showers", "drizzle", "mist", "sprinkles"])) and temperature_c > -3.5:
		return "RAIN"
	if _contains_any(combined, PackedStringArray(["cloudy", "overcast", "mostly cloudy", "partly cloudy"])):
		return "CLOUDY"
	return "CLEAR"

func _alert_titles(alerts: Array) -> Array[String]:
	var titles: Array[String] = []
	for alert_variant in alerts:
		if not (alert_variant is Dictionary):
			continue
		var alert: Dictionary = alert_variant
		var props: Dictionary = alert.get("properties", {})
		var event_name := String(props.get("event", "")).strip_edges()
		if event_name != "":
			titles.append(event_name)
	return titles

func _alerts_match_keywords(alerts: Array, keywords: PackedStringArray) -> bool:
	for title in _alert_titles(alerts):
		if _contains_any(title.to_lower(), keywords):
			return true
	return false

func _contains_any(text: String, keywords: PackedStringArray) -> bool:
	for keyword in keywords:
		if text.find(String(keyword).to_lower()) != -1:
			return true
	return false

func _daily_noise(year: int, month: int, day: int, salt: String) -> float:
	var key := "%d-%d-%d-%s" % [year, month, day, salt]
	var hash_value: int = abs(key.hash()) % 10000
	return float(hash_value) / 9999.0

func _resolve_node(path: NodePath) -> Node:
	if path == NodePath(""):
		return null
	return get_node_or_null(path)
