extends Node3D
class_name Route9Backdrop

const GeoProjectorScript := preload("res://scripts/geo/GeoProjector.gd")
const WaterShaderPath := "res://shaders/WaterSurface.gdshader"

@export var bounds: Resource
@export var world_size_m := Vector2(350000.0, 240000.0)
@export_file("*.json") var features_path := "res://data/route9_features.json"
@export var water_height_m := -2.4
@export var terrain_baseline_m := -0.35
@export var rolling_height_m := 0.72
@export var hill_height_scale := 0.34
@export var show_hill_masses := true
@export var hill_visual_radius_scale := 0.78
@export var hill_visual_height_scale := 0.62
@export var label_height_m := 9.0
@export var show_town_labels := true
@export var show_ridge_lines := true
@export var ridge_line_height_m := 1.8
@export var ridge_line_width_m := 180.0
@export var show_hydro_labels := true
@export var shoreline_blend_m := 900.0
@export var coastal_shoreline_blend_m := 1800.0
@export var riverbank_blend_m := 800.0
@export var elevation_compression_exponent := 0.68
@export var elevation_compression_scale := 0.35

var _features: Dictionary = {}
var _resolved_bounds := {}
var _cached_hills: Array[Dictionary] = []
var _cached_water_features: Array[Dictionary] = []
var _cached_towns: Array[Dictionary] = []
var _cached_elevation_points: Array[Dictionary] = []
var _cached_ridges: Array[Dictionary] = []

func _ready() -> void:
	if bounds == null and ResourceLoader.exists("res://data/ma_bounds.tres"):
		bounds = load("res://data/ma_bounds.tres")
	_resolved_bounds = _load_bounds()
	_features = _load_features()
	_prepare_feature_cache()
	_rebuild_visuals()

func ground_height_at(world_pos: Vector3) -> float:
	var height := terrain_baseline_m + _rolling_height(world_pos)
	var xz := Vector2(world_pos.x, world_pos.z)
	for point_variant in _cached_elevation_points:
		var point_height := _height_from_elevation_point(xz, point_variant)
		if point_height > height:
			height = point_height
	for ridge_variant in _cached_ridges:
		var ridge_height := _height_from_ridge(xz, ridge_variant)
		if ridge_height > height:
			height = ridge_height
	var context := terrain_context_at(world_pos)
	var shore_factor := float(context.get("shore_factor", 0.0))
	var river_factor := float(context.get("river_factor", 0.0))
	var water_factor := float(context.get("water_factor", 0.0))
	var surface_height := float(context.get("surface_height", water_height_m))
	if shore_factor > 0.0:
		var bank_target: float = minf(height, surface_height + lerpf(0.42, 1.10, 1.0 - river_factor))
		height = lerpf(height, bank_target, shore_factor * 0.82)
	if water_factor > 0.0:
		height = lerpf(height, surface_height, water_factor)
	return height

func terrain_context_at(world_pos: Vector3) -> Dictionary:
	var xz := Vector2(world_pos.x, world_pos.z)
	var context := {
		"water_factor": 0.0,
		"shore_factor": 0.0,
		"river_factor": 0.0,
		"coast_factor": 0.0,
		"surface_height": water_height_m,
		"distance_m": INF
	}
	for water_variant in _cached_water_features:
		var sample := _sample_water_feature(xz, water_variant)
		var distance_m := float(sample.get("distance_m", INF))
		if distance_m < float(context["distance_m"]):
			context["distance_m"] = distance_m
			context["surface_height"] = float(sample.get("surface_height", water_height_m))
		context["water_factor"] = maxf(float(context["water_factor"]), float(sample.get("water_factor", 0.0)))
		context["shore_factor"] = maxf(float(context["shore_factor"]), float(sample.get("shore_factor", 0.0)))
		context["river_factor"] = maxf(float(context["river_factor"]), float(sample.get("river_factor", 0.0)))
		context["coast_factor"] = maxf(float(context["coast_factor"]), float(sample.get("coast_factor", 0.0)))
	if float(context["distance_m"]) == INF:
		context["distance_m"] = 999999.0
	return context

func is_water_at(world_pos: Vector3) -> bool:
	return float(terrain_context_at(world_pos).get("water_factor", 0.0)) >= 0.99

func get_hill_markers() -> Array:
	return _cached_hills.duplicate(true)

