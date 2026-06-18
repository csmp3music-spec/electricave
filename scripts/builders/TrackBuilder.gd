extends Node3D
class_name TrackBuilder

const TrackBlendShader := preload("res://shaders/TrackBlend.gdshader")
const BallastAlbedoPath := "res://assets/textures/track_materials/clean_pebbles/clean_pebbles_diff_1k.jpg"
const BallastRoughnessPath := "res://assets/textures/track_materials/clean_pebbles/clean_pebbles_rough_1k.jpg"
const BallastNormalPath := "res://assets/textures/track_materials/clean_pebbles/clean_pebbles_nor_gl_1k.jpg"
const SleeperAlbedoPath := "res://assets/textures/track_materials/weathered_planks/weathered_planks_diff_1k.jpg"
const SleeperRoughnessPath := "res://assets/textures/track_materials/weathered_planks/weathered_planks_rough_1k.jpg"
const SleeperNormalPath := "res://assets/textures/track_materials/weathered_planks/weathered_planks_nor_gl_1k.jpg"
const RailAlbedoPath := "res://assets/textures/track_materials/metal_plate_02/metal_plate_02_diff_1k.jpg"
const RailRoughnessPath := "res://assets/textures/track_materials/metal_plate_02/metal_plate_02_rough_1k.jpg"
const RailNormalPath := "res://assets/textures/track_materials/metal_plate_02/metal_plate_02_nor_gl_1k.jpg"

signal segment_added(curve: Curve3D)
signal segment_removed(curve: Curve3D)

@export var weather_path: NodePath = NodePath("../Weather")
@export var max_grade := 0.06
@export var max_curve_deg := 25.0
@export var snap_spacing := 5.0
@export var render_segments := false
@export var track_width := 3.4
@export var track_height := 0.25
@export var roadbed_width := 7.8
@export var roadbed_height := 0.78
@export var roadbed_embed_depth := 0.24
@export var ballast_width := 4.6
@export var ballast_height := 0.28
@export var sleeper_width := 4.15
@export var sleeper_height := 0.14
@export var sleeper_length := 0.24
@export var sleeper_spacing := 1.35
@export var rail_center_offset_m := 0.78
@export var rail_width := 0.12
@export var rail_height := 0.2
@export var rail_joint_spacing := 11.8
@export var rail_joint_width := 0.18
@export var ballast_grime_spacing := 18.0
@export var ballast_grime_width := 1.15
@export var track_color := Color("4a4a4a")
@export var roadbed_color := Color("6b5d4d")

var segments: Array[Curve3D] = []
var _render_nodes: Array[Node3D] = []
var _roadbed_material: StandardMaterial3D
var _ballast_material: StandardMaterial3D
var _sleeper_material: StandardMaterial3D
var _rail_material: StandardMaterial3D
var _rail_joint_material: StandardMaterial3D
var _ballast_grime_material: StandardMaterial3D
var _weather_controller: Node
var _weather_payload := {}
var _surface_snow_override := -1.0
var _surface_wet_override := -1.0

func _ready() -> void:
	_weather_controller = _resolve_weather_controller()
	if _weather_controller != null and _weather_controller.has_signal("weather_changed"):
		_weather_controller.connect("weather_changed", Callable(self, "_on_weather_changed"))
	if _weather_controller != null and _weather_controller.has_method("get_weather_payload"):
		_weather_payload = _weather_controller.call("get_weather_payload")
	_apply_weather_material_state()

func can_place_segment(points: PackedVector3Array) -> bool:
	if points.size() < 2:
		return false
	for i in range(points.size() - 1):
		var a: Vector3 = points[i]
		var b: Vector3 = points[i + 1]
		var horizontal: float = Vector2(b.x - a.x, b.z - a.z).length()
		var vertical: float = absf(b.y - a.y)
		if horizontal <= 0.01:
			return false
		var grade: float = vertical / horizontal
		if grade > max_grade:
			return false
	return true

func add_segment(points: PackedVector3Array) -> Curve3D:
	if not can_place_segment(points):
		return null
	var curve: Curve3D = Curve3D.new()
	for p in points:
		curve.add_point(p)
	segments.append(curve)
	emit_signal("segment_added", curve)
	if render_segments:
		_render_curve(curve)
	return curve

func snap_point(world_pos: Vector3, spacing: float = -1.0) -> Vector3:
	var step := snap_spacing if spacing <= 0.0 else spacing
	if step <= 0.0:
		return world_pos
	return Vector3(
		snappedf(world_pos.x, step),
		world_pos.y,
		snappedf(world_pos.z, step)
	)

