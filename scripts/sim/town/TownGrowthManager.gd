extends Node3D
class_name TownGrowthManager

const TownScript := preload("res://scripts/sim/town/Town.gd")
const TransitStopScript := preload("res://scripts/sim/town/TransitStop.gd")
const TrackCorridorScript := preload("res://scripts/sim/town/TrackCorridor.gd")
const ParcelGeneratorScript := preload("res://scripts/sim/town/ParcelGenerator.gd")
const StreetGeneratorScript := preload("res://scripts/sim/streets/StreetGenerator.gd")
const WhiteCityParkScene := preload("res://scenes/town/prefabs/WhiteCityPark.tscn")
const NorumbegaParkScene := preload("res://scenes/town/prefabs/NorumbegaPark.tscn")
const BOSTON_CORE_STOPS := [
	"Park Street",
	"Boylston",
	"Arlington",
	"Copley",
	"North Station",
	"Scollay Square",
	"Haymarket"
]
const STREETCAR_SUBURB_STOPS := [
	"Brookline",
	"Chestnut Hill",
	"Newton Centre",
	"Wellesley Center",
	"Natick Center",
	"Framingham Junction",
	"Kenmore",
	"Massachusetts Avenue",
	"Ashmont",
	"Cedar Grove",
	"Butler",
	"Milton",
	"Central Avenue",
	"Valley Road",
	"Capen Street",
	"Mattapan"
]
const WESTERN_CENTERS := [
	"Framingham Junction",
	"Framingham Center",
	"Westborough Center",
	"Grafton Center",
	"Shrewsbury Center",
	"Lincoln Square"
]
const INDUSTRIAL_STOPS := [
	"Framingham Junction",
	"Framingham Center",
	"South Framingham",
	"Westborough Center",
	"Grafton Center",
	"Shrewsbury Center",
	"Lincoln Square",
	"Belmont Street"
]

signal town_created(town)
signal town_updated(town)

@export var building_db: Resource = null
@export var track_builder_path: NodePath
@export var world_root_path: NodePath
@export var tick_seconds := 2.0
@export var max_towns := 150
@export var walk_radius := 600.0
@export var core_radius := 150.0
@export var mid_radius := 400.0
@export var spawn_grid := 24.0
@export var corridor_sample_step := 80.0
@export var corridor_half_width := 40.0
@export var track_clearance_radius := 26.0
@export var street_clearance_radius := 12.0
@export var platform_offset := 18.0
@export var station_cluster_offset := 58.0
@export var station_cluster_spacing := 42.0
@export var max_spawns_per_tick := 40
@export var parcel_jitter := 6.0
@export var min_parcel_spacing := 10.0
@export var align_to_tracks := true
@export var align_to_stop := true
@export var align_to_streets := true
@export var street_frontage_setback_m := 8.0
@export var track_frontage_setback_m := 12.0
@export var occupied_radius := 6.5
@export var max_building_grade_delta_m := 1.25
@export var stop_marker_scene: PackedScene
@export var enable_stop_markers := true
@export var enable_streets := true
@export var street_width := 8.0
@export var street_color := Color(0.32, 0.27, 0.22, 1)
@export var debug_spawn_on_ready := false
@export var debug_stop_positions: Array[Vector3] = []
@export var debug_stop_frequency := 6.0

var towns: Array = []
var stops: Array = []
var corridor = TrackCorridorScript.new()
var _time_accum := 0.0
var _spawn_index := 0
var _occupied: Array[Vector3] = []
var _pending_spawns: Array = []
var _street_gen = StreetGeneratorScript.new()
var _street_root: Node3D
var _terrain_backdrop: Node

@onready var _world_root: Node3D = _resolve_world_root()

func _resolve_world_root() -> Node3D:
	if world_root_path == NodePath(""):
		return get_parent() as Node3D
	return get_node(world_root_path) as Node3D

