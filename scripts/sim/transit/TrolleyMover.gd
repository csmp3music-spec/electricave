extends PathFollow3D
class_name TrolleyMover

@export var speed_mps := 18.0
@export var controlled := false
@export var manual_control_enabled := true
@export var accel_mps2 := 6.0
@export var max_speed_mps := 26.0
@export var min_speed_mps := 0.0
@export var max_reverse_speed_mps := 10.0
@export var friction_mps2 := 2.0
@export var brake_mps2 := 12.0
@export var throttle_step_mps := 4.0
@export var throttle_notch_count := 6
@export var reverse_notch_count := 3
@export var throttle_hold_delay_s := 0.22
@export var throttle_repeat_interval_s := 0.12
@export var loop_path := true
@export var ping_pong := false
@export var curve_sample_spacing_m := 8.0
@export var curve_safe_lateral_accel_mps2 := 1.25

var travel_direction := 1.0
var _attachment_root: Node3D
var target_speed_mps := 0.0
var power_notch := 0
var failure_state := ""
var failure_message := ""
var failure_age_s := 999.0
var failure_speed_mps := 0.0
var _incident_roll_rad := 0.0
var _incident_pitch_rad := 0.0
var _incident_lateral_offset_m := 0.0
var _incident_vertical_drop_m := 0.0
var _manual_drive_initialized := false
var _throttle_up_repeat_s := 0.0
var _throttle_down_repeat_s := 0.0

func _ready() -> void:
	loop = loop_path
	rotation_mode = PathFollow3D.ROTATION_Y
	target_speed_mps = speed_mps
	_sync_power_notch_from_speed(target_speed_mps)
	_ensure_attachment_root()
	_sync_attachment_direction()

func get_attachment_root() -> Node3D:
	return _ensure_attachment_root()

func has_incident() -> bool:
	return failure_state != ""

func get_failure_payload() -> Dictionary:
	return {
		"active": has_incident(),
		"state": failure_state,
		"message": failure_message,
		"age_s": failure_age_s,
		"speed_mps": failure_speed_mps
	}

func trigger_incident(state: String, message: String, roll_deg: float = 12.0, pitch_deg: float = 0.0, lateral_offset_m: float = 0.6, vertical_drop_m: float = -0.22) -> void:
	if has_incident():
		return
	failure_state = state
	failure_message = message
	failure_age_s = 0.0
	failure_speed_mps = absf(speed_mps)
	speed_mps = 0.0
	target_speed_mps = 0.0
	_incident_roll_rad = deg_to_rad(roll_deg)
	_incident_pitch_rad = deg_to_rad(pitch_deg)
	_incident_lateral_offset_m = lateral_offset_m
	_incident_vertical_drop_m = vertical_drop_m
	_sync_attachment_direction()

func clear_incident() -> void:
	failure_state = ""
	failure_message = ""
	failure_age_s = 999.0
	failure_speed_mps = 0.0
	_incident_roll_rad = 0.0
	_incident_pitch_rad = 0.0
	_incident_lateral_offset_m = 0.0
	_incident_vertical_drop_m = 0.0
	_sync_attachment_direction()

