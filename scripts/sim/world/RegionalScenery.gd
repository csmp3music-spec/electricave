extends Node3D
class_name RegionalScenery

const PineTrunkDiffusePath := "res://assets/textures/tree_materials/pine_tree_01/pine_tree_01_trunk_a_diff_4k.jpg"
const PineTrunkNormalPath := "res://assets/textures/tree_materials/pine_tree_01/pine_tree_01_trunk_a_nor_gl_4k.jpg"
const PineTrunkRoughnessPath := "res://assets/textures/tree_materials/pine_tree_01/pine_tree_01_trunk_a_rough_4k.jpg"
const PineTwigDiffusePath := "res://assets/textures/tree_materials/pine_tree_01/pine_tree_01_twig_diff_4k.jpg"
const PineTwigAlphaPath := "res://assets/textures/tree_materials/pine_tree_01/pine_tree_01_twig_alpha_4k.jpg"
const PineTwigNormalPath := "res://assets/textures/tree_materials/pine_tree_01/pine_tree_01_twig_nor_gl_4k.jpg"
const PineTwigRoughnessPath := "res://assets/textures/tree_materials/pine_tree_01/pine_tree_01_twig_rough_4k.jpg"

@export var route9_backdrop_path: NodePath
@export var town_manager_path: NodePath
@export var corridor_path: NodePath
@export var weather_path: NodePath
@export var tree_clearance_to_stop_m := 125.0
@export var tree_clearance_to_route_m := 26.0
@export var min_tree_spacing_m := 13.0
@export var hill_tree_density := 0.012
@export var shoreline_tree_density := 0.007
@export var stop_tree_count := 16
@export var max_tree_instances := 1600
@export var mixed_forest_ratio := 0.34
@export var shoreline_broadleaf_bonus := 0.28
@export var max_ground_detail_instances := 2800
@export var grass_detail_density := 0.016
@export var reed_detail_density := 0.010
@export var rock_detail_density := 0.006
@export var stubble_detail_density := 0.012
@export var scrub_detail_density := 0.007
@export var ground_detail_clearance_to_route_m := 8.0
@export var ground_detail_clearance_to_stop_m := 30.0
@export var max_scrub_instances := 900

var _route9_backdrop: Node
var _town_manager: Node
var _corridor: Node
var _weather: Node
var _weather_payload := {}
var _rebuild_queued := false
var _trunk_material_cache: StandardMaterial3D
var _foliage_material_cache: StandardMaterial3D
var _broadleaf_foliage_material_cache: StandardMaterial3D
var _grass_detail_material_cache: StandardMaterial3D
var _reed_detail_material_cache: StandardMaterial3D
var _rock_detail_material_cache: StandardMaterial3D
var _stubble_detail_material_cache: StandardMaterial3D
var _scrub_detail_material_cache: StandardMaterial3D
var _foliage_mesh_cache: Mesh
var _broadleaf_foliage_mesh_cache: Mesh
var _grass_detail_mesh_cache: Mesh
var _stubble_detail_mesh_cache: Mesh
var _scrub_detail_mesh_cache: Mesh

func _ready() -> void:
	_resolve_dependencies()
	if _town_manager != null and _town_manager.has_signal("town_created"):
		_town_manager.town_created.connect(_queue_rebuild)
	if _weather != null and _weather.has_signal("weather_changed"):
		_weather.weather_changed.connect(_on_weather_changed)
	if _weather != null and _weather.has_method("get_weather_payload"):
		_weather_payload = _weather.call("get_weather_payload")
	call_deferred("_rebuild_scenery")

func _queue_rebuild(_arg = null) -> void:
	if _rebuild_queued:
		return
	_rebuild_queued = true
	call_deferred("_rebuild_scenery")

func _resolve_dependencies() -> void:
	if route9_backdrop_path != NodePath(""):
		_route9_backdrop = get_node_or_null(route9_backdrop_path)
	if _route9_backdrop == null:
		_route9_backdrop = get_parent().get_node_or_null("Route9Backdrop")
	var world_root := get_parent().get_parent() if get_parent() != null else null
	if town_manager_path != NodePath(""):
		_town_manager = get_node_or_null(town_manager_path)
	if _town_manager == null and world_root != null:
		_town_manager = world_root.get_node_or_null("TownGrowthManager")
	if corridor_path != NodePath(""):
		_corridor = get_node_or_null(corridor_path)
	if _corridor == null and world_root != null:
		_corridor = world_root.get_node_or_null("CorridorSeed")
	if weather_path != NodePath(""):
		_weather = get_node_or_null(weather_path)
	if _weather == null and world_root != null:
		_weather = world_root.get_node_or_null("Weather")

func _rebuild_scenery() -> void:
	_rebuild_queued = false
	_resolve_dependencies()
	for child in get_children():
		remove_child(child)
		child.queue_free()
	if _route9_backdrop == null or not is_instance_valid(_route9_backdrop):
		return
	var accepted_positions := PackedVector3Array()
	var route_points := _route_points()
	var stop_positions := _stop_positions()
	var hill_markers: Array = _route9_backdrop.call("get_hill_markers") if _route9_backdrop.has_method("get_hill_markers") else []
	for hill_variant in hill_markers:
		_scatter_hill_trees(hill_variant, accepted_positions, route_points, stop_positions)
	var water_markers: Array = _route9_backdrop.call("get_water_markers") if _route9_backdrop.has_method("get_water_markers") else []
	for water_variant in water_markers:
		_scatter_shoreline_trees(water_variant, accepted_positions, route_points, stop_positions)
	for stop_pos in stop_positions:
		_scatter_stop_trees(stop_pos, accepted_positions, route_points, stop_positions)
	_build_tree_multimeshes(accepted_positions)
	_build_ground_detail_multimeshes(route_points, stop_positions)
	_apply_weather_to_materials()

func _on_weather_changed(payload: Dictionary) -> void:
	_weather_payload = payload.duplicate(true)
	_apply_weather_to_materials()

func _route_points() -> PackedVector3Array:
	if _corridor == null or not is_instance_valid(_corridor):
		return PackedVector3Array()
	if not _corridor.has_method("get_system_route_points"):
		return PackedVector3Array()
	return _corridor.call("get_system_route_points")

func _stop_positions() -> PackedVector3Array:
	var positions := PackedVector3Array()
	if _town_manager == null or not is_instance_valid(_town_manager):
		return positions
	var stops: Array = _town_manager.get("stops")
	for stop in stops:
		if stop == null:
			continue
		positions.append(stop.position)
	return positions

func _scatter_hill_trees(hill_variant: Dictionary, accepted_positions: PackedVector3Array, route_points: PackedVector3Array, stop_positions: PackedVector3Array) -> void:
	var hill_pos := _hill_or_water_center(hill_variant)
	var radius_m := maxf(300.0, float(hill_variant.get("radius_m", 1200.0)))
	var count := clampi(int(radius_m * hill_tree_density), 20, 180)
	var rng := RandomNumberGenerator.new()
	rng.seed = abs(String(hill_variant.get("name", "hill")).hash())
	for i in range(count):
		if accepted_positions.size() >= max_tree_instances:
			return
		var angle := rng.randf_range(0.0, TAU)
		var radial := radius_m * sqrt(rng.randf_range(0.10, 0.96))
		var pos := hill_pos + Vector3(cos(angle) * radial, 0.0, sin(angle) * radial)
		if not _can_place_tree(pos, accepted_positions, route_points, stop_positions):
			continue
		accepted_positions.append(_grounded(pos))

