extends Node3D
class_name SeamlessCamera

enum CameraMode { STATE, ISOMETRIC, BUILD, STREET, SUBWAY }

@export var transition_speed := 2.5
@export var zoom_speed := 0.15

@export var state_height := 300000.0
@export var iso_height := 6000.0
@export var build_height := 5200.0
@export var street_height := 18.0

@export var iso_yaw_deg := 45.0
@export var iso_pitch_deg := -55.0
@export var build_yaw_deg := 0.0
@export var build_ortho_size := 2800.0
@export var build_pan_speed := 6400.0
@export var build_edge_pan_margin_px := 34.0
@export var street_pitch_deg := -8.0
@export var street_yaw_deg := 0.0
@export var subway_height := 1.55
@export var subway_back_offset := 9.5
@export var subway_side_offset := -0.9
@export var subway_pitch_deg := -1.0
@export var subway_yaw_deg := 0.0
@export var subway_fov := 66.0
@export var realistic_auto_exposure_enabled := true
@export var realistic_auto_exposure_scale := 0.58
@export var realistic_auto_exposure_speed := 0.72
@export var realistic_min_sensitivity := 70.0
@export var realistic_max_sensitivity := 540.0

var mode: CameraMode = CameraMode.STATE
var target_mode: CameraMode = CameraMode.STATE
var zoom := 1.0
var target_zoom := 1.0
var map_focus := Vector3.ZERO
var build_focus := Vector3.ZERO
var street_focus := Vector3.ZERO
var street_forward := Vector3.RIGHT
var subway_focus := Vector3.ZERO
var subway_forward := Vector3.RIGHT
var subway_view_points := PackedVector3Array()
var subway_view_index := 0
var _camera_attributes: CameraAttributesPractical

@onready var cam: Camera3D = $Camera3D

func _ready() -> void:
	_camera_attributes = CameraAttributesPractical.new()
	cam.attributes = _camera_attributes
	_apply_camera_attributes(mode)
	build_focus = map_focus
	_apply_mode(mode, true)

func _process(delta: float) -> void:
	_handle_input()
	_update_build_navigation(delta)
	_apply_mode(target_mode, false)
	var t := clampf(delta * transition_speed, 0.0, 1.0)
	global_transform.origin = global_transform.origin.lerp(_target_origin(), t)
	global_transform.basis = global_transform.basis.slerp(_target_basis(), t)
	cam.size = lerp(cam.size, _target_ortho_size(), t)
	cam.fov = lerp(cam.fov, _target_fov(), t)

func cycle_mode() -> void:
	if target_mode == CameraMode.BUILD or mode == CameraMode.BUILD:
		return
	match target_mode:
		CameraMode.STATE:
			target_mode = CameraMode.ISOMETRIC
		CameraMode.ISOMETRIC:
			target_mode = CameraMode.STREET
		CameraMode.BUILD:
			target_mode = CameraMode.STREET
		CameraMode.STREET:
			target_mode = CameraMode.SUBWAY
		CameraMode.SUBWAY:
			target_mode = CameraMode.STATE

func _handle_input() -> void:
	if Input.is_action_just_pressed("cycle_camera_mode"):
		cycle_mode()
	if Input.is_action_just_pressed("focus_subway_camera"):
		var was_subway := mode == CameraMode.SUBWAY or target_mode == CameraMode.SUBWAY
		target_mode = CameraMode.SUBWAY
		if not subway_view_points.is_empty():
			if was_subway:
				_apply_subway_view(subway_view_index + 1)
			else:
				_apply_subway_view(0)
	if Input.is_action_just_pressed("zoom_in"):
		target_zoom = max(0.2, target_zoom - zoom_speed)
	if Input.is_action_just_pressed("zoom_out"):
		target_zoom = min(4.0, target_zoom + zoom_speed)
	zoom = lerp(zoom, target_zoom, 0.1)

func set_focus_points(new_map_focus: Vector3, new_street_focus: Vector3, new_street_forward: Vector3 = Vector3.RIGHT) -> void:
	map_focus = new_map_focus
	if target_mode != CameraMode.BUILD and mode != CameraMode.BUILD:
		build_focus = new_map_focus
	street_focus = new_street_focus
	if new_street_forward.length() > 0.01:
		street_forward = new_street_forward.normalized()

