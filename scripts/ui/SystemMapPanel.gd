extends Control
class_name SystemMapPanel

signal navigation_requested(payload: Dictionary)

@export_file("*.jpg", "*.jpeg", "*.png", "*.webp") var background_path := "res://assets/maps/bw_airline_1908.jpg"
@export var refresh_interval := 0.2

var corridor: Node
var _backdrop: Node
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
	_resolve_backdrop()
	refresh_snapshot()

func set_open(open: bool) -> void:
	visible = open
	if open:
		_refresh_accum = 0.0
		refresh_snapshot()

func refresh_snapshot() -> void:
	_resolve_backdrop()
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
		draw_rect(map_rect, Color(0.95, 0.93, 0.88, 0.18), true)
	else:
		draw_rect(map_rect, Color(0.77, 0.71, 0.60, 1.0), true)
	draw_rect(map_rect, Color(0.43, 0.32, 0.20, 0.85), false, 2.0)
	_draw_relief(map_rect)
	_draw_hydrography(map_rect)
	_draw_route(map_rect)
	_draw_towns(map_rect)
	_draw_stops(map_rect)
	_draw_trolleys(map_rect)
	_draw_north_arrow(map_rect)
	_draw_scale_bar(map_rect)
	_draw_service_legend(map_rect)
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

func _resolve_backdrop() -> void:
	_backdrop = null
	if corridor == null or not is_instance_valid(corridor):
		return
	var world_root := corridor.get_parent()
	if world_root == null:
		return
	_backdrop = world_root.get_node_or_null("Terrain/Route9Backdrop")

func _draw_relief(map_rect: Rect2) -> void:
	if _backdrop == null or not is_instance_valid(_backdrop):
		return
	var bounds_min: Vector3 = _snapshot.get("bounds_min", Vector3.ZERO)
	var bounds_max: Vector3 = _snapshot.get("bounds_max", Vector3.ONE)
	var hills: Array = _backdrop.call("get_hill_markers") if _backdrop.has_method("get_hill_markers") else []
	for hill_variant in hills:
		if not (hill_variant is Dictionary):
			continue
		var hill: Dictionary = hill_variant
		var hill_pos: Vector3 = hill.get("world_pos", Vector3.ZERO)
		var center := _world_to_map(hill_pos, map_rect, bounds_min, bounds_max)
		var radius_m := maxf(400.0, float(hill.get("radius_m", 1200.0)) * 0.42)
		var radius_px := _meters_to_map_size(Vector2(radius_m, radius_m), map_rect, bounds_min, bounds_max)
		if radius_px.x < 8.0 or radius_px.y < 8.0:
			continue
		var shadow := _ellipse_points(center + Vector2(radius_px.x * 0.12, radius_px.y * 0.10), radius_px * Vector2(1.04, 0.82), 24)
		var highlight := _ellipse_points(center + Vector2(-radius_px.x * 0.09, -radius_px.y * 0.08), radius_px * Vector2(0.88, 0.72), 24)
		draw_colored_polygon(shadow, Color(0.18, 0.22, 0.18, 0.11))
		draw_colored_polygon(highlight, Color(0.98, 0.97, 0.92, 0.06))
	var ridges: Array = _backdrop.call("get_ridge_markers") if _backdrop.has_method("get_ridge_markers") else []
	for ridge_variant in ridges:
		if not (ridge_variant is Dictionary):
			continue
		var ridge: Dictionary = ridge_variant
		var world_points: PackedVector2Array = ridge.get("world_points_xz", PackedVector2Array())
		if world_points.size() < 2:
			continue
		var points := PackedVector2Array()
		for point in world_points:
			points.append(_xz_to_map(point, map_rect, bounds_min, bounds_max))
		var width_px := clampf(_meters_to_map_width(float(ridge.get("width_m", 8000.0)) * 0.09, map_rect, bounds_min, bounds_max), 2.0, 10.0)
		var highlight_points := _offset_polyline(points, Vector2(-1.2, -1.2))
		draw_polyline(points, Color(0.24, 0.26, 0.22, 0.18), width_px, true)
		draw_polyline(highlight_points, Color(0.98, 0.97, 0.93, 0.09), maxf(1.0, width_px * 0.45), true)

