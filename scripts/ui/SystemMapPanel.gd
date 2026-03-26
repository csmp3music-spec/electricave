extends Control
class_name SystemMapPanel

signal navigation_requested(payload: Dictionary)

@export_file("*.jpg", "*.jpeg", "*.png", "*.webp") var background_path := "res://assets/maps/bw_airline_1908.jpg"
@export var refresh_interval := 0.2

var corridor: Node
var _background: Texture2D
var _snapshot := {}
var _refresh_accum := 0.0
var _map_rect := Rect2()
var _hover_payload := {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	anchor_left = 0.06
	anchor_top = 0.06
	anchor_right = 0.94
	anchor_bottom = 0.60
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	visible = false
	_background = _load_background()

func _process(delta: float) -> void:
	if not visible:
		return
	_refresh_accum += delta
	if _refresh_accum < refresh_interval:
		return
	_refresh_accum = 0.0
	refresh_snapshot()

func set_corridor(target: Node) -> void:
	corridor = target
	refresh_snapshot()

func set_open(open: bool) -> void:
	visible = open
	if open:
		_refresh_accum = 0.0
		refresh_snapshot()

func refresh_snapshot() -> void:
	if corridor == null or not is_instance_valid(corridor) or not corridor.has_method("get_system_map_snapshot"):
		_snapshot = {}
	else:
		_snapshot = corridor.call("get_system_map_snapshot")
	queue_redraw()

func _draw() -> void:
	var outer := Rect2(Vector2.ZERO, size)
	draw_rect(outer, Color(0.95, 0.89, 0.78, 0.96), true)
	draw_rect(outer, Color(0.63, 0.49, 0.29, 1.0), false, 3.0)
	var font := ThemeDB.fallback_font
	var title_pos := Vector2(22.0, 28.0)
	if font != null:
		draw_string(font, title_pos, "Boston & Worcester System Map", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 20, Color(0.23, 0.16, 0.08, 1.0))
	var map_rect := Rect2(18.0, 40.0, maxf(120.0, size.x - 36.0), maxf(120.0, size.y - 64.0))
	_map_rect = map_rect
	if _background != null:
		draw_texture_rect(_background, map_rect, false)
	else:
		draw_rect(map_rect, Color(0.77, 0.71, 0.60, 1.0), true)
	draw_rect(map_rect, Color(0.43, 0.32, 0.20, 0.85), false, 2.0)
	_draw_route(map_rect)
	_draw_stops(map_rect)
	_draw_trolleys(map_rect)
	if font != null:
		var footer := "Click a stop or map point to jump there. Click a trolley to take control of it."
		if not _hover_payload.is_empty():
			footer = String(_hover_payload.get("hint", footer))
		draw_string(font, Vector2(22.0, size.y - 12.0), footer, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color(0.28, 0.19, 0.09, 0.92))

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseMotion:
		_update_hover((event as InputEventMouseMotion).position)
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			var payload := _hit_payload(mouse_event.position, true)
			if payload.is_empty():
				return
			emit_signal("navigation_requested", payload)
			accept_event()

func _update_hover(point: Vector2) -> void:
	var payload := _hit_payload(point, false)
	var next_hint := String(payload.get("hint", ""))
	var current_hint := String(_hover_payload.get("hint", ""))
	if next_hint == current_hint:
		return
	_hover_payload = payload
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if not payload.is_empty() else Control.CURSOR_ARROW
	queue_redraw()

func _draw_route(map_rect: Rect2) -> void:
	var bounds_min: Vector3 = _snapshot.get("bounds_min", Vector3.ZERO)
	var bounds_max: Vector3 = _snapshot.get("bounds_max", Vector3.ONE)
	var routes: Array = _snapshot.get("routes", [])
	if routes.is_empty():
		var route: PackedVector3Array = _snapshot.get("route_points", PackedVector3Array())
		if route.size() < 2:
			return
		var fallback_points: PackedVector2Array = PackedVector2Array()
		for point in route:
			fallback_points.append(_world_to_map(point, map_rect, bounds_min, bounds_max))
		draw_polyline(fallback_points, Color(1.0, 0.90, 0.62, 0.45), 7.0, true)
		draw_polyline(fallback_points, Color(0.69, 0.11, 0.10, 0.92), 3.0, true)
		return
	for route_variant in routes:
		var route_entry: Dictionary = route_variant
		var route_points: PackedVector3Array = route_entry.get("points", PackedVector3Array())
		if route_points.size() < 2:
			continue
		var color: Color = route_entry.get("color", Color("9c5132"))
		var points: PackedVector2Array = PackedVector2Array()
		for point in route_points:
			points.append(_world_to_map(point, map_rect, bounds_min, bounds_max))
		draw_polyline(points, color.lightened(0.45), 6.0, true)
		draw_polyline(points, color, 2.6, true)

func _draw_stops(map_rect: Rect2) -> void:
	var stops: Array = _snapshot.get("stops", [])
	var bounds_min: Vector3 = _snapshot.get("bounds_min", Vector3.ZERO)
	var bounds_max: Vector3 = _snapshot.get("bounds_max", Vector3.ONE)
	for stop_variant in stops:
		var stop: Dictionary = stop_variant
		var stop_pos: Vector3 = stop.get("position", Vector3.ZERO)
		var point := _world_to_map(stop_pos, map_rect, bounds_min, bounds_max)
		var is_hover := _hover_matches("stop", String(stop.get("name", "")))
		draw_circle(point, 3.0, Color(0.95, 0.89, 0.70, 0.9))
		draw_circle(point, 1.4, Color(0.39, 0.18, 0.12, 0.96))
		if is_hover:
			draw_circle(point, 8.0, Color(0.90, 0.72, 0.26, 0.26))

func _draw_trolleys(map_rect: Rect2) -> void:
	var trolleys: Array = _snapshot.get("trolleys", [])
	var bounds_min: Vector3 = _snapshot.get("bounds_min", Vector3.ZERO)
	var bounds_max: Vector3 = _snapshot.get("bounds_max", Vector3.ONE)
	for trolley_variant in trolleys:
		var trolley: Dictionary = trolley_variant
		var trolley_pos: Vector3 = trolley.get("position", Vector3.ZERO)
		var point := _world_to_map(trolley_pos, map_rect, bounds_min, bounds_max)
		var fill := Color(0.18, 0.62, 0.28, 0.96) if bool(trolley.get("controlled", false)) else Color(0.77, 0.18, 0.15, 0.94)
		var is_hover := _hover_matches("trolley", String(trolley.get("car_index", "")))
		draw_circle(point, 6.0, Color(0.07, 0.06, 0.04, 0.86))
		draw_circle(point, 4.0, fill)
		if is_hover:
			draw_circle(point, 10.0, Color(0.90, 0.72, 0.26, 0.24))

func _world_to_map(point: Vector3, map_rect: Rect2, bounds_min: Vector3, bounds_max: Vector3) -> Vector2:
	var width := maxf(1.0, bounds_max.x - bounds_min.x)
	var depth := maxf(1.0, bounds_max.z - bounds_min.z)
	var nx := clampf((point.x - bounds_min.x) / width, 0.0, 1.0)
	var ny := clampf((point.z - bounds_min.z) / depth, 0.0, 1.0)
	var left := map_rect.position.x + map_rect.size.x * 0.05
	var right := map_rect.position.x + map_rect.size.x * 0.95
	var top := map_rect.position.y + map_rect.size.y * 0.08
	var bottom := map_rect.position.y + map_rect.size.y * 0.92
	return Vector2(lerpf(left, right, nx), lerpf(bottom, top, ny))

func _map_to_world(point: Vector2, map_rect: Rect2, bounds_min: Vector3, bounds_max: Vector3) -> Vector3:
	var left := map_rect.position.x + map_rect.size.x * 0.05
	var right := map_rect.position.x + map_rect.size.x * 0.95
	var top := map_rect.position.y + map_rect.size.y * 0.08
	var bottom := map_rect.position.y + map_rect.size.y * 0.92
	var nx := inverse_lerp(left, right, point.x)
	var ny := inverse_lerp(bottom, top, point.y)
	var x := lerpf(bounds_min.x, bounds_max.x, clampf(nx, 0.0, 1.0))
	var z := lerpf(bounds_min.z, bounds_max.z, clampf(ny, 0.0, 1.0))
	return Vector3(x, 0.0, z)

func _hover_matches(kind: String, id_value: String) -> bool:
	return String(_hover_payload.get("kind", "")) == kind and String(_hover_payload.get("id", "")) == id_value

func _hit_payload(point: Vector2, include_world: bool) -> Dictionary:
	if not _map_rect.has_point(point):
		return {}
	var bounds_min: Vector3 = _snapshot.get("bounds_min", Vector3.ZERO)
	var bounds_max: Vector3 = _snapshot.get("bounds_max", Vector3.ONE)
	var best_trolley := {}
	var best_trolley_dist := INF
	for trolley_variant in _snapshot.get("trolleys", []):
		var trolley: Dictionary = trolley_variant
		var trolley_pos: Vector3 = trolley.get("position", Vector3.ZERO)
		var map_point := _world_to_map(trolley_pos, _map_rect, bounds_min, bounds_max)
		var dist := map_point.distance_to(point)
		if dist < 11.0 and dist < best_trolley_dist:
			best_trolley_dist = dist
			var line_name := String(trolley.get("line_name", ""))
			best_trolley = {
				"kind": "trolley",
				"id": String(trolley.get("car_index", "")),
				"label": "%s Car %s" % [line_name, String(trolley.get("car_index", ""))],
				"hint": "Click to take control of %s Car %s" % [line_name, String(trolley.get("car_index", ""))],
				"position": trolley_pos,
				"trolley_index": int(trolley.get("car_index", 0))
			}
	if not best_trolley.is_empty():
		return best_trolley
	var best_stop := {}
	var best_stop_dist := INF
	for stop_variant in _snapshot.get("stops", []):
		var stop: Dictionary = stop_variant
		var stop_pos: Vector3 = stop.get("position", Vector3.ZERO)
		var map_point := _world_to_map(stop_pos, _map_rect, bounds_min, bounds_max)
		var dist := map_point.distance_to(point)
		if dist < 10.0 and dist < best_stop_dist:
			best_stop_dist = dist
			var line_name := String(stop.get("line_name", ""))
			best_stop = {
				"kind": "stop",
				"id": String(stop.get("name", "")),
				"label": "%s (%s)" % [String(stop.get("name", "")), line_name],
				"hint": "Click to jump to %s on %s" % [String(stop.get("name", "")), line_name],
				"position": stop_pos
			}
	if not best_stop.is_empty():
		return best_stop
	if not include_world:
		return {
			"kind": "map",
			"id": "map",
			"hint": "Click to move camera to this area"
		}
	return {
		"kind": "map",
		"id": "map",
		"label": "Map focus",
		"hint": "Click to move camera to this area",
		"position": _map_to_world(point, _map_rect, bounds_min, bounds_max)
	}

func _load_background() -> Texture2D:
	if background_path == "":
		return null
	var absolute_path := ProjectSettings.globalize_path(background_path)
	if not FileAccess.file_exists(absolute_path):
		return null
	var image := Image.new()
	var err := image.load(absolute_path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(image)
	return null
