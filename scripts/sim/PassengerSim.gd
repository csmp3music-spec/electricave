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

var agents: Array[PassengerAgent] = []
var _town_manager: Node
var _corridor: Node
var _crowd_root: Node3D
var _crowd_nodes := {}
var _waiting_counts := {}
var _refresh_accum := 0.0

func _ready() -> void:
	_resolve_dependencies()
	_ensure_crowd_root()
	call_deferred("_refresh_station_crowds")

func seed_population(count: int) -> void:
	agents.clear()
	for i in range(count):
		var agent := PassengerAgent.new()
		agents.append(agent)

func _process(delta: float) -> void:
	_refresh_accum += delta
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

func service_stop_by_name(stop_name: String, capacity_hint: int = 12) -> Dictionary:
	var stop = _find_stop_by_name(stop_name)
	if stop == null:
		return {}
	var stop_id := String(stop.stop_id)
	var current_waiting := get_waiting_count_for_stop(stop_name)
	var boarded := 0
	if capacity_hint > 0:
		boarded = mini(current_waiting, capacity_hint)
	_waiting_counts[stop_id] = maxi(0, current_waiting - boarded)
	_sync_stop_visuals(stop, int(_waiting_counts[stop_id]))
	return {
		"boarded": boarded,
		"waiting": int(_waiting_counts[stop_id])
	}

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
		var target := _target_waiting_count(stop)
		var current := int(_waiting_counts.get(stop_id, target))
		if current < target:
			current = mini(target, current + crowd_regen_per_tick)
		elif current > target + 2:
			current = maxi(target, current - 1)
		_waiting_counts[stop_id] = current
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

func _target_waiting_count(stop) -> int:
	var demand := float(stop.ridership_demand)
	var frequency := maxf(1.0, float(stop.frequency))
	var connectivity := float(stop.connectivity)
	var waiting := int(round((demand / frequency) + connectivity * 0.55))
	if demand > 8.0:
		waiting = maxi(waiting, minimum_visuals_for_busy_stop)
	var name := String(stop.town_name)
	if name in ["Park Street", "Boylston", "Arlington", "Copley", "Kenmore", "Brookline"]:
		waiting += 3
	if String(stop.stop_kind) == "park":
		waiting += 2
	return clampi(waiting, 0, max_visuals_per_stop * 2)

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
	for i in range(child_count):
		var passenger := root.get_child(i)
		if passenger == null or not is_instance_valid(passenger):
			continue
		_configure_passenger_visual(passenger, stop_id, i, imported_budget, false)
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

func _configure_passenger_visual(passenger: Node, stop_id: String, index: int, imported_budget: int, force_reconfigure: bool = true) -> void:
	if passenger == null:
		return
	var use_imported := use_imported_passenger_models and index < imported_budget
	if passenger.has_method("set_prefer_imported_models"):
		passenger.call("set_prefer_imported_models", use_imported)
	else:
		passenger.set("prefer_imported_models", use_imported)
	if force_reconfigure:
		passenger.call("configure", _crowd_seed(stop_id, index), index % 5 == 0)
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
	var next_nodes := {}
	for stop_id in _crowd_nodes.keys():
		if live_stop_ids.has(stop_id):
			next_nodes[stop_id] = _crowd_nodes[stop_id]
	_crowd_nodes = next_nodes