func _ready() -> void:
	randomize()
	_street_root = Node3D.new()
	_street_root.name = "StreetSegments"
	add_child(_street_root)
	_terrain_backdrop = _resolve_terrain_backdrop()
	if track_builder_path != NodePath(""):
		var builder := get_node(track_builder_path)
		if builder and builder.has_signal("segment_added"):
			builder.segment_added.connect(_on_track_segment_added)
		if builder and builder.has_signal("segment_removed"):
			builder.segment_removed.connect(_on_track_segment_removed)
	if debug_spawn_on_ready:
		if debug_stop_positions.is_empty():
			debug_stop_positions = [Vector3.ZERO, Vector3(2400, 0, 1200)]
		for pos in debug_stop_positions:
			AddTransitStop(pos, debug_stop_frequency)

func _process(delta: float) -> void:
	_time_accum += delta
	if _time_accum >= tick_seconds:
		_time_accum = 0.0
		_simulate_growth_tick()
	_flush_pending_spawns()

func AddTransitStop(position: Vector3, frequency: float, town_name: String = "", stop_kind: String = "regular"):
	var stop = TransitStopScript.new()
	stop.stop_id = "stop_%d" % (stops.size() + 1)
	stop.frequency = frequency
	stop.position = position
	if town_name == "":
		town_name = _make_town_name(position)
	stop.town_name = town_name
	stop.stop_kind = stop_kind
	stops.append(stop)
	if enable_streets:
		_cache_streets_for_stop(stop)
	var town = TownScript.new()
	town.name = stop.town_name
	town.center = position
	town.stop_id = stop.stop_id
	towns.append(town)
	emit_signal("town_created", town)
	call_deferred("_spawn_station_cluster", stop)
	call_deferred("_spawn_stop_marker", stop)
	return stop

func RemoveTransitStop(stop_id: String) -> void:
	for i in range(stops.size() - 1, -1, -1):
		if stops[i].stop_id == stop_id:
			stops.remove_at(i)
	for town in towns:
		if town.stop_id == stop_id:
			town.growth_rate = -0.6
			town.population = int(town.population * 0.8)
			emit_signal("town_updated", town)
	for child in _world_root.get_children():
		if child is Node and String(child.get_meta("stop_id", "")) == stop_id:
			child.queue_free()

func GetTownGrowthRate(town) -> float:
	return town.growth_rate

func GetRidershipDemand(stop) -> float:
	return stop.ridership_demand

func SpawnStreetcarSuburb(stop) -> void:
	_spawn_growth_ring(stop, true)

func SpawnSuburbsForAllStops() -> void:
	for stop in stops:
		_spawn_growth_ring(stop, true)

func SetEra(_era: String) -> void:
	# Placeholder for era-based asset swaps.
	pass

func _simulate_growth_tick() -> void:
	if stops.is_empty():
		return
	_update_connectivity()
	var spawns := 0
	for stop in stops:
		var town = _town_for_stop(stop.stop_id)
		if town == null:
			continue
		var score: float = float(stop.transit_score())
		town.growth_rate = _score_to_growth(score)
		stop.ridership_demand = max(0.0, score) * 12.0
		if town.growth_rate > 0.05:
			spawns += _spawn_growth_ring(stop, false)
		elif town.growth_rate < -0.1:
			_spread_decay(stop)
		emit_signal("town_updated", town)
		if spawns >= max_spawns_per_tick:
			break
	_spawn_corridor_growth()

func _update_connectivity() -> void:
	for stop in stops:
		var nearby := 0
		for other in stops:
			if stop == other:
				continue
			if stop.position.distance_to(other.position) < 8000.0:
				nearby += 1
		stop.connectivity = max(1.0, float(nearby))
		stop.travel_time = clampf(6.0 - float(nearby) * 0.4, 2.5, 12.0)

func _score_to_growth(score: float) -> float:
	if score <= 0.0:
		return -0.3
	return clampf(score / 20.0, 0.05, 0.9)