func get_water_markers() -> Array:
	return _cached_water_features.duplicate(true)

func get_town_markers() -> Array:
	return _cached_towns.duplicate(true)

func get_ridge_markers() -> Array:
	return _cached_ridges.duplicate(true)

func world_point_for_lon_lat(lon: float, lat: float) -> Vector3:
	return _world_point(lon, lat)

func _rebuild_visuals() -> void:
	for child in get_children():
		child.queue_free()
	if show_hill_masses:
		_build_hill_meshes()
	if show_ridge_lines:
		_build_ridge_lines()
	_build_water_meshes()
	if show_hydro_labels:
		_build_hydro_labels()
	if show_town_labels:
		_build_town_labels()

func _prepare_feature_cache() -> void:
	_cached_hills.clear()
	_cached_water_features.clear()
	_cached_towns.clear()
	_cached_elevation_points.clear()
	_cached_ridges.clear()
	for point_variant in _features.get("elevation_points", []):
		if not (point_variant is Dictionary):
			continue
		var raw_point: Dictionary = point_variant
		var point: Dictionary = raw_point.duplicate(true)
		point["world_pos"] = _world_point(float(point.get("lon", 0.0)), float(point.get("lat", 0.0)))
		point["visual_height_m"] = _compress_elevation_m(float(point.get("elevation_m", 0.0)))
		_cached_elevation_points.append(point)
	for ridge_variant in _features.get("ridges", []):
		if not (ridge_variant is Dictionary):
			continue
		var raw_ridge: Dictionary = ridge_variant
		var ridge: Dictionary = raw_ridge.duplicate(true)
		var ridge_points := _packed_world_points_2d(ridge.get("points", []))
		if ridge_points.size() < 2:
			continue
		ridge["world_points_xz"] = ridge_points
		ridge["visual_peak_m"] = _compress_elevation_m(float(ridge.get("peak_elevation_m", 0.0)))
		ridge["world_pos"] = _centroid_for_points(ridge_points)
		_cached_ridges.append(ridge)
	for hill_variant in _features.get("hills", []):
		if not (hill_variant is Dictionary):
			continue
		var raw_hill: Dictionary = hill_variant
		var hill: Dictionary = raw_hill.duplicate(true)
		hill["world_pos"] = _world_point(float(hill.get("lon", 0.0)), float(hill.get("lat", 0.0)))
		_cached_hills.append(hill)
	for water_variant in _features.get("water", []):
		if water_variant is Dictionary:
			var cached_water := _cache_water_feature(water_variant)
			if not cached_water.is_empty():
				_cached_water_features.append(cached_water)
	for river_variant in _features.get("rivers", []):
		if river_variant is Dictionary:
			var cached_river := _cache_water_feature(river_variant)
			if not cached_river.is_empty():
				_cached_water_features.append(cached_river)
	for town_variant in _features.get("towns", []):
		if not (town_variant is Dictionary):
			continue
		var raw_town: Dictionary = town_variant
		var town: Dictionary = raw_town.duplicate(true)
		town["world_pos"] = _world_point(float(town.get("lon", 0.0)), float(town.get("lat", 0.0)))
		_cached_towns.append(town)

func _cache_water_feature(raw_feature: Dictionary) -> Dictionary:
	var cached := raw_feature.duplicate(true)
	var shape := String(cached.get("shape", "ellipse"))
	cached["shape"] = shape
	cached["surface_height"] = _compress_elevation_m(float(cached.get("surface_elevation_m", 0.0)))
	match shape:
		"river":
			var river_points := _packed_world_points_2d(cached.get("points", []))
			if river_points.size() < 2:
				return {}
			cached["world_points_xz"] = river_points
			cached["world_pos"] = _centroid_for_points(river_points)
			cached["path_length_m"] = _polyline_length(river_points)
		"polygon":
			var polygon_points := _packed_world_points_2d(cached.get("points", []))
			if polygon_points.size() < 3:
				return {}
			cached["world_polygon_xz"] = polygon_points
			cached["world_pos"] = _centroid_for_points(polygon_points)
		_:
			var world_pos := _world_point(float(cached.get("lon", 0.0)), float(cached.get("lat", 0.0)))
			cached["world_pos"] = world_pos
			cached["world_polygon_xz"] = _ellipse_polygon(
				Vector2(world_pos.x, world_pos.z),
				float(cached.get("radius_x_m", 800.0)),
				float(cached.get("radius_z_m", 600.0)),
				deg_to_rad(float(cached.get("rotation_deg", 0.0))),
				40
			)
	return cached

