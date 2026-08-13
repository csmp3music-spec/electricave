extends MeshInstance3D
class_name TerrainMaterialController

const GrassAlbedoPath := "res://assets/textures/terrain_materials/leafy_grass/leafy_grass_diff_1k.jpg"
const GrassRoughnessPath := "res://assets/textures/terrain_materials/leafy_grass/leafy_grass_rough_1k.jpg"
const GrassNormalPath := "res://assets/textures/terrain_materials/leafy_grass/leafy_grass_nor_gl_1k.jpg"
const SoilAlbedoPath := "res://assets/textures/terrain_materials/forest_ground_04/forest_ground_04_diff_1k.jpg"
const SoilRoughnessPath := "res://assets/textures/terrain_materials/forest_ground_04/forest_ground_04_rough_1k.jpg"
const SoilNormalPath := "res://assets/textures/terrain_materials/forest_ground_04/forest_ground_04_nor_gl_1k.jpg"
const MudAlbedoPath := "res://assets/textures/terrain_materials/brown_mud_leaves_01/brown_mud_leaves_01_diff_1k.jpg"
const MudRoughnessPath := "res://assets/textures/terrain_materials/brown_mud_leaves_01/brown_mud_leaves_01_rough_1k.jpg"
const MudNormalPath := "res://assets/textures/terrain_materials/brown_mud_leaves_01/brown_mud_leaves_01_nor_gl_1k.jpg"
const RockAlbedoPath := "res://assets/textures/terrain_materials/aerial_ground_rock/aerial_ground_rock_diff_1k.jpg"
const RockRoughnessPath := "res://assets/textures/terrain_materials/aerial_ground_rock/aerial_ground_rock_rough_1k.jpg"
const RockNormalPath := "res://assets/textures/terrain_materials/aerial_ground_rock/aerial_ground_rock_nor_gl_1k.jpg"

@export var route9_backdrop_path: NodePath = NodePath("../Route9Backdrop")
@export var weather_path: NodePath = NodePath("../../Weather")
@export var corridor_path: NodePath
@export var town_manager_path: NodePath
@export var backdrop_height_influence := 1.0
@export var micro_relief_m := 0.55
@export var micro_relief_scale := 0.00032
@export var terrain_texture_contrast := 1.08
@export var terrain_height_range_m := Vector2(-2.5, 18.0)
@export var detail_normal_strength := 0.16
@export var leaf_litter_strength := 0.24
@export var shoreline_grit_strength := 0.22
@export var puddle_strength := 0.34
@export var frost_tint_strength := 0.42
@export var upland_dryness_strength := 0.18
@export var duff_variation_strength := 0.20
@export var damp_stain_strength := 0.26
@export var route_disturbance_radius_m := 42.0
@export var station_grit_radius_m := 155.0
@export var route_disturbance_strength := 0.42
@export var urban_grit_strength := 0.36
@export var meadow_tuft_strength := 0.28
@export var trackside_rut_strength := 0.36
@export var shoreline_sediment_strength := 0.26
@export var seasonal_field_strength := 0.24

var _route9_backdrop: Node
var _weather: Node
var _corridor: Node
var _town_manager: Node
var _shader_material: ShaderMaterial
var _weather_payload := {}

func _ready() -> void:
	_resolve_dependencies()
	if _weather != null and _weather.has_signal("weather_changed"):
		_weather.connect("weather_changed", Callable(self, "_on_weather_changed"))
	call_deferred("_rebuild_terrain")

func _rebuild_terrain() -> void:
	_resolve_dependencies()
	_apply_heightfield()
	_apply_textures()
	if _weather != null and _weather.has_method("get_weather_payload"):
		_weather_payload = _weather.call("get_weather_payload")
	_apply_weather_to_shader()