func _spawn_station_cluster(stop) -> void:
	var shelter_pos := _stop_side_anchor(stop, 1.0, platform_offset, 8.0)
	_queue_spawn(shelter_pos, "transit", stop.position)
	if stop.town_name == "Park Street":
		_queue_spawn(_stop_side_anchor(stop, -1.0, 96.0, 36.0), "civic", stop.position)
	elif stop.town_name == "White City":
		_queue_spawn(_stop_side_anchor(stop, 1.0, 92.0, -54.0), "park_white_city", stop.position)
	elif stop.town_name == "Norumbega Park":
		_queue_spawn(_stop_side_anchor(stop, 1.0, 88.0, 24.0), "park_norumbega", stop.position)
	var cluster_offsets := [
		Vector2(-1.0, -station_cluster_spacing),
		Vector2(-1.0, 0.0),
		Vector2(-1.0, station_cluster_spacing),
		Vector2(1.0, -station_cluster_spacing),
		Vector2(1.0, 0.0),
		Vector2(1.0, station_cluster_spacing)
	]
	var categories := _station_cluster_categories(stop)
	for i in range(cluster_offsets.size()):
		var entry: Vector2 = cluster_offsets[i]
		var category := String(categories[i % categories.size()])
		_queue_spawn(_stop_side_anchor(stop, entry.x, station_cluster_offset, entry.y), category, stop.position)
	_queue_regional_landmarks(stop)

func _spawn_growth_ring(stop, force: bool) -> int:
	var spawned := 0
	var center: Vector3 = stop.position
	var parcels = ParcelGeneratorScript.generate_ring(center, walk_radius, spawn_grid, parcel_jitter)
	for pos in parcels:
		if spawned >= max_spawns_per_tick:
			return spawned
		var dist := pos.distance_to(center)
		if dist > walk_radius:
			continue
		if not force and randi() % 5 != 0:
			continue
		var zone := _zone_for_stop_distance(stop, dist)
		if not _can_spawn_at(pos, zone):
			continue
		_queue_spawn(pos, zone, center)
		spawned += 1
	return spawned

func _zone_for_distance(dist: float) -> String:
	if dist <= core_radius:
		return "commercial_high"
	if dist <= mid_radius:
		return "residential_medium"
	if dist <= walk_radius:
		return "residential_low"
	return "farms"

func _spawn_corridor_growth() -> void:
	if corridor.segments.is_empty():
		return
	var points: PackedVector3Array = corridor.corridor_points(corridor_sample_step)
	var parcels = ParcelGeneratorScript.generate_corridor(points, spawn_grid, corridor_half_width)
	for pos in parcels:
		if randi() % 3 != 0:
			continue
		if not _can_spawn_at(pos, "commercial_low"):
			continue
		_queue_spawn(pos, "commercial_low", pos)

func _spread_decay(stop) -> void:
	# Simple visual decay marker: remove random children near stop.
	var to_remove := []
	for child in _world_root.get_children():
		if child is Node3D and child.global_position.distance_to(stop.position) < core_radius:
			if randi() % 6 == 0:
				to_remove.append(child)
	for node in to_remove:
		node.queue_free()

func _queue_spawn(pos: Vector3, category: String, anchor: Vector3 = Vector3.ZERO) -> void:
	if not _can_spawn_at(pos, category):
		return
	_register_occupied(pos)
	_pending_spawns.append({
		"pos": pos,
		"category": category,
		"anchor": anchor
	})

func _flush_pending_spawns() -> void:
	if _pending_spawns.is_empty():
		return
	var budget := max_spawns_per_tick
	var count := 0
	while not _pending_spawns.is_empty() and count < budget:
		var entry: Dictionary = _pending_spawns.pop_front()
		_spawn_building_now(entry["pos"], entry["category"], entry["anchor"])
		count += 1

func _spawn_building_now(pos: Vector3, category: String, anchor: Vector3 = Vector3.ZERO) -> void:
	var scene := _scene_for_category(category)
	var instance: Node3D
	if scene:
		instance = scene.instantiate()
	else:
		instance = _placeholder_building(category)
	var placed_pos := _resolve_building_placement(pos, category, anchor)
	_world_root.add_child(instance)
	instance.global_position = placed_pos
	_place_instance_on_ground(instance)
	if instance is Node3D:
		instance.rotation.y = _rotation_for(placed_pos, anchor)
	_register_occupied(placed_pos)