func _build_hill_meshes() -> void:
	var root := Node3D.new()
	root.name = "HillMasses"
	add_child(root)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.33, 0.39, 0.26, 1.0)
	material.roughness = 0.95
	for hill_variant in _cached_hills:
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = String(hill_variant.get("name", "Hill")).replace(" ", "_")
		var mesh := SphereMesh.new()
		mesh.radial_segments = 28
		mesh.rings = 14
		mesh.radius = 0.5
		mesh.height = 1.0
		mesh_instance.mesh = mesh
		mesh_instance.set_surface_override_material(0, material)
		var world_pos: Vector3 = hill_variant.get("world_pos", Vector3.ZERO)
		var radius_m := maxf(450.0, float(hill_variant.get("radius_m", 1200.0)) * hill_visual_radius_scale)
		var height_m := maxf(5.0, float(hill_variant.get("height_m", 8.0)) * hill_visual_height_scale)
		mesh_instance.scale = Vector3(radius_m * 1.8, height_m, radius_m * 1.8)
		mesh_instance.position = Vector3(world_pos.x, ground_height_at(world_pos) + height_m * 0.5 - 1.0, world_pos.z)
		root.add_child(mesh_instance)

func _build_water_meshes() -> void:
	var root := Node3D.new()
	root.name = "Hydrography"
	add_child(root)
	for water_variant in _cached_water_features:
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = String(water_variant.get("name", "Water")).replace(" ", "_")
		mesh_instance.mesh = _build_water_mesh(water_variant)
		if mesh_instance.mesh == null:
			continue
		mesh_instance.material_override = _build_water_material(water_variant)
		root.add_child(mesh_instance)

func _build_ridge_lines() -> void:
	var root := Node3D.new()
	root.name = "Ridgelines"
	add_child(root)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.35, 0.37, 0.32, 1.0)
	material.roughness = 0.94
	material.metallic = 0.02
	for ridge_variant in _cached_ridges:
		var ridge_points: PackedVector2Array = ridge_variant.get("world_points_xz", PackedVector2Array())
		if ridge_points.size() < 2:
			continue
		var ridge_name := String(ridge_variant.get("name", "Ridge")).replace(" ", "_")
		for i in range(ridge_points.size() - 1):
			var a2 := ridge_points[i]
			var b2 := ridge_points[i + 1]
			var a := Vector3(a2.x, 0.0, a2.y)
			var b := Vector3(b2.x, 0.0, b2.y)
			var length_m := a.distance_to(b)
			if length_m < 2.0:
				continue
			var mid := a.lerp(b, 0.5)
			var segment := MeshInstance3D.new()
			segment.name = "%s_%d" % [ridge_name, i]
			var mesh := BoxMesh.new()
			mesh.size = Vector3(
				maxf(60.0, ridge_line_width_m * clampf(float(ridge_variant.get("width_m", 6000.0)) / 10000.0, 0.7, 1.4)),
				ridge_line_height_m,
				length_m
			)
			segment.mesh = mesh
			segment.set_surface_override_material(0, material)
			var forward := (b - a).normalized()
			var y := ground_height_at(mid) + ridge_line_height_m * 0.5 + 0.25
			segment.position = Vector3(mid.x, y, mid.z)
			segment.basis = _basis_from_forward(forward)
			root.add_child(segment)

func _build_hydro_labels() -> void:
	var root := Node3D.new()
	root.name = "HydroLabels"
	add_child(root)
	for water_variant in _cached_water_features:
		var water_type := String(water_variant.get("type", ""))
		if water_type == "" or water_type == "lagoon":
			continue
		var label := Label3D.new()
		label.name = "%sLabel" % String(water_variant.get("name", "Water")).replace(" ", "_")
		label.text = String(water_variant.get("name", ""))
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 28 if water_type in ["harbor", "bay", "tidal_river"] else 22
		label.modulate = Color(0.18, 0.32, 0.42, 0.80)
		label.outline_modulate = Color(0.90, 0.96, 0.99, 0.66)
		label.outline_size = 6
		var pos: Vector3 = water_variant.get("world_pos", Vector3.ZERO)
		var surface_height := float(water_variant.get("surface_height", water_height_m))
		label.position = Vector3(pos.x, maxf(surface_height + 0.6, ground_height_at(pos) + 0.8), pos.z)
		root.add_child(label)

