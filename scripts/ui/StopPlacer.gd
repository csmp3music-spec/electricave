extends Node
class_name StopPlacer

signal tool_state_changed(active: bool, tool_mode: int, has_anchor: bool)

enum ToolMode {
	TRACK,
	STATION,
	DEPOT,
	SIGNAL,
	BULLDOZE
}

@export var town_manager_path: NodePath
@export var track_builder_path: NodePath
@export var economy_path: NodePath
@export var corridor_path: NodePath
@export var frequency := 6.0
@export var active := false
@export var min_frequency := 2.0
@export var max_frequency := 12.0
@export var frequency_step := 1.0
@export var tool_mode: ToolMode = ToolMode.TRACK
@export var snap_radius := 28.0
@export var min_track_length := 18.0
@export var preview_height := 0.18
@export var track_preview_width := 4.4
@export var marker_size := Vector3(3.0, 0.4, 3.0)
@export var track_cost_per_meter := 140.0
@export var station_cost := 8000.0
@export var depot_cost := 22000.0
@export var signal_cost := 3500.0
@export var bulldoze_refund_ratio := 0.35
@export var bulldoze_radius := 26.0
@export var station_spacing_m := 110.0
@export var depot_spacing_m := 120.0
@export var signal_spacing_m := 70.0
@export var autorail_enabled := true
@export var asset_rotation_step_deg := 90.0
@export var asset_rotation_deg := 0.0
@export var station_platform_length_tiles := 3
@export var station_track_count := 2
@export var station_tile_length_m := 18.0
@export var station_platform_width_m := 4.8
@export var station_track_spacing_m := 5.0
@export var signal_run_spacing_m := 70.0
@export var station_track_snap_radius := 18.0
@export var depot_track_snap_radius := 24.0
@export var signal_track_snap_radius := 12.0
@export var max_station_grade_delta_m := 0.72
@export var max_depot_grade_delta_m := 0.95
@export var max_signal_grade_delta_m := 1.15

var _town_manager
var _track_builder
var _economy
var _corridor
var _terrain_backdrop: Node
var _anchor_point: Variant = null
var _preview_host: Node3D
var _preview_root: Node3D
var _placed_root: Node3D
var _preview_track: MeshInstance3D
var _preview_track_segments: Array[MeshInstance3D] = []
var _preview_marker: MeshInstance3D
var _anchor_marker: MeshInstance3D
var _preview_material_valid: StandardMaterial3D
var _preview_material_invalid: StandardMaterial3D
var _preview_material_marker: StandardMaterial3D
var _preview_material_demolish: StandardMaterial3D
var _preview_cost := 0.0
var _preview_valid := false
var _preview_message := ""
var _preview_target: Variant = null

func _ready() -> void:
	if town_manager_path != NodePath(""):
		_town_manager = get_node_or_null(town_manager_path)
	else:
		_town_manager = get_parent().get_node_or_null("TownGrowthManager")
	if track_builder_path != NodePath(""):
		_track_builder = get_node_or_null(track_builder_path)
	else:
		_track_builder = get_parent().get_node_or_null("TrackNetwork")
	if economy_path != NodePath(""):
		_economy = get_node_or_null(economy_path)
	else:
		_economy = get_parent().get_node_or_null("Economy")
	if corridor_path != NodePath(""):
		_corridor = get_node_or_null(corridor_path)
	else:
		_corridor = get_parent().get_node_or_null("CorridorSeed")
	_preview_host = get_parent() as Node3D
	_terrain_backdrop = _resolve_terrain_backdrop()
	call_deferred("_setup_preview")

func _process(_delta: float) -> void:
	if not active:
		return
	_update_preview()

func _setup_preview() -> void:
	_create_preview_nodes()
	_update_preview()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_stop_tool"):
		set_active(not active)
		return
	if event.is_action_pressed("cycle_build_mode"):
		cycle_tool_mode()
		return
	if event.is_action_pressed("stop_freq_up"):
		_adjust_context_setting(1)
		return
	if event.is_action_pressed("stop_freq_down"):
		_adjust_context_setting(-1)
		return
	if event.is_action_pressed("toggle_autorail"):
		autorail_enabled = not autorail_enabled
		_update_preview()
		_emit_tool_state()
		return
	if event.is_action_pressed("build_rotate_left"):
		_rotate_assets(-1)
		return
	if event.is_action_pressed("build_rotate_right"):
		_rotate_assets(1)
		return
	if not active:
		return
	if event.is_action_pressed("ui_cancel"):
		_cancel_current_action()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_cancel_current_action()
		return
	if _is_pointer_over_blocking_ui():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		match tool_mode:
			ToolMode.TRACK:
				_handle_track_click(event.position)
			ToolMode.STATION:
				_place_station_at_mouse(event.position)
			ToolMode.DEPOT:
				_place_depot_at_mouse(event.position)
			ToolMode.SIGNAL:
				_place_signal_at_mouse(event.position)
			ToolMode.BULLDOZE:
				_bulldoze_at_mouse(event.position)

func _is_pointer_over_blocking_ui() -> bool:
	var hovered := get_viewport().gui_get_hovered_control()
	if hovered == null:
		return false
	var node := hovered as Control
	while node != null:
		var name := String(node.name)
		if name == "HUD" or name == "Backdrop":
			return false
		if (
			node is BaseButton
			or node is ScrollContainer
			or name == "BottomBar"
			or name == "FinanceWindow"
			or name == "BuildModePanel"
			or name == "SystemMapPanel"
		):
			return true
		node = node.get_parent() as Control
	return false

func set_active(value: bool) -> void:
	active = value
	if not active:
		_anchor_point = null
	_preview_cost = 0.0
	_preview_valid = false
	_preview_message = ""
	_update_preview()
	_emit_tool_state()

func set_tool_mode(mode: ToolMode, activate_tool := true) -> void:
	tool_mode = mode
	if activate_tool:
		active = true
	if tool_mode != ToolMode.TRACK and tool_mode != ToolMode.SIGNAL:
		_anchor_point = null
	_update_preview()
	_emit_tool_state()

func set_tool_mode_name(mode_name: String, activate_tool := true) -> void:
	match mode_name.to_lower():
		"station", "stop":
			set_tool_mode(ToolMode.STATION, activate_tool)
		"depot":
			set_tool_mode(ToolMode.DEPOT, activate_tool)
		"signal":
			set_tool_mode(ToolMode.SIGNAL, activate_tool)
		"bulldoze", "remove":
			set_tool_mode(ToolMode.BULLDOZE, activate_tool)
		_:
			set_tool_mode(ToolMode.TRACK, activate_tool)

func cycle_tool_mode() -> void:
	var next_mode := (int(tool_mode) + 1) % ToolMode.size()
	set_tool_mode(next_mode, active)