func _scene_for_category(category: String) -> PackedScene:
	if building_db == null:
		return null
	if not building_db.has_method("pick"):
		return null
	match category:
		"park_white_city":
			return WhiteCityParkScene
		"park_norumbega":
			return NorumbegaParkScene
		"residential_low":
			return building_db.call("pick", building_db.get("residential_low"))
		"residential_medium":
			return building_db.call("pick", building_db.get("residential_medium"))
		"residential_high":
			return building_db.call("pick", building_db.get("residential_high"))
		"commercial_low":
			return building_db.call("pick", building_db.get("commercial_low"))
		"commercial_high":
			return building_db.call("pick", building_db.get("commercial_high"))
		"industrial":
			return building_db.call("pick", building_db.get("industrial"))
		"civic":
			return building_db.call("pick", building_db.get("civic"))
		"transit":
			return building_db.call("pick", building_db.get("transit"))
		"farms":
			return building_db.call("pick", building_db.get("farms"))
	return null

func _placeholder_building(category: String) -> Node3D:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(12.0, 8.0, 12.0)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = _color_for_category(category)
	mesh_instance.set_surface_override_material(0, mat)
	return mesh_instance

func _color_for_category(category: String) -> Color:
	match category:
		"commercial_high":
			return Color("b48a5a")
		"commercial_low":
			return Color("c9a26b")
		"residential_medium":
			return Color("8c9e86")
		"residential_low":
			return Color("7b8b74")
		"farms":
			return Color("9c8b6b")
		"industrial":
			return Color("7b6a6a")
		"civic":
			return Color("9c7458")
		"park_white_city":
			return Color("d8c79b")
		"park_norumbega":
			return Color("bba476")
		"transit":
			return Color("d0b78a")
	return Color("8c8c8c")

func _place_instance_on_ground(instance: Node3D) -> void:
	var min_y := _min_global_mesh_y(instance)
	if is_finite(min_y):
		instance.global_position.y -= min_y

func _min_global_mesh_y(node: Node3D) -> float:
	var best := INF
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh != null:
			var aabb := mesh_instance.mesh.get_aabb()
			for corner in _aabb_corners(aabb):
				best = min(best, (mesh_instance.global_transform * corner).y)
	for child in node.get_children():
		if child is Node3D:
			best = min(best, _min_global_mesh_y(child as Node3D))
	return best

func _aabb_corners(aabb: AABB) -> PackedVector3Array:
	var corners := PackedVector3Array()
	var p := aabb.position
	var s := aabb.size
	corners.append(p)
	corners.append(p + Vector3(s.x, 0.0, 0.0))
	corners.append(p + Vector3(0.0, s.y, 0.0))
	corners.append(p + Vector3(0.0, 0.0, s.z))
	corners.append(p + Vector3(s.x, s.y, 0.0))
	corners.append(p + Vector3(s.x, 0.0, s.z))
	corners.append(p + Vector3(0.0, s.y, s.z))
	corners.append(p + s)
	return corners

func _town_for_stop(stop_id: String):
	for town in towns:
		if town.stop_id == stop_id:
			return town
	return null

func _make_town_name(_position: Vector3) -> String:
	var prefixes = ["Oak", "River", "Pine", "Cedar", "Maple", "Elm", "North", "East", "West", "South"]
	var suffixes = ["Grove", "Heights", "dale", "field", "port", "hill", "cross", "center", "park", "village"]
	return "%s %s" % [prefixes[randi() % prefixes.size()], suffixes[randi() % suffixes.size()]]

func _on_track_segment_added(curve: Curve3D) -> void:
	corridor.segments.append(curve)

func _on_track_segment_removed(curve: Curve3D) -> void:
	for i in range(corridor.segments.size() - 1, -1, -1):
		if corridor.segments[i] == curve:
			corridor.segments.remove_at(i)
			break

func _cache_streets_for_stop(stop) -> void:
	var forward := _nearest_corridor_direction(stop.position)
	var segments := _street_gen.generate_for_stop(stop.position, forward, stop.town_name)
	_spawn_street_segments(segments)

func _nearest_street_direction(pos: Vector3) -> Vector3:
	return _street_gen.nearest_street_direction(pos)