func _build_water_mesh(water_variant: Dictionary) -> Mesh:
	var shape := String(water_variant.get("shape", "ellipse"))
	match shape:
		"river":
			return _build_river_mesh(water_variant)
		"polygon":
			return _build_polygon_water_mesh(water_variant.get("world_polygon_xz", PackedVector2Array()), float(water_variant.get("surface_height", water_height_m)))
		_:
			return _build_polygon_water_mesh(water_variant.get("world_polygon_xz", PackedVector2Array()), float(water_variant.get("surface_height", water_height_m)))

func _build_polygon_water_mesh(points: PackedVector2Array, surface_height: float) -> Mesh:
	if points.size() < 3:
		return null
	var indices := Geometry2D.triangulate_polygon(points)
	if indices.is_empty():
		return null
	var rect := _points_rect(points)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index_variant in indices:
		var point := points[int(index_variant)]
		var uv := Vector2(
			inverse_lerp(rect.position.x, rect.position.x + rect.size.x, point.x) if rect.size.x > 0.001 else 0.5,
			inverse_lerp(rect.position.y, rect.position.y + rect.size.y, point.y) if rect.size.y > 0.001 else 0.5
		)
		_emit_water_vertex(st, point, surface_height + 0.04, uv)
	return st.commit()

func _build_river_mesh(water_variant: Dictionary) -> Mesh:
	var points: PackedVector2Array = water_variant.get("world_points_xz", PackedVector2Array())
	if points.size() < 2:
		return null
	var width_m := maxf(40.0, float(water_variant.get("width_m", 160.0)))
	var surface_height := float(water_variant.get("surface_height", water_height_m))
	var left_bank := PackedVector2Array()
	var right_bank := PackedVector2Array()
	var cumulative_lengths := PackedFloat32Array()
	var total_length := maxf(1.0, _polyline_length(points))
	var running_length := 0.0
	for i in range(points.size()):
		if i > 0:
			running_length += points[i - 1].distance_to(points[i])
		cumulative_lengths.append(running_length)
		var tangent := _polyline_tangent(points, i)
		var normal := Vector2(-tangent.y, tangent.x)
		left_bank.append(points[i] - normal * width_m * 0.5)
		right_bank.append(points[i] + normal * width_m * 0.5)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(points.size() - 1):
		var u0 := cumulative_lengths[i] / total_length
		var u1 := cumulative_lengths[i + 1] / total_length
		_emit_water_vertex(st, left_bank[i], surface_height + 0.03, Vector2(u0, 0.0))
		_emit_water_vertex(st, right_bank[i], surface_height + 0.03, Vector2(u0, 1.0))
		_emit_water_vertex(st, right_bank[i + 1], surface_height + 0.03, Vector2(u1, 1.0))
		_emit_water_vertex(st, left_bank[i], surface_height + 0.03, Vector2(u0, 0.0))
		_emit_water_vertex(st, right_bank[i + 1], surface_height + 0.03, Vector2(u1, 1.0))
		_emit_water_vertex(st, left_bank[i + 1], surface_height + 0.03, Vector2(u1, 0.0))
	return st.commit()

func _emit_water_vertex(st: SurfaceTool, point: Vector2, y: float, uv: Vector2) -> void:
	st.set_uv(uv)
	st.add_vertex(Vector3(point.x, y, point.y))