func get_tool_mode_name() -> String:
	match tool_mode:
		ToolMode.STATION:
			return "Station"
		ToolMode.DEPOT:
			return "Depot"
		ToolMode.SIGNAL:
			return "Signal"
		ToolMode.BULLDOZE:
			return "Bulldoze"
		_:
			return "Track"

func get_status_text() -> String:
	var prefix := "Build %s | mode %s" % ["on" if active else "off", get_tool_mode_name()]
	if not active:
		return prefix
	if absf(_preview_cost) > 0.01:
		if _preview_cost >= 0.0:
			prefix += " | cost $%s" % _money_text(_preview_cost)
		else:
			prefix += " | refund $%s" % _money_text(absf(_preview_cost))
	if _preview_message != "":
		prefix += " | %s" % _preview_message
	return prefix

func get_tycoon_build_state() -> Dictionary:
	return {
		"active": active,
		"mode": get_tool_mode_name(),
		"frequency": frequency,
		"cash": _available_cash(),
		"preview_cost": _preview_cost,
		"preview_valid": _preview_valid,
		"status": _preview_message,
		"has_anchor": _anchor_point is Vector3,
		"autorail_enabled": autorail_enabled,
		"rotation_deg": asset_rotation_deg,
		"station_length_tiles": station_platform_length_tiles,
		"station_track_count": station_track_count,
		"signal_run_spacing_m": signal_run_spacing_m
	}

func _adjust_context_setting(direction: int) -> void:
	if active and tool_mode == ToolMode.STATION:
		station_platform_length_tiles = clampi(station_platform_length_tiles + direction, 2, 8)
	elif active and tool_mode == ToolMode.SIGNAL:
		signal_run_spacing_m = clampf(signal_run_spacing_m + float(direction) * 10.0, 24.0, 160.0)
	else:
		frequency = clampf(frequency + float(direction) * frequency_step, min_frequency, max_frequency)
	_update_preview()
	_emit_tool_state()

func _rotate_assets(direction: int) -> void:
	asset_rotation_deg = wrapf(asset_rotation_deg + float(direction) * asset_rotation_step_deg, -180.0, 180.0)
	_update_preview()
	_emit_tool_state()

func _station_build_cost() -> float:
	var platform_factor := 0.72 + float(station_platform_length_tiles) * 0.22
	var track_factor := 1.0 + float(maxi(station_track_count - 1, 0)) * 0.28
	return station_cost * platform_factor * track_factor

func _station_preview_size() -> Vector3:
	var width := station_platform_width_m * 2.0 + float(maxi(station_track_count - 1, 0)) * station_track_spacing_m + 3.2
	var length := float(station_platform_length_tiles) * station_tile_length_m
	return Vector3(width, 1.6, length)

func get_manual_build_counts() -> Dictionary:
	var counts := {
		"depot": 0,
		"signal": 0
	}
	if _placed_root == null or not is_instance_valid(_placed_root):
		return counts
	for child in _placed_root.get_children():
		if not (child is Node3D):
			continue
		var kind := String((child as Node3D).get_meta("build_kind", ""))
		if counts.has(kind):
			counts[kind] = int(counts[kind]) + 1
	return counts

func get_manual_depots() -> Array[Dictionary]:
	var depots: Array[Dictionary] = []
	if _placed_root == null or not is_instance_valid(_placed_root):
		return depots
	for child in _placed_root.get_children():
		if not (child is Node3D):
			continue
		var node := child as Node3D
		if String(node.get_meta("build_kind", "")) != "depot":
			continue
		depots.append({
			"id": String(node.get_meta("build_id", node.name)),
			"name": String(node.get_meta("build_label", node.name)),
			"position": node.global_position
		})
	return depots

func _handle_track_click(screen_pos: Vector2) -> void:
	if _track_builder == null:
		return
	var world_pos: Variant = _mouse_world_point(screen_pos)
	if world_pos == null:
		return
	var snapped := _snap_world_point(world_pos, true)
	if _anchor_point == null:
		_anchor_point = snapped
		_update_preview()
		_emit_tool_state()
		return
	var anchor: Vector3 = _anchor_point
	var points := _build_track_points(anchor, snapped)
	var length := _polyline_length(points)
	var cost := _track_cost(length)
	if length < min_track_length:
		return
	if not _track_builder.can_place_segment(points):
		return
	if not _try_spend(cost):
		return
	var curve = _track_builder.add_segment(points)
	if curve != null:
		_anchor_point = snapped
	_update_preview()
	_emit_tool_state()

func _place_station_at_mouse(screen_pos: Vector2) -> void:
	if _town_manager == null:
		return
	var pos: Variant = _mouse_snapped_point(screen_pos)
	if pos == null:
		return
	pos = _aligned_network_position(pos, station_track_snap_radius)
	if not _can_place_station_at(pos):
		return
	var build_cost := _station_build_cost()
	if not _try_spend(build_cost):
		return
	var forward := _placement_forward(pos)
	var stop = _town_manager.call("AddTransitStop", pos, frequency, "", "station")
	var stop_id := ""
	if stop != null and _has_property(stop, "stop_id"):
		stop_id = String(stop.get("stop_id"))
	var station_node := _build_station_node(pos, forward, stop_id, build_cost)
	_placed_root.add_child(station_node)
	_update_preview()

func _place_depot_at_mouse(screen_pos: Vector2) -> void:
	var pos: Variant = _mouse_snapped_point(screen_pos)
	if pos == null:
		return
	pos = _aligned_network_position(pos, depot_track_snap_radius)
	if not _can_place_depot_at(pos):
		return
	if not _try_spend(depot_cost):
		return
	var forward := _placement_forward(pos)
	var depot := _build_depot_node(pos, forward)
	_placed_root.add_child(depot)
	_update_preview()

func _place_signal_at_mouse(screen_pos: Vector2) -> void:
	var pos: Variant = _mouse_snapped_point(screen_pos)
	if pos == null:
		return
	pos = _aligned_network_position(pos, signal_track_snap_radius)
	if _anchor_point == null:
		if not _can_place_signal_at(pos):
			return
		_anchor_point = pos
		_update_preview()
		_emit_tool_state()
		return
	var anchor: Vector3 = _anchor_point
	var run := _build_signal_run(anchor, pos)
	if run.is_empty():
		return
	var cost := signal_cost * float(run.size())
	if not _try_spend(cost):
		return
	for entry in run:
		var signal_pos: Vector3 = entry.get("position", pos)
		var forward: Vector3 = entry.get("forward", Vector3.FORWARD)
		var signal_node := _build_signal_node(signal_pos, forward)
		_placed_root.add_child(signal_node)
	_anchor_point = pos
	_update_preview()
	_emit_tool_state()