func get_curve_dynamics() -> Dictionary:
	var parent_path := get_parent() as Path3D
	if parent_path == null or parent_path.curve == null:
		return {
			"radius_m": INF,
			"turn_angle_deg": 0.0,
			"safe_speed_mps": max_speed_mps
		}
	var curve := parent_path.curve
	var length := float(curve.get_baked_length())
	if length <= 1.0:
		return {
			"radius_m": INF,
			"turn_angle_deg": 0.0,
			"safe_speed_mps": max_speed_mps
		}
	var spacing := minf(curve_sample_spacing_m, maxf(3.0, length * 0.025))
	var prev_pos: Vector3 = curve.sample_baked(clampf(progress - spacing, 0.0, length))
	var current_pos: Vector3 = curve.sample_baked(clampf(progress, 0.0, length))
	var next_pos: Vector3 = curve.sample_baked(clampf(progress + spacing, 0.0, length))
	var in_vec := current_pos - prev_pos
	var out_vec := next_pos - current_pos
	if in_vec.length() < 0.1 or out_vec.length() < 0.1:
		return {
			"radius_m": INF,
			"turn_angle_deg": 0.0,
			"safe_speed_mps": max_speed_mps
		}
	var turn_angle := in_vec.normalized().angle_to(out_vec.normalized())
	var radius_m := INF
	if turn_angle > deg_to_rad(0.6):
		var chord := maxf(0.1, (in_vec.length() + out_vec.length()) * 0.5)
		radius_m = chord / maxf(0.001, 2.0 * sin(turn_angle * 0.5))
	var safe_speed_mps := max_speed_mps
	if is_finite(radius_m):
		safe_speed_mps = clampf(sqrt(maxf(1.0, radius_m) * curve_safe_lateral_accel_mps2), 4.0, max_speed_mps)
	return {
		"radius_m": radius_m,
		"turn_angle_deg": rad_to_deg(turn_angle),
		"safe_speed_mps": safe_speed_mps
	}

func get_manual_drive_status() -> Dictionary:
	return {
		"manual_control_enabled": manual_control_enabled,
		"power_notch": power_notch,
		"forward_notches": throttle_notch_count,
		"reverse_notches": reverse_notch_count,
		"command_mps": target_speed_mps,
		"command_mph": absf(target_speed_mps) * 2.23694,
		"braking": controlled and Input.is_action_pressed("drive_service_brake")
	}

func _process(delta: float) -> void:
	if has_incident():
		failure_age_s += delta
		speed_mps = 0.0
		target_speed_mps = 0.0
		return
	if controlled:
		if manual_control_enabled:
			_update_manual_drive(delta)
		else:
			_manual_drive_initialized = false
			_throttle_up_repeat_s = 0.0
			_throttle_down_repeat_s = 0.0
	else:
		_manual_drive_initialized = false
		_throttle_up_repeat_s = 0.0
		_throttle_down_repeat_s = 0.0
	var step := speed_mps * delta
	if absf(step) > 0.001:
		travel_direction = 1.0 if step >= 0.0 else -1.0
		_sync_attachment_direction()
	if ping_pong and not loop_path and not controlled:
		var parent_path := get_parent() as Path3D
		if parent_path != null and parent_path.curve != null:
			var limit := float(parent_path.curve.get_baked_length())
			progress += step * travel_direction
			if progress >= limit:
				progress = limit
				travel_direction = -1.0
				_sync_attachment_direction()
			elif progress <= 0.0:
				progress = 0.0
				travel_direction = 1.0
				_sync_attachment_direction()
		return
	progress += step
	if not loop_path:
		var parent_path := get_parent() as Path3D
		if parent_path != null and parent_path.curve != null:
			var limit := float(parent_path.curve.get_baked_length())
			if progress >= limit:
				progress = limit
				if controlled:
					speed_mps = 0.0
					target_speed_mps = minf(0.0, target_speed_mps)
				else:
					speed_mps = 0.0
			elif progress <= 0.0:
				progress = 0.0
				if controlled:
					speed_mps = 0.0
					target_speed_mps = maxf(0.0, target_speed_mps)

func _update_manual_drive(delta: float) -> void:
	if not _manual_drive_initialized:
		_sync_power_notch_from_speed(target_speed_mps if absf(target_speed_mps) > 0.05 else speed_mps)
		_manual_drive_initialized = true
	_handle_notch_hold("drive_throttle_up", 1, delta)
	_handle_notch_hold("drive_throttle_down", -1, delta)
	target_speed_mps = _target_speed_for_notch()
	if Input.is_action_pressed("drive_service_brake"):
		speed_mps = move_toward(speed_mps, 0.0, brake_mps2 * delta)
		return
	var accel := accel_mps2 if absf(target_speed_mps) >= absf(speed_mps) or signf(target_speed_mps) != signf(speed_mps) else friction_mps2
	speed_mps = move_toward(speed_mps, target_speed_mps, accel * delta)