func _build_water_material(water_variant: Dictionary) -> Material:
	var shader := load(WaterShaderPath) as Shader
	var shape := String(water_variant.get("shape", "ellipse"))
	var water_type := String(water_variant.get("type", "lake"))
	var coastal := water_type == "harbor" or water_type == "bay" or water_type == "coastal_inlet" or water_type == "tidal_river"
	if shader != null:
		var material := ShaderMaterial.new()
		material.shader = shader
		material.set_shader_parameter("deep_color", Color(0.08, 0.26, 0.34, 1.0) if coastal else Color(0.11, 0.31, 0.39, 1.0))
		material.set_shader_parameter("shallow_color", Color(0.40, 0.63, 0.71, 1.0) if coastal else Color(0.32, 0.57, 0.63, 1.0))
		material.set_shader_parameter("foam_color", Color(0.83, 0.89, 0.92, 1.0))
		material.set_shader_parameter("shoreline_color", Color(0.59, 0.67, 0.63, 1.0) if coastal else Color(0.52, 0.60, 0.54, 1.0))
		material.set_shader_parameter("shoreline_foam", 0.30 if coastal else 0.22)
		material.set_shader_parameter("normal_strength", 0.48 if shape == "river" else 0.42)
		material.set_shader_parameter("channel_mode", 1.0 if shape == "river" else 0.0)
		material.set_shader_parameter("flow_speed_scale", 1.1 if shape == "river" else 0.24)
		material.set_shader_parameter("wave_scale", 0.16 if shape == "river" else 0.06)
		material.set_shader_parameter("foam_strength", 0.14 if coastal else (0.18 if shape == "river" else 0.08))
		material.set_shader_parameter("water_opacity", 0.82 if coastal else (0.74 if shape == "river" else 0.78))
		material.set_shader_parameter("absorption_strength", 1.06 if coastal else (0.84 if shape == "river" else 1.22))
		material.set_shader_parameter("reflection_strength", 1.0 if coastal else (0.78 if shape == "river" else 0.92))
		material.set_shader_parameter("micro_ripple_strength", 0.22 if coastal else (0.12 if shape == "river" else 0.18))
		material.set_shader_parameter("micro_ripple_scale", 2.6 if coastal else (2.1 if shape == "river" else 1.7))
		material.set_shader_parameter("wave_height", 0.15 if coastal else (0.07 if shape == "river" else 0.11))
		material.set_shader_parameter("silt_tint_strength", 0.18 if shape == "river" else 0.14)
		return material
	var fallback := StandardMaterial3D.new()
	fallback.albedo_color = Color(0.36, 0.57, 0.70, 0.82)
	fallback.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fallback.roughness = 0.14
	fallback.metallic = 0.02
	fallback.cull_mode = BaseMaterial3D.CULL_DISABLED
	return fallback

func _build_town_labels() -> void:
	var root := Node3D.new()
	root.name = "TownLabels"
	add_child(root)
	for town_variant in _cached_towns:
		var label := Label3D.new()
		label.name = "%sLabel" % String(town_variant.get("name", "Town")).replace(" ", "_")
		label.text = String(town_variant.get("name", ""))
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 42 if String(town_variant.get("class", "town")) == "city" else 28
		label.modulate = Color(0.24, 0.19, 0.10, 0.84)
		label.outline_modulate = Color(0.96, 0.92, 0.86, 0.82)
		label.outline_size = 8
		var pos: Vector3 = town_variant.get("world_pos", Vector3.ZERO)
		label.position = Vector3(pos.x, ground_height_at(pos) + label_height_m, pos.z)
		root.add_child(label)

func _height_from_elevation_point(world_xz: Vector2, point_variant: Dictionary) -> float:
	var world_pos: Vector3 = point_variant.get("world_pos", Vector3.ZERO)
	var radius_m := maxf(1.0, float(point_variant.get("radius_m", 1.0)))
	var distance_m := world_xz.distance_to(Vector2(world_pos.x, world_pos.z))
	if distance_m >= radius_m:
		return -INF
	var t := 1.0 - clampf(distance_m / radius_m, 0.0, 1.0)
	return lerpf(terrain_baseline_m, float(point_variant.get("visual_height_m", terrain_baseline_m)), _smooth_peak(t))

func _height_from_ridge(world_xz: Vector2, ridge_variant: Dictionary) -> float:
	var world_points: PackedVector2Array = ridge_variant.get("world_points_xz", PackedVector2Array())
	if world_points.size() < 2:
		return -INF
	var width_m := maxf(1.0, float(ridge_variant.get("width_m", 1.0)))
	var distance_m := _distance_to_polyline_2d(world_xz, world_points)
	if distance_m >= width_m:
		return -INF
	var t := 1.0 - clampf(distance_m / width_m, 0.0, 1.0)
	return lerpf(terrain_baseline_m, float(ridge_variant.get("visual_peak_m", terrain_baseline_m)), _smooth_peak(t))

