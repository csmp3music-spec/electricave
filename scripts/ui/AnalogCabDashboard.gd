extends Control
class_name AnalogCabDashboard

const DASHBOARD_SIZE := Vector2(560.0, 220.0)
const PANEL_DARK := Color("6d4a31")
const PANEL_WOOD := Color("d9c3a0")
const PANEL_FACE := Color("f1e2c6")
const BRASS_DARK := Color("8e6f48")
const BRASS_LIGHT := Color("caa76a")
const INK_DARK := Color("2c1d12")
const INK_WARM := Color("422a18")
const PAPER_SHADOW := Color("cfb486")

var speed_mph := 0.0
var target_speed_mph := 0.0
var speed_limit_mph := 50.0
var signal_aspect := "GREEN"
var line_name := "Boston Elevated"
var route_text := "Park Street to Kenmore"
var control_text := "Controller idle"
var weather_text := "Weather clear"
var signal_text := "Signal clear"
var controller_ratio := 0.0
var brake_ratio := 0.18
var service_rating := 78.0
var curve_lamp := "OFF"
var curve_text := "Track steady"
var weather_lamp := "OFF"
var weather_signal_text := "Weather steady"

var _title_label: Label
var _route_label: Label
var _control_label: Label
var _weather_label: Label
var _signal_label: Label
var _signal_detail_label: Label
var _speed_label: Label
var _speed_title_label: Label
var _speed_unit_label: Label
var _controller_title_label: Label
var _signal_title_label: Label
var _service_label: Label
var _curve_label: Label

func _ready() -> void:
	custom_minimum_size = DASHBOARD_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_title_label = _make_label(Vector2(208.0, 18.0), Vector2(324.0, 26.0), 18)
	_route_label = _make_label(Vector2(208.0, 48.0), Vector2(324.0, 40.0), 15)
	_control_label = _make_label(Vector2(210.0, 112.0), Vector2(210.0, 28.0), 14)
	_weather_label = _make_label(Vector2(210.0, 144.0), Vector2(210.0, 32.0), 13)
	_signal_label = _make_label(Vector2(426.0, 102.0), Vector2(120.0, 26.0), 13, HORIZONTAL_ALIGNMENT_CENTER)
	_signal_detail_label = _make_label(Vector2(426.0, 126.0), Vector2(120.0, 34.0), 11, HORIZONTAL_ALIGNMENT_CENTER)
	_speed_label = _make_label(Vector2(52.0, 132.0), Vector2(128.0, 34.0), 18, HORIZONTAL_ALIGNMENT_CENTER)
	_speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_speed_title_label = _make_label(Vector2(78.0, 58.0), Vector2(78.0, 18.0), 13, HORIZONTAL_ALIGNMENT_CENTER)
	_speed_unit_label = _make_label(Vector2(90.0, 76.0), Vector2(54.0, 16.0), 11, HORIZONTAL_ALIGNMENT_CENTER)
	_controller_title_label = _make_label(Vector2(222.0, 88.0), Vector2(182.0, 16.0), 12, HORIZONTAL_ALIGNMENT_CENTER)
	_signal_title_label = _make_label(Vector2(438.0, 170.0), Vector2(90.0, 16.0), 11, HORIZONTAL_ALIGNMENT_CENTER)
	_service_label = _make_label(Vector2(214.0, 182.0), Vector2(202.0, 18.0), 12, HORIZONTAL_ALIGNMENT_LEFT)
	_curve_label = _make_label(Vector2(426.0, 186.0), Vector2(118.0, 18.0), 10, HORIZONTAL_ALIGNMENT_CENTER)
	_apply_labels()