func set_build_focus_point(new_build_focus: Vector3, snap := false) -> void:
	if snap:
		build_focus = new_build_focus
		return
	build_focus = build_focus.lerp(new_build_focus, 0.72) if build_focus.distance_to(new_build_focus) > 0.05 else new_build_focus

func enter_build_mode(focus_point: Vector3 = Vector3.ZERO) -> void:
	if focus_point != Vector3.ZERO:
		build_focus = focus_point
	elif build_focus == Vector3.ZERO:
		build_focus = get_active_focus_point()
	target_mode = CameraMode.BUILD

func leave_build_mode(restore_mode: int = CameraMode.ISOMETRIC) -> void:
	target_mode = restore_mode

func get_active_focus_point() -> Vector3:
	match target_mode:
		CameraMode.STREET:
			return street_focus
		CameraMode.SUBWAY:
			return subway_focus
		CameraMode.BUILD:
			return build_focus
		_:
			return map_focus

func set_subway_focus_points(new_subway_focus: Vector3, new_subway_forward: Vector3 = Vector3.RIGHT) -> void:
	subway_focus = new_subway_focus
	if new_subway_forward.length() > 0.01:
		subway_forward = new_subway_forward.normalized()

func set_subway_view_points(points: PackedVector3Array) -> void:
	subway_view_points = points
	subway_view_index = 0
	if not subway_view_points.is_empty():
		_apply_subway_view(0)

func _apply_subway_view(index: int) -> void:
	if subway_view_points.is_empty():
		return
	subway_view_index = posmod(index, subway_view_points.size())
	subway_focus = subway_view_points[subway_view_index]
	var from_idx := maxi(subway_view_index - 1, 0)
	var to_idx := mini(subway_view_index + 1, subway_view_points.size() - 1)
	var forward := subway_view_points[to_idx] - subway_view_points[from_idx]
	if forward.length() > 0.01:
		subway_forward = forward.normalized()

func _apply_mode(new_mode: CameraMode, snap: bool) -> void:
	mode = new_mode
	if mode == CameraMode.STREET or mode == CameraMode.SUBWAY:
		cam.projection = Camera3D.PROJECTION_PERSPECTIVE
	else:
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	_apply_camera_attributes(mode)
	if snap:
		global_transform.origin = _target_origin()
		global_transform.basis = _target_basis()
		cam.size = _target_ortho_size()
		cam.fov = _target_fov()

func _target_origin() -> Vector3:
	match target_mode:
		CameraMode.STATE:
			return map_focus + Vector3(0.0, state_height * zoom, 0.0)
		CameraMode.ISOMETRIC:
			return map_focus + Vector3(0.0, iso_height * zoom, iso_height * 0.6 * zoom)
		CameraMode.BUILD:
			return build_focus + Vector3(0.0, build_height * zoom, 0.0)
		CameraMode.STREET:
			return street_focus - street_forward * 34.0 + Vector3(0.0, street_height, 0.0)
		CameraMode.SUBWAY:
			var side := Vector3(-subway_forward.z, 0.0, subway_forward.x).normalized()
			return subway_focus - subway_forward * subway_back_offset + side * subway_side_offset + Vector3(0.0, subway_height, 0.0)
	return Vector3.ZERO

func _target_basis() -> Basis:
	var origin := _target_origin()
	match target_mode:
		CameraMode.STATE:
			return Basis().looking_at(map_focus - origin, Vector3.FORWARD)
		CameraMode.ISOMETRIC:
			return (
				Basis()
				.rotated(Vector3.UP, deg_to_rad(iso_yaw_deg))
				.rotated(Vector3.RIGHT, deg_to_rad(iso_pitch_deg))
			)
		CameraMode.BUILD:
			var basis := Basis().looking_at(Vector3.DOWN, Vector3.BACK)
			if absf(build_yaw_deg) > 0.01:
				basis = basis.rotated(Vector3.UP, deg_to_rad(build_yaw_deg))
			return basis
		CameraMode.STREET:
			var look_target := street_focus + street_forward * 64.0
			var basis := Basis().looking_at(look_target - origin, Vector3.UP)
			if absf(street_yaw_deg) > 0.01:
				basis = basis.rotated(Vector3.UP, deg_to_rad(street_yaw_deg))
			if absf(street_pitch_deg) > 0.01:
				basis = basis.rotated(basis.x.normalized(), deg_to_rad(street_pitch_deg))
			return basis
		CameraMode.SUBWAY:
			var look_target := subway_focus + subway_forward * 44.0
			var basis := Basis().looking_at(look_target - origin, Vector3.UP)
			if absf(subway_yaw_deg) > 0.01:
				basis = basis.rotated(Vector3.UP, deg_to_rad(subway_yaw_deg))
			if absf(subway_pitch_deg) > 0.01:
				basis = basis.rotated(basis.x.normalized(), deg_to_rad(subway_pitch_deg))
			return basis
	return Basis()

