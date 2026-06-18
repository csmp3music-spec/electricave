extends Node
class_name PassengerSim

const PassengerCrowdActorScript := preload("res://scripts/characters/PassengerCrowdActor.gd")

class PassengerAgent:
	var home_id := ""
	var work_id := ""
	var income_class := 0
	var current_stop := ""
	var destination_stop := ""
	var preferred_route := ""

@export var town_manager_path: NodePath
@export var corridor_path: NodePath
@export var time_controller_path: NodePath
@export var crowd_refresh_seconds := 1.2
@export var crowd_regen_per_tick := 2
@export var max_visuals_per_stop := 18
@export var minimum_visuals_for_busy_stop := 2
@export var crowd_row_spacing := 1.25
@export var crowd_side_offset := 3.2
@export var use_imported_passenger_models := true
@export var max_imported_visuals_per_stop := 1
@export var imported_model_activation_radius_m := 450.0
@export var max_active_imported_visuals := 4
@export var overcrowding_threshold := 14
@export var severe_overcrowding_threshold := 24
@export var service_memory_seconds := 90.0
@export var downtown_peak_bonus := 0.18
@export var trolley_park_peak_bonus := 0.42
@export var summer_park_bonus := 0.24
@export var perceived_wait_weight := 0.72
@export var station_amenity_rating_bonus := 10.0
@export var uncertainty_rating_penalty := 16.0
@export var lost_rider_pressure_threshold := 0.55
@export var overcrowding_alarm_seconds := 42.0
@export var severe_overcrowding_alarm_seconds := 20.0
@export var overcrowding_recovery_rate := 2.4

var agents: Array[PassengerAgent] = []
var _town_manager: Node
var _corridor: Node
var _time_controller: Node
var _crowd_root: Node3D
var _crowd_nodes := {}
var _waiting_counts := {}
var _last_service_age_s := {}
var _stop_service_ratings := {}
var _overcrowding_age_s := {}
var _last_rescue_event := {}
var _calendar_payload := {
	"year": 1900,
	"month": 5,
	"day": 1,
	"hour": 6,
	"minute": 30
}
var _refresh_accum := 0.0

func _ready() -> void:
	_resolve_dependencies()
	_connect_time_controller()
	_ensure_crowd_root()
	call_deferred("_refresh_station_crowds")

func seed_population(count: int) -> void:
	agents.clear()
	for i in range(count):
		var agent := PassengerAgent.new()
		agents.append(agent)

func _process(delta: float) -> void:
	_refresh_accum += delta
	if not _last_rescue_event.is_empty():
		_last_rescue_event["age_s"] = float(_last_rescue_event.get("age_s", 0.0)) + maxf(delta, 0.0)
	if _refresh_accum < crowd_refresh_seconds:
		return
	_refresh_accum = 0.0
	_refresh_station_crowds()

func get_waiting_count_for_stop(stop_name: String) -> int:
	var stop = _find_stop_by_name(stop_name)
	if stop == null:
		return 0
	var stop_id := String(stop.stop_id)
	if _waiting_counts.has(stop_id):
		return int(_waiting_counts[stop_id])
	return _target_waiting_count(stop)

func get_stop_service_snapshot(stop_name: String) -> Dictionary:
	var stop = _find_stop_by_name(stop_name)
	return _build_stop_service_snapshot(stop)

func get_station_operations_snapshot(limit: int = 6) -> Array[Dictionary]:
	if _town_manager == null or not is_instance_valid(_town_manager):
		_resolve_dependencies()
	var rows: Array[Dictionary] = []
	for stop in _stop_list():
		var snapshot: Dictionary = _build_stop_service_snapshot(stop)
		if snapshot.is_empty():
			continue
		var priority_score := _station_priority_score(snapshot)
		var row: Dictionary = snapshot.duplicate(true)
		row["priority_score"] = priority_score
		row["status"] = _station_status_label(snapshot, priority_score)
		row["recommendation"] = _station_recommendation(snapshot)
		rows.append(row)
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("priority_score", 0.0)) > float(b.get("priority_score", 0.0))
	)
	var max_rows := maxi(1, limit)
	while rows.size() > max_rows:
		rows.remove_at(rows.size() - 1)
	return rows