func set_payload(payload: Dictionary) -> void:
	speed_mph = maxf(0.0, float(payload.get("speed_mph", 0.0)))
	target_speed_mph = maxf(0.0, float(payload.get("target_speed_mph", speed_mph)))
	speed_limit_mph = maxf(25.0, float(payload.get("speed_limit_mph", 50.0)))
	signal_aspect = String(payload.get("signal_aspect", "GREEN")).to_upper()
	line_name = String(payload.get("line_name", line_name))
	route_text = String(payload.get("route_text", route_text))
	control_text = String(payload.get("control_text", control_text))
	weather_text = String(payload.get("weather_text", weather_text))
	signal_text = String(payload.get("signal_text", signal_text))
	controller_ratio = clampf(float(payload.get("controller_ratio", 0.0)), -1.0, 1.0)
	brake_ratio = clampf(float(payload.get("brake_ratio", brake_ratio)), 0.0, 1.0)
	service_rating = clampf(float(payload.get("service_rating", service_rating)), 0.0, 100.0)
	curve_lamp = String(payload.get("curve_lamp", curve_lamp)).to_upper()
	curve_text = String(payload.get("curve_text", curve_text))
	weather_lamp = String(payload.get("weather_lamp", weather_lamp)).to_upper()
	weather_signal_text = String(payload.get("weather_signal_text", weather_signal_text))
	_apply_labels()
	queue_redraw()

