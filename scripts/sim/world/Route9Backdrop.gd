extends Node3D
class_name Route9Backdrop

const GeoProjectorScript := preload("res://scripts/geo/GeoProjector.gd")
const WaterShaderPath := "res://shaders/WaterSurface.gdshader"

@export var bounds: Resource
@export var world_size_m := Vector2(350000.0, 240000.0)
@export_file("*.json") var features_path := "res://data/route9_features.json"
@export var water_height_m := -2.4
@export var rolling_height_m := 1.1
@export var hill_height_scale := 0.34
@export var show_hill_masses := true
@export var hill_visual_radius_scale := 0.78
@export var hill_visual_height_scale := 0.62
@export var label_height_m := 9.0
@export var show_town_labels := true

var _features := {
	"water": [],
	"hills": [],
	"towns": []
}
var _resolved_bounds := {}

func _ready() -> void:
	if bounds == null and ResourceLoader.exists("res://data/ma_bounds.tres"):
		bounds = load("res://data/ma_bounds.tres")
	_resolved_bounds = _load_bounds()
	_features = _load_features()
	_rebuild_visuals()

func ground_height_at(world_pos: Vector3) -> float:
	var height := _rolling_height(world_pos)
	for hill_variant in _features.get("hills", []):
		var hill: Dictionary = hill_variant
		var center := _world_point(float(hill.get("lon", 0.0)), float(hill.get("lat", 0.0)))
		var radius := maxf(1.0, float(hill.get("radius_m", 1.0)))
		var t := 1.0 - clampf(center.distance_to(world_pos) / radius, 0.0, 1.0)
		height += float(hill.get("height_m", 0.0)) * hill_height_scale * t * t * (3.0 - 2.0 * t)
	for water_variant in _features.get("water", []):
		var water: Dictionary = water_variant
		var inside := _ellipse_weight(world_pos, water)
		if inside > 0.0:
			height = lerpf(height, water_height_m, inside)
	return height

func is_water_at(world_pos: Vector3) -> bool:
	for water_variant in _features.get("water", []):
		if _ellipse_contains(world_pos, water_variant):
			return true
	return false

func get_hill_markers() -> Array:
	return _features.get("hills", [])

func get_water_markers() -> Array:
	return _features.get("water", [])

func get_town_markers() -> Array:
	return _features.get("towns", [])

func world_point_for_lon_lat(lon: float, lat: float) -> Vector3:
	return _world_point(lon, lat)

func _rebuild_visuals() -> void:
	for child in get_children():
		child.queue_free()
	if show_hill_masses:
		_build_hill_meshes()
	_build_water_meshes()
	if show_town_labels:
		_build_town_labels()

func _build_hill_meshes() -> void:
	var root := Node3D.new()
	root.name = "HillMasses"
	add_child(root)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.37, 0.43, 0.29, 1.0)
	material.roughness = 0.96
	for hill_variant in _features.get("hills", []):
		var hill: Dictionary = hill_variant
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = String(hill.get("name", "Hill")).replace(" ", "_")
		var mesh := SphereMesh.new()
		mesh.radial_segments = 28
		mesh.rings = 14
		mesh.radius = 0.5
		mesh.height = 1.0
		mesh_instance.mesh = mesh
		mesh_instance.set_surface_override_material(0, material)
		var world_pos := _world_point(float(hill.get("lon", 0.0)), float(hill.get("lat", 0.0)))
		var radius_m := maxf(400.0, float(hill.get("radius_m", 1200.0)) * hill_visual_radius_scale)
		var height_m := maxf(4.0, float(hill.get("height_m", 8.0)) * hill_visual_height_scale)
		mesh_instance.scale = Vector3(radius_m * 1.8, height_m, radius_m * 1.8)
		mesh_instance.position = Vector3(world_pos.x, _rolling_height(world_pos) + height_m * 0.5 - 1.0, world_pos.z)
		root.add_child(mesh_instance)

func _build_water_meshes() -> void:
	var root := Node3D.new()
	root.name = "Hydrography"
	add_child(root)
	var material := _build_water_material()
	for water_variant in _features.get("water", []):
		var water: Dictionary = water_variant
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = String(water.get("name", "Water")).replace(" ", "_")
		var mesh := CylinderMesh.new()
		mesh.top_radius = 1.0
		mesh.bottom_radius = 1.0
		mesh.height = 0.12
		mesh.radial_segments = 48
		mesh_instance.mesh = mesh
		mesh_instance.set_surface_override_material(0, material)
		var world_pos := _world_point(float(water.get("lon", 0.0)), float(water.get("lat", 0.0)))
		mesh_instance.position = Vector3(world_pos.x, water_height_m + 0.06, world_pos.z)
		mesh_instance.scale = Vector3(
			float(water.get("radius_x_m", 1200.0)),
			1.0,
			float(water.get("radius_z_m", 900.0))
		)
		mesh_instance.rotation.y = deg_to_rad(float(water.get("rotation_deg", 0.0)))
		root.add_child(mesh_instance)

