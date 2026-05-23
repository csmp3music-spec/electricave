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
@export var backdrop_height_influence := 1.0
@export var micro_relief_m := 0.55
@export var micro_relief_scale := 0.00032
@export var terrain_texture_contrast := 1.08
@export var terrain_height_range_m := Vector2(-2.5, 18.0)
@export var detail_normal_strength := 0.16
@export var leaf_litter_strength := 0.24
@export var shoreline_grit_strength := 0.22

var _route9_backdrop: Node
var _weather: Node
var _shader_material: ShaderMaterial
var _weather_payload := {}

func _ready() -> void:
	_route9_backdrop = get_node_or_null(route9_backdrop_path)
	_weather = get_node_or_null(weather_path)
	if _weather != null and _weather.has_signal("weather_changed"):
		_weather.connect("weather_changed", Callable(self, "_on_weather_changed"))
	call_deferred("_rebuild_terrain")

func _rebuild_terrain() -> void:
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
	var normals := PackedVector3Array()
	normals.resize(vertices.size())
	var colors := PackedColorArray()
	colors.resize(vertices.size())
	var origin := global_transform.origin
	for i in range(vertices.size()):
		var vertex: Vector3 = vertices[i]
		var world_sample := Vector3(origin.x + vertex.x, 0.0, origin.z + vertex.z)
		var base_height := float(_route9_backdrop.call("ground_height_at", world_sample)) * backdrop_height_influence
		var context := {}
		if _route9_backdrop.has_method("terrain_context_at"):
			context = _route9_backdrop.call("terrain_context_at", world_sample)
		vertex.y = base_height - origin.y + _micro_relief(Vector2(world_sample.x, world_sample.z))
		vertices[i] = vertex
		var elevation_hint := clampf(inverse_lerp(terrain_height_range_m.x, terrain_height_range_m.y, base_height), 0.0, 1.0)
		var shore_factor := clampf(float(context.get("shore_factor", 0.0)), 0.0, 1.0)
		var river_factor := clampf(float(context.get("river_factor", 0.0)), 0.0, 1.0)
		var coast_factor := clampf(float(context.get("coast_factor", 0.0)), 0.0, 1.0)
		colors[i] = Color(elevation_hint, shore_factor, river_factor, coast_factor)
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
	_shader_material.set_shader_parameter("rain_wetness", rain_wetness)
	_shader_material.set_shader_parameter("snow_cover", snow_cover)

func _micro_relief(world_xz: Vector2) -> float:
	var a := sin(world_xz.x * micro_relief_scale) * micro_relief_m * 0.42
	var b := cos(world_xz.y * micro_relief_scale * 1.18) * micro_relief_m * 0.33
	var c := sin((world_xz.x + world_xz.y) * micro_relief_scale * 0.61) * micro_relief_m * 0.25
	return a + b + c

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