func get_segment_endpoints() -> PackedVector3Array:
	var endpoints := PackedVector3Array()
	for curve in segments:
		if curve == null or curve.point_count < 1:
			continue
		endpoints.append(curve.get_point_position(0))
		if curve.point_count > 1:
			endpoints.append(curve.get_point_position(curve.point_count - 1))
	return endpoints

func get_closest_endpoint(world_pos: Vector3, max_distance: float = INF) -> Dictionary:
	var best := {}
	var best_distance := max_distance
	for point in get_segment_endpoints():
		var distance := point.distance_to(world_pos)
		if distance <= best_distance:
			best_distance = distance
			best = {
				"position": point,
				"distance": distance
			}
	return best

func get_closest_track_point(world_pos: Vector3, max_distance: float = INF) -> Dictionary:
	var best := {}
	var best_distance := max_distance
	for curve in segments:
		if curve == null or curve.point_count < 2:
			continue
		var offset := float(curve.get_closest_offset(world_pos))
		var point := curve.sample_baked(offset)
		var distance := point.distance_to(world_pos)
		if distance > best_distance:
			continue
		var tangent := _curve_tangent_at_offset(curve, offset)
		best_distance = distance
		best = {
			"position": point,
			"distance": distance,
			"direction": tangent,
			"offset": offset,
			"curve": curve
		}
	return best

func get_distance_to_network(world_pos: Vector3) -> float:
	var closest := get_closest_track_point(world_pos, INF)
	if closest.has("distance"):
		return float(closest.get("distance", INF))
	return INF

func get_total_track_length() -> float:
	var total := 0.0
	for curve in segments:
		if curve == null or curve.point_count < 2:
			continue
		total += float(curve.get_baked_length())
	return total

func clear_network() -> void:
	_clear_render_nodes()
	segments.clear()

func remove_segment_near(world_pos: Vector3, max_distance: float = 24.0) -> Dictionary:
	if segments.is_empty():
		return {}
	var best_index := -1
	var best_distance := max_distance
	for i in range(segments.size()):
		var curve := segments[i]
		if curve == null or curve.point_count < 2:
			continue
		var closest := curve.get_closest_point(world_pos)
		var distance := closest.distance_to(world_pos)
		if distance <= best_distance:
			best_distance = distance
			best_index = i
	if best_index < 0:
		return {}
	var removed: Curve3D = segments[best_index]
	segments.remove_at(best_index)
	if render_segments:
		_rebuild_render_nodes()
	emit_signal("segment_removed", removed)
	return {
		"curve": removed,
		"length": float(removed.get_baked_length()),
		"distance": best_distance
	}

func _render_curve(curve: Curve3D) -> void:
	for i in range(curve.point_count - 1):
		var a: Vector3 = curve.get_point_position(i)
		var b: Vector3 = curve.get_point_position(i + 1)
		var length := a.distance_to(b)
		if length < 0.5:
			continue
		var segment_root := Node3D.new()
		segment_root.global_transform = _segment_transform(a, b)
		add_child(segment_root)

		var roadbed_mesh := BoxMesh.new()
		roadbed_mesh.size = Vector3(roadbed_width, roadbed_height, length)
		var roadbed_instance := MeshInstance3D.new()
		roadbed_instance.mesh = roadbed_mesh
		roadbed_instance.set_surface_override_material(0, _ensure_roadbed_material())
		roadbed_instance.position.y = roadbed_height * 0.5 - roadbed_embed_depth
		segment_root.add_child(roadbed_instance)

		var ballast_mesh := BoxMesh.new()
		ballast_mesh.size = Vector3(ballast_width, ballast_height, length)
		var ballast_instance := MeshInstance3D.new()
		ballast_instance.mesh = ballast_mesh
		ballast_instance.set_surface_override_material(0, _ensure_ballast_material())
		ballast_instance.position.y = roadbed_height - roadbed_embed_depth + ballast_height * 0.42
		segment_root.add_child(ballast_instance)

		_add_sleepers(segment_root, length)

		for rail_side in [-1.0, 1.0]:
			var rail_mesh := BoxMesh.new()
			rail_mesh.size = Vector3(rail_width, rail_height, length)
			var rail_instance := MeshInstance3D.new()
			rail_instance.mesh = rail_mesh
			rail_instance.set_surface_override_material(0, _ensure_rail_material())
			rail_instance.position = Vector3(rail_side * rail_center_offset_m, roadbed_height - roadbed_embed_depth + ballast_height + rail_height * 0.44, 0.0)
			segment_root.add_child(rail_instance)

		_add_track_surface_details(segment_root, length, _segment_detail_seed(a, b))
		_render_nodes.append(segment_root)