func _bulldoze_at_mouse(screen_pos: Vector2) -> void:
	var pos: Variant = _mouse_snapped_point(screen_pos)
	if pos == null:
		return
	var target := _find_bulldoze_target(pos)
	if target.is_empty():
		return
	match String(target.get("kind", "")):
		"track":
			var removed: Dictionary = _track_builder.remove_segment_near(pos, bulldoze_radius)
			var removed_length := float(removed.get("length", 0.0))
			_apply_refund(_track_cost(removed_length) * bulldoze_refund_ratio)
		"stop":
			var stop = target.get("stop")
			if stop != null and _town_manager != null:
				_town_manager.call("RemoveTransitStop", String(stop.stop_id))
				_apply_refund(station_cost * bulldoze_refund_ratio)
		"placed":
			var node := target.get("node") as Node3D
			if node != null and is_instance_valid(node):
				var stop_id := String(node.get_meta("stop_id", ""))
				if stop_id != "" and _town_manager != null:
					_town_manager.call("RemoveTransitStop", stop_id)
				_apply_refund(float(node.get_meta("build_cost", 0.0)) * bulldoze_refund_ratio)
				node.queue_free()
	_update_preview()
	_emit_tool_state()

func _mouse_snapped_point(screen_pos: Vector2) -> Variant:
	var world_pos: Variant = _mouse_world_point(screen_pos)
	if world_pos == null:
		return null
	return _snap_world_point(world_pos, true)

func _mouse_world_point(screen_pos: Vector2) -> Variant:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return null
	var from := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	return _with_ground_height(_intersect_ground(from, dir))

func _intersect_ground(origin: Vector3, direction: Vector3) -> Vector3:
	if abs(direction.y) < 0.0001:
		return origin
	var t := -origin.y / direction.y
	return origin + direction * t

func _snap_world_point(world_pos: Vector3, snap_to_stop := false) -> Vector3:
	var best_pos := _with_ground_height(world_pos)
	var best_distance := INF
	var network_snap := _nearest_network_snap(world_pos, snap_radius)
	if network_snap.has("position"):
		best_pos = network_snap["position"]
		best_distance = float(network_snap.get("distance", world_pos.distance_to(best_pos)))
	if snap_to_stop and _town_manager != null:
		for stop in _town_manager.stops:
			if stop == null:
				continue
			var stop_pos: Vector3 = stop.position
			var distance := world_pos.distance_to(stop_pos)
			if distance <= snap_radius and distance < best_distance:
				best_distance = distance
				best_pos = stop_pos
	if best_distance == INF and _track_builder != null and _track_builder.has_method("snap_point"):
		best_pos = _track_builder.snap_point(world_pos)
	return _with_ground_height(best_pos)

func _nearest_network_snap(world_pos: Vector3, max_distance: float) -> Dictionary:
	var best := _nearest_track_snap(world_pos, max_distance)
	var best_distance := float(best.get("distance", max_distance))
	var route_snap := _nearest_route_snap(world_pos, max_distance)
	if route_snap.has("position") and float(route_snap.get("distance", INF)) <= best_distance:
		best = route_snap
		best_distance = float(route_snap.get("distance", best_distance))
	if best.has("position"):
		best["position"] = _with_ground_height(best.get("position", world_pos))
	return best

func _nearest_track_snap(world_pos: Vector3, max_distance: float) -> Dictionary:
	if _track_builder == null or not _track_builder.has_method("get_closest_track_point"):
		return {}
	return _track_builder.call("get_closest_track_point", world_pos, max_distance)

func _aligned_network_position(world_pos: Vector3, max_distance: float) -> Vector3:
	var snap := _nearest_network_snap(world_pos, max_distance)
	if snap.has("position"):
		return snap["position"]
	return _with_ground_height(world_pos)

func _nearest_route_snap(world_pos: Vector3, max_distance: float) -> Dictionary:
	var points := PackedVector3Array()
	if _corridor != null and _corridor.has_method("get_system_route_points"):
		points = _corridor.call("get_system_route_points")
	if points.is_empty() and _corridor != null and _corridor.has_method("get_mainline_points"):
		points = _corridor.call("get_mainline_points")
	if points.size() < 2:
		return {}
	var best_distance := max_distance
	var best_point := Vector3.ZERO
	var best_direction := Vector3.FORWARD
	for i in range(points.size() - 1):
		var a: Vector3 = points[i]
		var b: Vector3 = points[i + 1]
		var candidate := _closest_point_on_segment(world_pos, a, b)
		var distance := candidate.distance_to(world_pos)
		if distance <= best_distance:
			best_distance = distance
			best_point = candidate
			best_direction = (b - a).normalized()
	if best_distance > max_distance:
		return {}
	return {
		"position": best_point,
		"distance": best_distance,
		"direction": best_direction
	}

func _closest_point_on_segment(point: Vector3, a: Vector3, b: Vector3) -> Vector3:
	var segment := b - a
	var length_sq := segment.length_squared()
	if length_sq <= 0.0001:
		return a
	var t := clampf((point - a).dot(segment) / length_sq, 0.0, 1.0)
	return a + segment * t

func _cancel_current_action() -> void:
	if (tool_mode == ToolMode.TRACK or tool_mode == ToolMode.SIGNAL) and _anchor_point != null:
		_anchor_point = null
		_update_preview()
		_emit_tool_state()
		return
	set_active(false)

func _create_preview_nodes() -> void:
	if _preview_host == null:
		return
	_preview_root = Node3D.new()
	_preview_root.name = "BuildPreview"
	_preview_host.add_child(_preview_root)
	_placed_root = Node3D.new()
	_placed_root.name = "TycoonPlacements"
	_preview_host.add_child(_placed_root)
	_preview_material_valid = _make_preview_material(Color(0.34, 0.76, 0.49, 0.82))
	_preview_material_invalid = _make_preview_material(Color(0.84, 0.34, 0.28, 0.88))
	_preview_material_marker = _make_preview_material(Color(0.96, 0.84, 0.48, 0.90))
	_preview_material_demolish = _make_preview_material(Color(0.82, 0.30, 0.24, 0.82))
	_preview_track = MeshInstance3D.new()
	var track_mesh := BoxMesh.new()
	track_mesh.size = Vector3(track_preview_width, preview_height, 1.0)
	_preview_track.mesh = track_mesh
	_preview_root.add_child(_preview_track)
	_preview_track.set_surface_override_material(0, _preview_material_valid)
	_preview_track_segments = [_preview_track]
	_preview_marker = MeshInstance3D.new()
	var marker_mesh := BoxMesh.new()
	marker_mesh.size = marker_size
	_preview_marker.mesh = marker_mesh
	_preview_marker.set_surface_override_material(0, _preview_material_marker)
	_preview_root.add_child(_preview_marker)
	_anchor_marker = MeshInstance3D.new()
	_anchor_marker.mesh = marker_mesh.duplicate()
	_anchor_marker.set_surface_override_material(0, _preview_material_marker)
	_preview_root.add_child(_anchor_marker)

func _make_preview_material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = false
	return mat

