extends Control
class_name FinanceHistoryGraph

var _history: Array[Dictionary] = []

func set_history(entries: Array[Dictionary]) -> void:
	_history.clear()
	for entry in entries:
		_history.append(entry.duplicate(true))
	queue_redraw()

func _draw() -> void:
	var frame := Rect2(Vector2(12.0, 10.0), size - Vector2(24.0, 28.0))
	if frame.size.x <= 16.0 or frame.size.y <= 16.0:
		return
	var bg_color := Color(0.95, 0.91, 0.84, 0.55)
	var axis_color := Color("8c6a4a")
	var grid_color := Color(0.55, 0.42, 0.28, 0.18)
	draw_rect(frame, bg_color, true)
	draw_rect(frame, axis_color, false, 1.5)
	if _history.is_empty():
		_draw_center_text(frame, "No monthly history yet", axis_color.darkened(0.18))
		return
	var min_value := 0.0
	var max_value := 1.0
	for entry in _history:
		var revenue := float(entry.get("revenue", 0.0))
		var expenses := float(entry.get("expenses", 0.0))
		var net := float(entry.get("net", 0.0))
		min_value = minf(min_value, minf(revenue, minf(expenses, net)))
		max_value = maxf(max_value, maxf(revenue, maxf(expenses, net)))
	if is_equal_approx(min_value, max_value):
		max_value += 1.0
	var padding := maxf(1000.0, (max_value - min_value) * 0.08)
	min_value -= padding
	max_value += padding
	for i in range(5):
		var t := float(i) / 4.0
		var y := lerpf(frame.position.y + frame.size.y, frame.position.y, t)
		draw_line(Vector2(frame.position.x, y), Vector2(frame.position.x + frame.size.x, y), grid_color, 1.0)
	var zero_y := _value_to_y(0.0, min_value, max_value, frame)
	draw_line(Vector2(frame.position.x, zero_y), Vector2(frame.position.x + frame.size.x, zero_y), axis_color, 1.4)
	_draw_series(frame, min_value, max_value, "revenue", Color("3c9154"))
	_draw_series(frame, min_value, max_value, "expenses", Color("b34a3f"))
	_draw_series(frame, min_value, max_value, "net", Color("caa76a"))
	_draw_legend(frame)
	_draw_labels(frame, axis_color.darkened(0.2))

func _draw_series(frame: Rect2, min_value: float, max_value: float, key: String, color: Color) -> void:
	if _history.size() == 1:
		var single_y := _value_to_y(float(_history[0].get(key, 0.0)), min_value, max_value, frame)
		draw_circle(Vector2(frame.position.x + frame.size.x * 0.5, single_y), 4.0, color)
		return
	var points := PackedVector2Array()
	for i in range(_history.size()):
		var t := float(i) / float(maxi(_history.size() - 1, 1))
		var x := lerpf(frame.position.x, frame.position.x + frame.size.x, t)
		var y := _value_to_y(float(_history[i].get(key, 0.0)), min_value, max_value, frame)
		points.append(Vector2(x, y))
	if points.size() >= 2:
		draw_polyline(points, color, 2.4, true)
	for point in points:
		draw_circle(point, 2.2, color)

func _draw_legend(frame: Rect2) -> void:
	var labels := [
		{"text": "Revenue", "color": Color("3c9154")},
		{"text": "Expenses", "color": Color("b34a3f")},
		{"text": "Net", "color": Color("caa76a")}
	]
	var cursor := Vector2(frame.position.x + 8.0, frame.position.y + 8.0)
	for entry in labels:
		var swatch_rect := Rect2(cursor, Vector2(12.0, 12.0))
		draw_rect(swatch_rect, entry["color"], true)
		_draw_text(cursor + Vector2(18.0, 11.0), String(entry["text"]), entry["color"].darkened(0.35))
		cursor.x += 92.0

func _draw_labels(frame: Rect2, color: Color) -> void:
	if _history.is_empty():
		return
	var first_period := String(_history[0].get("period", ""))
	var last_period := String(_history[_history.size() - 1].get("period", ""))
	_draw_text(Vector2(frame.position.x + 2.0, frame.position.y + frame.size.y + 16.0), first_period, color)
	var font := get_theme_default_font()
	var font_size := get_theme_default_font_size()
	var last_width := 0.0
	if font != null:
		last_width = font.get_string_size(last_period, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	_draw_text(Vector2(frame.position.x + frame.size.x - last_width - 2.0, frame.position.y + frame.size.y + 16.0), last_period, color)

func _draw_center_text(frame: Rect2, text: String, color: Color) -> void:
	var font := get_theme_default_font()
	if font == null:
		return
	var font_size := get_theme_default_font_size()
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
	var pos := frame.position + (frame.size - text_size) * 0.5 + Vector2(0.0, text_size.y)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)

func _draw_text(position: Vector2, text: String, color: Color) -> void:
	var font := get_theme_default_font()
	if font == null:
		return
	draw_string(font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, get_theme_default_font_size(), color)

func _value_to_y(value: float, min_value: float, max_value: float, frame: Rect2) -> float:
	var t := inverse_lerp(min_value, max_value, value)
	return lerpf(frame.position.y + frame.size.y, frame.position.y, clampf(t, 0.0, 1.0))