func get_network_gameplay_snapshot() -> Dictionary:
	if _town_manager == null or not is_instance_valid(_town_manager):
		_resolve_dependencies()
	var stop_count := 0
	var total_waiting := 0
	var overcrowded_stop_count := 0
	var severe_stop_count := 0
	var rating_total := 0.0
	var highest_pressure := 0.0
	var worst_stop_name := ""
	var worst_stop_waiting := 0
	var perceived_wait_total := 0.0
	var lost_riders_total := 0
	var crowding_alarm_count := 0
	var urgent_crowding_alarm_count := 0
	var rescue_stop_name := ""
	var rescue_time_left_s := INF
	var rescue_alarm_limit_s := 0.0
	var rescue_waiting := 0
	for stop in _stop_list():
		var snapshot: Dictionary = _build_stop_service_snapshot(stop)
		if snapshot.is_empty():
			continue
		stop_count += 1
		var waiting := int(snapshot.get("waiting", 0))
		var pressure := float(snapshot.get("crowding_pressure", 0.0))
		total_waiting += waiting
		perceived_wait_total += float(snapshot.get("perceived_wait_min", 0.0))
		lost_riders_total += int(snapshot.get("lost_riders", 0))
		rating_total += float(snapshot.get("rating", 75.0))
		if bool(snapshot.get("overcrowded", false)):
			overcrowded_stop_count += 1
		if bool(snapshot.get("severe_overcrowding", false)):
			severe_stop_count += 1
		if waiting > worst_stop_waiting:
			worst_stop_waiting = waiting
			worst_stop_name = String(snapshot.get("stop_name", ""))
		highest_pressure = maxf(highest_pressure, pressure)
		if bool(snapshot.get("crowding_alarm", false)):
			crowding_alarm_count += 1
			var time_left := float(snapshot.get("overcrowding_time_left_s", INF))
			if time_left <= rescue_time_left_s:
				rescue_time_left_s = time_left
				rescue_stop_name = String(snapshot.get("stop_name", ""))
				rescue_alarm_limit_s = float(snapshot.get("overcrowding_limit_s", 0.0))
				rescue_waiting = waiting
		if bool(snapshot.get("crowding_urgent", false)):
			urgent_crowding_alarm_count += 1
	if stop_count <= 0:
		return {
			"stop_count": 0,
			"total_waiting": 0,
			"average_rating": 75.0,
			"overcrowded_stop_count": 0,
			"severe_stop_count": 0,
			"crowding_alarm_count": 0,
			"urgent_crowding_alarm_count": 0,
			"worst_stop_name": "",
			"worst_stop_waiting": 0,
			"rescue_stop_name": "",
			"rescue_time_left_s": 0.0,
			"rescue_alarm_limit_s": 0.0,
			"rescue_waiting": 0,
			"average_perceived_wait_min": 0.0,
			"lost_riders": 0,
			"highest_pressure": 0.0,
			"advisory_text": ""
		}
	var average_rating := rating_total / float(stop_count)
	var average_perceived_wait := perceived_wait_total / float(stop_count)
	var advisory_text := ""
	if urgent_crowding_alarm_count > 0 and rescue_stop_name != "":
		advisory_text = "Dispatch rescue to %s: %d waiting, %.0fs left" % [rescue_stop_name, rescue_waiting, rescue_time_left_s]
	elif severe_stop_count > 0 and worst_stop_name != "":
		advisory_text = "Crowding alert: %s has %d waiting; add cars or cut headway" % [worst_stop_name, worst_stop_waiting]
	elif lost_riders_total > 0:
		advisory_text = "Riders walked away: %d lost this cycle" % lost_riders_total
	elif average_perceived_wait >= 7.5:
		advisory_text = "Long perceived waits: %.1f min average" % average_perceived_wait
	elif overcrowded_stop_count >= 3:
		advisory_text = "System pressure rising: %d crowded stops" % overcrowded_stop_count
	return {
		"stop_count": stop_count,
		"total_waiting": total_waiting,
		"average_rating": average_rating,
		"average_perceived_wait_min": average_perceived_wait,
		"lost_riders": lost_riders_total,
		"overcrowded_stop_count": overcrowded_stop_count,
		"severe_stop_count": severe_stop_count,
		"crowding_alarm_count": crowding_alarm_count,
		"urgent_crowding_alarm_count": urgent_crowding_alarm_count,
		"worst_stop_name": worst_stop_name,
		"worst_stop_waiting": worst_stop_waiting,
		"rescue_stop_name": rescue_stop_name,
		"rescue_time_left_s": 0.0 if rescue_time_left_s == INF else rescue_time_left_s,
		"rescue_alarm_limit_s": rescue_alarm_limit_s,
		"rescue_waiting": rescue_waiting,
		"highest_pressure": highest_pressure,
		"advisory_text": advisory_text
	}