func _target_ortho_size() -> float:
	match target_mode:
		CameraMode.STATE:
			return 180000.0 * zoom
		CameraMode.ISOMETRIC:
			return 8000.0 * zoom
		CameraMode.BUILD:
			return build_ortho_size * zoom
		CameraMode.STREET:
			return 5.0
	return 10.0

func _target_fov() -> float:
	if target_mode == CameraMode.STREET:
		return 60.0
	if target_mode == CameraMode.SUBWAY:
		return subway_fov
	return 30.0

func _apply_camera_attributes(for_mode: CameraMode) -> void:
	if _camera_attributes == null:
		return
	_camera_attributes.exposure_sensitivity = 120.0
	_camera_attributes.exposure_multiplier = 1.0
	_camera_attributes.auto_exposure_enabled = realistic_auto_exposure_enabled
	_camera_attributes.auto_exposure_scale = realistic_auto_exposure_scale
	_camera_attributes.auto_exposure_speed = realistic_auto_exposure_speed
	_camera_attributes.auto_exposure_min_sensitivity = realistic_min_sensitivity
	_camera_attributes.auto_exposure_max_sensitivity = realistic_max_sensitivity
	match for_mode:
		CameraMode.STATE, CameraMode.ISOMETRIC, CameraMode.BUILD:
			_camera_attributes.exposure_multiplier = 1.0
		CameraMode.STREET:
			_camera_attributes.exposure_sensitivity = 140.0
			_camera_attributes.exposure_multiplier = 1.05
		CameraMode.SUBWAY:
			_camera_attributes.exposure_sensitivity = 180.0
			_camera_attributes.exposure_multiplier = 1.12

func _update_build_navigation(delta: float) -> void:
	if target_mode != CameraMode.BUILD and mode != CameraMode.BUILD:
		return
	var pan_dir := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_LEFT):
		pan_dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_RIGHT):
		pan_dir.x += 1.0
	if Input.is_physical_key_pressed(KEY_UP):
		pan_dir.y -= 1.0
	if Input.is_physical_key_pressed(KEY_DOWN):
		pan_dir.y += 1.0
	var hovered := get_viewport().gui_get_hovered_control()
	if hovered == null:
		var mouse_pos := get_viewport().get_mouse_position()
		var viewport_size := get_viewport().get_visible_rect().size
		if mouse_pos.x <= build_edge_pan_margin_px:
			pan_dir.x -= 1.0 - clampf(mouse_pos.x / maxf(build_edge_pan_margin_px, 1.0), 0.0, 1.0)
		elif mouse_pos.x >= viewport_size.x - build_edge_pan_margin_px:
			pan_dir.x += 1.0 - clampf((viewport_size.x - mouse_pos.x) / maxf(build_edge_pan_margin_px, 1.0), 0.0, 1.0)
		if mouse_pos.y <= build_edge_pan_margin_px:
			pan_dir.y -= 1.0 - clampf(mouse_pos.y / maxf(build_edge_pan_margin_px, 1.0), 0.0, 1.0)
		elif mouse_pos.y >= viewport_size.y - build_edge_pan_margin_px:
			pan_dir.y += 1.0 - clampf((viewport_size.y - mouse_pos.y) / maxf(build_edge_pan_margin_px, 1.0), 0.0, 1.0)
	if pan_dir.length_squared() <= 0.0001:
		return
	pan_dir = pan_dir.normalized()
	var zoom_factor := lerpf(0.68, 1.85, clampf((zoom - 0.2) / 3.8, 0.0, 1.0))
	build_focus += Vector3(pan_dir.x, 0.0, pan_dir.y) * build_pan_speed * zoom_factor * delta