func _scatter_shoreline_trees(water_variant: Dictionary, accepted_positions: PackedVector3Array, route_points: PackedVector3Array, stop_positions: PackedVector3Array) -> void:
	var shape := String(water_variant.get("shape", "ellipse"))
	if shape == "river":
		_scatter_riverbank_trees(water_variant, accepted_positions, route_points, stop_positions)
		return
	if shape == "polygon":
		_scatter_polygon_shoreline_trees(water_variant, accepted_positions, route_points, stop_positions)
		return
	var center := _hill_or_water_center(water_variant)
	var rx := maxf(150.0, float(water_variant.get("radius_x_m", 400.0)))
	var rz := maxf(150.0, float(water_variant.get("radius_z_m", 400.0)))
	var angle_offset := deg_to_rad(float(water_variant.get("rotation_deg", 0.0)))
	var count := clampi(int((rx + rz) * shoreline_tree_density), 12, 140)
	var rng := RandomNumberGenerator.new()
	rng.seed = abs(String(water_variant.get("name", "water")).hash()) + 431
	for i in range(count):
		if accepted_positions.size() >= max_tree_instances:
			return
		var angle := rng.randf_range(0.0, TAU)
		var ring := rng.randf_range(1.04, 1.28)
		var local := Vector2(cos(angle) * rx * ring, sin(angle) * rz * ring).rotated(angle_offset)
		var pos := center + Vector3(local.x, 0.0, local.y)
		if not _can_place_tree(pos, accepted_positions, route_points, stop_positions):
			continue
		accepted_positions.append(_grounded(pos))

func _scatter_polygon_shoreline_trees(water_variant: Dictionary, accepted_positions: PackedVector3Array, route_points: PackedVector3Array, stop_positions: PackedVector3Array) -> void:
	var polygon: PackedVector2Array = water_variant.get("world_polygon_xz", PackedVector2Array())
	if polygon.size() < 3:
		return
	var perimeter := 0.0
	for i in range(polygon.size()):
		perimeter += polygon[i].distance_to(polygon[(i + 1) % polygon.size()])
	var count := clampi(int(perimeter * shoreline_tree_density * 0.16), 14, 160)
	var rng := RandomNumberGenerator.new()
	rng.seed = abs(String(water_variant.get("name", "polygon_water")).hash()) + 991
	var placed := 0
	var attempts := 0
	while placed < count and attempts < count * 12:
		attempts += 1
		var seg_index := rng.randi_range(0, polygon.size() - 1)
		var a := polygon[seg_index]
		var b := polygon[(seg_index + 1) % polygon.size()]
		var edge_point := a.lerp(b, rng.randf())
		var tangent := (b - a).normalized()
		if tangent.length() <= 0.001:
			continue
		var normal := Vector2(-tangent.y, tangent.x)
		var side := -1.0 if rng.randf() < 0.5 else 1.0
		var offset := rng.randf_range(28.0, 130.0)
		var pos := Vector3(edge_point.x + normal.x * offset * side, 0.0, edge_point.y + normal.y * offset * side)
		if _route9_backdrop.has_method("is_water_at") and bool(_route9_backdrop.call("is_water_at", pos)):
			continue
		if not _can_place_tree(pos, accepted_positions, route_points, stop_positions):
			continue
		accepted_positions.append(_grounded(pos))
		placed += 1

func _scatter_riverbank_trees(water_variant: Dictionary, accepted_positions: PackedVector3Array, route_points: PackedVector3Array, stop_positions: PackedVector3Array) -> void:
	var path: PackedVector2Array = water_variant.get("world_points_xz", PackedVector2Array())
	if path.size() < 2:
		return
	var width_m := maxf(40.0, float(water_variant.get("width_m", 160.0)))
	var count := clampi(int(_polyline_length_2d(path) * shoreline_tree_density * 0.10), 12, 180)
	var rng := RandomNumberGenerator.new()
	rng.seed = abs(String(water_variant.get("name", "river")).hash()) + 1771
	var placed := 0
	var attempts := 0
	while placed < count and attempts < count * 14:
		attempts += 1
		var seg_index := rng.randi_range(0, path.size() - 2)
		var a := path[seg_index]
		var b := path[seg_index + 1]
		var center := a.lerp(b, rng.randf())
		var tangent := (b - a).normalized()
		if tangent.length() <= 0.001:
			continue
		var normal := Vector2(-tangent.y, tangent.x)
		var side := -1.0 if rng.randf() < 0.5 else 1.0
		var offset := width_m * 0.5 + rng.randf_range(18.0, 95.0)
		var pos := Vector3(center.x + normal.x * offset * side, 0.0, center.y + normal.y * offset * side)
		if _route9_backdrop.has_method("is_water_at") and bool(_route9_backdrop.call("is_water_at", pos)):
			continue
		if not _can_place_tree(pos, accepted_positions, route_points, stop_positions):
			continue
		accepted_positions.append(_grounded(pos))
		placed += 1