func service_stop_by_name(stop_name: String, capacity_hint: int = 12) -> Dictionary:
	var stop = _find_stop_by_name(stop_name)
	if stop == null:
		return {}
	var stop_id := String(stop.stop_id)
	var current_waiting := get_waiting_count_for_stop(stop_name)
	var rescue_candidate := _is_rescue_candidate(stop_id, current_waiting)
	var rescue_age_s := float(_overcrowding_age_s.get(stop_id, 0.0))
	var boarded := 0
	if capacity_hint > 0:
		boarded = mini(current_waiting, capacity_hint)
	_waiting_counts[stop_id] = maxi(0, current_waiting - boarded)
	_last_service_age_s[stop_id] = 0.0
	if int(_waiting_counts[stop_id]) < overcrowding_threshold:
		_overcrowding_age_s.erase(stop_id)
	elif current_waiting != int(_waiting_counts[stop_id]):
		_update_overcrowding_timer(stop, int(_waiting_counts[stop_id]), 0.0)
	_stop_service_ratings[stop_id] = _service_rating_for_stop(stop, int(_waiting_counts[stop_id]), 0.0)
	if rescue_candidate and boarded > 0 and int(_waiting_counts[stop_id]) < overcrowding_threshold:
		_last_rescue_event = {
			"stop_id": stop_id,
			"stop_name": String(stop.town_name),
			"boarded": boarded,
			"waiting_before": current_waiting,
			"waiting_after": int(_waiting_counts[stop_id]),
			"rescue_age_s": rescue_age_s,
			"age_s": 0.0
		}
	_sync_stop_visuals(stop, int(_waiting_counts[stop_id]))
	return {
		"boarded": boarded,
		"waiting": int(_waiting_counts[stop_id])
	}

func claim_recent_rescue_event(max_age_s: float = 8.0) -> Dictionary:
	if _last_rescue_event.is_empty():
		return {}
	if float(_last_rescue_event.get("age_s", 999.0)) > max_age_s:
		_last_rescue_event.clear()
		return {}
	var payload := _last_rescue_event.duplicate(true)
	_last_rescue_event.clear()
	return payload

func _refresh_station_crowds() -> void:
	if _town_manager == null or not is_instance_valid(_town_manager):
		_resolve_dependencies()
	if _town_manager == null or not is_instance_valid(_town_manager):
		return
	_ensure_crowd_root()
	var imported_budgets := _build_imported_visual_budgets(_stop_list())
	var live_stop_ids := {}
	for stop in _stop_list():
		if stop == null:
			continue
		var stop_id := String(stop.stop_id)
		live_stop_ids[stop_id] = true
		var service_age_s := minf(service_memory_seconds * 2.0, float(_last_service_age_s.get(stop_id, service_memory_seconds * 0.35)) + crowd_refresh_seconds)
		_last_service_age_s[stop_id] = service_age_s
		var target := _target_waiting_count(stop)
		var current := int(_waiting_counts.get(stop_id, target))
		if current < target:
			current = mini(target, current + crowd_regen_per_tick)
		elif current > target + 2:
			current = maxi(target, current - 1)
		var rating := _service_rating_for_stop(stop, current, service_age_s)
		var perceived_wait := _perceived_wait_minutes(stop, current, service_age_s)
		var lost_riders := _lost_riders_for_stop(stop, current, perceived_wait, rating)
		if lost_riders > 0:
			current = maxi(0, current - lost_riders)
			rating = _service_rating_for_stop(stop, current, service_age_s)
		_waiting_counts[stop_id] = current
		_update_overcrowding_timer(stop, current, crowd_refresh_seconds)
		_stop_service_ratings[stop_id] = rating
		_sync_stop_visuals(stop, current, int(imported_budgets.get(stop_id, 0)))
	_prune_missing_crowds(live_stop_ids)