func _apply_heightfield() -> void:
	if _route9_backdrop == null or not _route9_backdrop.has_method("ground_height_at"):
		return
	if mesh == null or mesh.get_surface_count() <= 0:
		return
	var arrays := mesh.surface_get_arrays(0)
	if arrays.is_empty():
		return
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	if vertices.is_empty() or indices.is_empty():
		return
	var route_points := _route_points()
	var stop_points := _stop_points()
	var normals := PackedVector3Array()
	normals.resize(vertices.size())
	var colors := PackedColorArray()
	colors.resize(vertices.size())
	var landuse_uv := PackedVector2Array()
	landuse_uv.resize(vertices.size())
	var origin := global_transform.origin
	for i in range(vertices.size()):
		var vertex: Vector3 = vertices[i]
		var world_sample := Vector3(origin.x + vertex.x, 0.0, origin.z + vertex.z)
		var base_height := float(_route9_backdrop.call("ground_height_at", world_sample)) * backdrop_height_influence
		var context := {}
		if _route9_backdrop.has_method("terrain_context_at"):
			context = _route9_backdrop.call("terrain_context_at", world_sample)
		var relief := _micro_relief(Vector2(world_sample.x, world_sample.z)) * _micro_relief_weight(context)
		vertex.y = base_height - origin.y + relief
		vertices[i] = vertex
		var elevation_hint := clampf(inverse_lerp(terrain_height_range_m.x, terrain_height_range_m.y, base_height), 0.0, 1.0)
		var shore_factor := clampf(float(context.get("shore_factor", 0.0)), 0.0, 1.0)
		var river_factor := clampf(float(context.get("river_factor", 0.0)), 0.0, 1.0)
		var coast_factor := clampf(float(context.get("coast_factor", 0.0)), 0.0, 1.0)
		colors[i] = Color(elevation_hint, shore_factor, river_factor, coast_factor)
		landuse_uv[i] = Vector2(
			_route_disturbance_factor(world_sample, route_points),
			_station_grit_factor(world_sample, stop_points)
		)
	for i in range(0, indices.size(), 3):
		var ia := indices[i]
		var ib := indices[i + 1]
		var ic := indices[i + 2]
		var a: Vector3 = vertices[ia]
		var b: Vector3 = vertices[ib]
		var c: Vector3 = vertices[ic]
		var tri_normal := (b - a).cross(c - a)
		normals[ia] += tri_normal
		normals[ib] += tri_normal
		normals[ic] += tri_normal
	for i in range(normals.size()):
		normals[i] = normals[i].normalized()
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_TEX_UV2] = landuse_uv
	var rebuilt_mesh := ArrayMesh.new()
	rebuilt_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh = rebuilt_mesh

func _apply_textures() -> void:
	_shader_material = material_override as ShaderMaterial
	if _shader_material == null:
		return
	var texture_map := {
		"grass_albedo": _load_runtime_texture(GrassAlbedoPath),
		"grass_roughness": _load_runtime_texture(GrassRoughnessPath),
		"grass_normal": _load_runtime_texture(GrassNormalPath),
		"soil_albedo": _load_runtime_texture(SoilAlbedoPath),
		"soil_roughness": _load_runtime_texture(SoilRoughnessPath),
		"soil_normal": _load_runtime_texture(SoilNormalPath),
		"mud_albedo": _load_runtime_texture(MudAlbedoPath),
		"mud_roughness": _load_runtime_texture(MudRoughnessPath),
		"mud_normal": _load_runtime_texture(MudNormalPath),
		"rock_albedo": _load_runtime_texture(RockAlbedoPath),
		"rock_roughness": _load_runtime_texture(RockRoughnessPath),
		"rock_normal": _load_runtime_texture(RockNormalPath)
	}
	var complete := true
	for key in texture_map.keys():
		var texture := texture_map[key] as Texture2D
		if texture == null:
			complete = false
			continue
		_shader_material.set_shader_parameter(key, texture)
	_shader_material.set_shader_parameter("use_texture_layers", complete)
	_shader_material.set_shader_parameter("height_scale", 0.82)
	_shader_material.set_shader_parameter("ridge_strength", 0.12)
	_shader_material.set_shader_parameter("grass_uv_scale", 0.069)
	_shader_material.set_shader_parameter("soil_uv_scale", 0.059)
	_shader_material.set_shader_parameter("mud_uv_scale", 0.083)
	_shader_material.set_shader_parameter("rock_uv_scale", 0.049)
	_shader_material.set_shader_parameter("rock_triplanar_sharpness", 7.5)
	_shader_material.set_shader_parameter("rock_triplanar_blend_start", 0.18)
	_shader_material.set_shader_parameter("rock_triplanar_blend_end", 0.48)
	_shader_material.set_shader_parameter("normal_strength", 0.9)
	_shader_material.set_shader_parameter("detail_normal_strength", detail_normal_strength)
	_shader_material.set_shader_parameter("leaf_litter_strength", leaf_litter_strength)
	_shader_material.set_shader_parameter("shoreline_grit_strength", shoreline_grit_strength)
	_shader_material.set_shader_parameter("puddle_strength", puddle_strength)
	_shader_material.set_shader_parameter("frost_tint_strength", frost_tint_strength)
	_shader_material.set_shader_parameter("upland_dryness_strength", upland_dryness_strength)
	_shader_material.set_shader_parameter("duff_variation_strength", duff_variation_strength)
	_shader_material.set_shader_parameter("damp_stain_strength", damp_stain_strength)
	_shader_material.set_shader_parameter("route_disturbance_strength", route_disturbance_strength)
	_shader_material.set_shader_parameter("urban_grit_strength", urban_grit_strength)
	_shader_material.set_shader_parameter("meadow_tuft_strength", meadow_tuft_strength)
	_shader_material.set_shader_parameter("trackside_rut_strength", trackside_rut_strength)
	_shader_material.set_shader_parameter("shoreline_sediment_strength", shoreline_sediment_strength)
	_shader_material.set_shader_parameter("seasonal_field_strength", seasonal_field_strength)
	_shader_material.set_shader_parameter("macro_albedo_strength", terrain_texture_contrast * 1.03)
	_shader_material.set_shader_parameter("wet_clearcoat_strength", 0.82)
	_shader_material.set_shader_parameter("terrain_low_hint", terrain_height_range_m.x)
	_shader_material.set_shader_parameter("terrain_high_hint", terrain_height_range_m.y)