func _draw_hydrography(map_rect: Rect2) -> void:
	if _backdrop == null or not is_instance_valid(_backdrop):
		return
	var bounds_min: Vector3 = _snapshot.get("bounds_min", Vector3.ZERO)
	var bounds_max: Vector3 = _snapshot.get("bounds_max", Vector3.ONE)
	var waters: Array = _backdrop.call("get_water_markers") if _backdrop.has_method("get_water_markers") else []
	for water_variant in waters:
		if not (water_variant is Dictionary):
			continue
		var water: Dictionary = water_variant
		var shape := String(water.get("shape", "ellipse"))
		var water_type := String(water.get("type", "lake"))
		var fill := Color(0.64, 0.79, 0.86, 0.58)
		var edge := Color(0.29, 0.46, 0.58, 0.72)
		if water_type in ["harbor", "bay", "coastal_inlet", "tidal_river"]:
			fill = Color(0.60, 0.75, 0.84, 0.54)
			edge = Color(0.24, 0.42, 0.55, 0.74)
		if shape == "river":
			var world_points: PackedVector2Array = water.get("world_points_xz", PackedVector2Array())
			if world_points.size() < 2:
				continue
			var points := PackedVector2Array()
			for point in world_points:
				points.append(_xz_to_map(point, map_rect, bounds_min, bounds_max))
			var river_width := clampf(_meters_to_map_width(float(water.get("width_m", 160.0)), map_rect, bounds_min, bounds_max), 2.0, 16.0)
			draw_polyline(points, fill.lightened(0.10), river_width + 2.0, true)
			draw_polyline(points, edge, river_width, true)
		else:
			var polygon_world: PackedVector2Array = water.get("world_polygon_xz", PackedVector2Array())
			if polygon_world.size() < 3:
				continue
			var polygon := PackedVector2Array()
			for point in polygon_world:
				polygon.append(_xz_to_map(point, map_rect, bounds_min, bounds_max))
			draw_colored_polygon(polygon, fill)
			draw_polyline(_closed_polyline(polygon), edge, 2.0, true)

func _draw_towns(map_rect: Rect2) -> void:
	if _backdrop == null or not is_instance_valid(_backdrop):
		return
	var font := ThemeDB.fallback_font
	if font == null:
		return
	var bounds_min: Vector3 = _snapshot.get("bounds_min", Vector3.ZERO)
	var bounds_max: Vector3 = _snapshot.get("bounds_max", Vector3.ONE)
	var towns: Array = _backdrop.call("get_town_markers") if _backdrop.has_method("get_town_markers") else []
	var occupied: Array[Rect2] = []
	for settlement_class in ["city", "town"]:
		for town_variant in towns:
			if not (town_variant is Dictionary):
				continue
			var town: Dictionary = town_variant
			if String(town.get("class", "town")) != settlement_class:
				continue
			var point := _world_to_map(town.get("world_pos", Vector3.ZERO), map_rect, bounds_min, bounds_max)
			var label_text := String(town.get("name", ""))
			var font_size := 15 if settlement_class == "city" else 11
			var label_size := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
			var label_pos := point + Vector2(6.0, -4.0)
			var label_rect := Rect2(label_pos + Vector2(-2.0, -font_size), label_size + Vector2(4.0, font_size + 4.0))
			if settlement_class != "city":
				var blocked := false
				for rect_variant in occupied:
					var rect: Rect2 = rect_variant
					if rect.intersects(label_rect):
						blocked = true
						break
				if blocked:
					continue
			occupied.append(label_rect)
			draw_circle(point, 2.0 if settlement_class == "city" else 1.5, Color(0.26, 0.20, 0.12, 0.86))
			_draw_halo_text(font, label_pos, label_text, font_size, Color(0.24, 0.18, 0.10, 0.90), Color(0.97, 0.94, 0.88, 0.82))

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
		draw_polyline(points, Color(0.18, 0.14, 0.10, 0.28), 8.2, true)
		draw_polyline(points, color.lightened(0.50), 5.8, true)
		draw_polyline(points, color, 2.8, true)