func _resolve_dependencies() -> void:
	if town_manager_path != NodePath(""):
		_town_manager = get_node_or_null(town_manager_path)
	if _town_manager == null:
		_town_manager = get_parent().get_node_or_null("TownGrowthManager")
	if corridor_path != NodePath(""):
		_corridor = get_node_or_null(corridor_path)
	if _corridor == null:
		_corridor = get_parent().get_node_or_null("CorridorSeed")
	if time_controller_path != NodePath(""):
		_time_controller = get_node_or_null(time_controller_path)
	if _time_controller == null:
		_time_controller = get_parent().get_node_or_null("TimeOfDay")

func _connect_time_controller() -> void:
	if _time_controller == null or not is_instance_valid(_time_controller):
		return
	if _time_controller.has_method("get_time_payload"):
		var payload: Dictionary = _time_controller.call("get_time_payload")
		if not payload.is_empty():
			_calendar_payload = payload.duplicate(true)
	if _time_controller.has_signal("calendar_changed"):
		var callback := Callable(self, "_on_calendar_changed")
		if not _time_controller.is_connected("calendar_changed", callback):
			_time_controller.connect("calendar_changed", callback)

func _on_calendar_changed(payload: Dictionary) -> void:
	if payload.is_empty():
		return
	_calendar_payload = payload.duplicate(true)

func _ensure_crowd_root() -> void:
	if _crowd_root != null and is_instance_valid(_crowd_root):
		return
	_crowd_root = get_node_or_null("StationCrowds") as Node3D
	if _crowd_root == null:
		_crowd_root = Node3D.new()
		_crowd_root.name = "StationCrowds"
		add_child(_crowd_root)

func _stop_list() -> Array:
	if _town_manager == null or not is_instance_valid(_town_manager):
		return []
	return _town_manager.get("stops")

func _find_stop_by_name(stop_name: String):
	if stop_name == "":
		return null
	for stop in _stop_list():
		if stop == null:
			continue
		if String(stop.town_name) == stop_name:
			return stop
	return null

func _build_stop_service_snapshot(stop) -> Dictionary:
	if stop == null:
		return {}
	var stop_id := String(stop.stop_id)
	var waiting_count := int(_waiting_counts.get(stop_id, _target_waiting_count(stop)))
	var service_age_s := float(_last_service_age_s.get(stop_id, service_memory_seconds * 0.35))
	var rating := float(_stop_service_ratings.get(stop_id, _service_rating_for_stop(stop, waiting_count, service_age_s)))
	var crowding_pressure := _crowding_pressure(waiting_count)
	var perceived_wait := _perceived_wait_minutes(stop, waiting_count, service_age_s)
	var amenity_score := _amenity_score_for_stop(stop)
	var lost_riders := _lost_riders_for_stop(stop, waiting_count, perceived_wait, rating)
	var overcrowding_age := _overcrowding_age_for_stop(stop_id)
	var overcrowding_limit := _overcrowding_alarm_limit(waiting_count)
	var overcrowding_time_left := maxf(0.0, overcrowding_limit - overcrowding_age) if waiting_count >= overcrowding_threshold else overcrowding_limit
	var crowding_alarm := waiting_count >= overcrowding_threshold
	var crowding_urgent := crowding_alarm and (waiting_count >= severe_overcrowding_threshold or overcrowding_time_left <= overcrowding_limit * 0.34)
	return {
		"stop_id": stop_id,
		"stop_name": String(stop.town_name),
		"waiting": waiting_count,
		"rating": rating,
		"crowding_pressure": crowding_pressure,
		"overcrowded": waiting_count >= overcrowding_threshold,
		"severe_overcrowding": waiting_count >= severe_overcrowding_threshold,
		"service_age_s": service_age_s,
		"perceived_wait_min": perceived_wait,
		"amenity_score": amenity_score,
		"lost_riders": lost_riders,
		"demand_multiplier": _stop_demand_multiplier(stop),
		"overcrowding_age_s": overcrowding_age,
		"overcrowding_time_left_s": overcrowding_time_left,
		"overcrowding_limit_s": overcrowding_limit,
		"crowding_alarm": crowding_alarm,
		"crowding_urgent": crowding_urgent
	}

