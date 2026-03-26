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
@export var tree_clearance_to_stop_m := 125.0
@export var tree_clearance_to_route_m := 26.0
@export var min_tree_spacing_m := 13.0
@export var hill_tree_density := 0.012
@export var shoreline_tree_density := 0.007
@export var stop_tree_count := 16
@export var max_tree_instances := 1600

var _route9_backdrop: Node
var _town_manager: Node
var _corridor: Node
var _rebuild_queued := false
var _trunk_material_cache: StandardMaterial3D
var _foliage_material_cache: StandardMaterial3D
var _foliage_mesh_cache: Mesh

func _ready() -> void:
	_resolve_dependencies()
	if _town_manager != null and _town_manager.has_signal("town_created"):
		_town_manager.town_created.connect(_queue_rebuild)
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

func _scatter_stop_trees(stop_pos: Vector3, accepted_positions: PackedVector3Array, route_points: PackedVector3Array, stop_positions: PackedVector3Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(abs(stop_pos.x * 0.31 + stop_pos.z * 0.17))
	for i in range(stop_tree_count):
		if accepted_positions.size() >= max_tree_instances:
			return
		var angle := rng.randf_range(0.0, TAU)
		var radius := rng.randf_range(tree_clearance_to_stop_m + 28.0, tree_clearance_to_stop_m + 110.0)
		var pos := stop_pos + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
		if not _can_place_tree(pos, accepted_positions, route_points, stop_positions):
			continue
		accepted_positions.append(_grounded(pos))

func _build_tree_multimeshes(positions: PackedVector3Array) -> void:
	if positions.is_empty():
		return
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.16
	trunk_mesh.bottom_radius = 0.28
	trunk_mesh.height = 1.0
	trunk_mesh.radial_segments = 10
	var canopy_mesh := _build_foliage_card_mesh()
	var trunk_material := _tree_trunk_material()
	var canopy_material := _tree_foliage_material()
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
	rng.seed = 19260324
	for i in range(positions.size()):
		var pos := positions[i]
		var trunk_height := rng.randf_range(4.8, 8.8)
		var canopy_radius := rng.randf_range(2.3, 4.4)
		var canopy_height := canopy_radius * rng.randf_range(1.9, 2.7)
		var yaw := rng.randf_range(0.0, TAU)
		var trunk_basis := Basis().rotated(Vector3.UP, yaw).scaled(Vector3(1.0, trunk_height, 1.0))
		var canopy_basis := Basis().rotated(Vector3.UP, yaw).scaled(Vector3(canopy_radius * 2.0, canopy_height, canopy_radius * 2.0))
		var trunk_xform := Transform3D(trunk_basis, pos + Vector3(0.0, trunk_height * 0.5, 0.0))
		var canopy_xform := Transform3D(canopy_basis, pos + Vector3(0.0, trunk_height * 0.22, 0.0))
		trunk_mm.set_instance_transform(i, trunk_xform)
		canopy_mm.set_instance_transform(i, canopy_xform)
	var trunk_instance := MultiMeshInstance3D.new()
	trunk_instance.name = "TreeTrunks"
	trunk_instance.multimesh = trunk_mm
	trunk_instance.material_override = trunk_material
	add_child(trunk_instance)
	var canopy_instance := MultiMeshInstance3D.new()
	canopy_instance.name = "TreeCanopies"
	canopy_instance.multimesh = canopy_mm
	canopy_instance.material_override = canopy_material
	add_child(canopy_instance)

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
	_foliage_material_cache.cull_mode = BaseMaterial3D.CULL_DISABLED
	_foliage_material_cache.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	_foliage_material_cache.vertex_color_use_as_albedo = false
	_foliage_material_cache.normal_enabled = normal != null
	_foliage_material_cache.normal_texture = normal
	_foliage_material_cache.roughness_texture = roughness
	_foliage_material_cache.roughness = 0.92
	_foliage_material_cache.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return _foliage_material_cache

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
	return true

func _grounded(pos: Vector3) -> Vector3:
	var ground_y := 0.0
	if _route9_backdrop != null and _route9_backdrop.has_method("ground_height_at"):
		ground_y = float(_route9_backdrop.call("ground_height_at", pos))
	return Vector3(pos.x, ground_y, pos.z)

func _hill_or_water_center(feature: Dictionary) -> Vector3:
	if _route9_backdrop == null:
		return Vector3.ZERO
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