func _draw_stops(map_rect: Rect2) -> void:
	var stops: Array = _snapshot.get("stops", [])
	var bounds_min: Vector3 = _snapshot.get("bounds_min", Vector3.ZERO)
	var bounds_max: Vector3 = _snapshot.get("bounds_max", Vector3.ONE)
	for stop_variant in stops:
		var stop: Dictionary = stop_variant
		var stop_pos: Vector3 = stop.get("position", Vector3.ZERO)
		var point := _world_to_map(stop_pos, map_rect, bounds_min, bounds_max)
		var is_hover := _hover_matches("stop", String(stop.get("name", "")))
		var rating := float(stop.get("rating", 75.0))
		var pressure := float(stop.get("crowding_pressure", 0.0))
		var severe := bool(stop.get("severe_overcrowding", false))
		var radius := 3.2 + clampf(pressure, 0.0, 1.0) * 3.8
		var fill := _stop_rating_color(rating, pressure, severe)
		draw_circle(point, radius + 2.3, Color(0.12, 0.08, 0.05, 0.42))
		draw_circle(point, radius, fill)
		draw_circle(point, maxf(1.3, radius * 0.36), Color(0.96, 0.91, 0.72, 0.92))
		if severe:
			draw_circle(point, radius + 4.5, Color(0.78, 0.12, 0.08, 0.24))
		if is_hover:
			draw_circle(point, radius + 5.0, Color(0.90, 0.72, 0.26, 0.32))

func _stop_rating_color(rating: float, pressure: float, severe: bool) -> Color:
	if severe:
		return Color(0.73, 0.18, 0.14, 0.98)
	if pressure >= 0.72:
		return Color(0.83, 0.45, 0.16, 0.96)
	if rating >= 84.0:
		return Color(0.22, 0.58, 0.32, 0.96)
	if rating >= 68.0:
		return Color(0.79, 0.63, 0.28, 0.96)
	return Color(0.69, 0.24, 0.18, 0.96)

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

func _xz_to_map(point: Vector2, map_rect: Rect2, bounds_min: Vector3, bounds_max: Vector3) -> Vector2:
	return _world_to_map(Vector3(point.x, 0.0, point.y), map_rect, bounds_min, bounds_max)

func _meters_to_map_size(size_m: Vector2, map_rect: Rect2, bounds_min: Vector3, bounds_max: Vector3) -> Vector2:
	var usable_width_px := map_rect.size.x * 0.90
	var usable_height_px := map_rect.size.y * 0.84
	var width_m := maxf(1.0, bounds_max.x - bounds_min.x)
	var depth_m := maxf(1.0, bounds_max.z - bounds_min.z)
	return Vector2(size_m.x * usable_width_px / width_m, size_m.y * usable_height_px / depth_m)

func _meters_to_map_width(distance_m: float, map_rect: Rect2, bounds_min: Vector3, bounds_max: Vector3) -> float:
	var size_px := _meters_to_map_size(Vector2(distance_m, distance_m), map_rect, bounds_min, bounds_max)
	return (size_px.x + size_px.y) * 0.5

func _ellipse_points(center: Vector2, radius: Vector2, steps: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	var count := maxi(12, steps)
	for i in range(count):
		var angle := TAU * float(i) / float(count)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return points

func _offset_polyline(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var shifted := PackedVector2Array()
	for point in points:
		shifted.append(point + offset)
	return shifted

func _closed_polyline(points: PackedVector2Array) -> PackedVector2Array:
	var closed := PackedVector2Array()
	for point in points:
		closed.append(point)
	if not points.is_empty():
		closed.append(points[0])
	return closed

func _draw_halo_text(font: Font, position: Vector2, text: String, font_size: int, text_color: Color, halo_color: Color) -> void:
	for offset in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
		draw_string(font, position + offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, halo_color)
	draw_string(font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, text_color)

func _draw_north_arrow(map_rect: Rect2) -> void:
	var font := ThemeDB.fallback_font
	var base := Vector2(map_rect.end.x - 28.0, map_rect.position.y + 18.0)
	draw_line(base + Vector2(0.0, 18.0), base + Vector2(0.0, -6.0), Color(0.22, 0.16, 0.09, 0.92), 2.0)
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(0.0, -12.0),
		base + Vector2(-5.0, -1.0),
		base + Vector2(5.0, -1.0)
	]), Color(0.22, 0.16, 0.09, 0.92))
	if font != null:
		draw_string(font, base + Vector2(-6.0, 28.0), "N", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color(0.22, 0.16, 0.09, 0.92))