func _add_sleepers(segment_root: Node3D, length: float) -> void:
	if segment_root == null or length < 0.5:
		return
	var sleeper_count := maxi(1, int(floor(length / maxf(0.8, sleeper_spacing))))
	var sleeper_mesh := BoxMesh.new()
	sleeper_mesh.size = Vector3(sleeper_width, sleeper_height, sleeper_length)
	sleeper_mesh.material = _ensure_sleeper_material()
	var sleeper_multimesh := MultiMesh.new()
	sleeper_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	sleeper_multimesh.mesh = sleeper_mesh
	sleeper_multimesh.instance_count = sleeper_count
	var sleeper_y := roadbed_height - roadbed_embed_depth + ballast_height * 0.74
	var rng := RandomNumberGenerator.new()
	rng.seed = int(absf(length * 971.0 + sleeper_count * 37.0))
	for sleeper_index in range(sleeper_count):
		var sleeper_ratio := (float(sleeper_index) + 0.5) / float(sleeper_count)
		var sleeper_z := lerpf(-length * 0.5 + sleeper_length, length * 0.5 - sleeper_length, sleeper_ratio)
		var yaw := rng.randf_range(-0.018, 0.018)
		var basis := Basis().rotated(Vector3.UP, yaw).scaled(Vector3(
			rng.randf_range(0.94, 1.08),
			1.0,
			rng.randf_range(0.86, 1.14)
		))
		sleeper_multimesh.set_instance_transform(sleeper_index, Transform3D(basis, Vector3(0.0, sleeper_y, sleeper_z)))
	var sleeper_instance := MultiMeshInstance3D.new()
	sleeper_instance.multimesh = sleeper_multimesh
	segment_root.add_child(sleeper_instance)

func _add_track_surface_details(segment_root: Node3D, length: float, seed: int) -> void:
	if segment_root == null or length < 4.0:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var ballast_top_y := roadbed_height - roadbed_embed_depth + ballast_height + 0.024
	var rail_top_y := roadbed_height - roadbed_embed_depth + ballast_height + rail_height + 0.026
	var stain_step := maxf(6.0, ballast_grime_spacing)
	var stain_count := clampi(int(length / stain_step), 0, 18)
	for i in range(stain_count):
		if rng.randf() < 0.28:
			continue
		var z := lerpf(-length * 0.5 + 2.0, length * 0.5 - 2.0, (float(i) + rng.randf_range(0.22, 0.78)) / float(maxi(1, stain_count)))
		var stain_mesh := BoxMesh.new()
		stain_mesh.size = Vector3(
			rng.randf_range(ballast_grime_width * 0.65, ballast_grime_width * 1.45),
			0.028,
			rng.randf_range(1.2, 3.6)
		)
		var stain := MeshInstance3D.new()
		stain.mesh = stain_mesh
		stain.set_surface_override_material(0, _ensure_ballast_grime_material())
		stain.position = Vector3(rng.randf_range(-ballast_width * 0.18, ballast_width * 0.18), ballast_top_y, z)
		stain.rotation.y = rng.randf_range(-0.08, 0.08)
		segment_root.add_child(stain)
	var joint_step := maxf(4.0, rail_joint_spacing)
	var joint_count := clampi(int(length / joint_step), 0, 36)
	for i in range(joint_count):
		var z := -length * 0.5 + float(i + 1) * joint_step
		if z > length * 0.5 - 0.8:
			break
		for rail_side in [-1.0, 1.0]:
			var joint_mesh := BoxMesh.new()
			joint_mesh.size = Vector3(rail_width * 1.85, 0.035, rail_joint_width)
			var joint := MeshInstance3D.new()
			joint.mesh = joint_mesh
			joint.set_surface_override_material(0, _ensure_rail_joint_material())
			joint.position = Vector3(rail_side * rail_center_offset_m, rail_top_y, z + rng.randf_range(-0.08, 0.08))
			segment_root.add_child(joint)

func _segment_detail_seed(a: Vector3, b: Vector3) -> int:
	return int(absf(a.x * 0.021 + a.z * 0.037 + b.x * 0.049 + b.z * 0.061) * 1000.0) + 101

