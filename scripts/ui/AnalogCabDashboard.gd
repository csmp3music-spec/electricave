extends PanelContainer
class_name AnalogCabDashboard

const FACE := Color("f1e2c6")
const BRASS := Color("caa76a")
const BRASS_DARK := Color("8e6f48")
const WOOD := Color("6d4a31")
const PAPER := Color("f7eedf")
const TEXT_DARK := Color("2c1d12")
const TEXT_SOFT := Color("5f4631")

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

var _speed_value_label: Label
var _speed_meta_label: Label
var _speed_bar: ProgressBar
var _title_label: Label
var _route_label: Label
var _control_label: Label
var _weather_label: Label
var _controller_bar: ProgressBar
var _brake_bar: ProgressBar
var _service_label: Label
var _service_bar: ProgressBar
var _signal_label: Label
var _signal_detail_label: Label
var _red_lamp: Panel
var _yellow_lamp: Panel
var _green_lamp: Panel
var _curve_lamp_panel: Panel
var _weather_lamp_panel: Panel
var _curve_label: Label

func _ready() -> void:
	custom_minimum_size = Vector2(560.0, 220.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override("panel", _panel_style(FACE, BRASS_DARK, 3, 14))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)

	row.add_child(_build_speed_panel())
	row.add_child(_build_center_panel())
	row.add_child(_build_signal_panel())
	_apply_payload()

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
	_apply_payload()

func _build_speed_panel() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(154.0, 0.0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(PAPER, BRASS, 2, 12))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)

	var title := Label.new()
	title.text = "Speed Indicator"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.modulate = TEXT_SOFT
	content.add_child(title)

	_speed_value_label = Label.new()
	_speed_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_speed_value_label.add_theme_font_size_override("font_size", 30)
	_speed_value_label.modulate = TEXT_DARK
	content.add_child(_speed_value_label)

	_speed_meta_label = Label.new()
	_speed_meta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_speed_meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_speed_meta_label.modulate = TEXT_SOFT
	content.add_child(_speed_meta_label)

	_speed_bar = ProgressBar.new()
	_speed_bar.min_value = 0.0
	_speed_bar.max_value = 50.0
	_speed_bar.show_percentage = false
	_speed_bar.custom_minimum_size = Vector2(0.0, 18.0)
	_speed_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_progress_style(_speed_bar, Color("a66a3f"), Color("d8c4a1"))
	content.add_child(_speed_bar)
	return panel

func _build_center_panel() -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(PAPER, BRASS, 2, 12))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 7)
	margin.add_child(content)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 18)
	_title_label.modulate = TEXT_DARK
	content.add_child(_title_label)

	_route_label = Label.new()
	_route_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_route_label.modulate = TEXT_SOFT
	content.add_child(_route_label)

	_control_label = Label.new()
	_control_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_control_label.modulate = TEXT_DARK
	content.add_child(_control_label)

	var controller_title := Label.new()
	controller_title.text = "Controller"
	controller_title.modulate = TEXT_SOFT
	content.add_child(controller_title)

	_controller_bar = ProgressBar.new()
	_controller_bar.min_value = 0.0
	_controller_bar.max_value = 100.0
	_controller_bar.show_percentage = false
	_controller_bar.custom_minimum_size = Vector2(0.0, 16.0)
	_apply_progress_style(_controller_bar, Color("5f9d59"), Color("d8c4a1"))
	content.add_child(_controller_bar)

	var brake_title := Label.new()
	brake_title.text = "Air Brake"
	brake_title.modulate = TEXT_SOFT
	content.add_child(brake_title)

	_brake_bar = ProgressBar.new()
	_brake_bar.min_value = 0.0
	_brake_bar.max_value = 100.0
	_brake_bar.show_percentage = false
	_brake_bar.custom_minimum_size = Vector2(0.0, 16.0)
	_apply_progress_style(_brake_bar, Color("b55747"), Color("d8c4a1"))
	content.add_child(_brake_bar)

	_service_label = Label.new()
	_service_label.modulate = TEXT_DARK
	content.add_child(_service_label)

	_service_bar = ProgressBar.new()
	_service_bar.min_value = 0.0
	_service_bar.max_value = 100.0
	_service_bar.show_percentage = false
	_service_bar.custom_minimum_size = Vector2(0.0, 14.0)
	_apply_progress_style(_service_bar, BRASS_DARK, Color("d8c4a1"))
	content.add_child(_service_bar)

	_weather_label = Label.new()
	_weather_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_weather_label.modulate = TEXT_SOFT
	content.add_child(_weather_label)
	return panel