func _target_waiting_count(stop) -> int:
	var demand := float(stop.ridership_demand) * _stop_demand_multiplier(stop)
	var frequency := maxf(1.0, float(stop.frequency))
	var connectivity := float(stop.connectivity)
	var waiting := int(round((demand / frequency) + connectivity * 0.55))
	if demand > 8.0:
		waiting = maxi(waiting, minimum_visuals_for_busy_stop)
	var name := String(stop.town_name)
	if name in ["Park Street", "Boylston", "Arlington", "Copley", "Kenmore", "Brookline"]:
		waiting += 3
	if _is_downtown_stop(name) and _is_peak_commute_hour():
		waiting += 2
	if String(stop.stop_kind) == "park":
		waiting += 2
		if _stop_demand_multiplier(stop) > 1.22:
			waiting += 2
	return clampi(waiting, 0, max_visuals_per_stop * 2)

func _service_rating_for_stop(stop, waiting_count: int, service_age_s: float) -> float:
	var rating := 52.0
	rating += clampf(float(stop.frequency) / 10.0, 0.0, 1.4) * 16.0
	rating += clampf(float(stop.connectivity) / 6.0, 0.0, 1.0) * 12.0
	var pickup_factor := 1.0 - clampf(service_age_s / maxf(service_memory_seconds, 1.0), 0.0, 1.0)
	rating += lerpf(-18.0, 22.0, pickup_factor)
	rating -= _crowding_pressure(waiting_count) * 36.0
	rating -= _waiting_uncertainty(stop, service_age_s) * uncertainty_rating_penalty
	rating -= clampf(_perceived_wait_minutes(stop, waiting_count, service_age_s) / 10.0, 0.0, 1.0) * 15.0 * perceived_wait_weight
	rating += _amenity_score_for_stop(stop) * station_amenity_rating_bonus
	if waiting_count <= minimum_visuals_for_busy_stop + 1:
		rating += 6.0
	if String(stop.stop_kind) == "park" and _stop_demand_multiplier(stop) > 1.25 and waiting_count < severe_overcrowding_threshold:
		rating += 4.0
	return clampf(rating, 5.0, 100.0)

func _crowding_pressure(waiting_count: int) -> float:
	return clampf(
		(float(waiting_count) - float(overcrowding_threshold)) / maxf(1.0, float(severe_overcrowding_threshold - overcrowding_threshold)),
		0.0,
		1.0
	)

func _overcrowding_alarm_limit(waiting_count: int) -> float:
	var severity := _crowding_pressure(waiting_count)
	return lerpf(overcrowding_alarm_seconds, severe_overcrowding_alarm_seconds, severity)

func _overcrowding_age_for_stop(stop_id: String) -> float:
	return float(_overcrowding_age_s.get(stop_id, 0.0))

func _update_overcrowding_timer(stop, waiting_count: int, elapsed_s: float) -> void:
	var stop_id := String(stop.stop_id)
	if waiting_count >= overcrowding_threshold:
		var limit := _overcrowding_alarm_limit(waiting_count)
		var age := minf(limit * 1.25, _overcrowding_age_for_stop(stop_id) + maxf(elapsed_s, 0.0))
		_overcrowding_age_s[stop_id] = age
		return
	var age := maxf(0.0, _overcrowding_age_for_stop(stop_id) - maxf(elapsed_s, 0.0) * overcrowding_recovery_rate)
	if age <= 0.01:
		_overcrowding_age_s.erase(stop_id)
	else:
		_overcrowding_age_s[stop_id] = age

func _is_rescue_candidate(stop_id: String, waiting_count: int) -> bool:
	if waiting_count < overcrowding_threshold:
		return false
	var alarm_limit := _overcrowding_alarm_limit(waiting_count)
	return _overcrowding_age_for_stop(stop_id) >= alarm_limit * 0.25

func _scheduled_headway_minutes(stop) -> float:
	return 60.0 / maxf(1.0, float(stop.frequency))

func _waiting_uncertainty(stop, service_age_s: float) -> float:
	var headway := _scheduled_headway_minutes(stop)
	var elapsed_min := service_age_s / 60.0
	var over_headway := clampf((elapsed_min - headway * 0.55) / maxf(1.0, headway), 0.0, 1.0)
	var low_frequency := 1.0 - clampf(float(stop.frequency) / 8.0, 0.0, 1.0)
	return clampf(over_headway * 0.72 + low_frequency * 0.28, 0.0, 1.0)