func _clear_render_nodes() -> void:
	for node in _render_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_render_nodes.clear()

func _rebuild_render_nodes() -> void:
	_clear_render_nodes()
	for curve in segments:
		if curve == null:
			continue
		_render_curve(curve)

func _ensure_roadbed_material() -> StandardMaterial3D:
	if _roadbed_material != null:
		return _roadbed_material
	_roadbed_material = StandardMaterial3D.new()
	_roadbed_material.albedo_color = roadbed_color
	_roadbed_material.roughness = 0.96
	_apply_weather_material_state()
	return _roadbed_material

func _ensure_ballast_material() -> StandardMaterial3D:
	if _ballast_material != null:
		return _ballast_material
	_ballast_material = StandardMaterial3D.new()
	_ballast_material.albedo_texture = _load_runtime_texture(BallastAlbedoPath)
	_ballast_material.roughness_texture = _load_runtime_texture(BallastRoughnessPath)
	_ballast_material.normal_enabled = true
	_ballast_material.normal_texture = _load_runtime_texture(BallastNormalPath)
	_ballast_material.normal_scale = 0.55
	_ballast_material.albedo_color = Color(0.92, 0.9, 0.86, 1.0)
	_ballast_material.roughness = 0.95
	_ballast_material.uv1_triplanar = true
	_ballast_material.uv1_scale = Vector3(2.1, 2.1, 2.1)
	_apply_weather_material_state()
	return _ballast_material

func _ensure_sleeper_material() -> StandardMaterial3D:
	if _sleeper_material != null:
		return _sleeper_material
	_sleeper_material = StandardMaterial3D.new()
	_sleeper_material.albedo_texture = _load_runtime_texture(SleeperAlbedoPath)
	_sleeper_material.roughness_texture = _load_runtime_texture(SleeperRoughnessPath)
	_sleeper_material.normal_enabled = true
	_sleeper_material.normal_texture = _load_runtime_texture(SleeperNormalPath)
	_sleeper_material.normal_scale = 0.48
	_sleeper_material.albedo_color = Color(0.88, 0.84, 0.78, 1.0)
	_sleeper_material.roughness = 0.9
	_sleeper_material.uv1_triplanar = true
	_sleeper_material.uv1_scale = Vector3(1.1, 1.1, 1.1)
	_apply_weather_material_state()
	return _sleeper_material

func _ensure_rail_material() -> StandardMaterial3D:
	if _rail_material != null:
		return _rail_material
	_rail_material = StandardMaterial3D.new()
	_rail_material.albedo_texture = _load_runtime_texture(RailAlbedoPath)
	_rail_material.roughness_texture = _load_runtime_texture(RailRoughnessPath)
	_rail_material.normal_enabled = true
	_rail_material.normal_texture = _load_runtime_texture(RailNormalPath)
	_rail_material.normal_scale = 0.42
	_rail_material.albedo_color = Color(0.82, 0.81, 0.8, 1.0)
	_rail_material.metallic = 0.74
	_rail_material.roughness = 0.28
	_rail_material.uv1_triplanar = true
	_rail_material.uv1_scale = Vector3(2.2, 2.2, 2.2)
	_apply_weather_material_state()
	return _rail_material

func _ensure_rail_joint_material() -> StandardMaterial3D:
	if _rail_joint_material != null:
		return _rail_joint_material
	_rail_joint_material = StandardMaterial3D.new()
	_rail_joint_material.albedo_color = Color(0.20, 0.19, 0.18, 1.0)
	_rail_joint_material.metallic = 0.68
	_rail_joint_material.roughness = 0.38
	_rail_joint_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_apply_weather_material_state()
	return _rail_joint_material

func _ensure_ballast_grime_material() -> StandardMaterial3D:
	if _ballast_grime_material != null:
		return _ballast_grime_material
	_ballast_grime_material = StandardMaterial3D.new()
	_ballast_grime_material.albedo_texture = _load_runtime_texture(BallastAlbedoPath)
	_ballast_grime_material.roughness_texture = _load_runtime_texture(BallastRoughnessPath)
	_ballast_grime_material.normal_enabled = true
	_ballast_grime_material.normal_texture = _load_runtime_texture(BallastNormalPath)
	_ballast_grime_material.normal_scale = 0.36
	_ballast_grime_material.albedo_color = Color(0.32, 0.30, 0.27, 1.0)
	_ballast_grime_material.roughness = 0.98
	_ballast_grime_material.uv1_triplanar = true
	_ballast_grime_material.uv1_scale = Vector3(1.4, 1.4, 1.4)
	_apply_weather_material_state()
	return _ballast_grime_material

