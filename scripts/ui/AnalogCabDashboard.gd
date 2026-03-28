extends Control
class_name AnalogCabDashboard

var speed_mph := 0.0
var target_speed_mph := 0.0
var speed_limit_mph := 50.0
var signal_aspect := "GREEN"
var line_name := "Boston Elevated"
var route_text := "Park Street to Kenmore"
var control_text := "Controller idle"
var weather_text := "Weather clear"
var signal_text := "Signal clear"

var _title_label: Label
var _route_label: Label
var _control_label: Label
var _weather_label: Label
var _signal_label: Label
var _speed_label: Label

func _ready() -> void:
	custom_minimum_size = Vector2(560.0, 220.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_label = _make_label(Vector2(208.0, 18.0), Vector2(324.0, 26.0), 18)
	_route_label = _make_label(Vector2(208.0, 48.0), Vector2(324.0, 40.0), 15)
	_control_label = _make_label(Vector2(208.0, 108.0), Vector2(220.0, 34.0), 14)
	_weather_label = _make_label(Vector2(208.0, 146.0), Vector2(220.0, 52.0), 13)
	_signal_label = _make_label(Vector2(438.0, 106.0), Vector2(92.0, 54.0), 13)
	_speed_label = _make_label(Vector2(58.0, 132.0), Vector2(116.0, 32.0), 18)
	_speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_apply_labels()

func set_payload(payload: Dictionary) -> void:
	speed_mph = float(payload.get("speed_mph", 0.0))
	target_speed_mph = float(payload.get("target_speed_mph", speed_mph))
	speed_limit_mph = maxf(25.0, float(payload.get("speed_limit_mph", 50.0)))
	signal_aspect = String(payload.get("signal_aspect", "GREEN"))
	line_name = String(payload.get("line_name", line_name))
	route_text = String(payload.get("route_text", route_text))
	control_text = String(payload.get("control_text", control_text))
	weather_text = String(payload.get("weather_text", weather_text))
	signal_text = String(payload.get("signal_text", signal_text))
	_apply_labels()
	queue_redraw()

func _make_label(pos: Vector2, size_vec: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.custom_minimum_size = size_vec
	label.size = size_vec
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = Color("271a11")
	add_child(label)
	return label

func _apply_labels() -> void:
	if _title_label == null:
		return
	_title_label.text = line_name
	_route_label.text = route_text
	_control_label.text = control_text
	_weather_label.text = weather_text
	_signal_label.text = signal_text
	_speed_label.text = "%.0f mph" % speed_mph

func _draw() -> void:
	var panel_rect := Rect2(Vector2.ZERO, size)
	draw_rect(panel_rect, Color("6d4a31"))
	draw_rect(Rect2(8.0, 8.0, size.x - 16.0, size.y - 16.0), Color("d9c3a0"))
	draw_rect(Rect2(16.0, 16.0, size.x - 32.0, size.y - 32.0), Color("f1e2c6"))
	_draw_speedometer()
	_draw_signal_cluster()
	_draw_plaques()

func _draw_speedometer() -> void:
	var center := Vector2(116.0, 106.0)
	var radius := 74.0
	var start_angle := deg_to_rad(-132.0)
	var end_angle := deg_to_rad(132.0)
	draw_circle(center, radius + 12.0, Color("9d7645"))
	draw_circle(center, radius + 7.0, Color("caa76a"))
	draw_circle(center, radius, Color("f7eedf"))
	draw_arc(center, radius, start_angle, end_angle, 64, Color("3d2818"), 3.0)
	for i in range(11):
		var t := float(i) / 10.0
		var angle := lerpf(start_angle, end_angle, t)
		var inner := center + Vector2(cos(angle), sin(angle)) * (radius - 12.0)
		var outer := center + Vector2(cos(angle), sin(angle)) * (radius - 1.0)
		draw_line(inner, outer, Color("422a18"), 3.0)
		if i < 10:
			for minor in range(1, 5):
				var minor_t := (float(i) + float(minor) / 5.0) / 10.0
				var minor_angle := lerpf(start_angle, end_angle, minor_t)
				var minor_inner := center + Vector2(cos(minor_angle), sin(minor_angle)) * (radius - 8.0)
				var minor_outer := center + Vector2(cos(minor_angle), sin(minor_angle)) * (radius - 2.0)
				draw_line(minor_inner, minor_outer, Color("7b6042"), 1.3)
	var limit_ratio := clampf(speed_limit_mph / 50.0, 0.0, 1.0)
	var limit_angle := lerpf(start_angle, end_angle, limit_ratio)
	var limit_end := center + Vector2(cos(limit_angle), sin(limit_angle)) * (radius - 10.0)
	draw_line(center, limit_end, Color("3f3125"), 2.0)
	var target_ratio := clampf(target_speed_mph / 50.0, 0.0, 1.0)
	var target_angle := lerpf(start_angle, end_angle, target_ratio)
	var target_end := center + Vector2(cos(target_angle), sin(target_angle)) * (radius - 18.0)
	draw_line(center, target_end, Color("80684a"), 3.0)
	var speed_ratio := clampf(speed_mph / 50.0, 0.0, 1.0)
	var speed_angle := lerpf(start_angle, end_angle, speed_ratio)
	var needle_end := center + Vector2(cos(speed_angle), sin(speed_angle)) * (radius - 16.0)
	draw_line(center, needle_end, Color("a33c2e"), 4.0)
	draw_circle(center, 7.0, Color("8e6f48"))
	draw_circle(center, 3.0, Color("2c1d12"))
	draw_string(ThemeDB.fallback_font, Vector2(82.0, 74.0), "SPEED", HORIZONTAL_ALIGNMENT_LEFT, 72.0, 14, Color("3a2818"))
	draw_string(ThemeDB.fallback_font, Vector2(90.0, 90.0), "MPH", HORIZONTAL_ALIGNMENT_LEFT, 52.0, 14, Color("72593a"))

func _draw_signal_cluster() -> void:
	var lamp_colors := {
		"RED": Color("c65042"),
		"YELLOW": Color("d7b35b"),
		"GREEN": Color("5f9d59")
	}
	var order := ["RED", "YELLOW", "GREEN"]
	var center_x := 472.0
	var start_y := 72.0
	draw_rect(Rect2(444.0, 34.0, 60.0, 118.0), Color("7a573a"))
	draw_rect(Rect2(450.0, 40.0, 48.0, 106.0), Color("2a1d14"))
	for i in range(order.size()):
		var aspect := String(order[i])
		var lamp_center := Vector2(center_x, start_y + float(i) * 28.0)
		var lamp_color: Color = lamp_colors.get(aspect, Color.WHITE)
		var fill := lamp_color if aspect == signal_aspect else lamp_color.darkened(0.78)
		draw_circle(lamp_center, 9.5, fill)
		draw_circle(lamp_center, 11.5, Color("6c5237"))

func _draw_plaques() -> void:
	draw_rect(Rect2(210.0, 86.0, 206.0, 18.0), Color("cfb486"))
	draw_rect(Rect2(438.0, 168.0, 88.0, 20.0), Color("cfb486"))
	draw_string(ThemeDB.fallback_font, Vector2(220.0, 99.0), "Controller Stand", HORIZONTAL_ALIGNMENT_LEFT, 190.0, 12, Color("49311d"))
	draw_string(ThemeDB.fallback_font, Vector2(446.0, 182.0), "Signal Head", HORIZONTAL_ALIGNMENT_LEFT, 80.0, 11, Color("49311d"))