func _amenity_score_for_stop(stop) -> float:
	var name := String(stop.town_name)
	var score := 0.0
	match String(stop.stop_kind):
		"station":
			score += 0.48
		"park":
			score += 0.22
		"regular":
			score += 0.08
	if _is_downtown_stop(name):
		score += 0.18
	if float(stop.connectivity) >= 4.0:
		score += 0.18
	if name in ["South Station", "North Station", "Park Street", "Harvard", "Kendall/MIT"]:
		score += 0.18
	return clampf(score, 0.0, 1.0)

func _perceived_wait_minutes(stop, waiting_count: int, service_age_s: float) -> float:
	var actual_wait := minf(service_age_s / 60.0, service_memory_seconds / 30.0)
	var headway_wait := _scheduled_headway_minutes(stop) * 0.52
	var uncertainty := _waiting_uncertainty(stop, service_age_s)
	var crowd_factor := _crowding_pressure(waiting_count) * 0.42
	var weather_factor := 0.0
	var amenity_relief := _amenity_score_for_stop(stop) * 0.30
	var perceived := maxf(actual_wait, headway_wait)
	perceived *= 1.0 + uncertainty * 0.48 + crowd_factor + weather_factor - amenity_relief
	if _is_peak_commute_hour() and _is_downtown_stop(String(stop.town_name)):
		perceived *= 1.12
	return clampf(perceived, 0.3, 18.0)

func _lost_riders_for_stop(stop, waiting_count: int, perceived_wait_min: float, rating: float) -> int:
	var pressure := clampf((perceived_wait_min - 6.5) / 7.5, 0.0, 1.0)
	pressure = maxf(pressure, _crowding_pressure(waiting_count) * 0.72)
	pressure = maxf(pressure, clampf((58.0 - rating) / 42.0, 0.0, 1.0) * 0.65)
	if pressure < lost_rider_pressure_threshold:
		return 0
	var demand := float(stop.ridership_demand) * _stop_demand_multiplier(stop)
	return clampi(int(round(demand * pressure * 0.18)), 0, waiting_count)

func _station_priority_score(snapshot: Dictionary) -> float:
	var waiting := int(snapshot.get("waiting", 0))
	var rating := float(snapshot.get("rating", 75.0))
	var perceived_wait := float(snapshot.get("perceived_wait_min", 0.0))
	var pressure := float(snapshot.get("crowding_pressure", 0.0))
	var lost_riders := int(snapshot.get("lost_riders", 0))
	var waiting_score := clampf(float(waiting) / maxf(1.0, float(severe_overcrowding_threshold)), 0.0, 1.0)
	var wait_score := clampf(perceived_wait / 10.0, 0.0, 1.0)
	var rating_score := clampf((82.0 - rating) / 62.0, 0.0, 1.0)
	var loss_score := clampf(float(lost_riders) / 10.0, 0.0, 1.0)
	var alarm_limit := maxf(1.0, float(snapshot.get("overcrowding_limit_s", overcrowding_alarm_seconds)))
	var alarm_score := clampf(float(snapshot.get("overcrowding_age_s", 0.0)) / alarm_limit, 0.0, 1.0) if bool(snapshot.get("crowding_alarm", false)) else 0.0
	return clampf(pressure * 0.32 + wait_score * 0.22 + rating_score * 0.18 + alarm_score * 0.16 + waiting_score * 0.08 + loss_score * 0.04, 0.0, 1.0)

func _station_status_label(snapshot: Dictionary, priority_score: float) -> String:
	if bool(snapshot.get("crowding_urgent", false)):
		return "Rescue"
	if bool(snapshot.get("severe_overcrowding", false)) or priority_score >= 0.72:
		return "Critical"
	if bool(snapshot.get("overcrowded", false)) or priority_score >= 0.48:
		return "Watch"
	if float(snapshot.get("rating", 75.0)) >= 84.0:
		return "Strong"
	return "Stable"