func _make_label(pos: Vector2, size_vec: Vector2, font_size: int, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.position = pos
	label.custom_minimum_size = size_vec
	label.size = size_vec
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
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
	_signal_detail_label.text = weather_signal_text
	_speed_label.text = "%.0f mph" % speed_mph
	_speed_title_label.text = "SPEED"
	_speed_unit_label.text = "MPH"
	_controller_title_label.text = "Controller Stand"
	_signal_title_label.text = "Signal Head"
	_service_label.text = "Service %.0f | Brake %.0f%%" % [service_rating, brake_ratio * 100.0]
	_curve_label.text = curve_text

func _draw() -> void:
	if size.x < DASHBOARD_SIZE.x or size.y < DASHBOARD_SIZE.y:
		return
	var panel_rect := Rect2(Vector2.ZERO, DASHBOARD_SIZE)
	draw_rect(panel_rect, PANEL_DARK)
	draw_rect(Rect2(8.0, 8.0, DASHBOARD_SIZE.x - 16.0, DASHBOARD_SIZE.y - 16.0), PANEL_WOOD)
	draw_rect(Rect2(16.0, 16.0, DASHBOARD_SIZE.x - 32.0, DASHBOARD_SIZE.y - 32.0), PANEL_FACE)
	_draw_speedometer()
	_draw_controller_stand()
	_draw_service_meter()
	_draw_signal_cluster()
	_draw_aux_lamps()

func _draw_speedometer() -> void:
	var center := Vector2(116.0, 106.0)
	var radius := 74.0
	var start_angle := deg_to_rad(-132.0)
	var end_angle := deg_to_rad(132.0)
	draw_circle(center, radius + 12.0, Color("9d7645"))
	draw_circle(center, radius + 7.0, BRASS_LIGHT)
	draw_circle(center, radius, Color("f7eedf"))
	_draw_arc_polyline(center, radius, start_angle, end_angle, 48, INK_WARM, 3.0)
	for i in range(11):
		var t := float(i) / 10.0
		var angle := lerpf(start_angle, end_angle, t)
		var inner := center + Vector2(cos(angle), sin(angle)) * (radius - 12.0)
		var outer := center + Vector2(cos(angle), sin(angle)) * (radius - 1.0)
		draw_line(inner, outer, INK_WARM, 3.0)
		if i < 10:
			for minor in range(1, 5):
				var minor_t := (float(i) + float(minor) / 5.0) / 10.0
				var minor_angle := lerpf(start_angle, end_angle, minor_t)
				var minor_inner := center + Vector2(cos(minor_angle), sin(minor_angle)) * (radius - 8.0)
				var minor_outer := center + Vector2(cos(minor_angle), sin(minor_angle)) * (radius - 2.0)
				draw_line(minor_inner, minor_outer, Color("7b6042"), 1.3)
	var caution_start := lerpf(start_angle, end_angle, 0.76)
	var caution_end := lerpf(start_angle, end_angle, 1.0)
	_draw_arc_polyline(center, radius - 7.0, caution_start, caution_end, 16, Color("b65d42"), 4.0)
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
	draw_circle(center, 7.0, BRASS_DARK)
	draw_circle(center, 3.0, INK_DARK)

func _draw_controller_stand() -> void:
	draw_rect(Rect2(210.0, 86.0, 206.0, 18.0), PAPER_SHADOW)
	var slot_rect := Rect2(224.0, 120.0, 172.0, 16.0)
	draw_rect(slot_rect, Color("7d6041"))
	draw_rect(slot_rect.grow(-2.0), Color("f3e4ca"))
	var brake_width := slot_rect.size.x * 0.46 * brake_ratio
	if brake_width > 0.0:
		draw_rect(Rect2(slot_rect.position.x + 4.0, slot_rect.position.y + 3.0, brake_width, slot_rect.size.y - 6.0), Color("b55747"))
	var power_ratio := clampf(maxf(controller_ratio, 0.0), 0.0, 1.0)
	var power_width := slot_rect.size.x * 0.46 * power_ratio
	if power_width > 0.0:
		draw_rect(Rect2(slot_rect.end.x - 4.0 - power_width, slot_rect.position.y + 3.0, power_width, slot_rect.size.y - 6.0), Color("5f9d59"))
	var lever_x := lerpf(slot_rect.position.x + 6.0, slot_rect.end.x - 6.0, (controller_ratio + 1.0) * 0.5)
	draw_line(Vector2(lever_x, slot_rect.position.y - 8.0), Vector2(lever_x, slot_rect.end.y + 8.0), INK_DARK, 3.0)
	draw_circle(Vector2(lever_x, slot_rect.position.y - 10.0), 7.0, BRASS_LIGHT)
	draw_circle(Vector2(lever_x, slot_rect.position.y - 10.0), 4.0, BRASS_DARK)
	for notch in range(7):
		var notch_x := lerpf(slot_rect.position.x + 6.0, slot_rect.end.x - 6.0, float(notch) / 6.0)
		draw_line(Vector2(notch_x, slot_rect.end.y + 4.0), Vector2(notch_x, slot_rect.end.y + 10.0), Color("6c5237"), 1.4)

func _draw_service_meter() -> void:
	var lit_count := int(round(service_rating / 20.0))
	for i in range(5):
		var lamp_center := Vector2(234.0 + float(i) * 24.0, 168.0)
		var lamp_fill := Color("d7b35b") if i < lit_count else Color("5f4733")
		draw_circle(lamp_center, 8.0, Color("2a1d14"))
		draw_circle(lamp_center, 6.0, lamp_fill)

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

func _draw_aux_lamps() -> void:
	draw_rect(Rect2(438.0, 168.0, 88.0, 20.0), PAPER_SHADOW)
	_draw_named_lamp(Vector2(458.0, 158.0), curve_lamp)
	_draw_named_lamp(Vector2(488.0, 158.0), weather_lamp)
	_draw_named_lamp(Vector2(518.0, 158.0), signal_aspect)

func _draw_named_lamp(center: Vector2, aspect: String) -> void:
	var fill := Color("4e3e30")
	match aspect:
		"RED":
			fill = Color("c65042")
		"YELLOW":
			fill = Color("d7b35b")
		"GREEN":
			fill = Color("5f9d59")
		"SNOW", "ICE":
			fill = Color("d8edf6")
		"WET":
			fill = Color("5f84a0")
	draw_circle(center, 7.5, INK_DARK)
	draw_circle(center, 5.5, fill)

func _draw_arc_polyline(center: Vector2, radius: float, start_angle: float, end_angle: float, segments: int, color: Color, width: float) -> void:
	if segments < 2:
		return
	var points := PackedVector2Array()
	for i in range(segments + 1):
		var t := float(i) / float(segments)
		var angle := lerpf(start_angle, end_angle, t)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_polyline(points, color, width, true)