func _update_preview() -> void:
	if _preview_root == null:
		return
	if not active:
		_preview_root.visible = false
		return
	_preview_root.visible = true
	var mouse_pos := get_viewport().get_mouse_position()
	var world_point: Variant = _mouse_world_point(mouse_pos)
	if world_point == null:
		_preview_root.visible = false
		return
	var snapped := _snap_world_point(world_point, true)
	_preview_target = snapped
	_preview_cost = 0.0
	_preview_valid = false
	_preview_message = ""
	_preview_marker.visible = true
	_set_preview_track_segments_visible(0)
	_anchor_marker.visible = (_anchor_point is Vector3) and (tool_mode == ToolMode.TRACK or tool_mode == ToolMode.SIGNAL)
	if _anchor_marker.visible:
		_anchor_marker.global_position = _anchor_point + Vector3(0.0, marker_size.y * 0.5 + 0.04, 0.0)
	match tool_mode:
		ToolMode.TRACK:
			_update_track_preview(snapped)
		ToolMode.STATION:
			var station_pos := _aligned_network_position(snapped, station_track_snap_radius)
			_update_fixed_asset_preview(station_pos, _station_build_cost(), _station_preview_size(), _can_place_station_at(station_pos), "Station")
		ToolMode.DEPOT:
			var depot_pos := _aligned_network_position(snapped, depot_track_snap_radius)
			_update_fixed_asset_preview(depot_pos, depot_cost, Vector3(18.0, 4.0, 12.0), _can_place_depot_at(depot_pos), "Depot")
		ToolMode.SIGNAL:
			_update_signal_preview(_aligned_network_position(snapped, signal_track_snap_radius))
		ToolMode.BULLDOZE:
			_update_bulldoze_preview(snapped)

func _update_track_preview(snapped: Vector3) -> void:
	_set_marker_size(marker_size)
	_preview_marker.set_surface_override_material(0, _preview_material_marker)
	_preview_marker.global_position = snapped + Vector3(0.0, marker_size.y * 0.5 + 0.04, 0.0)
	_preview_marker.rotation = Vector3.ZERO
	if not (_anchor_point is Vector3):
		_preview_message = "Click an anchor on the main line or built track%s" % (" | Autorail" if autorail_enabled else " | Direct")
		return
	var anchor: Vector3 = _anchor_point
	var points := _build_track_points(anchor, snapped)
	var length := _polyline_length(points)
	if length < 0.01:
		_preview_message = "Move cursor to set track end point"
		return
	_preview_cost = _track_cost(length)
	var valid: bool = length >= min_track_length and _track_builder != null and _track_builder.can_place_segment(points) and _can_afford(_preview_cost)
	_preview_valid = valid
	_preview_message = "%s track %.0fm" % ["Autorail" if autorail_enabled else "Direct", length] if valid else "Track too short, too steep, or unaffordable"
	_apply_polyline_preview(points, valid)

func _update_fixed_asset_preview(pos: Vector3, cost: float, size: Vector3, valid: bool, label: String) -> void:
	_preview_cost = cost
	_preview_valid = valid and _can_afford(cost)
	_preview_message = "%s ready" % label if _preview_valid else "%s needs track access, spacing, and funds" % label
	_set_marker_size(size)
	_preview_marker.global_position = pos + Vector3(0.0, size.y * 0.5 + 0.04, 0.0)
	_preview_marker.set_surface_override_material(0, _preview_material_valid if _preview_valid else _preview_material_invalid)
	_preview_marker.rotation = Vector3.ZERO
	if tool_mode == ToolMode.STATION or tool_mode == ToolMode.DEPOT:
		var forward := _placement_forward(pos)
		_preview_marker.rotation.y = atan2(forward.x, forward.z)

func _update_signal_preview(snapped: Vector3) -> void:
	_set_marker_size(Vector3(2.0, 7.5, 2.0))
	_preview_marker.set_surface_override_material(0, _preview_material_marker)
	_preview_marker.global_position = snapped + Vector3(0.0, 3.8, 0.0)
	_preview_marker.rotation = Vector3.ZERO
	if not (_anchor_point is Vector3):
		_preview_message = "Click start of signal run | %.0fm spacing" % signal_run_spacing_m
		return
	var anchor: Vector3 = _anchor_point
	var points := _build_track_points(anchor, snapped)
	var run := _build_signal_run(anchor, snapped)
	var cost := signal_cost * float(run.size())
	var valid := not run.is_empty() and _can_afford(cost)
	_preview_cost = cost
	_preview_valid = valid
	_preview_message = "Signal run %d posts | %.0fm spacing" % [run.size(), signal_run_spacing_m] if valid else "Signal run needs a straighter, accessible track segment"
	_apply_polyline_preview(points, valid)

func _update_bulldoze_preview(pos: Vector3) -> void:
	var target := _find_bulldoze_target(pos)
	_set_marker_size(Vector3(8.0, 2.0, 8.0))
	_preview_marker.set_surface_override_material(0, _preview_material_demolish)
	if target.is_empty():
		_preview_marker.global_position = pos + Vector3(0.0, 1.1, 0.0)
		_preview_valid = false
		_preview_message = "Nothing removable under cursor"
		_preview_cost = 0.0
		return
	var target_pos: Vector3 = target.get("position", pos)
	_preview_marker.global_position = target_pos + Vector3(0.0, 1.1, 0.0)
	_preview_valid = true
	_preview_cost = -float(target.get("refund", 0.0))
	_preview_message = "Bulldoze %s" % String(target.get("kind", "asset")).capitalize()

func _set_marker_size(size: Vector3) -> void:
	var mesh := _preview_marker.mesh as BoxMesh
	if mesh != null:
		mesh.size = size
	var anchor_mesh := _anchor_marker.mesh as BoxMesh
	if anchor_mesh != null:
		anchor_mesh.size = marker_size

func _can_place_station_at(pos: Vector3) -> bool:
	if _is_water(pos):
		return false
	if _ground_grade_delta(pos) > max_station_grade_delta_m:
		return false
	if _nearest_stop_distance(pos) < station_spacing_m + float(station_platform_length_tiles - 1) * 12.0:
		return false
	return _distance_to_track_network(pos) <= station_track_snap_radius

func _can_place_depot_at(pos: Vector3) -> bool:
	if _is_water(pos):
		return false
	if _ground_grade_delta(pos) > max_depot_grade_delta_m:
		return false
	if _nearest_placed_distance(pos, "depot") < depot_spacing_m:
		return false
	return _distance_to_track_network(pos) <= depot_track_snap_radius

func _can_place_signal_at(pos: Vector3) -> bool:
	if _is_water(pos):
		return false
	if _ground_grade_delta(pos) > max_signal_grade_delta_m:
		return false
	if _nearest_placed_distance(pos, "signal") < signal_spacing_m:
		return false
	return _distance_to_track_network(pos) <= signal_track_snap_radius

func _distance_to_track_network(pos: Vector3) -> float:
	var best := INF
	var network_snap := _nearest_network_snap(pos, INF)
	if network_snap.has("distance"):
		best = float(network_snap.get("distance", INF))
	return best