func _spawn_stop_marker(stop) -> void:
	if not enable_stop_markers:
		return
	var scene := stop_marker_scene
	if scene == null and ResourceLoader.exists("res://scenes/town/props/StopMarker.tscn"):
		scene = load("res://scenes/town/props/StopMarker.tscn")
	if scene == null:
		return
	var marker := scene.instantiate()
	if marker is Node3D:
		_world_root.add_child(marker)
		marker.global_position = _stop_side_anchor(stop, -1.0, platform_offset + 5.0, -8.0)
		marker.set("town_name", stop.town_name)
		marker.set("stop_kind", stop.stop_kind)
		marker.set_meta("stop_id", stop.stop_id)

func _spawn_street_segments(segments: PackedVector3Array) -> void:
	if not enable_streets:
		return
	if segments.size() < 2:
		return
	for i in range(0, segments.size(), 2):
		_spawn_street_segment(segments[i], segments[i + 1])

func _spawn_street_segment(a: Vector3, b: Vector3) -> void:
	a = _with_ground_height(a, 0.04)
	b = _with_ground_height(b, 0.04)
	var length := a.distance_to(b)
	if length < 1.0:
		return
	var mesh := BoxMesh.new()
	mesh.size = Vector3(street_width, 0.4, length)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = street_color
	mesh_instance.set_surface_override_material(0, mat)
	_street_root.add_child(mesh_instance)
	mesh_instance.global_position = (a + b) * 0.5
	mesh_instance.look_at(mesh_instance.global_position + (b - a).normalized(), Vector3.UP)
	mesh_instance.rotate_y(PI)

func _register_occupied(pos: Vector3) -> void:
	_occupied.append(pos)

func _is_occupied(pos: Vector3) -> bool:
	for p in _occupied:
		if p.distance_to(pos) < occupied_radius:
			return true
	return false

func _can_spawn_at(pos: Vector3, category: String = "") -> bool:
	if _is_occupied(pos):
		return false
	if _is_water(pos):
		return false
	if _ground_grade_delta(pos) > _max_grade_delta_for(category):
		return false
	if _distance_to_corridor(pos) < _track_clearance_for(category):
		return false
	if _distance_to_street(pos) < _street_clearance_for(category):
		return false
	return true

func _max_grade_delta_for(category: String) -> float:
	match category:
		"farms":
			return max_building_grade_delta_m * 2.0
		"residential_low":
			return max_building_grade_delta_m * 1.35
		"residential_medium", "residential_high":
			return max_building_grade_delta_m * 1.1
		"commercial_low":
			return max_building_grade_delta_m * 0.95
		"commercial_high", "industrial", "civic", "transit":
			return max_building_grade_delta_m * 0.8
		_:
			return max_building_grade_delta_m

func _track_clearance_for(category: String) -> float:
	match category:
		"transit":
			return maxf(8.0, platform_offset - 5.0)
		"park_white_city", "park_norumbega":
			return 18.0
		"farms":
			return track_clearance_radius * 0.7
		_:
			return track_clearance_radius

func _building_setback_for(category: String) -> float:
	match category:
		"commercial_high":
			return street_frontage_setback_m * 0.65
		"commercial_low", "civic", "transit":
			return street_frontage_setback_m * 0.85
		"industrial":
			return maxf(track_frontage_setback_m, street_frontage_setback_m * 1.25)
		"residential_high":
			return street_frontage_setback_m * 1.0
		"residential_medium":
			return street_frontage_setback_m * 1.2
		"residential_low", "farms":
			return street_frontage_setback_m * 1.55
		_:
			return street_frontage_setback_m

func _resolve_building_placement(pos: Vector3, category: String, anchor: Vector3) -> Vector3:
	var frontage := Vector3.ZERO
	if align_to_streets:
		frontage = _nearest_street_direction(pos)
	if frontage.length() <= 0.01 and align_to_tracks:
		frontage = _nearest_corridor_direction(pos)
	if frontage.length() <= 0.01 and align_to_stop and anchor != Vector3.ZERO:
		frontage = (anchor - pos).normalized()
	if frontage.length() <= 0.01:
		return _with_ground_height(pos)
	var side := Vector3(-frontage.z, 0.0, frontage.x).normalized()
	var bias_seed := int(absf(pos.x * 0.11 + pos.z * 0.07))
	var side_sign := -1.0 if bias_seed % 2 == 0 else 1.0
	var setback := _building_setback_for(category)
	var candidate := pos + side * setback * side_sign
	if _is_water(candidate):
		return _with_ground_height(pos)
	if _ground_grade_delta(candidate) > _max_grade_delta_for(category):
		return _with_ground_height(pos)
	if _distance_to_corridor(candidate) < maxf(4.0, _track_clearance_for(category) * 0.82):
		return _with_ground_height(pos)
	if _distance_to_street(candidate) < maxf(4.0, _street_clearance_for(category) * 0.45):
		return _with_ground_height(pos)
	return _with_ground_height(candidate)