func _handle_notch_hold(action_name: String, direction: int, delta: float) -> void:
	if not Input.is_action_pressed(action_name):
		if direction > 0:
			_throttle_up_repeat_s = 0.0
		else:
			_throttle_down_repeat_s = 0.0
		return
	if Input.is_action_just_pressed(action_name):
		_step_power_notch(direction)
		if direction > 0:
			_throttle_up_repeat_s = throttle_hold_delay_s
		else:
			_throttle_down_repeat_s = throttle_hold_delay_s
		return
	if direction > 0:
		_throttle_up_repeat_s -= delta
		while _throttle_up_repeat_s <= 0.0:
			_step_power_notch(direction)
			_throttle_up_repeat_s += maxf(0.04, throttle_repeat_interval_s)
	else:
		_throttle_down_repeat_s -= delta
		while _throttle_down_repeat_s <= 0.0:
			_step_power_notch(direction)
			_throttle_down_repeat_s += maxf(0.04, throttle_repeat_interval_s)

func _step_power_notch(direction: int) -> void:
	var min_notch := -maxi(1, reverse_notch_count)
	var max_notch := maxi(1, throttle_notch_count)
	power_notch = clampi(power_notch + direction, min_notch, max_notch)

func _target_speed_for_notch() -> float:
	if power_notch > 0:
		var forward_ratio := float(power_notch) / float(maxi(1, throttle_notch_count))
		return maxf(min_speed_mps, max_speed_mps * forward_ratio)
	if power_notch < 0:
		var reverse_ratio := float(abs(power_notch)) / float(maxi(1, reverse_notch_count))
		return -maxf(min_speed_mps, max_reverse_speed_mps * reverse_ratio)
	return 0.0

func _sync_power_notch_from_speed(command_speed_mps: float) -> void:
	if command_speed_mps > 0.05:
		var forward_ratio := clampf(command_speed_mps / maxf(1.0, max_speed_mps), 0.0, 1.0)
		power_notch = clampi(int(round(forward_ratio * float(maxi(1, throttle_notch_count)))), 1, maxi(1, throttle_notch_count))
		return
	if command_speed_mps < -0.05:
		var reverse_ratio := clampf(absf(command_speed_mps) / maxf(1.0, max_reverse_speed_mps), 0.0, 1.0)
		power_notch = -clampi(int(round(reverse_ratio * float(maxi(1, reverse_notch_count)))), 1, maxi(1, reverse_notch_count))
		return
	power_notch = 0

func set_manual_control_enabled(enabled: bool) -> void:
	manual_control_enabled = enabled
	if not manual_control_enabled:
		_manual_drive_initialized = false
		_throttle_up_repeat_s = 0.0
		_throttle_down_repeat_s = 0.0
	else:
		_sync_power_notch_from_speed(target_speed_mps if absf(target_speed_mps) > 0.05 else speed_mps)

func is_manual_control_enabled() -> bool:
	return manual_control_enabled

func _ensure_attachment_root() -> Node3D:
	if _attachment_root != null and is_instance_valid(_attachment_root):
		return _attachment_root
	_attachment_root = get_node_or_null("DirectionRoot") as Node3D
	if _attachment_root == null:
		_attachment_root = Node3D.new()
		_attachment_root.name = "DirectionRoot"
		add_child(_attachment_root)
	return _attachment_root

func _sync_attachment_direction() -> void:
	var root := _ensure_attachment_root()
	root.position = Vector3.ZERO
	root.rotation = Vector3(_incident_pitch_rad, 0.0, _incident_roll_rad)
	root.position.x = _incident_lateral_offset_m
	root.position.y = _incident_vertical_drop_m
	if travel_direction < 0.0:
		root.rotation.y = PI
		root.rotation.z = -_incident_roll_rad
		root.position.x = -_incident_lateral_offset_m