func _sample_water_feature(world_xz: Vector2, water_variant: Dictionary) -> Dictionary:
	var sample := {
		"distance_m": INF,
		"surface_height": float(water_variant.get("surface_height", water_height_m)),
		"water_factor": 0.0,
		"shore_factor": 0.0,
		"river_factor": 0.0,
		"coast_factor": 0.0
	}
	var shape := String(water_variant.get("shape", "ellipse"))
	var water_type := String(water_variant.get("type", "lake"))
	var coastal := water_type == "harbor" or water_type == "bay" or water_type == "coastal_inlet" or water_type == "tidal_river"
	match shape:
		"river":
			var path: PackedVector2Array = water_variant.get("world_points_xz", PackedVector2Array())
			if path.size() < 2:
				return sample
			var half_width := maxf(10.0, float(water_variant.get("width_m", 160.0)) * 0.5)
			var bank_width := maxf(60.0, float(water_variant.get("bank_width_m", riverbank_blend_m)))
			var center_distance := _distance_to_polyline_2d(world_xz, path)
			var edge_distance := maxf(0.0, center_distance - half_width)
			sample["distance_m"] = edge_distance
			if center_distance <= half_width:
				sample["water_factor"] = 1.0
			sample["shore_factor"] = 1.0 - clampf(edge_distance / bank_width, 0.0, 1.0)
			sample["river_factor"] = 1.0 - clampf(edge_distance / maxf(bank_width * 0.75, 1.0), 0.0, 1.0)
			sample["coast_factor"] = sample["shore_factor"] if coastal else 0.0
		"polygon":
			var polygon: PackedVector2Array = water_variant.get("world_polygon_xz", PackedVector2Array())
			if polygon.size() < 3:
				return sample
			var inside := Geometry2D.is_point_in_polygon(world_xz, polygon)
			var edge_distance := 0.0 if inside else _distance_to_polygon_edge_2d(world_xz, polygon)
			var blend_m := coastal_shoreline_blend_m if coastal else shoreline_blend_m
			sample["distance_m"] = edge_distance
			sample["water_factor"] = 1.0 if inside else 0.0
			sample["shore_factor"] = 1.0 if inside else 1.0 - clampf(edge_distance / blend_m, 0.0, 1.0)
			sample["coast_factor"] = sample["shore_factor"] if coastal else 0.0
		_:
			var center: Vector3 = water_variant.get("world_pos", Vector3.ZERO)
			var rotation_rad := deg_to_rad(float(water_variant.get("rotation_deg", 0.0)))
			var rx := maxf(1.0, float(water_variant.get("radius_x_m", 1.0)))
			var rz := maxf(1.0, float(water_variant.get("radius_z_m", 1.0)))
			var delta := Vector2(world_xz.x - center.x, world_xz.y - center.z).rotated(-rotation_rad)
			var norm := sqrt(pow(delta.x / rx, 2.0) + pow(delta.y / rz, 2.0))
			var average_radius := (rx + rz) * 0.5
			var edge_distance := maxf(0.0, (norm - 1.0) * average_radius)
			sample["distance_m"] = edge_distance
			sample["water_factor"] = 1.0 if norm <= 1.0 else 0.0
			sample["shore_factor"] = 1.0 if norm <= 1.0 else 1.0 - clampf(edge_distance / shoreline_blend_m, 0.0, 1.0)
			sample["coast_factor"] = sample["shore_factor"] if coastal else 0.0
	return sample

func _rolling_height(world_pos: Vector3) -> float:
	var a := sin(world_pos.x * 0.000048) * rolling_height_m * 0.52
	var b := cos(world_pos.z * 0.000064) * rolling_height_m * 0.38
	var c := sin((world_pos.x - world_pos.z) * 0.000026) * rolling_height_m * 0.24
	return a + b + c

func _compress_elevation_m(elevation_m: float) -> float:
	if elevation_m <= 0.0:
		return water_height_m + elevation_m * 0.1
	return water_height_m + pow(elevation_m, elevation_compression_exponent) * elevation_compression_scale

func _smooth_peak(t: float) -> float:
	var clamped := clampf(t, 0.0, 1.0)
	return clamped * clamped * (3.0 - 2.0 * clamped)

func _world_point(lon: float, lat: float) -> Vector3:
	return GeoProjectorScript.lon_lat_to_world(lon, lat, _resolved_bounds, world_size_m)

func _packed_world_points_2d(raw_points: Variant) -> PackedVector2Array:
	var result := PackedVector2Array()
	if not (raw_points is Array):
		return result
	for point_variant in raw_points:
		if not (point_variant is Dictionary):
			continue
		var point_dict: Dictionary = point_variant
		var world_pos := _world_point(float(point_dict.get("lon", 0.0)), float(point_dict.get("lat", 0.0)))
		result.append(Vector2(world_pos.x, world_pos.z))
	return result