func _on_weather_changed(payload: Dictionary) -> void:
	_weather_payload = payload.duplicate(true)
	_apply_weather_to_shader()

func _apply_weather_to_shader() -> void:
	if _shader_material == null:
		_shader_material = material_override as ShaderMaterial
	if _shader_material == null:
		return
	var rain_wetness := clampf(float(_weather_payload.get("surface_wetness", 0.0)), 0.0, 1.0)
	if rain_wetness <= 0.01 and bool(_weather_payload.get("rain_active", false)):
		rain_wetness = clampf(float(_weather_payload.get("intensity", 0.0)), 0.0, 1.0)
	var snow_cover := clampf(float(_weather_payload.get("snow_cover", 0.0)), 0.0, 1.0)
	if snow_cover <= 0.01 and bool(_weather_payload.get("snow_active", false)):
		snow_cover = clampf(float(_weather_payload.get("intensity", 0.0)) * 0.9, 0.0, 1.0)
	var humidity_amount := clampf(float(_weather_payload.get("humidity", 0.0)), 0.0, 1.0)
	var storminess_amount := clampf(float(_weather_payload.get("storminess", 0.0)), 0.0, 1.0)
	var mist_amount := clampf(float(_weather_payload.get("mist_amount", 0.0)), 0.0, 1.0)
	var ground_frost := clampf(float(_weather_payload.get("ground_frost", 0.0)), 0.0, 1.0)
	_shader_material.set_shader_parameter("rain_wetness", rain_wetness)
	_shader_material.set_shader_parameter("snow_cover", snow_cover)
	_shader_material.set_shader_parameter("humidity_amount", humidity_amount)
	_shader_material.set_shader_parameter("storminess_amount", storminess_amount)
	_shader_material.set_shader_parameter("mist_amount", mist_amount)
	_shader_material.set_shader_parameter("ground_frost", ground_frost)

func _resolve_dependencies() -> void:
	_route9_backdrop = get_node_or_null(route9_backdrop_path)
	_weather = get_node_or_null(weather_path)
	if corridor_path != NodePath(""):
		_corridor = get_node_or_null(corridor_path)
	if town_manager_path != NodePath(""):
		_town_manager = get_node_or_null(town_manager_path)
	var terrain_parent := get_parent()
	var world_root := terrain_parent.get_parent() if terrain_parent != null else null
	if _corridor == null and world_root != null:
		_corridor = world_root.get_node_or_null("CorridorSeed")
	if _town_manager == null and world_root != null:
		_town_manager = world_root.get_node_or_null("TownGrowthManager")