func _zone_for_stop_distance(stop, dist: float) -> String:
	var name := String(stop.town_name)
	if name in BOSTON_CORE_STOPS:
		if dist <= core_radius * 0.9:
			return _pick_weighted_category(["commercial_high", "commercial_high", "civic", "residential_high"])
		if dist <= mid_radius:
			return _pick_weighted_category(["residential_high", "residential_medium", "commercial_low"])
		return _pick_weighted_category(["residential_medium", "residential_low"])
	if name in STREETCAR_SUBURB_STOPS:
		if dist <= core_radius:
			return _pick_weighted_category(["commercial_low", "civic", "residential_medium"])
		if dist <= mid_radius:
			return _pick_weighted_category(["residential_medium", "residential_high", "residential_low"])
		return _pick_weighted_category(["residential_low", "farms"])
	if name in WESTERN_CENTERS:
		if dist <= core_radius:
			return _pick_weighted_category(["commercial_high", "commercial_low", "civic"])
		if dist <= mid_radius:
			return _pick_weighted_category(["industrial", "residential_medium", "commercial_low"])
		return _pick_weighted_category(["residential_low", "farms"])
	if dist <= core_radius and name in INDUSTRIAL_STOPS:
		return _pick_weighted_category(["industrial", "commercial_low", "commercial_high"])
	return _zone_for_distance(dist)

func _station_cluster_categories(stop) -> Array[String]:
	var name := String(stop.town_name)
	if name in BOSTON_CORE_STOPS:
		return ["commercial_high", "commercial_high", "civic", "commercial_high", "residential_high", "commercial_high"]
	if name in STREETCAR_SUBURB_STOPS:
		return ["commercial_low", "civic", "commercial_low", "residential_medium", "residential_high", "commercial_low"]
	if name in WESTERN_CENTERS:
		return ["commercial_high", "civic", "industrial", "commercial_low", "residential_medium", "commercial_low"]
	return ["commercial_high", "commercial_low", "civic", "commercial_low", "residential_medium", "commercial_high"]

func _queue_regional_landmarks(stop) -> void:
	var name := String(stop.town_name)
	if name in ["Framingham Center", "Lincoln Square"]:
		_queue_spawn(_stop_side_anchor(stop, -1.0, 118.0, 68.0), "civic", stop.position)
		_queue_spawn(_stop_side_anchor(stop, 1.0, 132.0, -84.0), "industrial", stop.position)
	elif name in ["Westborough Center", "Grafton Center", "Wellesley Center"]:
		_queue_spawn(_stop_side_anchor(stop, -1.0, 108.0, 52.0), "civic", stop.position)
	elif name in BOSTON_CORE_STOPS:
		_queue_spawn(_stop_side_anchor(stop, -1.0, 112.0, -64.0), "commercial_high", stop.position)

func _pick_weighted_category(options: Array[String]) -> String:
	if options.is_empty():
		return "residential_low"
	return String(options[randi() % options.size()])

func _street_clearance_for(category: String) -> float:
	match category:
		"transit":
			return 5.0
		"park_white_city", "park_norumbega":
			return 6.0
		_:
			return street_clearance_radius

func _distance_to_corridor(pos: Vector3) -> float:
	if corridor.segments.is_empty():
		return INF
	var best_dist := INF
	for curve in corridor.segments:
		var length: float = float(curve.get_baked_length())
		if length <= 0.1:
			continue
		var closest: Vector3 = curve.get_closest_point(pos)
		best_dist = min(best_dist, pos.distance_to(closest))
	return best_dist