func _station_recommendation(snapshot: Dictionary) -> String:
	var waiting := int(snapshot.get("waiting", 0))
	var rating := float(snapshot.get("rating", 75.0))
	var perceived_wait := float(snapshot.get("perceived_wait_min", 0.0))
	var service_age_s := float(snapshot.get("service_age_s", 0.0))
	var time_left := float(snapshot.get("overcrowding_time_left_s", 999.0))
	if bool(snapshot.get("crowding_urgent", false)):
		return "Dispatch car now (%.0fs)" % time_left
	if bool(snapshot.get("severe_overcrowding", false)):
		return "Add cars or cut headway"
	if waiting >= overcrowding_threshold:
		return "Shorten headway"
	if perceived_wait >= 7.0:
		return "Reduce wait uncertainty"
	if rating < 64.0:
		return "Improve pickup reliability"
	if service_age_s >= service_memory_seconds * 0.85:
		return "Send a car soon"
	return "Maintain service"

func _stop_demand_multiplier(stop) -> float:
	var multiplier := 1.0
	var month := int(_calendar_payload.get("month", 5))
	var hour := int(_calendar_payload.get("hour", 12))
	var name := String(stop.town_name)
	if _is_downtown_stop(name):
		if hour >= 7 and hour < 10:
			multiplier += downtown_peak_bonus
		elif hour >= 16 and hour < 19:
			multiplier += downtown_peak_bonus * 1.15
	if String(stop.stop_kind) == "park":
		if month >= 5 and month <= 9:
			multiplier += summer_park_bonus
		if hour >= 11 and hour <= 21:
			multiplier += trolley_park_peak_bonus
		if month >= 7 and month <= 8:
			multiplier += 0.08
	elif name in ["South Station", "North Station", "Harvard", "Kendall/MIT"] and hour >= 16 and hour < 19:
		multiplier += 0.08
	return clampf(multiplier, 0.75, 1.85)

func _is_peak_commute_hour() -> bool:
	var hour := int(_calendar_payload.get("hour", 12))
	return (hour >= 7 and hour < 10) or (hour >= 16 and hour < 19)

func _is_downtown_stop(stop_name: String) -> bool:
	return stop_name in [
		"Park Street",
		"Boylston",
		"Arlington",
		"Copley",
		"Scollay Square",
		"Haymarket",
		"North Station",
		"South Station"
	]

func _sync_stop_visuals(stop, waiting_count: int, imported_budget: int = 0) -> void:
	if _crowd_root == null:
		return
	var stop_id := String(stop.stop_id)
	var root := _crowd_nodes.get(stop_id) as Node3D
	if root == null or not is_instance_valid(root):
		root = Node3D.new()
		root.name = "Crowd_%s" % stop_id
		_crowd_root.add_child(root)
		_crowd_nodes[stop_id] = root
	root.position = stop.position
	var target_visuals := clampi(waiting_count, 0, max_visuals_per_stop)
	var remove_count := maxi(0, root.get_child_count() - target_visuals)
	for i in range(remove_count):
		var child := root.get_child(root.get_child_count() - 1)
		root.remove_child(child)
		child.queue_free()
	while root.get_child_count() < target_visuals:
		var passenger = PassengerCrowdActorScript.new()
		var index := root.get_child_count()
		root.add_child(passenger)
		_configure_passenger_visual(passenger, stop_id, index, imported_budget)
	var child_count := root.get_child_count()
	var wait_stress := clampf(_crowding_pressure(waiting_count) * 0.68 + _waiting_uncertainty(stop, float(_last_service_age_s.get(stop_id, 0.0))) * 0.32, 0.0, 1.0)
	for i in range(child_count):
		var passenger := root.get_child(i)
		if passenger == null or not is_instance_valid(passenger):
			continue
		_configure_passenger_visual(passenger, stop_id, i, imported_budget, false, wait_stress)
	root.visible = target_visuals > 0

func _crowd_seed(stop_id: String, index: int) -> int:
	return abs(stop_id.hash() + index * 7919)

func _crowd_offset_for(stop_id: String, index: int) -> Vector3:
	var seed := _crowd_seed(stop_id, index)
	var side := -1.0 if index % 2 == 0 else 1.0
	var row := index / 2
	var lane := row % 3
	var band := row / 3
	var longitudinal := (float(lane) - 1.0) * crowd_row_spacing
	longitudinal += (float(seed % 11) - 5.0) * 0.06
	var lateral := side * (crowd_side_offset + float(band) * 0.92)
	var depth := (float((seed / 13) % 9) - 4.0) * 0.08
	return Vector3(lateral, 0.0, longitudinal + depth)