func _micro_relief(world_xz: Vector2) -> float:
	var a := sin(world_xz.x * micro_relief_scale) * micro_relief_m * 0.42
	var b := cos(world_xz.y * micro_relief_scale * 1.18) * micro_relief_m * 0.33
	var c := sin((world_xz.x + world_xz.y) * micro_relief_scale * 0.61) * micro_relief_m * 0.25
	return a + b + c

func _micro_relief_weight(context: Dictionary) -> float:
	var shore_factor := clampf(float(context.get("shore_factor", 0.0)), 0.0, 1.0)
	var river_factor := clampf(float(context.get("river_factor", 0.0)), 0.0, 1.0)
	var coast_factor := clampf(float(context.get("coast_factor", 0.0)), 0.0, 1.0)
	var water_factor := clampf(float(context.get("water_factor", 0.0)), 0.0, 1.0)
	return clampf(1.0 - shore_factor * 0.48 - river_factor * 0.18 - coast_factor * 0.10 - water_factor * 0.72, 0.18, 1.0)

func _route_points() -> PackedVector3Array:
	if _corridor == null or not is_instance_valid(_corridor):
		return PackedVector3Array()
	if _corridor.has_method("get_system_route_points"):
		var system_points: Variant = _corridor.call("get_system_route_points")
		if system_points is PackedVector3Array:
			return system_points
	if _corridor.has_method("get_mainline_points"):
		var mainline_points: Variant = _corridor.call("get_mainline_points")
		if mainline_points is PackedVector3Array:
			return mainline_points
	return PackedVector3Array()

func _stop_points() -> PackedVector3Array:
	var points := PackedVector3Array()
	if _town_manager == null or not is_instance_valid(_town_manager):
		return points
	if not _has_property(_town_manager, "stops"):
		return points
	var stops: Array = _town_manager.get("stops")
	for stop in stops:
		if stop == null:
			continue
		if _has_property(stop, "position"):
			points.append(stop.position)
	return points

func _route_disturbance_factor(world_pos: Vector3, route_points: PackedVector3Array) -> float:
	if route_points.size() < 2:
		return 0.0
	var radius_sq := route_disturbance_radius_m * route_disturbance_radius_m
	var best_sq := radius_sq
	var sample := Vector2(world_pos.x, world_pos.z)
	for i in range(route_points.size() - 1):
		var a := Vector2(route_points[i].x, route_points[i].z)
		var b := Vector2(route_points[i + 1].x, route_points[i + 1].z)
		var ab := b - a
		var len_sq := ab.length_squared()
		if len_sq <= 0.001:
			continue
		var t := clampf((sample - a).dot(ab) / len_sq, 0.0, 1.0)
		var closest := a + ab * t
		best_sq = minf(best_sq, sample.distance_squared_to(closest))
	return clampf(1.0 - sqrt(best_sq) / maxf(1.0, route_disturbance_radius_m), 0.0, 1.0)

func _station_grit_factor(world_pos: Vector3, stop_points: PackedVector3Array) -> float:
	if stop_points.is_empty():
		return 0.0
	var radius_sq := station_grit_radius_m * station_grit_radius_m
	var best_sq := radius_sq
	var sample := Vector2(world_pos.x, world_pos.z)
	for stop_pos in stop_points:
		best_sq = minf(best_sq, sample.distance_squared_to(Vector2(stop_pos.x, stop_pos.z)))
	return clampf(1.0 - sqrt(best_sq) / maxf(1.0, station_grit_radius_m), 0.0, 1.0)

func _has_property(target: Object, prop_name: String) -> bool:
	if target == null:
		return false
	for prop in target.get_property_list():
		if String(prop.get("name", "")) == prop_name:
			return true
	return false

func _load_runtime_texture(resource_path: String) -> Texture2D:
	if resource_path == "":
		return null
	if ResourceLoader.exists(resource_path):
		var imported := load(resource_path)
		if imported is Texture2D:
			return imported
	var absolute_path := ProjectSettings.globalize_path(resource_path)
	if not FileAccess.file_exists(absolute_path):
		return null
	var image := Image.new()
	var err := image.load(absolute_path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(image)