func _centroid_for_points(points: PackedVector2Array) -> Vector3:
	if points.is_empty():
		return Vector3.ZERO
	var sum := Vector2.ZERO
	for point in points:
		sum += point
	var center := sum / float(points.size())
	return Vector3(center.x, 0.0, center.y)

func _ellipse_polygon(center: Vector2, radius_x: float, radius_z: float, rotation_rad: float, steps: int) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	var clamped_steps: int = maxi(12, steps)
	for i in range(clamped_steps):
		var angle := TAU * float(i) / float(clamped_steps)
		var local := Vector2(cos(angle) * radius_x, sin(angle) * radius_z).rotated(rotation_rad)
		polygon.append(center + local)
	return polygon

func _points_rect(points: PackedVector2Array) -> Rect2:
	if points.is_empty():
		return Rect2()
	var min_point := points[0]
	var max_point := points[0]
	for point in points:
		min_point.x = minf(min_point.x, point.x)
		min_point.y = minf(min_point.y, point.y)
		max_point.x = maxf(max_point.x, point.x)
		max_point.y = maxf(max_point.y, point.y)
	return Rect2(min_point, max_point - min_point)

func _polyline_tangent(points: PackedVector2Array, index: int) -> Vector2:
	if points.size() == 1:
		return Vector2.RIGHT
	if index <= 0:
		return (points[1] - points[0]).normalized()
	if index >= points.size() - 1:
		return (points[index] - points[index - 1]).normalized()
	var incoming := (points[index] - points[index - 1]).normalized()
	var outgoing := (points[index + 1] - points[index]).normalized()
	var tangent := (incoming + outgoing).normalized()
	return tangent if tangent.length() > 0.001 else outgoing

func _polyline_length(points: PackedVector2Array) -> float:
	var length_m := 0.0
	for i in range(points.size() - 1):
		length_m += points[i].distance_to(points[i + 1])
	return length_m

func _distance_to_polyline_2d(point: Vector2, polyline: PackedVector2Array) -> float:
	if polyline.size() == 0:
		return INF
	if polyline.size() == 1:
		return point.distance_to(polyline[0])
	var min_distance := INF
	for i in range(polyline.size() - 1):
		min_distance = minf(min_distance, _distance_to_segment_2d(point, polyline[i], polyline[i + 1]))
	return min_distance

func _distance_to_polygon_edge_2d(point: Vector2, polygon: PackedVector2Array) -> float:
	if polygon.size() < 2:
		return INF
	var min_distance := INF
	for i in range(polygon.size()):
		var a := polygon[i]
		var b := polygon[(i + 1) % polygon.size()]
		min_distance = minf(min_distance, _distance_to_segment_2d(point, a, b))
	return min_distance

func _distance_to_segment_2d(point: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var ab_length_sq := ab.length_squared()
	if ab_length_sq <= 0.000001:
		return point.distance_to(a)
	var t := clampf((point - a).dot(ab) / ab_length_sq, 0.0, 1.0)
	return point.distance_to(a + ab * t)

func _basis_from_forward(forward: Vector3) -> Basis:
	var z_axis := forward.normalized()
	if z_axis.length() < 0.01:
		z_axis = Vector3.FORWARD
	var x_axis := Vector3.UP.cross(z_axis).normalized()
	if x_axis.length() < 0.01:
		x_axis = Vector3.RIGHT
	var y_axis := z_axis.cross(x_axis).normalized()
	return Basis(x_axis, y_axis, z_axis).orthonormalized()

func _load_features() -> Dictionary:
	var empty := _empty_features()
	var absolute_path := ProjectSettings.globalize_path(features_path)
	if not FileAccess.file_exists(absolute_path):
		return empty
	var file := FileAccess.open(absolute_path, FileAccess.READ)
	if file == null:
		return empty
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		for key in empty.keys():
			if parsed.has(key):
				var value: Variant = parsed[key]
				if (value is Array) or (value is Dictionary):
					empty[key] = value
	return empty

func _empty_features() -> Dictionary:
	return {
		"terrain_meta": {},
		"water": [],
		"rivers": [],
		"elevation_points": [],
		"ridges": [],
		"hills": [],
		"towns": []
	}

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