func _distance_to_street(pos: Vector3) -> float:
	if _street_gen.street_points.size() < 2:
		return INF
	var best_dist := INF
	for i in range(0, _street_gen.street_points.size(), 2):
		var a: Vector3 = _street_gen.street_points[i]
		var b: Vector3 = _street_gen.street_points[i + 1]
		var closest := _closest_point_on_segment(pos, a, b)
		best_dist = min(best_dist, pos.distance_to(closest))
	return best_dist

func _stop_side_anchor(stop, side_sign: float, lateral: float, longitudinal: float = 0.0) -> Vector3:
	var forward := _nearest_corridor_direction(stop.position)
	if forward.length() < 0.01:
		forward = _nearest_street_direction(stop.position)
	if forward.length() < 0.01:
		forward = Vector3.FORWARD
	var side := Vector3(-forward.z, 0.0, forward.x).normalized()
	return _with_ground_height(stop.position + side * lateral * signf(side_sign) + forward * longitudinal, 0.02)

func _rotation_for(pos: Vector3, anchor: Vector3) -> float:
	var base := deg_to_rad(90 * (randi() % 4))
	if align_to_streets:
		var dir := _nearest_street_direction(pos)
		if dir.length() > 0.01:
			return atan2(dir.x, dir.z)
	if align_to_tracks and not corridor.segments.is_empty():
		var dir := _nearest_corridor_direction(pos)
		if dir.length() > 0.01:
			return atan2(dir.x, dir.z)
	if align_to_stop and anchor != Vector3.ZERO:
		var to_center := (anchor - pos)
		if to_center.length() > 0.01:
			return atan2(to_center.x, to_center.z)
	return base

func _nearest_corridor_direction(pos: Vector3) -> Vector3:
	var best_dir := Vector3.ZERO
	var best_dist := INF
	for curve in corridor.segments:
		var length: float = float(curve.get_baked_length())
		if length <= 0.1:
			continue
		var closest: Vector3 = curve.get_closest_point(pos)
		var d := pos.distance_to(closest)
		if d < best_dist:
			best_dist = d
			var offset: float = float(curve.get_closest_offset(pos))
			var ahead: Vector3 = curve.sample_baked(clampf(offset + 6.0, 0.0, length))
			best_dir = (ahead - closest).normalized()
	return best_dir

func _closest_point_on_segment(p: Vector3, a: Vector3, b: Vector3) -> Vector3:
	var ab: Vector3 = b - a
	var denom: float = maxf(0.0001, ab.dot(ab))
	var t: float = clampf((p - a).dot(ab) / denom, 0.0, 1.0)
	return a + ab * t

func _resolve_terrain_backdrop() -> Node:
	if _world_root == null:
		return null
	if _world_root.has_node("Terrain/Route9Backdrop"):
		return _world_root.get_node("Terrain/Route9Backdrop")
	if _world_root.has_node("Route9Backdrop"):
		return _world_root.get_node("Route9Backdrop")
	return null

func _ground_height_at(pos: Vector3) -> float:
	if _terrain_backdrop == null or not is_instance_valid(_terrain_backdrop):
		return 0.0
	if not _terrain_backdrop.has_method("ground_height_at"):
		return 0.0
	return float(_terrain_backdrop.call("ground_height_at", pos))

func _ground_grade_delta(pos: Vector3) -> float:
	var sample := 7.5
	var center := _ground_height_at(pos)
	var dx := absf(_ground_height_at(pos + Vector3(sample, 0.0, 0.0)) - center)
	var dz := absf(_ground_height_at(pos + Vector3(0.0, 0.0, sample)) - center)
	return maxf(dx, dz)

func _is_water(pos: Vector3) -> bool:
	if _terrain_backdrop == null or not is_instance_valid(_terrain_backdrop):
		return false
	if not _terrain_backdrop.has_method("is_water_at"):
		return false
	return bool(_terrain_backdrop.call("is_water_at", pos))

func _with_ground_height(pos: Vector3, offset: float = 0.0) -> Vector3:
	var grounded := pos
	grounded.y = _ground_height_at(pos) + offset
	return grounded