func _crowd_rotation_for(stop_id: String, index: int) -> float:
	var seed := _crowd_seed(stop_id, index)
	return deg_to_rad(float(seed % 120) - 60.0)

func _configure_passenger_visual(passenger: Node, stop_id: String, index: int, imported_budget: int, force_reconfigure: bool = true, wait_stress: float = 0.0) -> void:
	if passenger == null:
		return
	var use_imported := use_imported_passenger_models and index < imported_budget
	if passenger.has_method("set_prefer_imported_models"):
		passenger.call("set_prefer_imported_models", use_imported)
	else:
		passenger.set("prefer_imported_models", use_imported)
	if force_reconfigure:
		passenger.call("configure", _crowd_seed(stop_id, index), index % 5 == 0)
	if passenger.has_method("set_wait_stress"):
		passenger.call("set_wait_stress", wait_stress)
	passenger.position = _crowd_offset_for(stop_id, index)
	passenger.rotation.y = _crowd_rotation_for(stop_id, index)

func _build_imported_visual_budgets(stops: Array) -> Dictionary:
	if not use_imported_passenger_models:
		return {}
	if max_active_imported_visuals <= 0 or max_imported_visuals_per_stop <= 0:
		return {}
	if _corridor == null or not is_instance_valid(_corridor):
		return {}
	if not _corridor.has_method("get_driver_world_position"):
		return {}
	var driver_position: Vector3 = _driver_world_position()
	var candidates: Array[Dictionary] = []
	for stop in stops:
		if stop == null:
			continue
		var stop_id := String(stop.stop_id)
		var target_visuals := clampi(int(_waiting_counts.get(stop_id, _target_waiting_count(stop))), 0, max_visuals_per_stop)
		if target_visuals <= 0:
			continue
		var stop_position: Vector3 = stop.position
		var distance: float = stop_position.distance_to(driver_position)
		if distance > imported_model_activation_radius_m:
			continue
		candidates.append({
			"stop_id": stop_id,
			"distance": distance,
			"target_visuals": target_visuals
		})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("distance", 0.0)) < float(b.get("distance", 0.0))
	)
	var budget_remaining := max_active_imported_visuals
	var budgets := {}
	for candidate in candidates:
		if budget_remaining <= 0:
			break
		var stop_id := String(candidate.get("stop_id", ""))
		var target_visuals := int(candidate.get("target_visuals", 0))
		var allowed := mini(target_visuals, mini(max_imported_visuals_per_stop, budget_remaining))
		if allowed <= 0:
			continue
		budgets[stop_id] = allowed
		budget_remaining -= allowed
	return budgets

func _driver_world_position() -> Vector3:
	return _corridor.call("get_driver_world_position")

func _prune_missing_crowds(live_stop_ids: Dictionary) -> void:
	for stop_id in _crowd_nodes.keys():
		if live_stop_ids.has(stop_id):
			continue
		var root := _crowd_nodes[stop_id] as Node3D
		if root != null and is_instance_valid(root):
			root.queue_free()
	var next_waiting := {}
	for stop_id in _waiting_counts.keys():
		if live_stop_ids.has(stop_id):
			next_waiting[stop_id] = _waiting_counts[stop_id]
	_waiting_counts = next_waiting
	var next_service_ages := {}
	for stop_id in _last_service_age_s.keys():
		if live_stop_ids.has(stop_id):
			next_service_ages[stop_id] = _last_service_age_s[stop_id]
	_last_service_age_s = next_service_ages
	var next_ratings := {}
	for stop_id in _stop_service_ratings.keys():
		if live_stop_ids.has(stop_id):
			next_ratings[stop_id] = _stop_service_ratings[stop_id]
	_stop_service_ratings = next_ratings
	var next_overcrowding_ages := {}
	for stop_id in _overcrowding_age_s.keys():
		if live_stop_ids.has(stop_id):
			next_overcrowding_ages[stop_id] = _overcrowding_age_s[stop_id]
	_overcrowding_age_s = next_overcrowding_ages
	if not _last_rescue_event.is_empty() and not live_stop_ids.has(String(_last_rescue_event.get("stop_id", ""))):
		_last_rescue_event.clear()
	var next_nodes := {}
	for stop_id in _crowd_nodes.keys():
		if live_stop_ids.has(stop_id):
			next_nodes[stop_id] = _crowd_nodes[stop_id]
	_crowd_nodes = next_nodes