func _build_water_material() -> Material:
	var shader := load(WaterShaderPath) as Shader
	if shader != null:
		var material := ShaderMaterial.new()
		material.shader = shader
		material.set_shader_parameter("deep_color", Color(0.10, 0.29, 0.38, 1.0))
		material.set_shader_parameter("shallow_color", Color(0.38, 0.61, 0.69, 1.0))
		material.set_shader_parameter("foam_color", Color(0.82, 0.89, 0.92, 1.0))
		return material
	var fallback := StandardMaterial3D.new()
	fallback.albedo_color = Color(0.38, 0.58, 0.73, 0.78)
	fallback.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fallback.roughness = 0.14
	fallback.metallic = 0.02
	fallback.cull_mode = BaseMaterial3D.CULL_DISABLED
	return fallback

func _build_town_labels() -> void:
	var root := Node3D.new()
	root.name = "TownLabels"
	add_child(root)
	for town_variant in _features.get("towns", []):
		var town: Dictionary = town_variant
		var label := Label3D.new()
		label.name = "%sLabel" % String(town.get("name", "Town")).replace(" ", "_")
		label.text = String(town.get("name", ""))
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 42 if String(town.get("class", "town")) == "city" else 28
		label.modulate = Color(0.24, 0.19, 0.10, 0.84)
		label.outline_modulate = Color(0.96, 0.92, 0.86, 0.82)
		label.outline_size = 8
		var pos := _world_point(float(town.get("lon", 0.0)), float(town.get("lat", 0.0)))
		label.position = Vector3(pos.x, ground_height_at(pos) + label_height_m, pos.z)
		root.add_child(label)

func _rolling_height(world_pos: Vector3) -> float:
	var a := sin(world_pos.x * 0.000055) * rolling_height_m * 0.7
	var b := cos(world_pos.z * 0.000072) * rolling_height_m * 0.55
	var c := sin((world_pos.x - world_pos.z) * 0.000028) * rolling_height_m * 0.4
	return a + b + c

func _ellipse_contains(world_pos: Vector3, water_variant: Dictionary) -> bool:
	return _ellipse_distance(world_pos, water_variant) <= 1.0

func _ellipse_weight(world_pos: Vector3, water_variant: Dictionary) -> float:
	var d := _ellipse_distance(world_pos, water_variant)
	if d >= 1.0:
		return 0.0
	return 1.0 - d

func _ellipse_distance(world_pos: Vector3, water_variant: Dictionary) -> float:
	var center := _world_point(float(water_variant.get("lon", 0.0)), float(water_variant.get("lat", 0.0)))
	var delta := Vector2(world_pos.x - center.x, world_pos.z - center.z)
	var angle := deg_to_rad(float(water_variant.get("rotation_deg", 0.0)))
	var rotated := delta.rotated(-angle)
	var rx := maxf(1.0, float(water_variant.get("radius_x_m", 1.0)))
	var rz := maxf(1.0, float(water_variant.get("radius_z_m", 1.0)))
	return sqrt(pow(rotated.x / rx, 2.0) + pow(rotated.y / rz, 2.0))

func _world_point(lon: float, lat: float) -> Vector3:
	return GeoProjectorScript.lon_lat_to_world(lon, lat, _resolved_bounds, world_size_m)

func _load_features() -> Dictionary:
	var empty := {
		"water": [],
		"hills": [],
		"towns": []
	}
	var absolute_path := ProjectSettings.globalize_path(features_path)
	if not FileAccess.file_exists(absolute_path):
		return empty
	var file := FileAccess.open(absolute_path, FileAccess.READ)
	if file == null:
		return empty
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		for key in empty.keys():
			if parsed.has(key) and parsed[key] is Array:
				empty[key] = parsed[key]
	return empty

func _load_bounds() -> Dictionary:
	var resolved := {
		"min_lat": 41.2,
		"max_lat": 42.9,
		"min_lon": -73.6,
		"max_lon": -69.9
	}
	var raw_bounds: Variant = bounds
	if raw_bounds is Dictionary:
		for key in resolved.keys():
			if raw_bounds.has(key):
				resolved[key] = float(raw_bounds[key])
		return resolved
	var bounds_path := "res://data/ma_bounds.tres"
	if raw_bounds is Resource and String(raw_bounds.resource_path) != "":
		bounds_path = String(raw_bounds.resource_path)
	if not ResourceLoader.exists(bounds_path):
		return resolved
	var file := FileAccess.open(bounds_path, FileAccess.READ)
	if file == null:
		return resolved
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty() or line.begins_with("[") or not line.contains("="):
			continue
		var parts := line.split("=", false, 1)
		if parts.size() != 2:
			continue
		var key := parts[0].strip_edges()
		if not resolved.has(key):
			continue
		resolved[key] = float(parts[1].strip_edges())
	return resolved