func _nearest_stop_distance(pos: Vector3) -> float:
	if _town_manager == null:
		return INF
	var best := INF
	for stop in _town_manager.stops:
		if stop == null:
			continue
		best = minf(best, pos.distance_to(stop.position))
	return best

func _nearest_placed_distance(pos: Vector3, kind: String) -> float:
	if _placed_root == null:
		return INF
	var best := INF
	for child in _placed_root.get_children():
		if child is Node3D and String(child.get_meta("build_kind", "")) == kind:
			best = minf(best, pos.distance_to((child as Node3D).global_position))
	return best

func _find_bulldoze_target(pos: Vector3) -> Dictionary:
	var best := {}
	var best_distance := bulldoze_radius
	if _track_builder != null and _has_property(_track_builder, "segments"):
		for curve_variant in _track_builder.get("segments"):
			var curve := curve_variant as Curve3D
			if curve == null:
				continue
			var closest := curve.get_closest_point(pos)
			var distance := closest.distance_to(pos)
			if distance <= best_distance:
				best_distance = distance
				best = {
					"kind": "track",
					"position": closest,
					"refund": _track_cost(float(curve.get_baked_length())) * bulldoze_refund_ratio
				}
	for stop in (_town_manager.stops if _town_manager != null else []):
		if stop == null:
			continue
		var distance: float = stop.position.distance_to(pos)
		if distance <= best_distance:
			best_distance = distance
			best = {
				"kind": "stop",
				"position": stop.position,
				"stop": stop,
				"refund": station_cost * bulldoze_refund_ratio
			}
	if _placed_root != null:
		for child in _placed_root.get_children():
			if not (child is Node3D):
				continue
			var node := child as Node3D
			var distance := node.global_position.distance_to(pos)
			if distance <= best_distance:
				best_distance = distance
				best = {
					"kind": "placed",
					"position": node.global_position,
					"node": node,
					"refund": float(node.get_meta("build_cost", 0.0)) * bulldoze_refund_ratio
				}
	return best

func _set_preview_track_segments_visible(visible_count: int) -> void:
	_ensure_preview_track_segment_count(visible_count)
	for i in range(_preview_track_segments.size()):
		_preview_track_segments[i].visible = i < visible_count

func _ensure_preview_track_segment_count(count: int) -> void:
	if _preview_root == null:
		return
	while _preview_track_segments.size() < count:
		var segment := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(track_preview_width, preview_height, 1.0)
		segment.mesh = mesh
		segment.set_surface_override_material(0, _preview_material_valid)
		_preview_root.add_child(segment)
		_preview_track_segments.append(segment)

func _apply_polyline_preview(points: PackedVector3Array, valid: bool) -> void:
	var segment_count := maxi(0, points.size() - 1)
	_set_preview_track_segments_visible(segment_count)
	for i in range(segment_count):
		var a: Vector3 = points[i]
		var b: Vector3 = points[i + 1]
		var segment := _preview_track_segments[i]
		var length := a.distance_to(b)
		if length < 0.05:
			segment.visible = false
			continue
		segment.visible = true
		segment.set_surface_override_material(0, _preview_material_valid if valid else _preview_material_invalid)
		var mesh := segment.mesh as BoxMesh
		mesh.size = Vector3(track_preview_width, preview_height, length)
		segment.global_transform = _segment_transform(a, b, preview_height * 0.5 + 0.03)

func _build_track_points(anchor: Vector3, snapped: Vector3) -> PackedVector3Array:
	var direct := PackedVector3Array([anchor, snapped])
	if not autorail_enabled:
		return direct
	if absf(anchor.x - snapped.x) <= 0.5 or absf(anchor.z - snapped.z) <= 0.5:
		return direct
	var corner_a := _with_ground_height(Vector3(snapped.x, 0.0, anchor.z))
	var corner_b := _with_ground_height(Vector3(anchor.x, 0.0, snapped.z))
	var candidate_a := _compact_polyline(PackedVector3Array([anchor, corner_a, snapped]))
	var candidate_b := _compact_polyline(PackedVector3Array([anchor, corner_b, snapped]))
	var candidate_a_water := _polyline_has_water(candidate_a)
	var candidate_b_water := _polyline_has_water(candidate_b)
	if candidate_a_water and not candidate_b_water:
		return candidate_b
	if candidate_b_water and not candidate_a_water:
		return candidate_a
	var grade_a := _path_max_grade(candidate_a)
	var grade_b := _path_max_grade(candidate_b)
	if grade_a < grade_b:
		return candidate_a
	if grade_b < grade_a:
		return candidate_b
	return candidate_a if absf(snapped.x - anchor.x) >= absf(snapped.z - anchor.z) else candidate_b

func _compact_polyline(points: PackedVector3Array) -> PackedVector3Array:
	var compacted := PackedVector3Array()
	for point in points:
		if compacted.is_empty() or compacted[compacted.size() - 1].distance_to(point) > 0.25:
			compacted.append(point)
	return compacted

func _polyline_length(points: PackedVector3Array) -> float:
	var total := 0.0
	for i in range(maxi(0, points.size() - 1)):
		total += points[i].distance_to(points[i + 1])
	return total

func _path_max_grade(points: PackedVector3Array) -> float:
	var worst := 0.0
	for i in range(maxi(0, points.size() - 1)):
		var a: Vector3 = points[i]
		var b: Vector3 = points[i + 1]
		var horizontal := Vector2(b.x - a.x, b.z - a.z).length()
		if horizontal <= 0.01:
			continue
		worst = maxf(worst, absf(b.y - a.y) / horizontal)
	return worst

func _polyline_has_water(points: PackedVector3Array) -> bool:
	for point in points:
		if _is_water(point):
			return true
	return false

func _sample_polyline(points: PackedVector3Array, distance_along: float) -> Vector3:
	if points.is_empty():
		return Vector3.ZERO
	var remaining := maxf(distance_along, 0.0)
	for i in range(maxi(0, points.size() - 1)):
		var a: Vector3 = points[i]
		var b: Vector3 = points[i + 1]
		var segment_length := a.distance_to(b)
		if segment_length <= 0.01:
			continue
		if remaining <= segment_length:
			return a.lerp(b, remaining / segment_length)
		remaining -= segment_length
	return points[points.size() - 1]

func _polyline_direction_at_distance(points: PackedVector3Array, distance_along: float) -> Vector3:
	if points.size() < 2:
		return Vector3.FORWARD
	var remaining := maxf(distance_along, 0.0)
	for i in range(points.size() - 1):
		var a: Vector3 = points[i]
		var b: Vector3 = points[i + 1]
		var segment := b - a
		var segment_length := segment.length()
		if segment_length <= 0.01:
			continue
		if remaining <= segment_length:
			return segment.normalized()
		remaining -= segment_length
	return (points[points.size() - 1] - points[points.size() - 2]).normalized()