func _scatter_stop_trees(stop_pos: Vector3, accepted_positions: PackedVector3Array, route_points: PackedVector3Array, stop_positions: PackedVector3Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(abs(stop_pos.x * 0.31 + stop_pos.z * 0.17))
	var cluster_count := 2 if rng.randf() < 0.68 else 3
	var cluster_angles: Array[float] = []
	var base_angle := rng.randf_range(0.0, TAU)
	for i in range(cluster_count):
		cluster_angles.append(base_angle + TAU * float(i) / float(cluster_count) + rng.randf_range(-0.38, 0.38))
	for i in range(stop_tree_count):
		if accepted_positions.size() >= max_tree_instances:
			return
		var cluster_angle := cluster_angles[rng.randi_range(0, cluster_angles.size() - 1)]
		var angle := cluster_angle + rng.randf_range(-0.56, 0.56)
		var radius := rng.randf_range(tree_clearance_to_stop_m + 42.0, tree_clearance_to_stop_m + 168.0)
		var pos := stop_pos + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
		if not _can_place_tree(pos, accepted_positions, route_points, stop_positions):
			continue
		accepted_positions.append(_grounded(pos))

func _build_tree_multimeshes(positions: PackedVector3Array) -> void:
	if positions.is_empty():
		return
	var conifer_positions := PackedVector3Array()
	var broadleaf_positions := PackedVector3Array()
	for pos in positions:
		if _use_broadleaf_variant(pos):
			broadleaf_positions.append(pos)
		else:
			conifer_positions.append(pos)
	_build_tree_variant(conifer_positions, false)
	_build_tree_variant(broadleaf_positions, true)

func _build_tree_variant(positions: PackedVector3Array, broadleaf: bool) -> void:
	if positions.is_empty():
		return
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.16
	trunk_mesh.bottom_radius = 0.28
	trunk_mesh.height = 1.0
	trunk_mesh.radial_segments = 10
	var canopy_mesh := _build_broadleaf_foliage_mesh() if broadleaf else _build_foliage_card_mesh()
	var trunk_material := _tree_trunk_material()
	var canopy_material := _tree_broadleaf_material() if broadleaf else _tree_foliage_material()
	if trunk_material == null or canopy_material == null or canopy_mesh == null:
		var fallback_canopy := SphereMesh.new()
		fallback_canopy.radius = 0.5
		fallback_canopy.height = 1.0
		fallback_canopy.radial_segments = 10
		fallback_canopy.rings = 6
		canopy_mesh = fallback_canopy
		trunk_material = StandardMaterial3D.new()
		trunk_material.albedo_color = Color(0.29, 0.22, 0.15, 1.0)
		trunk_material.roughness = 0.95
		canopy_material = StandardMaterial3D.new()
		canopy_material.albedo_color = Color(0.27, 0.39, 0.21, 1.0)
		canopy_material.roughness = 0.96
	var trunk_mm := MultiMesh.new()
	var canopy_mm := MultiMesh.new()
	trunk_mm.transform_format = MultiMesh.TRANSFORM_3D
	canopy_mm.transform_format = MultiMesh.TRANSFORM_3D
	trunk_mm.mesh = trunk_mesh
	canopy_mm.mesh = canopy_mesh
	trunk_mm.instance_count = positions.size()
	canopy_mm.instance_count = positions.size()
	var rng := RandomNumberGenerator.new()
	rng.seed = 19260324 + (791 if broadleaf else 0)
	for i in range(positions.size()):
		var pos := positions[i]
		var trunk_height := rng.randf_range(4.4, 7.2) if broadleaf else rng.randf_range(4.8, 8.8)
		var canopy_radius := rng.randf_range(3.4, 5.6) if broadleaf else rng.randf_range(2.3, 4.4)
		var canopy_height := canopy_radius * (rng.randf_range(1.15, 1.55) if broadleaf else rng.randf_range(1.9, 2.7))
		var yaw := rng.randf_range(0.0, TAU)
		var trunk_basis := Basis().rotated(Vector3.UP, yaw).scaled(Vector3(1.0, trunk_height, 1.0))
		var canopy_basis := Basis().rotated(Vector3.UP, yaw).scaled(Vector3(canopy_radius * 2.0, canopy_height, canopy_radius * 2.0))
		var trunk_xform := Transform3D(trunk_basis, pos + Vector3(0.0, trunk_height * 0.5, 0.0))
		var canopy_xform := Transform3D(canopy_basis, pos + Vector3(0.0, trunk_height * (0.38 if broadleaf else 0.22), 0.0))
		trunk_mm.set_instance_transform(i, trunk_xform)
		canopy_mm.set_instance_transform(i, canopy_xform)
	var trunk_instance := MultiMeshInstance3D.new()
	trunk_instance.name = "BroadleafTreeTrunks" if broadleaf else "TreeTrunks"
	trunk_instance.multimesh = trunk_mm
	trunk_instance.material_override = trunk_material
	add_child(trunk_instance)
	var canopy_instance := MultiMeshInstance3D.new()
	canopy_instance.name = "BroadleafTreeCanopies" if broadleaf else "TreeCanopies"
	canopy_instance.multimesh = canopy_mm
	canopy_instance.material_override = canopy_material
	add_child(canopy_instance)

func _build_ground_detail_multimeshes(route_points: PackedVector3Array, stop_positions: PackedVector3Array) -> void:
	var grass_positions := PackedVector3Array()
	var reed_positions := PackedVector3Array()
	var rock_positions := PackedVector3Array()
	var stubble_positions := PackedVector3Array()
	var scrub_positions := PackedVector3Array()
	var water_markers: Array = _route9_backdrop.call("get_water_markers") if _route9_backdrop.has_method("get_water_markers") else []
	for water_variant in water_markers:
		_scatter_shore_detail(water_variant, grass_positions, reed_positions, scrub_positions, route_points, stop_positions)
	var hill_markers: Array = _route9_backdrop.call("get_hill_markers") if _route9_backdrop.has_method("get_hill_markers") else []
	for hill_variant in hill_markers:
		_scatter_upland_detail(hill_variant, grass_positions, rock_positions, stubble_positions, scrub_positions, route_points, stop_positions)
	for stop_pos in stop_positions:
		_scatter_corridor_detail(stop_pos, grass_positions, route_points, stop_positions)
		_scatter_town_edge_detail(stop_pos, stubble_positions, scrub_positions, route_points, stop_positions)
	_trim_detail_positions(grass_positions, max_ground_detail_instances)
	_trim_detail_positions(reed_positions, int(max_ground_detail_instances * 0.38))
	_trim_detail_positions(rock_positions, int(max_ground_detail_instances * 0.24))
	_trim_detail_positions(stubble_positions, int(max_ground_detail_instances * 0.46))
	_trim_detail_positions(scrub_positions, max_scrub_instances)
	_build_grass_or_reed_detail(grass_positions, false)
	_build_grass_or_reed_detail(reed_positions, true)
	_build_rock_detail(rock_positions)
	_build_stubble_detail(stubble_positions)
	_build_scrub_detail(scrub_positions)

func _scatter_shore_detail(water_variant: Dictionary, grass_positions: PackedVector3Array, reed_positions: PackedVector3Array, scrub_positions: PackedVector3Array, route_points: PackedVector3Array, stop_positions: PackedVector3Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = abs(String(water_variant.get("name", "water_detail")).hash()) + 9091
	var perimeter_hint := _water_perimeter_hint(water_variant)
	var grass_count := clampi(int(perimeter_hint * grass_detail_density * 0.18), 10, 220)
	var reed_count := clampi(int(perimeter_hint * reed_detail_density * 0.16), 8, 180)
	var scrub_count := clampi(int(perimeter_hint * scrub_detail_density * 0.055), 4, 70)
	for i in range(grass_count):
		if grass_positions.size() >= max_ground_detail_instances:
			break
		var pos := _random_water_edge_position(water_variant, rng, 22.0, 150.0)
		if _can_place_ground_detail(pos, route_points, stop_positions):
			grass_positions.append(_grounded(pos))
	for i in range(reed_count):
		if reed_positions.size() >= int(max_ground_detail_instances * 0.38):
			break
		var pos := _random_water_edge_position(water_variant, rng, 4.0, 42.0)
		if _can_place_ground_detail(pos, route_points, stop_positions):
			reed_positions.append(_grounded(pos))
	for i in range(scrub_count):
		if scrub_positions.size() >= max_scrub_instances:
			break
		var pos := _random_water_edge_position(water_variant, rng, 58.0, 210.0)
		if _can_place_scrub_detail(pos, route_points, stop_positions):
			scrub_positions.append(_grounded(pos))

func _scatter_upland_detail(hill_variant: Dictionary, grass_positions: PackedVector3Array, rock_positions: PackedVector3Array, stubble_positions: PackedVector3Array, scrub_positions: PackedVector3Array, route_points: PackedVector3Array, stop_positions: PackedVector3Array) -> void:
	var center := _hill_or_water_center(hill_variant)
	var radius_m := maxf(260.0, float(hill_variant.get("radius_m", 950.0)))
	var rng := RandomNumberGenerator.new()
	rng.seed = abs(String(hill_variant.get("name", "upland_detail")).hash()) + 5303
	var grass_count := clampi(int(radius_m * grass_detail_density * 0.30), 8, 160)
	var rock_count := clampi(int(radius_m * rock_detail_density * 0.26), 4, 90)
	var stubble_count := clampi(int(radius_m * stubble_detail_density * 0.18), 4, 90)
	var scrub_count := clampi(int(radius_m * scrub_detail_density * 0.13), 3, 58)
	for i in range(grass_count):
		if grass_positions.size() >= max_ground_detail_instances:
			break
		var angle := rng.randf_range(0.0, TAU)
		var radial := radius_m * sqrt(rng.randf_range(0.08, 0.92))
		var pos := center + Vector3(cos(angle) * radial, 0.0, sin(angle) * radial)
		if _can_place_ground_detail(pos, route_points, stop_positions):
			grass_positions.append(_grounded(pos))
	for i in range(rock_count):
		if rock_positions.size() >= int(max_ground_detail_instances * 0.24):
			break
		var angle := rng.randf_range(0.0, TAU)
		var radial := radius_m * sqrt(rng.randf_range(0.15, 0.98))
		var pos := center + Vector3(cos(angle) * radial, 0.0, sin(angle) * radial)
		var context := _terrain_context_at(pos)
		if float(context.get("shore_factor", 0.0)) > 0.42:
			continue
		if _can_place_ground_detail(pos, route_points, stop_positions):
			rock_positions.append(_grounded(pos))
	for i in range(stubble_count):
		if stubble_positions.size() >= int(max_ground_detail_instances * 0.46):
			break
		var angle := rng.randf_range(0.0, TAU)
		var radial := radius_m * sqrt(rng.randf_range(0.20, 0.86))
		var pos := center + Vector3(cos(angle) * radial, 0.0, sin(angle) * radial)
		var context := _terrain_context_at(pos)
		if float(context.get("shore_factor", 0.0)) > 0.24:
			continue
		if _can_place_ground_detail(pos, route_points, stop_positions):
			stubble_positions.append(_grounded(pos))
	for i in range(scrub_count):
		if scrub_positions.size() >= max_scrub_instances:
			break
		var angle := rng.randf_range(0.0, TAU)
		var radial := radius_m * sqrt(rng.randf_range(0.34, 0.98))
		var pos := center + Vector3(cos(angle) * radial, 0.0, sin(angle) * radial)
		if _can_place_scrub_detail(pos, route_points, stop_positions):
			scrub_positions.append(_grounded(pos))

func _scatter_corridor_detail(stop_pos: Vector3, grass_positions: PackedVector3Array, route_points: PackedVector3Array, stop_positions: PackedVector3Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(absf(stop_pos.x * 0.19 + stop_pos.z * 0.23)) + 771
	for i in range(22):
		if grass_positions.size() >= max_ground_detail_instances:
			return
		var angle := rng.randf_range(0.0, TAU)
		var radius := rng.randf_range(ground_detail_clearance_to_stop_m + 12.0, ground_detail_clearance_to_stop_m + 96.0)
		var pos := stop_pos + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
		if _can_place_ground_detail(pos, route_points, stop_positions):
			grass_positions.append(_grounded(pos))

func _scatter_town_edge_detail(stop_pos: Vector3, stubble_positions: PackedVector3Array, scrub_positions: PackedVector3Array, route_points: PackedVector3Array, stop_positions: PackedVector3Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(absf(stop_pos.x * 0.13 + stop_pos.z * 0.29)) + 1447
	for i in range(10):
		if stubble_positions.size() >= int(max_ground_detail_instances * 0.46):
			break
		var angle := rng.randf_range(0.0, TAU)
		var radius := rng.randf_range(170.0, 420.0)
		var pos := stop_pos + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
		var context := _terrain_context_at(pos)
		if float(context.get("water_factor", 0.0)) > 0.18 or float(context.get("shore_factor", 0.0)) > 0.32:
			continue
		if _can_place_ground_detail(pos, route_points, stop_positions):
			stubble_positions.append(_grounded(pos))
	for i in range(5):
		if scrub_positions.size() >= max_scrub_instances:
			break
		var angle := rng.randf_range(0.0, TAU)
		var radius := rng.randf_range(120.0, 360.0)
		var pos := stop_pos + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
		if _can_place_scrub_detail(pos, route_points, stop_positions):
			scrub_positions.append(_grounded(pos))

func _build_grass_or_reed_detail(positions: PackedVector3Array, reeds: bool) -> void:
	if positions.is_empty():
		return
	var mesh := _build_grass_detail_mesh()
	var material := _reed_detail_material() if reeds else _grass_detail_material()
	if mesh == null or material == null:
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = positions.size()
	var rng := RandomNumberGenerator.new()
	rng.seed = 31153 + (977 if reeds else 0)
	for i in range(positions.size()):
		var pos := positions[i]
		var height := rng.randf_range(1.15, 2.35) if reeds else rng.randf_range(0.28, 0.82)
		var width := rng.randf_range(0.26, 0.58) if reeds else rng.randf_range(0.36, 0.92)
		var yaw := rng.randf_range(0.0, TAU)
		var lean := rng.randf_range(-0.08, 0.08)
		var basis := Basis().rotated(Vector3.UP, yaw).rotated(Vector3.RIGHT, lean).scaled(Vector3(width, height, width))
		mm.set_instance_transform(i, Transform3D(basis, pos))
	var instance := MultiMeshInstance3D.new()
	instance.name = "ShoreReeds" if reeds else "GroundGrassClumps"
	instance.multimesh = mm
	instance.material_override = material
	add_child(instance)

func _build_rock_detail(positions: PackedVector3Array) -> void:
	if positions.is_empty():
		return
	var mesh := SphereMesh.new()
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.radius = 0.5
	mesh.height = 0.65
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = positions.size()
	var rng := RandomNumberGenerator.new()
	rng.seed = 62011
	for i in range(positions.size()):
		var pos := positions[i]
		var sx := rng.randf_range(0.55, 1.85)
		var sy := rng.randf_range(0.18, 0.58)
		var sz := rng.randf_range(0.42, 1.35)
		var yaw := rng.randf_range(0.0, TAU)
		var basis := Basis().rotated(Vector3.UP, yaw).scaled(Vector3(sx, sy, sz))
		mm.set_instance_transform(i, Transform3D(basis, pos + Vector3(0.0, sy * 0.34, 0.0)))
	var instance := MultiMeshInstance3D.new()
	instance.name = "UplandStoneScatter"
	instance.multimesh = mm
	instance.material_override = _rock_detail_material()
	add_child(instance)

func _build_stubble_detail(positions: PackedVector3Array) -> void:
	if positions.is_empty():
		return
	var mesh := _build_stubble_detail_mesh()
	var material := _stubble_detail_material()
	if mesh == null or material == null:
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = positions.size()
	var rng := RandomNumberGenerator.new()
	rng.seed = 90377
	for i in range(positions.size()):
		var pos := positions[i]
		var height := rng.randf_range(0.18, 0.48)
		var width := rng.randf_range(0.45, 1.25)
		var yaw := rng.randf_range(0.0, TAU)
		var basis := Basis().rotated(Vector3.UP, yaw).scaled(Vector3(width, height, width))
		mm.set_instance_transform(i, Transform3D(basis, pos))
	var instance := MultiMeshInstance3D.new()
	instance.name = "FieldStubble"
	instance.multimesh = mm
	instance.material_override = material
	add_child(instance)

func _build_scrub_detail(positions: PackedVector3Array) -> void:
	if positions.is_empty():
		return
	var mesh := _build_scrub_detail_mesh()
	var material := _scrub_detail_material()
	if mesh == null or material == null:
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = positions.size()
	var rng := RandomNumberGenerator.new()
	rng.seed = 72163
	for i in range(positions.size()):
		var pos := positions[i]
		var height := rng.randf_range(0.72, 1.85)
		var width := rng.randf_range(1.25, 3.4)
		var yaw := rng.randf_range(0.0, TAU)
		var basis := Basis().rotated(Vector3.UP, yaw).scaled(Vector3(width, height, width))
		mm.set_instance_transform(i, Transform3D(basis, pos))
	var instance := MultiMeshInstance3D.new()
	instance.name = "TownEdgeScrub"
	instance.multimesh = mm
	instance.material_override = material
	add_child(instance)

func _tree_trunk_material() -> StandardMaterial3D:
	if _trunk_material_cache != null:
		return _trunk_material_cache
	var diffuse := _load_runtime_texture(PineTrunkDiffusePath)
	var normal := _load_runtime_texture(PineTrunkNormalPath)
	var roughness := _load_runtime_texture(PineTrunkRoughnessPath)
	if diffuse == null:
		return null
	_trunk_material_cache = StandardMaterial3D.new()
	_trunk_material_cache.albedo_texture = diffuse
	_trunk_material_cache.normal_enabled = normal != null
	_trunk_material_cache.normal_texture = normal
	_trunk_material_cache.roughness_texture = roughness
	_trunk_material_cache.roughness = 0.96
	_trunk_material_cache.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_trunk_material_cache.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	return _trunk_material_cache

func _tree_foliage_material() -> StandardMaterial3D:
	if _foliage_material_cache != null:
		return _foliage_material_cache
	var albedo := _load_albedo_with_alpha_texture(PineTwigDiffusePath, PineTwigAlphaPath)
	var normal := _load_runtime_texture(PineTwigNormalPath)
	var roughness := _load_runtime_texture(PineTwigRoughnessPath)
	if albedo == null:
		return null
	_foliage_material_cache = StandardMaterial3D.new()
	_foliage_material_cache.albedo_texture = albedo
	_foliage_material_cache.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	_foliage_material_cache.alpha_scissor_threshold = 0.42
	_foliage_material_cache.alpha_antialiasing_mode = BaseMaterial3D.ALPHA_ANTIALIASING_ALPHA_TO_COVERAGE
	_foliage_material_cache.alpha_antialiasing_edge = 0.65
	_foliage_material_cache.cull_mode = BaseMaterial3D.CULL_DISABLED
	_foliage_material_cache.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	_foliage_material_cache.vertex_color_use_as_albedo = false
	_foliage_material_cache.set_feature(BaseMaterial3D.FEATURE_BACKLIGHT, true)
	_foliage_material_cache.backlight = Color(0.22, 0.31, 0.18, 1.0)
	_foliage_material_cache.normal_enabled = normal != null
	_foliage_material_cache.normal_texture = normal
	_foliage_material_cache.roughness_texture = roughness
	_foliage_material_cache.roughness = 0.92
	_foliage_material_cache.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_foliage_material_cache.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	return _foliage_material_cache

func _tree_broadleaf_material() -> StandardMaterial3D:
	if _broadleaf_foliage_material_cache != null:
		return _broadleaf_foliage_material_cache
	var base_material := _tree_foliage_material()
	if base_material == null:
		return null
	_broadleaf_foliage_material_cache = base_material.duplicate()
	_broadleaf_foliage_material_cache.albedo_color = Color(0.82, 0.92, 0.77, 1.0)
	_broadleaf_foliage_material_cache.backlight = Color(0.29, 0.37, 0.22, 1.0)
	_broadleaf_foliage_material_cache.roughness = 0.88
	return _broadleaf_foliage_material_cache

func _grass_detail_material() -> StandardMaterial3D:
	if _grass_detail_material_cache != null:
		return _grass_detail_material_cache
	_grass_detail_material_cache = StandardMaterial3D.new()
	_grass_detail_material_cache.albedo_color = Color(0.37, 0.46, 0.25, 1.0)
	_grass_detail_material_cache.roughness = 0.96
	_grass_detail_material_cache.cull_mode = BaseMaterial3D.CULL_DISABLED
	_grass_detail_material_cache.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return _grass_detail_material_cache

func _reed_detail_material() -> StandardMaterial3D:
	if _reed_detail_material_cache != null:
		return _reed_detail_material_cache
	_reed_detail_material_cache = StandardMaterial3D.new()
	_reed_detail_material_cache.albedo_color = Color(0.48, 0.43, 0.24, 1.0)
	_reed_detail_material_cache.roughness = 0.94
	_reed_detail_material_cache.cull_mode = BaseMaterial3D.CULL_DISABLED
	_reed_detail_material_cache.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return _reed_detail_material_cache

func _rock_detail_material() -> StandardMaterial3D:
	if _rock_detail_material_cache != null:
		return _rock_detail_material_cache
	_rock_detail_material_cache = StandardMaterial3D.new()
	_rock_detail_material_cache.albedo_color = Color(0.37, 0.36, 0.32, 1.0)
	_rock_detail_material_cache.roughness = 0.98
	_rock_detail_material_cache.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return _rock_detail_material_cache

func _stubble_detail_material() -> StandardMaterial3D:
	if _stubble_detail_material_cache != null:
		return _stubble_detail_material_cache
	_stubble_detail_material_cache = StandardMaterial3D.new()
	_stubble_detail_material_cache.albedo_color = Color(0.60, 0.52, 0.31, 1.0)
	_stubble_detail_material_cache.roughness = 0.98
	_stubble_detail_material_cache.cull_mode = BaseMaterial3D.CULL_DISABLED
	_stubble_detail_material_cache.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return _stubble_detail_material_cache

func _scrub_detail_material() -> StandardMaterial3D:
	if _scrub_detail_material_cache != null:
		return _scrub_detail_material_cache
	_scrub_detail_material_cache = StandardMaterial3D.new()
	_scrub_detail_material_cache.albedo_color = Color(0.33, 0.38, 0.22, 1.0)
	_scrub_detail_material_cache.roughness = 0.96
	_scrub_detail_material_cache.cull_mode = BaseMaterial3D.CULL_DISABLED
	_scrub_detail_material_cache.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return _scrub_detail_material_cache

func _build_foliage_card_mesh() -> Mesh:
	if _foliage_mesh_cache != null:
		return _foliage_mesh_cache
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_append_tree_card(st, 0.0, 0.46, 0.62, 0.04)
	_append_tree_card(st, PI * 0.35, 0.52, 0.86, 0.12)
	_append_tree_card(st, PI * 0.68, 0.44, 0.58, 0.38)
	_append_tree_card(st, PI * 0.12, 0.30, 0.34, 0.66)
	st.generate_normals()
	_foliage_mesh_cache = st.commit()
	return _foliage_mesh_cache

func _build_broadleaf_foliage_mesh() -> Mesh:
	if _broadleaf_foliage_mesh_cache != null:
		return _broadleaf_foliage_mesh_cache
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_append_tree_card(st, 0.0, 0.68, 0.72, 0.10)
	_append_tree_card(st, PI * 0.22, 0.74, 0.88, 0.18)
	_append_tree_card(st, PI * 0.44, 0.72, 0.94, 0.22)
	_append_tree_card(st, PI * 0.68, 0.64, 0.82, 0.34)
	_append_tree_card(st, PI * 0.88, 0.56, 0.62, 0.56)
	st.generate_normals()
	_broadleaf_foliage_mesh_cache = st.commit()
	return _broadleaf_foliage_mesh_cache

func _build_grass_detail_mesh() -> Mesh:
	if _grass_detail_mesh_cache != null:
		return _grass_detail_mesh_cache
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_append_ground_blade_card(st, 0.0, 0.18, 1.0, 0.06)
	_append_ground_blade_card(st, PI * 0.33, 0.14, 0.82, 0.04)
	_append_ground_blade_card(st, PI * 0.66, 0.16, 0.92, 0.08)
	_append_ground_blade_card(st, PI * 0.12, 0.11, 0.70, -0.03)
	st.generate_normals()
	_grass_detail_mesh_cache = st.commit()
	return _grass_detail_mesh_cache

func _build_stubble_detail_mesh() -> Mesh:
	if _stubble_detail_mesh_cache != null:
		return _stubble_detail_mesh_cache
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_append_ground_blade_card(st, 0.0, 0.11, 1.0, 0.02)
	_append_ground_blade_card(st, PI * 0.25, 0.09, 0.76, -0.03)
	_append_ground_blade_card(st, PI * 0.52, 0.08, 0.64, 0.01)
	st.generate_normals()
	_stubble_detail_mesh_cache = st.commit()
	return _stubble_detail_mesh_cache

func _build_scrub_detail_mesh() -> Mesh:
	if _scrub_detail_mesh_cache != null:
		return _scrub_detail_mesh_cache
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_append_tree_card(st, 0.0, 0.42, 0.82, 0.02)
	_append_tree_card(st, PI * 0.28, 0.48, 0.74, 0.08)
	_append_tree_card(st, PI * 0.58, 0.38, 0.68, 0.14)
	_append_tree_card(st, PI * 0.82, 0.30, 0.56, 0.04)
	st.generate_normals()
	_scrub_detail_mesh_cache = st.commit()
	return _scrub_detail_mesh_cache

func _append_ground_blade_card(st: SurfaceTool, angle: float, half_width: float, height: float, lean: float) -> void:
	var basis := Basis().rotated(Vector3.UP, angle)
	var right := basis.x * half_width
	var lean_vec := basis.z * lean
	var a := -right
	var b := right
	var c := right * 0.34 + Vector3(0.0, height, 0.0) + lean_vec
	var d := -right * 0.34 + Vector3(0.0, height, 0.0) + lean_vec
	_emit_tree_vertex(st, a, Vector2(0.0, 1.0))
	_emit_tree_vertex(st, b, Vector2(1.0, 1.0))
	_emit_tree_vertex(st, c, Vector2(1.0, 0.0))
	_emit_tree_vertex(st, a, Vector2(0.0, 1.0))
	_emit_tree_vertex(st, c, Vector2(1.0, 0.0))
	_emit_tree_vertex(st, d, Vector2(0.0, 0.0))

func _append_tree_card(st: SurfaceTool, angle: float, width: float, height: float, y_offset: float) -> void:
	var basis := Basis().rotated(Vector3.UP, angle)
	var right := basis.x * width
	var bottom_center := Vector3(0.0, y_offset, 0.0)
	var top_center := bottom_center + Vector3(0.0, height, 0.0)
	var a := bottom_center - right
	var b := bottom_center + right
	var c := top_center + right
	var d := top_center - right
	_emit_tree_vertex(st, a, Vector2(0.0, 1.0))
	_emit_tree_vertex(st, b, Vector2(1.0, 1.0))
	_emit_tree_vertex(st, c, Vector2(1.0, 0.0))
	_emit_tree_vertex(st, a, Vector2(0.0, 1.0))
	_emit_tree_vertex(st, c, Vector2(1.0, 0.0))
	_emit_tree_vertex(st, d, Vector2(0.0, 0.0))

func _emit_tree_vertex(st: SurfaceTool, pos: Vector3, uv: Vector2) -> void:
	st.set_uv(uv)
	st.add_vertex(pos)

func _load_runtime_texture(resource_path: String) -> Texture2D:
	if resource_path == "":
		return null
	var absolute_path := ProjectSettings.globalize_path(resource_path)
	if not FileAccess.file_exists(absolute_path):
		return null
	var image := Image.new()
	if image.load(absolute_path) != OK:
		return null
	if image.get_width() > 2048:
		var target_width := 2048
		var target_height := int(round(float(image.get_height()) * (float(target_width) / float(image.get_width()))))
		image.resize(target_width, max(1, target_height), Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(image)

func _load_albedo_with_alpha_texture(albedo_path: String, alpha_path: String) -> Texture2D:
	if albedo_path == "" or alpha_path == "":
		return null
	var albedo_abs := ProjectSettings.globalize_path(albedo_path)
	var alpha_abs := ProjectSettings.globalize_path(alpha_path)
	if not FileAccess.file_exists(albedo_abs) or not FileAccess.file_exists(alpha_abs):
		return null
	var albedo_image := Image.new()
	var alpha_image := Image.new()
	if albedo_image.load(albedo_abs) != OK or alpha_image.load(alpha_abs) != OK:
		return null
	if albedo_image.get_width() > 2048:
		var target_width := 2048
		var target_height := int(round(float(albedo_image.get_height()) * (float(target_width) / float(albedo_image.get_width()))))
		albedo_image.resize(target_width, max(1, target_height), Image.INTERPOLATE_LANCZOS)
	if alpha_image.get_size() != albedo_image.get_size():
		alpha_image.resize(albedo_image.get_width(), albedo_image.get_height(), Image.INTERPOLATE_LANCZOS)
	albedo_image.convert(Image.FORMAT_RGBA8)
	alpha_image.convert(Image.FORMAT_RF)
	for y in range(albedo_image.get_height()):
		for x in range(albedo_image.get_width()):
			var px := albedo_image.get_pixel(x, y)
			px.a = alpha_image.get_pixel(x, y).r
			albedo_image.set_pixel(x, y, px)
	return ImageTexture.create_from_image(albedo_image)

func _can_place_tree(pos: Vector3, accepted_positions: PackedVector3Array, route_points: PackedVector3Array, stop_positions: PackedVector3Array) -> bool:
	if _route9_backdrop.has_method("is_water_at") and bool(_route9_backdrop.call("is_water_at", pos)):
		return false
	for stop_pos in stop_positions:
		if pos.distance_to(stop_pos) < tree_clearance_to_stop_m:
			return false
	for route_pos in route_points:
		if pos.distance_to(route_pos) < tree_clearance_to_route_m:
			return false
	for other in accepted_positions:
		if pos.distance_to(other) < min_tree_spacing_m:
			return false
	if _position_roll(pos, 0.013) > _tree_density_score(pos, stop_positions):
		return false
	return true

func _use_broadleaf_variant(pos: Vector3) -> bool:
	var probability := mixed_forest_ratio
	var context := _terrain_context_at(pos)
	probability += float(context.get("shore_factor", 0.0)) * shoreline_broadleaf_bonus
	probability += float(context.get("river_factor", 0.0)) * 0.16
	probability -= clampf(inverse_lerp(3.0, 15.0, _grounded(pos).y), 0.0, 1.0) * 0.12
	var roll := _position_roll(pos, 0.021)
	return roll < clampf(probability, 0.14, 0.78)

func _apply_weather_to_materials() -> void:
	var wetness := clampf(float(_weather_payload.get("surface_wetness", 0.0)), 0.0, 1.0)
	var storminess := clampf(float(_weather_payload.get("storminess", 0.0)), 0.0, 1.0)
	var snow_cover := clampf(float(_weather_payload.get("snow_cover", 0.0)), 0.0, 1.0)
	var ground_frost := clampf(float(_weather_payload.get("ground_frost", 0.0)), 0.0, 1.0)
	if _trunk_material_cache != null:
		_trunk_material_cache.albedo_color = Color(1.0, 1.0, 1.0, 1.0).lerp(Color(0.90, 0.92, 0.95, 1.0), snow_cover * 0.18 + ground_frost * 0.10)
		_trunk_material_cache.roughness = lerpf(0.96, 0.74, wetness * 0.66 + storminess * 0.18)
	if _foliage_material_cache != null:
		var conifer_tint := Color(1.0, 1.0, 1.0, 1.0)
		conifer_tint = conifer_tint.lerp(Color(0.86, 0.90, 0.86, 1.0), wetness * 0.12 + storminess * 0.10)
		conifer_tint = conifer_tint.lerp(Color(0.80, 0.85, 0.90, 1.0), snow_cover * 0.36 + ground_frost * 0.16)
		_foliage_material_cache.albedo_color = conifer_tint
		_foliage_material_cache.backlight = Color(0.22, 0.31, 0.18, 1.0).lerp(Color(0.17, 0.22, 0.20, 1.0), storminess * 0.42).lerp(Color(0.26, 0.30, 0.33, 1.0), snow_cover * 0.18)
		_foliage_material_cache.roughness = lerpf(0.92, 0.66, wetness * 0.68 + storminess * 0.14)
	if _broadleaf_foliage_material_cache != null:
		var broadleaf_tint := Color(0.82, 0.92, 0.77, 1.0)
		broadleaf_tint = broadleaf_tint.lerp(Color(0.78, 0.84, 0.77, 1.0), wetness * 0.14 + storminess * 0.12)
		broadleaf_tint = broadleaf_tint.lerp(Color(0.82, 0.86, 0.91, 1.0), snow_cover * 0.34 + ground_frost * 0.18)
		_broadleaf_foliage_material_cache.albedo_color = broadleaf_tint
		_broadleaf_foliage_material_cache.backlight = Color(0.29, 0.37, 0.22, 1.0).lerp(Color(0.20, 0.25, 0.22, 1.0), storminess * 0.36).lerp(Color(0.28, 0.31, 0.35, 1.0), snow_cover * 0.18)
		_broadleaf_foliage_material_cache.roughness = lerpf(0.88, 0.62, wetness * 0.70 + storminess * 0.16)
	if _grass_detail_material_cache != null:
		var grass_tint := Color(0.37, 0.46, 0.25, 1.0)
		grass_tint = grass_tint.lerp(Color(0.28, 0.34, 0.22, 1.0), wetness * 0.34 + storminess * 0.16)
		grass_tint = grass_tint.lerp(Color(0.74, 0.78, 0.78, 1.0), snow_cover * 0.42 + ground_frost * 0.24)
		_grass_detail_material_cache.albedo_color = grass_tint
		_grass_detail_material_cache.roughness = lerpf(0.96, 0.64, wetness * 0.62 + storminess * 0.18)
	if _reed_detail_material_cache != null:
		var reed_tint := Color(0.48, 0.43, 0.24, 1.0)
		reed_tint = reed_tint.lerp(Color(0.36, 0.34, 0.22, 1.0), wetness * 0.30 + storminess * 0.18)
		reed_tint = reed_tint.lerp(Color(0.76, 0.77, 0.72, 1.0), snow_cover * 0.36 + ground_frost * 0.18)
		_reed_detail_material_cache.albedo_color = reed_tint
		_reed_detail_material_cache.roughness = lerpf(0.94, 0.66, wetness * 0.54 + storminess * 0.18)
	if _rock_detail_material_cache != null:
		var rock_tint := Color(0.37, 0.36, 0.32, 1.0).darkened(wetness * 0.18)
		rock_tint = rock_tint.lerp(Color(0.72, 0.74, 0.74, 1.0), snow_cover * 0.32 + ground_frost * 0.16)
		_rock_detail_material_cache.albedo_color = rock_tint
		_rock_detail_material_cache.roughness = lerpf(0.98, 0.48, wetness * 0.68 + storminess * 0.12)
	if _stubble_detail_material_cache != null:
		var stubble_tint := Color(0.60, 0.52, 0.31, 1.0)
		stubble_tint = stubble_tint.lerp(Color(0.42, 0.38, 0.25, 1.0), wetness * 0.28 + storminess * 0.16)
		stubble_tint = stubble_tint.lerp(Color(0.78, 0.78, 0.73, 1.0), snow_cover * 0.34 + ground_frost * 0.18)
		_stubble_detail_material_cache.albedo_color = stubble_tint
		_stubble_detail_material_cache.roughness = lerpf(0.98, 0.70, wetness * 0.48 + storminess * 0.12)
	if _scrub_detail_material_cache != null:
		var scrub_tint := Color(0.33, 0.38, 0.22, 1.0)
		scrub_tint = scrub_tint.lerp(Color(0.25, 0.30, 0.20, 1.0), wetness * 0.32 + storminess * 0.16)
		scrub_tint = scrub_tint.lerp(Color(0.72, 0.76, 0.74, 1.0), snow_cover * 0.40 + ground_frost * 0.20)
		_scrub_detail_material_cache.albedo_color = scrub_tint
		_scrub_detail_material_cache.roughness = lerpf(0.96, 0.64, wetness * 0.58 + storminess * 0.14)

func _tree_density_score(pos: Vector3, stop_positions: PackedVector3Array) -> float:
	var context := _terrain_context_at(pos)
	var shore_factor := clampf(float(context.get("shore_factor", 0.0)), 0.0, 1.0)
	var river_factor := clampf(float(context.get("river_factor", 0.0)), 0.0, 1.0)
	var coast_factor := clampf(float(context.get("coast_factor", 0.0)), 0.0, 1.0)
	var nearest_stop := _nearest_distance(pos, stop_positions)
	var town_pressure := 1.0 - smoothstep(tree_clearance_to_stop_m + 18.0, tree_clearance_to_stop_m + 210.0, nearest_stop)
	var elevation_factor := clampf(inverse_lerp(2.0, 14.0, _grounded(pos).y), 0.0, 1.0)
	var score := 0.50
	score += shore_factor * 0.16 + river_factor * 0.12 + elevation_factor * 0.08
	score -= coast_factor * 0.12 + town_pressure * 0.44
	score += (_position_roll(pos, 0.047) - 0.5) * 0.14
	return clampf(score, 0.08, 0.96)

func _water_perimeter_hint(water_variant: Dictionary) -> float:
	var shape := String(water_variant.get("shape", "ellipse"))
	match shape:
		"river":
			return maxf(100.0, float(water_variant.get("path_length_m", 1000.0)))
		"polygon":
			var polygon: PackedVector2Array = water_variant.get("world_polygon_xz", PackedVector2Array())
			if polygon.size() < 3:
				return 600.0
			var perimeter := 0.0
			for i in range(polygon.size()):
				perimeter += polygon[i].distance_to(polygon[(i + 1) % polygon.size()])
			return maxf(100.0, perimeter)
		_:
			var rx := maxf(80.0, float(water_variant.get("radius_x_m", 450.0)))
			var rz := maxf(80.0, float(water_variant.get("radius_z_m", 350.0)))
			return PI * (3.0 * (rx + rz) - sqrt((3.0 * rx + rz) * (rx + 3.0 * rz)))

func _random_water_edge_position(water_variant: Dictionary, rng: RandomNumberGenerator, offset_min: float, offset_max: float) -> Vector3:
	var shape := String(water_variant.get("shape", "ellipse"))
	match shape:
		"river":
			var path: PackedVector2Array = water_variant.get("world_points_xz", PackedVector2Array())
			if path.size() < 2:
				return _hill_or_water_center(water_variant)
			var seg_index := rng.randi_range(0, path.size() - 2)
			var a := path[seg_index]
			var b := path[seg_index + 1]
			var tangent := (b - a).normalized()
			if tangent.length() <= 0.001:
				return Vector3(a.x, 0.0, a.y)
			var normal := Vector2(-tangent.y, tangent.x)
			var side := -1.0 if rng.randf() < 0.5 else 1.0
			var width := maxf(28.0, float(water_variant.get("width_m", 120.0)))
			var center := a.lerp(b, rng.randf())
			var offset := width * 0.5 + rng.randf_range(offset_min, offset_max)
			return Vector3(center.x + normal.x * offset * side, 0.0, center.y + normal.y * offset * side)
		"polygon":
			var polygon: PackedVector2Array = water_variant.get("world_polygon_xz", PackedVector2Array())
			if polygon.size() < 3:
				return _hill_or_water_center(water_variant)
			var seg_index := rng.randi_range(0, polygon.size() - 1)
			var a := polygon[seg_index]
			var b := polygon[(seg_index + 1) % polygon.size()]
			var tangent := (b - a).normalized()
			if tangent.length() <= 0.001:
				return Vector3(a.x, 0.0, a.y)
			var normal := Vector2(-tangent.y, tangent.x)
			var side := -1.0 if rng.randf() < 0.5 else 1.0
			var edge_point := a.lerp(b, rng.randf())
			var offset := rng.randf_range(offset_min, offset_max)
			return Vector3(edge_point.x + normal.x * offset * side, 0.0, edge_point.y + normal.y * offset * side)
		_:
			var center := _hill_or_water_center(water_variant)
			var rx := maxf(80.0, float(water_variant.get("radius_x_m", 450.0)))
			var rz := maxf(80.0, float(water_variant.get("radius_z_m", 350.0)))
			var angle_offset := deg_to_rad(float(water_variant.get("rotation_deg", 0.0)))
			var angle := rng.randf_range(0.0, TAU)
			var ring_offset := rng.randf_range(offset_min, offset_max)
			var local := Vector2(cos(angle) * (rx + ring_offset), sin(angle) * (rz + ring_offset)).rotated(angle_offset)
			return center + Vector3(local.x, 0.0, local.y)

func _can_place_ground_detail(pos: Vector3, route_points: PackedVector3Array, stop_positions: PackedVector3Array) -> bool:
	if _route9_backdrop.has_method("is_water_at") and bool(_route9_backdrop.call("is_water_at", pos)):
		return false
	for stop_pos in stop_positions:
		if pos.distance_to(stop_pos) < ground_detail_clearance_to_stop_m:
			return false
	if _distance_to_route(pos, route_points) < ground_detail_clearance_to_route_m:
		return false
	if _position_roll(pos, 0.037) < 0.08:
		return false
	return true

func _can_place_scrub_detail(pos: Vector3, route_points: PackedVector3Array, stop_positions: PackedVector3Array) -> bool:
	if _route9_backdrop.has_method("is_water_at") and bool(_route9_backdrop.call("is_water_at", pos)):
		return false
	var context := _terrain_context_at(pos)
	if float(context.get("water_factor", 0.0)) > 0.12:
		return false
	for stop_pos in stop_positions:
		if pos.distance_to(stop_pos) < ground_detail_clearance_to_stop_m + 18.0:
			return false
	if _distance_to_route(pos, route_points) < ground_detail_clearance_to_route_m + 12.0:
		return false
	if _position_roll(pos, 0.043) < 0.14:
		return false
	return true

func _distance_to_route(pos: Vector3, route_points: PackedVector3Array) -> float:
	if route_points.size() < 2:
		return INF
	var sample := Vector2(pos.x, pos.z)
	var best := INF
	for i in range(route_points.size() - 1):
		var a := Vector2(route_points[i].x, route_points[i].z)
		var b := Vector2(route_points[i + 1].x, route_points[i + 1].z)
		var ab := b - a
		var len_sq := ab.length_squared()
		if len_sq <= 0.001:
			continue
		var t := clampf((sample - a).dot(ab) / len_sq, 0.0, 1.0)
		best = minf(best, sample.distance_to(a + ab * t))
	return best

func _trim_detail_positions(positions: PackedVector3Array, max_count: int) -> void:
	while positions.size() > max_count:
		positions.remove_at(positions.size() - 1)

func _terrain_context_at(pos: Vector3) -> Dictionary:
	if _route9_backdrop != null and _route9_backdrop.has_method("terrain_context_at"):
		return _route9_backdrop.call("terrain_context_at", pos)
	return {}

func _nearest_distance(pos: Vector3, points: PackedVector3Array) -> float:
	if points.is_empty():
		return INF
	var best := INF
	for point in points:
		best = minf(best, pos.distance_to(point))
	return best

func _position_roll(pos: Vector3, scale: float) -> float:
	var seed := int(absf(pos.x * scale + pos.z * scale * 1.71))
	return float(seed % 1000) / 1000.0

func _grounded(pos: Vector3) -> Vector3:
	var ground_y := 0.0
	if _route9_backdrop != null and _route9_backdrop.has_method("ground_height_at"):
		ground_y = float(_route9_backdrop.call("ground_height_at", pos))
	return Vector3(pos.x, ground_y, pos.z)

func _hill_or_water_center(feature: Dictionary) -> Vector3:
	if _route9_backdrop == null:
		return Vector3.ZERO
	if feature.has("world_pos"):
		return feature.get("world_pos", Vector3.ZERO)
	var lon := float(feature.get("lon", 0.0))
	var lat := float(feature.get("lat", 0.0))
	if _route9_backdrop.has_method("world_point_for_lon_lat"):
		return _route9_backdrop.call("world_point_for_lon_lat", lon, lat)
	var world_size := Vector2(350000.0, 240000.0)
	if _route9_backdrop.has_method("get"):
		world_size = _route9_backdrop.get("world_size_m")
	var bounds := {
		"min_lat": 41.2,
		"max_lat": 42.9,
		"min_lon": -73.6,
		"max_lon": -69.9
	}
	var x := lerpf(-world_size.x * 0.5, world_size.x * 0.5, inverse_lerp(float(bounds["min_lon"]), float(bounds["max_lon"]), lon))
	var z := lerpf(world_size.y * 0.5, -world_size.y * 0.5, inverse_lerp(float(bounds["min_lat"]), float(bounds["max_lat"]), lat))
	return Vector3(x, 0.0, z)

func _polyline_length_2d(points: PackedVector2Array) -> float:
	var length_m := 0.0
	for i in range(points.size() - 1):
		length_m += points[i].distance_to(points[i + 1])
	return length_m