func _draw_scale_bar(map_rect: Rect2) -> void:
	var font := ThemeDB.fallback_font
	if font == null:
		return
	var bounds_min: Vector3 = _snapshot.get("bounds_min", Vector3.ZERO)
	var bounds_max: Vector3 = _snapshot.get("bounds_max", Vector3.ONE)
	var meters_per_pixel := _map_meters_per_pixel(map_rect, bounds_min, bounds_max)
	if meters_per_pixel <= 0.0:
		return
	var nice_distance_m := _nice_scale_distance(meters_per_pixel * 100.0)
	var bar_width_px := nice_distance_m / meters_per_pixel
	var origin := Vector2(map_rect.position.x + 20.0, map_rect.end.y - 18.0)
	draw_rect(Rect2(origin + Vector2(-8.0, -20.0), Vector2(bar_width_px + 16.0, 28.0)), Color(0.96, 0.93, 0.88, 0.72), true)
	draw_rect(Rect2(origin + Vector2(-8.0, -20.0), Vector2(bar_width_px + 16.0, 28.0)), Color(0.42, 0.31, 0.19, 0.68), false, 1.0)
	draw_rect(Rect2(origin, Vector2(bar_width_px * 0.5, 6.0)), Color(0.20, 0.16, 0.11, 0.92), true)
	draw_rect(Rect2(origin + Vector2(bar_width_px * 0.5, 0.0), Vector2(bar_width_px * 0.5, 6.0)), Color(0.92, 0.89, 0.82, 0.96), true)
	draw_rect(Rect2(origin, Vector2(bar_width_px, 6.0)), Color(0.20, 0.16, 0.11, 0.92), false, 1.2)
	var miles := nice_distance_m / 1609.344
	var label := "%.1f mi" % miles if miles < 10.0 else "%.0f mi" % miles
	draw_string(font, origin + Vector2(0.0, -4.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, Color(0.22, 0.16, 0.09, 0.92))

func _draw_service_legend(map_rect: Rect2) -> void:
	var font := ThemeDB.fallback_font
	if font == null:
		return
	var origin := Vector2(map_rect.end.x - 190.0, map_rect.end.y - 76.0)
	var panel := Rect2(origin + Vector2(-10.0, -18.0), Vector2(176.0, 68.0))
	draw_rect(panel, Color(0.96, 0.93, 0.86, 0.78), true)
	draw_rect(panel, Color(0.42, 0.31, 0.19, 0.62), false, 1.0)
	draw_string(font, origin + Vector2(0.0, -2.0), "Stop service", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, Color(0.22, 0.16, 0.09, 0.94))
	var legend_items := [
		{"label": "good", "color": Color(0.22, 0.58, 0.32, 0.96)},
		{"label": "watch", "color": Color(0.79, 0.63, 0.28, 0.96)},
		{"label": "crowded", "color": Color(0.73, 0.18, 0.14, 0.98)}
	]
	for i in range(legend_items.size()):
		var item: Dictionary = legend_items[i]
		var y := origin.y + 15.0 + float(i) * 14.0
		var item_color: Color = item.get("color", Color.WHITE)
		draw_circle(Vector2(origin.x + 7.0, y - 4.0), 4.0, item_color)
		draw_string(font, Vector2(origin.x + 18.0, y), String(item.get("label", "")), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, Color(0.25, 0.18, 0.10, 0.92))

func _map_meters_per_pixel(map_rect: Rect2, bounds_min: Vector3, bounds_max: Vector3) -> float:
	var usable_width_px := maxf(1.0, map_rect.size.x * 0.90)
	var width_m := maxf(1.0, bounds_max.x - bounds_min.x)
	return width_m / usable_width_px

func _nice_scale_distance(raw_distance_m: float) -> float:
	var steps := [500.0, 1000.0, 2000.0, 5000.0, 10000.0, 20000.0, 50000.0, 100000.0]
	for step_variant in steps:
		var step := float(step_variant)
		if step >= raw_distance_m:
			return step
	return 100000.0

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
			var rating := float(stop.get("rating", 75.0))
			var waiting := int(stop.get("waiting", 0))
			var perceived_wait := float(stop.get("perceived_wait_min", 0.0))
			best_stop = {
				"kind": "stop",
				"id": String(stop.get("name", "")),
				"label": "%s (%s)" % [String(stop.get("name", "")), line_name],
				"hint": "Click to jump to %s on %s | %.0f rating | %d waiting | %.1f min wait" % [String(stop.get("name", "")), line_name, rating, waiting, perceived_wait],
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