func _build_signal_panel() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(122.0, 0.0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(PAPER, BRASS, 2, 12))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)

	var title := Label.new()
	title.text = "Signal Head"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.modulate = TEXT_SOFT
	content.add_child(title)

	var lamps := VBoxContainer.new()
	lamps.alignment = BoxContainer.ALIGNMENT_CENTER
	lamps.add_theme_constant_override("separation", 6)
	content.add_child(lamps)

	_red_lamp = _make_lamp()
	lamps.add_child(_red_lamp)
	_yellow_lamp = _make_lamp()
	lamps.add_child(_yellow_lamp)
	_green_lamp = _make_lamp()
	lamps.add_child(_green_lamp)

	_signal_label = Label.new()
	_signal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_signal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_signal_label.modulate = TEXT_DARK
	content.add_child(_signal_label)

	_signal_detail_label = Label.new()
	_signal_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_signal_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_signal_detail_label.modulate = TEXT_SOFT
	content.add_child(_signal_detail_label)

	var aux_row := HBoxContainer.new()
	aux_row.alignment = BoxContainer.ALIGNMENT_CENTER
	aux_row.add_theme_constant_override("separation", 8)
	content.add_child(aux_row)

	_curve_lamp_panel = _make_lamp(14.0)
	aux_row.add_child(_curve_lamp_panel)
	_weather_lamp_panel = _make_lamp(14.0)
	aux_row.add_child(_weather_lamp_panel)

	_curve_label = Label.new()
	_curve_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_curve_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_curve_label.modulate = TEXT_SOFT
	content.add_child(_curve_label)
	return panel

func _make_lamp(size_value: float = 18.0) -> Panel:
	var lamp := Panel.new()
	lamp.custom_minimum_size = Vector2(size_value, size_value)
	lamp.add_theme_stylebox_override("panel", _lamp_style(Color("4e3e30")))
	return lamp

func _apply_payload() -> void:
	if _speed_value_label == null:
		return
	_speed_value_label.text = "%.0f mph" % speed_mph
	_speed_meta_label.text = "Target %.0f | Limit %.0f" % [target_speed_mph, speed_limit_mph]
	_speed_bar.value = minf(speed_mph, _speed_bar.max_value)
	_title_label.text = line_name
	_route_label.text = route_text
	_control_label.text = control_text
	_weather_label.text = weather_text
	_controller_bar.value = clampf((controller_ratio + 1.0) * 50.0, 0.0, 100.0)
	_brake_bar.value = brake_ratio * 100.0
	_service_label.text = "Service %.0f%%" % service_rating
	_service_bar.value = service_rating
	_signal_label.text = signal_text
	_signal_detail_label.text = weather_signal_text
	_curve_label.text = curve_text
	_set_lamp(_red_lamp, signal_aspect == "RED", Color("c65042"))
	_set_lamp(_yellow_lamp, signal_aspect == "YELLOW", Color("d7b35b"))
	_set_lamp(_green_lamp, signal_aspect == "GREEN", Color("5f9d59"))
	_set_lamp(_curve_lamp_panel, curve_lamp in ["RED", "YELLOW", "GREEN"], _lamp_color(curve_lamp))
	_set_lamp(_weather_lamp_panel, weather_lamp != "OFF", _lamp_color(weather_lamp))

func _panel_style(bg: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0, 0, 0.12)
	style.shadow_size = 4
	return style

func _lamp_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = WOOD
	style.set_border_width_all(1)
	style.set_corner_radius_all(64)
	style.shadow_color = Color(0, 0, 0, 0.16)
	style.shadow_size = 2
	return style

func _apply_progress_style(progress: ProgressBar, fill: Color, background: Color) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = background
	bg.set_corner_radius_all(8)
	var fg := StyleBoxFlat.new()
	fg.bg_color = fill
	fg.set_corner_radius_all(8)
	progress.add_theme_stylebox_override("background", bg)
	progress.add_theme_stylebox_override("fill", fg)
	progress.add_theme_color_override("font_color", TEXT_DARK)

func _set_lamp(panel: Panel, active: bool, color: Color) -> void:
	if panel == null:
		return
	var fill := color if active else color.darkened(0.72)
	panel.add_theme_stylebox_override("panel", _lamp_style(fill))

func _lamp_color(aspect: String) -> Color:
	match aspect:
		"RED":
			return Color("c65042")
		"YELLOW":
			return Color("d7b35b")
		"GREEN":
			return Color("5f9d59")
		"SNOW", "ICE":
			return Color("d8edf6")
		"WET":
			return Color("5f84a0")
	return BRASS_DARK