func _build_signal_run(anchor: Vector3, snapped: Vector3) -> Array[Dictionary]:
	var run: Array[Dictionary] = []
	var points := _build_track_points(anchor, snapped)
	var total_length := _polyline_length(points)
	if total_length < 8.0:
		return run
	var spacing := maxf(signal_spacing_m, signal_run_spacing_m)
	var sample_distance := 0.0
	while sample_distance <= total_length + 0.01:
		var pos := _sample_polyline(points, minf(sample_distance, total_length))
		if not _can_place_signal_at(pos):
			return []
		run.append({
			"position": pos,
			"forward": _polyline_direction_at_distance(points, sample_distance)
		})
		sample_distance += spacing
	if run.is_empty():
		return []
	var last_pos: Vector3 = run[run.size() - 1].get("position", Vector3.ZERO)
	var end_pos := _sample_polyline(points, total_length)
	if last_pos.distance_to(end_pos) > spacing * 0.45:
		if not _can_place_signal_at(end_pos):
			return []
		run.append({
			"position": end_pos,
			"forward": _polyline_direction_at_distance(points, total_length)
		})
	return run

func _track_cost(length_m: float) -> float:
	return maxf(0.0, length_m) * track_cost_per_meter

func _try_spend(cost: float) -> bool:
	if cost <= 0.0:
		return true
	if _economy != null and _economy.has_method("spend_capital"):
		return bool(_economy.call("spend_capital", cost))
	if _economy != null and _economy.has_method("apply_expense"):
		_economy.call("apply_expense", cost)
		return true
	return true

func _apply_refund(refund: float) -> void:
	if refund <= 0.0:
		return
	if _economy != null and _economy.has_method("refund_capital"):
		_economy.call("refund_capital", refund)
		return
	if _economy != null and _economy.has_method("apply_revenue"):
		_economy.call("apply_revenue", refund)

func _available_cash() -> float:
	if _economy != null and _has_property(_economy, "cash"):
		return float(_economy.get("cash"))
	return 0.0

func _can_afford(cost: float) -> bool:
	if cost <= 0.0:
		return true
	if _economy != null and _economy.has_method("can_afford"):
		return bool(_economy.call("can_afford", cost))
	return true

func _build_station_node(pos: Vector3, forward: Vector3, stop_id: String, build_cost: float) -> Node3D:
	var root := Node3D.new()
	root.name = "Station_%d" % Time.get_ticks_msec()
	root.global_position = _with_ground_height(pos)
	root.rotation.y = atan2(forward.x, forward.z)
	root.set_meta("build_kind", "station_asset")
	root.set_meta("build_cost", build_cost)
	if stop_id != "":
		root.set_meta("stop_id", stop_id)

	var length := float(station_platform_length_tiles) * station_tile_length_m
	var total_width := _station_preview_size().x
	var platform_offset := total_width * 0.5 - station_platform_width_m * 0.5 - 1.2

	var roadbed := MeshInstance3D.new()
	var roadbed_mesh := BoxMesh.new()
	roadbed_mesh.size = Vector3(total_width + 8.0, 0.58, length + 4.0)
	roadbed.mesh = roadbed_mesh
	var roadbed_mat := StandardMaterial3D.new()
	roadbed_mat.albedo_color = Color("786a58")
	roadbed_mat.roughness = 0.96
	roadbed.set_surface_override_material(0, roadbed_mat)
	roadbed.position = Vector3(0.0, 0.29, 0.0)
	root.add_child(roadbed)

	var ballast := MeshInstance3D.new()
	var ballast_mesh := BoxMesh.new()
	ballast_mesh.size = Vector3(total_width + 2.6, 0.22, length + 1.5)
	ballast.mesh = ballast_mesh
	var ballast_mat := StandardMaterial3D.new()
	ballast_mat.albedo_color = Color("655b4e")
	ballast_mat.roughness = 0.98
	ballast.set_surface_override_material(0, ballast_mat)
	ballast.position = Vector3(0.0, 0.58, 0.0)
	root.add_child(ballast)

	for side in [-1.0, 1.0]:
		var platform := MeshInstance3D.new()
		var platform_mesh := BoxMesh.new()
		platform_mesh.size = Vector3(station_platform_width_m, 0.8, length)
		platform.mesh = platform_mesh
		var platform_mat := StandardMaterial3D.new()
		platform_mat.albedo_color = Color("d8ccb3")
		platform_mat.roughness = 0.95
		platform.set_surface_override_material(0, platform_mat)
		platform.position = Vector3(platform_offset * side, 0.55, 0.0)
		root.add_child(platform)

		var canopy := MeshInstance3D.new()
		var canopy_mesh := BoxMesh.new()
		canopy_mesh.size = Vector3(station_platform_width_m + 1.2, 0.2, length * 0.86)
		canopy.mesh = canopy_mesh
		var canopy_mat := StandardMaterial3D.new()
		canopy_mat.albedo_color = Color("705c4b")
		canopy_mat.roughness = 0.76
		canopy.set_surface_override_material(0, canopy_mat)
		canopy.position = Vector3(platform_offset * side, 3.4, 0.0)
		root.add_child(canopy)

		var edge := MeshInstance3D.new()
		var edge_mesh := BoxMesh.new()
		edge_mesh.size = Vector3(0.18, 0.92, length)
		edge.mesh = edge_mesh
		var edge_mat := StandardMaterial3D.new()
		edge_mat.albedo_color = Color("efe4c4")
		edge_mat.roughness = 0.88
		edge.set_surface_override_material(0, edge_mat)
		var inside_edge: float = platform_offset * side - side * (station_platform_width_m * 0.5 - 0.09)
		edge.position = Vector3(inside_edge, 0.72, 0.0)
		root.add_child(edge)

	var track_base_offset := -float(station_track_count - 1) * station_track_spacing_m * 0.5
	for i in range(station_track_count):
		var offset := track_base_offset + float(i) * station_track_spacing_m
		var bed := MeshInstance3D.new()
		var bed_mesh := BoxMesh.new()
		bed_mesh.size = Vector3(3.2, 0.2, length + 1.2)
		bed.mesh = bed_mesh
		var bed_mat := StandardMaterial3D.new()
		bed_mat.albedo_color = Color("63584a")
		bed_mat.roughness = 0.98
		bed.set_surface_override_material(0, bed_mat)
		bed.position = Vector3(offset, 0.62, 0.0)
		root.add_child(bed)

		var sleeper_count := maxi(1, int(floor(length / 1.4)))
		for sleeper_index in range(sleeper_count):
			var sleeper := MeshInstance3D.new()
			var sleeper_mesh := BoxMesh.new()
			sleeper_mesh.size = Vector3(2.9, 0.12, 0.22)
			sleeper.mesh = sleeper_mesh
			var sleeper_mat := StandardMaterial3D.new()
			sleeper_mat.albedo_color = Color("7b6b58")
			sleeper_mat.roughness = 0.94
			sleeper.set_surface_override_material(0, sleeper_mat)
			var sleeper_z := lerpf(-length * 0.5 + 0.5, length * 0.5 - 0.5, (float(sleeper_index) + 0.5) / float(sleeper_count))
			sleeper.position = Vector3(offset, 0.76, sleeper_z)
			root.add_child(sleeper)

		for rail_side in [-1.0, 1.0]:
			var rail := MeshInstance3D.new()
			var rail_mesh := BoxMesh.new()
			rail_mesh.size = Vector3(0.12, 0.24, length + 1.0)
			rail.mesh = rail_mesh
			var rail_mat := StandardMaterial3D.new()
			rail_mat.albedo_color = Color("b5aba0")
			rail_mat.metallic = 0.78
			rail_mat.roughness = 0.3
			rail.set_surface_override_material(0, rail_mat)
			rail.position = Vector3(offset + rail_side * 0.78, 0.84, 0.0)
			root.add_child(rail)
	return root