func _segment_transform(a: Vector3, b: Vector3) -> Transform3D:
	var midpoint := (a + b) * 0.5
	var forward := (b - a).normalized()
	if forward.length() <= 0.001:
		return Transform3D(Basis(), midpoint)
	var right := Vector3.UP.cross(forward)
	if right.length() <= 0.001:
		right = Vector3.RIGHT
	right = right.normalized()
	var up := forward.cross(right).normalized()
	return Transform3D(Basis(right, up, forward), midpoint)

func _curve_tangent_at_offset(curve: Curve3D, offset: float) -> Vector3:
	var length := float(curve.get_baked_length())
	if length <= 0.1:
		return Vector3.FORWARD
	var behind := curve.sample_baked(clampf(offset - 3.0, 0.0, length))
	var ahead := curve.sample_baked(clampf(offset + 3.0, 0.0, length))
	var tangent := (ahead - behind).normalized()
	if tangent.length() <= 0.001:
		return Vector3.FORWARD
	return tangent

func set_weather_surface_state(track_snow_amount: float, wetness: float) -> void:
	_surface_snow_override = clampf(track_snow_amount, 0.0, 1.0)
	_surface_wet_override = clampf(wetness, 0.0, 1.0)
	_apply_weather_material_state()

func _on_weather_changed(payload: Dictionary) -> void:
	_weather_payload = payload.duplicate(true)
	_apply_weather_material_state()

func _apply_weather_material_state() -> void:
	var snow_amount := clampf(maxf(_surface_snow_override, float(_weather_payload.get("snow_cover", 0.0)) * 0.55), 0.0, 1.0)
	var wetness := clampf(maxf(_surface_wet_override, float(_weather_payload.get("surface_wetness", 0.0))), 0.0, 1.0)
	if _roadbed_material != null:
		var roadbed_base: Color = roadbed_color
		_roadbed_material.albedo_color = roadbed_base.lerp(Color(0.88, 0.88, 0.86, 1.0), snow_amount).darkened(wetness * 0.22)
		_roadbed_material.roughness = clampf(0.96 - wetness * 0.18 - snow_amount * 0.08, 0.18, 1.0)
	if _ballast_material != null:
		_ballast_material.albedo_color = Color(0.92, 0.9, 0.86, 1.0).lerp(Color(0.96, 0.96, 0.95, 1.0), snow_amount).darkened(wetness * 0.18)
		_ballast_material.roughness = clampf(0.95 - wetness * 0.24 - snow_amount * 0.10, 0.16, 1.0)
	if _sleeper_material != null:
		_sleeper_material.albedo_color = Color(0.88, 0.84, 0.78, 1.0).lerp(Color(0.92, 0.91, 0.89, 1.0), snow_amount * 0.82).darkened(wetness * 0.16)
		_sleeper_material.roughness = clampf(0.90 - wetness * 0.14, 0.20, 1.0)
	if _rail_material != null:
		_rail_material.albedo_color = Color(0.82, 0.81, 0.80, 1.0).lerp(Color(0.90, 0.90, 0.90, 1.0), snow_amount * 0.25).darkened(wetness * 0.08)
		_rail_material.roughness = clampf(0.28 - wetness * 0.10 + snow_amount * 0.04, 0.08, 0.9)
	if _rail_joint_material != null:
		_rail_joint_material.albedo_color = Color(0.20, 0.19, 0.18, 1.0).lerp(Color(0.62, 0.63, 0.62, 1.0), snow_amount * 0.28).darkened(wetness * 0.12)
		_rail_joint_material.roughness = clampf(0.38 - wetness * 0.12 + snow_amount * 0.06, 0.10, 0.9)
	if _ballast_grime_material != null:
		_ballast_grime_material.albedo_color = Color(0.32, 0.30, 0.27, 1.0).lerp(Color(0.72, 0.73, 0.72, 1.0), snow_amount * 0.42).darkened(wetness * 0.24)
		_ballast_grime_material.roughness = clampf(0.98 - wetness * 0.28 - snow_amount * 0.08, 0.18, 1.0)

func _resolve_weather_controller() -> Node:
	if weather_path != NodePath(""):
		return get_node_or_null(weather_path)
	var world_root := get_parent()
	if world_root != null:
		return world_root.get_node_or_null("Weather")
	return null

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