func _build_depot_node(pos: Vector3, forward: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = "Depot_%d" % Time.get_ticks_msec()
	root.global_position = _with_ground_height(pos)
	root.rotation.y = atan2(forward.x, forward.z)
	root.set_meta("build_kind", "depot")
	root.set_meta("build_id", root.name)
	root.set_meta("build_label", "Depot")
	root.set_meta("build_cost", depot_cost)

	var apron := MeshInstance3D.new()
	var apron_mesh := BoxMesh.new()
	apron_mesh.size = Vector3(16.0, 0.55, 34.0)
	apron.mesh = apron_mesh
	var apron_mat := StandardMaterial3D.new()
	apron_mat.albedo_color = Color("6b6258")
	apron_mat.roughness = 0.96
	apron.set_surface_override_material(0, apron_mat)
	apron.position = Vector3(0.0, 0.28, 9.0)
	root.add_child(apron)

	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(22.0, 8.6, 16.0)
	body.mesh = body_mesh
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color("7e4f3a")
	body_mat.roughness = 0.92
	body.set_surface_override_material(0, body_mat)
	body.position = Vector3(0.0, 4.3, 0.0)
	root.add_child(body)

	var roof := MeshInstance3D.new()
	var roof_mesh := BoxMesh.new()
	roof_mesh.size = Vector3(24.0, 0.9, 18.0)
	roof.mesh = roof_mesh
	var roof_mat := StandardMaterial3D.new()
	roof_mat.albedo_color = Color("3c3732")
	roof_mat.roughness = 0.48
	roof_mat.metallic = 0.16
	roof.set_surface_override_material(0, roof_mat)
	roof.position = Vector3(0.0, 8.95, 0.0)
	root.add_child(roof)

	var monitor := MeshInstance3D.new()
	var monitor_mesh := BoxMesh.new()
	monitor_mesh.size = Vector3(10.0, 2.2, 13.8)
	monitor.mesh = monitor_mesh
	var monitor_mat := StandardMaterial3D.new()
	monitor_mat.albedo_color = Color("c8b79e")
	monitor_mat.roughness = 0.88
	monitor.set_surface_override_material(0, monitor_mat)
	monitor.position = Vector3(0.0, 9.95, 0.0)
	root.add_child(monitor)

	var monitor_roof := MeshInstance3D.new()
	var monitor_roof_mesh := BoxMesh.new()
	monitor_roof_mesh.size = Vector3(11.0, 0.45, 14.8)
	monitor_roof.mesh = monitor_roof_mesh
	monitor_roof.set_surface_override_material(0, roof_mat)
	monitor_roof.position = Vector3(0.0, 11.25, 0.0)
	root.add_child(monitor_roof)

	var office := MeshInstance3D.new()
	var office_mesh := BoxMesh.new()
	office_mesh.size = Vector3(8.6, 4.8, 9.6)
	office.mesh = office_mesh
	var office_mat := StandardMaterial3D.new()
	office_mat.albedo_color = Color("cdb79b")
	office_mat.roughness = 0.9
	office.set_surface_override_material(0, office_mat)
	office.position = Vector3(8.0, 2.4, -1.6)
	root.add_child(office)

	var office_roof := MeshInstance3D.new()
	var office_roof_mesh := BoxMesh.new()
	office_roof_mesh.size = Vector3(9.4, 0.42, 10.4)
	office_roof.mesh = office_roof_mesh
	office_roof.set_surface_override_material(0, roof_mat)
	office_roof.position = Vector3(8.0, 4.95, -1.6)
	root.add_child(office_roof)

	var arch := MeshInstance3D.new()
	var arch_mesh := BoxMesh.new()
	arch_mesh.size = Vector3(10.6, 7.0, 1.0)
	arch.mesh = arch_mesh
	arch.set_surface_override_material(0, body_mat)
	arch.position = Vector3(0.0, 3.6, 8.1)
	root.add_child(arch)

	var door := MeshInstance3D.new()
	var door_mesh := BoxMesh.new()
	door_mesh.size = Vector3(7.4, 5.9, 0.8)
	door.mesh = door_mesh
	var door_mat := StandardMaterial3D.new()
	door_mat.albedo_color = Color("2e2924")
	door_mat.roughness = 0.78
	door.set_surface_override_material(0, door_mat)
	door.position = Vector3(0.0, 2.9, 8.55)
	root.add_child(door)

	var lead := MeshInstance3D.new()
	var lead_mesh := BoxMesh.new()
	lead_mesh.size = Vector3(3.0, 0.18, 22.0)
	lead.mesh = lead_mesh
	var lead_mat := StandardMaterial3D.new()
	lead_mat.albedo_color = Color("5f584c")
	lead_mat.roughness = 0.95
	lead.set_surface_override_material(0, lead_mat)
	lead.position = Vector3(0.0, 0.7, 17.0)
	root.add_child(lead)

	var depot_sleeper_count := maxi(1, int(floor(18.0 / 1.4)))
	for sleeper_index in range(depot_sleeper_count):
		var sleeper := MeshInstance3D.new()
		var sleeper_mesh := BoxMesh.new()
		sleeper_mesh.size = Vector3(2.8, 0.12, 0.22)
		sleeper.mesh = sleeper_mesh
		var sleeper_mat := StandardMaterial3D.new()
		sleeper_mat.albedo_color = Color("7b6b58")
		sleeper_mat.roughness = 0.94
		sleeper.set_surface_override_material(0, sleeper_mat)
		var sleeper_z := lerpf(8.0, 26.0, (float(sleeper_index) + 0.5) / float(depot_sleeper_count))
		sleeper.position = Vector3(0.0, 0.82, sleeper_z)
		root.add_child(sleeper)

	for rail_side in [-1.0, 1.0]:
		var rail := MeshInstance3D.new()
		var rail_mesh := BoxMesh.new()
		rail_mesh.size = Vector3(0.12, 0.22, 22.2)
		rail.mesh = rail_mesh
		var rail_mat := StandardMaterial3D.new()
		rail_mat.albedo_color = Color("b5aba0")
		rail_mat.metallic = 0.78
		rail_mat.roughness = 0.3
		rail.set_surface_override_material(0, rail_mat)
		rail.position = Vector3(rail_side * 0.78, 0.86, 17.0)
		root.add_child(rail)

	for pilaster_side in [-1.0, 1.0]:
		for z_pos in [-5.0, 0.0, 5.0]:
			var pilaster := MeshInstance3D.new()
			var pilaster_mesh := BoxMesh.new()
			pilaster_mesh.size = Vector3(0.7, 7.8, 0.7)
			pilaster.mesh = pilaster_mesh
			pilaster.set_surface_override_material(0, body_mat)
			pilaster.position = Vector3(pilaster_side * 10.4, 3.9, z_pos)
			root.add_child(pilaster)

	var fascia := MeshInstance3D.new()
	var fascia_mesh := BoxMesh.new()
	fascia_mesh.size = Vector3(22.8, 0.28, 1.0)
	fascia.mesh = fascia_mesh
	fascia.set_surface_override_material(0, office_mat)
	fascia.position = Vector3(0.0, 6.4, 8.45)
	root.add_child(fascia)

	var sign := Label3D.new()
	sign.text = "CARHOUSE"
	sign.font_size = 26
	sign.modulate = Color(0.96, 0.93, 0.87, 1.0)
	sign.position = Vector3(0.0, 6.85, 8.8)
	root.add_child(sign)

	for lamp_side in [-1.0, 1.0]:
		var lamp := OmniLight3D.new()
		lamp.light_energy = 0.42
		lamp.light_color = Color(1.0, 0.94, 0.84)
		lamp.omni_range = 10.0
		lamp.position = Vector3(lamp_side * 3.8, 5.1, 8.6)
		root.add_child(lamp)
	return root

func _build_signal_node(pos: Vector3, forward: Vector3) -> Node3D:
	var root := Node3D.new()
	root.name = "ManualSignal_%d" % Time.get_ticks_msec()
	root.global_position = _with_ground_height(pos)
	root.rotation.y = atan2(forward.x, forward.z)
	root.set_meta("build_kind", "signal")
	root.set_meta("build_cost", signal_cost)

	var pole := MeshInstance3D.new()
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.08
	pole_mesh.bottom_radius = 0.1
	pole_mesh.height = 6.6
	pole.mesh = pole_mesh
	var pole_mat := StandardMaterial3D.new()
	pole_mat.albedo_color = Color("2d2b28")
	pole_mat.roughness = 0.84
	pole.set_surface_override_material(0, pole_mat)
	pole.position = Vector3(0.0, 3.3, 0.0)
	root.add_child(pole)

	var head := MeshInstance3D.new()
	var head_mesh := BoxMesh.new()
	head_mesh.size = Vector3(0.42, 0.9, 0.26)
	head.mesh = head_mesh
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color("141414")
	head_mat.roughness = 0.55
	head.set_surface_override_material(0, head_mat)
	head.position = Vector3(0.0, 5.8, 0.0)
	root.add_child(head)

	var lamp := MeshInstance3D.new()
	var lamp_mesh := SphereMesh.new()
	lamp_mesh.radius = 0.11
	lamp_mesh.height = 0.22
	lamp.mesh = lamp_mesh
	var lamp_mat := StandardMaterial3D.new()
	lamp_mat.albedo_color = Color("6fbd63")
	lamp_mat.emission_enabled = true
	lamp_mat.emission = Color("6fbd63")
	lamp_mat.emission_energy_multiplier = 2.0
	lamp.set_surface_override_material(0, lamp_mat)
	lamp.position = Vector3(0.0, 5.8, 0.16)
	root.add_child(lamp)
	return root

func _placement_forward(pos: Vector3) -> Vector3:
	var snap := _nearest_network_snap(pos, 120.0)
	var best_forward := Vector3.FORWARD
	if snap.has("direction"):
		best_forward = snap.get("direction", Vector3.FORWARD)
	if best_forward.length() <= 0.01 and _anchor_point is Vector3:
		var anchor: Vector3 = _anchor_point
		var dir: Vector3 = (anchor - pos).normalized()
		if dir.length() > 0.01:
			best_forward = dir
	if best_forward.length() <= 0.01:
		best_forward = Vector3.FORWARD
	if tool_mode == ToolMode.STATION or tool_mode == ToolMode.DEPOT:
		best_forward = best_forward.rotated(Vector3.UP, deg_to_rad(asset_rotation_deg))
	return best_forward.normalized()

func _emit_tool_state() -> void:
	emit_signal("tool_state_changed", active, int(tool_mode), _anchor_point is Vector3)

func _resolve_terrain_backdrop() -> Node:
	var world_root := get_parent()
	if world_root == null:
		return null
	if world_root.has_node("Terrain/Route9Backdrop"):
		return world_root.get_node("Terrain/Route9Backdrop")
	return null

func _ground_height_at(pos: Vector3) -> float:
	if _terrain_backdrop != null and _terrain_backdrop.has_method("ground_height_at"):
		return float(_terrain_backdrop.call("ground_height_at", pos))
	return 0.0

func _ground_grade_delta(pos: Vector3) -> float:
	var sample := 7.5
	var center := _ground_height_at(pos)
	var dx := absf(_ground_height_at(pos + Vector3(sample, 0.0, 0.0)) - center)
	var dz := absf(_ground_height_at(pos + Vector3(0.0, 0.0, sample)) - center)
	return maxf(dx, dz)

func _is_water(pos: Vector3) -> bool:
	if _terrain_backdrop != null and _terrain_backdrop.has_method("is_water_at"):
		return bool(_terrain_backdrop.call("is_water_at", pos))
	return false

func _with_ground_height(pos: Vector3, extra := 0.0) -> Vector3:
	return Vector3(pos.x, _ground_height_at(pos) + extra, pos.z)

func _has_property(target: Object, prop_name: String) -> bool:
	if target == null:
		return false
	for prop in target.get_property_list():
		if String(prop.get("name", "")) == prop_name:
			return true
	return false

func _money_text(amount: float) -> String:
	return String.num(amount, 0)

func _segment_transform(a: Vector3, b: Vector3, lift_y: float = 0.0) -> Transform3D:
	var midpoint := (a + b) * 0.5 + Vector3(0.0, lift_y, 0.0)
	var forward := (b - a).normalized()
	if forward.length() <= 0.001:
		return Transform3D(Basis(), midpoint)
	var right := Vector3.UP.cross(forward)
	if right.length() <= 0.001:
		right = Vector3.RIGHT
	right = right.normalized()
	var up := forward.cross(right).normalized()
	return Transform3D(Basis(right, up, forward), midpoint)
