extends Control
class_name HUD

const ClassicThemeScript := preload("res://scripts/ui/ClassicTheme.gd")
const FinanceHistoryGraphScript := preload("res://scripts/ui/FinanceHistoryGraph.gd")
const SystemMapPanelScript := preload("res://scripts/ui/SystemMapPanel.gd")
const AnalogCabDashboardScript := preload("res://scripts/ui/AnalogCabDashboard.gd")

const TAB_DATA := {
	"Overview": {
		"title": "This month",
		"rows": [
			{"label": "Passenger fares", "amount": "$22.4k", "value": 0.85, "color": Color("3f8a3a")},
			{"label": "Freight", "amount": "$12.9k", "value": 0.55, "color": Color("3f8a3a")},
			{"label": "Mail", "amount": "$6.1k", "value": 0.32, "color": Color("3f8a3a")},
			{"label": "Power", "amount": "$8.2k", "value": 0.68, "color": Color("b34a3f")},
			{"label": "Maintenance", "amount": "$10.7k", "value": 0.72, "color": Color("b34a3f")}
		],
		"summary": [
			{"label": "Debt interest", "amount": "$4.0k", "value": 0.55, "color": Color("b34a3f")},
			{"label": "Capital spend", "amount": "$9.8k", "value": 0.78, "color": Color("b34a3f")}
		]
	},
	"Revenue": {
		"title": "Top line",
		"rows": [
			{"label": "Urban passenger", "amount": "$14.6k", "value": 0.62, "color": Color("3c9154")},
			{"label": "Interurban passenger", "amount": "$9.8k", "value": 0.42, "color": Color("3c9154")},
			{"label": "Express freight", "amount": "$6.7k", "value": 0.31, "color": Color("3c9154")},
			{"label": "Mail contracts", "amount": "$5.2k", "value": 0.24, "color": Color("3c9154")},
			{"label": "Advertising & charters", "amount": "$1.9k", "value": 0.09, "color": Color("3c9154")}
		],
		"summary": [
			{"label": "Average fare", "amount": "$0.13 / pax", "value": 0.42, "color": Color("3c9154")},
			{"label": "Load factor", "amount": "71%", "value": 0.71, "color": Color("3c9154")}
		]
	},
	"Expenses": {
		"title": "Operating costs",
		"rows": [
			{"label": "Crew wages", "amount": "$11.4k", "value": 0.58, "color": Color("b34a3f")},
			{"label": "Power & substations", "amount": "$8.2k", "value": 0.41, "color": Color("b34a3f")},
			{"label": "Track upkeep", "amount": "$7.5k", "value": 0.37, "color": Color("b34a3f")},
			{"label": "Car maintenance", "amount": "$5.9k", "value": 0.29, "color": Color("b34a3f")},
			{"label": "Right-of-way leases", "amount": "$4.3k", "value": 0.21, "color": Color("b34a3f")}
		],
		"summary": [
			{"label": "Interest service", "amount": "$4.0k", "value": 0.55, "color": Color("b34a3f")},
			{"label": "Capital program", "amount": "$9.8k", "value": 0.78, "color": Color("b34a3f")}
		]
	},
	"Pricing": {
		"title": "Tariffs",
		"rows": [
			{"label": "Urban base (5¢)", "amount": "Holding", "value": 0.35, "color": Color("3f8a8a")},
			{"label": "Interurban (10–20¢)", "amount": "Elastic", "value": 0.48, "color": Color("3f8a8a")},
			{"label": "Excursion fares", "amount": "Seasonal", "value": 0.26, "color": Color("3f8a8a")},
			{"label": "Freight tariff", "amount": "$0.012 / ton-mi", "value": 0.52, "color": Color("3f8a8a")},
			{"label": "Mail payment", "amount": "$0.007 / mail-mi", "value": 0.44, "color": Color("3f8a8a")}
		],
		"summary": [
			{"label": "Elasticity", "amount": "-0.37", "value": 0.37, "color": Color("3f8a8a")},
			{"label": "Riders / mile", "amount": "148", "value": 0.60, "color": Color("3f8a8a")}
		]
	}
}

const TOOL_BUTTON_LABELS := [
	"Routes", "Finance", "Overlay", "Build", "Demo", "Stops",
	"Growth", "Cam", "Map", "Speed", "Pause", "Help"
]

func _resolve_main_scene() -> Node:
	var current := get_tree().get_current_scene()
	if current != null:
		return current
	var root := get_tree().root
	if root != null and root.get_child_count() > 0:
		return root.get_child(root.get_child_count() - 1)
	return self

@onready var finance_window: PanelContainer = $FinanceWindow
@onready var finance_rows := $FinanceWindow/FinanceMargin/FinanceContent/TablePanel/TableMargin/TableContent/RowsScroll/Rows.get_children()
@onready var finance_summary_rows := $FinanceWindow/FinanceMargin/FinanceContent/SummaryPanel/SummaryMargin/SummaryContent/SummaryRows.get_children()
@onready var finance_header_label: Label = $FinanceWindow/FinanceMargin/FinanceContent/HeaderPanel/HeaderContent/HeaderLabel
@onready var finance_close_button: Button = $FinanceWindow/FinanceMargin/FinanceContent/HeaderPanel/HeaderContent/CloseButton
@onready var finance_tabs: Array = $FinanceWindow/FinanceMargin/FinanceContent/TabsPanel/Tabs.get_children()
@onready var finance_tab_buttons: Array = finance_tabs
@onready var tool_buttons: Array = $BottomBar/BottomMargin/BottomContent/ToolStrip/ToolRow.get_children()
@onready var announcement_strip: PanelContainer = $AnnouncementStrip
@onready var announcement_text_label: Label = $AnnouncementStrip/AnnouncementText
@onready var build_mode_panel: PanelContainer = $BuildModePanel
@onready var build_info_label: Label = $BuildModePanel/BuildMargin/BuildContent/BuildInfo
@onready var build_hint_label: Label = $BuildModePanel/BuildMargin/BuildContent/BuildHint
@onready var build_track_button: Button = $BuildModePanel/BuildMargin/BuildContent/BuildToolRow/TrackButton
@onready var build_station_button: Button = $BuildModePanel/BuildMargin/BuildContent/BuildToolRow/StationButton
@onready var build_depot_button: Button = $BuildModePanel/BuildMargin/BuildContent/BuildToolRow/DepotButton
@onready var build_signal_button: Button = $BuildModePanel/BuildMargin/BuildContent/BuildToolRow/SignalButton
@onready var build_bulldoze_button: Button = $BuildModePanel/BuildMargin/BuildContent/BuildToolRow/BulldozeButton
@onready var build_close_button: Button = $BuildModePanel/BuildMargin/BuildContent/BuildToolRow/CloseBuildButton
@onready var time_line_label: Label = $BottomBar/BottomMargin/BottomContent/StatusPanel/StatusContent/TimeLine
@onready var status_title_label: Label = $BottomBar/BottomMargin/BottomContent/StatusPanel/StatusContent/StatusTitle
@onready var status_line_label: Label = $BottomBar/BottomMargin/BottomContent/StatusPanel/StatusContent/StatusLine
@onready var service_line_label: Label = $BottomBar/BottomMargin/BottomContent/StatusPanel/StatusContent/ServiceLine
@onready var signal_red_lamp: Panel = $BottomBar/BottomMargin/BottomContent/StatusPanel/StatusContent/SignalHead/RedLamp
@onready var signal_yellow_lamp: Panel = $BottomBar/BottomMargin/BottomContent/StatusPanel/StatusContent/SignalHead/YellowLamp
@onready var signal_green_lamp: Panel = $BottomBar/BottomMargin/BottomContent/StatusPanel/StatusContent/SignalHead/GreenLamp
@onready var signal_line_label: Label = $BottomBar/BottomMargin/BottomContent/StatusPanel/StatusContent/SignalLine
@onready var _main_scene: Node = _resolve_main_scene()
@onready var _camera_rig: Node = _main_scene.get_node_or_null("WorldRoot/CameraRig") if _main_scene != null else null
@onready var _overlay: Node = _main_scene.get_node_or_null("OverlayCanvas/HistoricOverlay") if _main_scene != null else null
@onready var _stop_placer: Node = _main_scene.get_node_or_null("WorldRoot/StopPlacer") if _main_scene != null else null
@onready var _corridor: Node = _main_scene.get_node_or_null("WorldRoot/CorridorSeed") if _main_scene != null else null
@onready var _towns: Node = _main_scene.get_node_or_null("WorldRoot/TownGrowthManager") if _main_scene != null else null
@onready var _economy: Node = _main_scene.get_node_or_null("WorldRoot/Economy") if _main_scene != null else null
@onready var _time_controller: Node = _main_scene.get_node_or_null("WorldRoot/TimeOfDay") if _main_scene != null else null
var _current_tab := "Overview"
var _system_map_panel: Control
var _finance_graph_panel: PanelContainer
var _finance_history_graph: Control
var _timetable_window: PanelContainer
var _timetable_header_panel: PanelContainer
var _timetable_segment_panel: PanelContainer
var _timetable_depot_panel: PanelContainer
var _timetable_close_button: Button
var _timetable_summary_label: Label
var _timetable_message_label: Label
var _timetable_segment_rows: VBoxContainer
var _timetable_depot_rows: VBoxContainer
var _timetable_message := ""
var _timetable_refresh_accum := 0.0
var _line_selector_panel: PanelContainer
var _line_selector_option: OptionButton
var _manual_control_toggle: CheckButton
var _line_selector_ids: Array[String] = []
var _line_selector_syncing := false
var _driver_dashboard_panel: PanelContainer
var _driver_dashboard: Control

func _ready() -> void:
	theme = ClassicThemeScript.build_theme()
	_ensure_finance_graph_panel()
	_ensure_timetable_window()
	_ensure_line_selector_panel()
	_ensure_driver_dashboard()
	_style_controls()
	_ensure_system_map_panel()
	_bind_signals()
	_setup_tool_actions()
	_select_tab(_current_tab)
	_apply_row_colors()
	_update_status_panel()

func _process(_delta: float) -> void:
	if finance_window.visible:
		_refresh_finance_window()
	if _timetable_window != null and _timetable_window.visible:
		_timetable_refresh_accum += _delta
		if _timetable_refresh_accum >= 0.25:
			_timetable_refresh_accum = 0.0
			_refresh_timetable_window()
	_refresh_line_selector_panel()
	_update_status_panel()
	_update_build_panel()
	_update_announcement_banner()
	_update_driver_dashboard()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_routes"):
		_toggle_timetable_window()
	if event.is_action_pressed("toggle_finances"):
		_toggle_finance_window()
	if event.is_action_pressed("toggle_map"):
		_toggle_system_map_view()
	if event.is_action_pressed("build_tool_track"):
		_select_build_tool("track")
	if event.is_action_pressed("build_tool_station"):
		_select_build_tool("station")
	if event.is_action_pressed("build_tool_depot"):
		_select_build_tool("depot")
	if event.is_action_pressed("build_tool_signal"):
		_select_build_tool("signal")
	if event.is_action_pressed("build_tool_bulldoze"):
		_select_build_tool("bulldoze")
	if event.is_action_pressed("ui_cancel"):
		if finance_window.visible:
			_toggle_finance_window(false)
		if _timetable_window != null and _timetable_window.visible:
			_toggle_timetable_window(false)
		if _system_map_panel != null and _system_map_panel.visible:
			_toggle_system_map_view(false)
		if build_mode_panel != null and build_mode_panel.visible and (_stop_placer == null or not bool(_stop_placer.get("active"))):
			_close_build_mode()

func _apply_row_colors() -> void:
	for row in finance_rows + finance_summary_rows:
		if row.has_method("apply_theme"):
			row.apply_theme()

func _style_controls() -> void:
	var wood_dark := Color("6f4a2e")
	var wood_mid := Color("8c6a4a")
	var wood_light := Color("a88563")
	var brass := Color("caa76a")
	var brass_dark := Color("a4814f")
	var parchment := Color("f1e5cf")
	var parchment_dark := Color("dfcdb0")

	var wood_panel := _make_panel(wood_mid, brass, 2, 8, Color(0, 0, 0, 0.28), 10)
	var inset_panel := _make_panel(parchment, brass_dark, 1, 6, Color(0, 0, 0, 0.18), 6)
	var header_panel := _make_panel(wood_light, brass, 2, 6, Color(0, 0, 0, 0.25), 8)

	_apply_panel("FinanceWindow", wood_panel)
	_apply_panel("FinanceWindow/FinanceMargin/FinanceContent/HeaderPanel", header_panel)
	_apply_panel("FinanceWindow/FinanceMargin/FinanceContent/TabsPanel", inset_panel)
	_apply_panel("FinanceWindow/FinanceMargin/FinanceContent/TablePanel", inset_panel)
	_apply_panel("FinanceWindow/FinanceMargin/FinanceContent/SummaryPanel", inset_panel)
	_apply_panel("AnnouncementStrip", header_panel)
	_apply_panel("BuildModePanel", header_panel)
	_apply_panel("BottomBar", wood_panel)
	_apply_panel("BottomBar/BottomMargin/BottomContent/ToolStrip", inset_panel)
	_apply_panel("BottomBar/BottomMargin/BottomContent/StatusPanel", inset_panel)
	_apply_signal_head("GREEN")

	for button in finance_tab_buttons:
		if button is Button:
			_apply_button_style(button, wood_dark, brass, wood_light)

	for button in tool_buttons:
		if button is Button:
			_apply_tool_button_style(button, wood_mid, brass)
	for button in [build_track_button, build_station_button, build_depot_button, build_signal_button, build_bulldoze_button, build_close_button]:
		if button != null:
			_apply_button_style(button, wood_dark, brass, wood_light)
	for i in range(min(tool_buttons.size(), TOOL_BUTTON_LABELS.size())):
		var btn = tool_buttons[i]
		if btn is Button:
			btn.text = TOOL_BUTTON_LABELS[i]
	_apply_button_style(finance_close_button, wood_dark, brass, wood_light)
	if _finance_graph_panel != null:
		_finance_graph_panel.add_theme_stylebox_override("panel", inset_panel)
	if _timetable_window != null:
		_timetable_window.add_theme_stylebox_override("panel", wood_panel)
	if _timetable_header_panel != null:
		_timetable_header_panel.add_theme_stylebox_override("panel", header_panel)
	if _timetable_segment_panel != null:
		_timetable_segment_panel.add_theme_stylebox_override("panel", inset_panel)
	if _timetable_depot_panel != null:
		_timetable_depot_panel.add_theme_stylebox_override("panel", inset_panel)
	if _timetable_close_button != null:
		_apply_button_style(_timetable_close_button, wood_dark, brass, wood_light)
	if _line_selector_panel != null:
		_line_selector_panel.add_theme_stylebox_override("panel", header_panel)
	if _line_selector_option != null:
		_apply_button_style(_line_selector_option, wood_dark, brass, wood_light)
	if _manual_control_toggle != null:
		_apply_button_style(_manual_control_toggle, wood_dark, brass, wood_light)
	if _driver_dashboard_panel != null:
		_driver_dashboard_panel.add_theme_stylebox_override("panel", wood_panel)

func _make_panel(bg: Color, border: Color, border_w: int, radius: int, shadow: Color, shadow_size: int) -> StyleBoxFlat:
	var panel := StyleBoxFlat.new()
	panel.bg_color = bg
	panel.border_color = border
	panel.set_border_width_all(border_w)
	panel.set_corner_radius_all(radius)
	panel.shadow_color = shadow
	panel.shadow_size = shadow_size
	return panel

func _apply_panel(path: String, panel: StyleBoxFlat) -> void:
	if not has_node(path):
		return
	var node := get_node(path)
	if node is PanelContainer:
		node.add_theme_stylebox_override("panel", panel)

func _apply_button_style(button: Button, bg: Color, border: Color, hover: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = bg
	normal.border_color = border
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(4)
	button.add_theme_stylebox_override("normal", normal)

	var hover_box := normal.duplicate()
	hover_box.bg_color = hover
	button.add_theme_stylebox_override("hover", hover_box)

	var pressed := normal.duplicate()
	pressed.bg_color = border
	button.add_theme_stylebox_override("pressed", pressed)

func _apply_tool_button_style(button: Button, bg: Color, border: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = bg
	normal.border_color = border
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", normal)
	button.add_theme_stylebox_override("pressed", normal)

func _make_signal_lamp(fill: Color) -> StyleBoxFlat:
	var lamp := StyleBoxFlat.new()
	lamp.bg_color = fill
	lamp.border_color = fill.darkened(0.45)
	lamp.set_border_width_all(1)
	lamp.set_corner_radius_all(8)
	lamp.shadow_color = Color(0, 0, 0, 0.24)
	lamp.shadow_size = 3
	return lamp

func _set_signal_lamp(panel: Panel, active: bool, color: Color) -> void:
	if panel == null:
		return
	var fill := color if active else color.darkened(0.72)
	panel.add_theme_stylebox_override("panel", _make_signal_lamp(fill))

func _apply_signal_head(aspect: String) -> void:
	_set_signal_lamp(signal_red_lamp, aspect == "RED", Color("b34a3f"))
	_set_signal_lamp(signal_yellow_lamp, aspect == "YELLOW", Color("caa76a"))
	_set_signal_lamp(signal_green_lamp, aspect == "GREEN", Color("6f8b52"))

func _bind_signals() -> void:
	for button in finance_tab_buttons:
		if button is Button:
			button.pressed.connect(func(): _select_tab(button.text))
	if finance_close_button:
		finance_close_button.pressed.connect(func(): _toggle_finance_window(false))
	for button in tool_buttons:
		if button is Button and button.text == "Finance":
			button.pressed.connect(func(): _toggle_finance_window())
	if build_track_button != null:
		build_track_button.pressed.connect(func(): _select_build_tool("track"))
	if build_station_button != null:
		build_station_button.pressed.connect(func(): _select_build_tool("station"))
	if build_depot_button != null:
		build_depot_button.pressed.connect(func(): _select_build_tool("depot"))
	if build_signal_button != null:
		build_signal_button.pressed.connect(func(): _select_build_tool("signal"))
	if build_bulldoze_button != null:
		build_bulldoze_button.pressed.connect(func(): _select_build_tool("bulldoze"))
	if build_close_button != null:
		build_close_button.pressed.connect(_close_build_mode)
	if _stop_placer != null and _stop_placer.has_signal("tool_state_changed"):
		var state_callable := Callable(self, "_on_build_tool_state_changed")
		if not _stop_placer.is_connected("tool_state_changed", state_callable):
			_stop_placer.connect("tool_state_changed", state_callable)
	if _timetable_close_button != null:
		_timetable_close_button.pressed.connect(func(): _toggle_timetable_window(false))
	if _line_selector_option != null:
		_line_selector_option.item_selected.connect(_on_line_selector_selected)
	if _manual_control_toggle != null:
		_manual_control_toggle.toggled.connect(_on_manual_control_toggled)

func _toggle_finance_window(force_state: Variant = null) -> void:
	var target := finance_window.visible if force_state == null else bool(force_state)
	finance_window.visible = (not target) if force_state == null else target
	if finance_window.visible:
		_refresh_finance_window()

func _ensure_finance_graph_panel() -> void:
	if _finance_graph_panel != null and is_instance_valid(_finance_graph_panel):
		return
	var finance_content := get_node_or_null("FinanceWindow/FinanceMargin/FinanceContent") as VBoxContainer
	var summary_panel := get_node_or_null("FinanceWindow/FinanceMargin/FinanceContent/SummaryPanel")
	if finance_content == null:
		return
	_finance_graph_panel = PanelContainer.new()
	_finance_graph_panel.name = "FinanceGraphPanel"
	_finance_graph_panel.custom_minimum_size = Vector2(0.0, 220.0)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	_finance_graph_panel.add_child(margin)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)
	var title := Label.new()
	title.text = "Monthly Trend"
	content.add_child(title)
	_finance_history_graph = FinanceHistoryGraphScript.new()
	_finance_history_graph.custom_minimum_size = Vector2(0.0, 176.0)
	_finance_history_graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_finance_history_graph.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(_finance_history_graph)
	finance_content.add_child(_finance_graph_panel)
	if summary_panel != null:
		finance_content.move_child(_finance_graph_panel, summary_panel.get_index())

func _ensure_timetable_window() -> void:
	if _timetable_window != null and is_instance_valid(_timetable_window):
		return
	_timetable_window = PanelContainer.new()
	_timetable_window.name = "TimetableWindow"
	_timetable_window.visible = false
	_timetable_window.anchor_left = 0.14
	_timetable_window.anchor_top = 0.1
	_timetable_window.anchor_right = 0.86
	_timetable_window.anchor_bottom = 0.83
	add_child(_timetable_window)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	_timetable_window.add_child(margin)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)

	_timetable_header_panel = PanelContainer.new()
	_timetable_header_panel.custom_minimum_size = Vector2(0.0, 36.0)
	content.add_child(_timetable_header_panel)
	var header_row := HBoxContainer.new()
	header_row.alignment = BoxContainer.ALIGNMENT_CENTER
	header_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_theme_constant_override("separation", 8)
	_timetable_header_panel.add_child(header_row)
	var header_label := Label.new()
	header_label.text = "Operations & Timetable"
	header_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_row.add_child(header_label)
	_timetable_close_button = Button.new()
	_timetable_close_button.text = "Close"
	_timetable_close_button.custom_minimum_size = Vector2(76.0, 30.0)
	_timetable_close_button.focus_mode = Control.FOCUS_NONE
	header_row.add_child(_timetable_close_button)

	_timetable_summary_label = Label.new()
	_timetable_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_timetable_summary_label.text = "No live timetable data."
	content.add_child(_timetable_summary_label)

	var body := HBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	content.add_child(body)

	_timetable_segment_panel = PanelContainer.new()
	_timetable_segment_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_timetable_segment_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(_timetable_segment_panel)
	var segment_margin := MarginContainer.new()
	segment_margin.add_theme_constant_override("margin_left", 12)
	segment_margin.add_theme_constant_override("margin_top", 10)
	segment_margin.add_theme_constant_override("margin_right", 12)
	segment_margin.add_theme_constant_override("margin_bottom", 10)
	_timetable_segment_panel.add_child(segment_margin)
	var segment_content := VBoxContainer.new()
	segment_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	segment_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	segment_content.add_theme_constant_override("separation", 8)
	segment_margin.add_child(segment_content)
	var segment_title := Label.new()
	segment_title.text = "Segment Headways"
	segment_content.add_child(segment_title)
	var segment_scroll := ScrollContainer.new()
	segment_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	segment_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	segment_content.add_child(segment_scroll)
	_timetable_segment_rows = VBoxContainer.new()
	_timetable_segment_rows.add_theme_constant_override("separation", 6)
	segment_scroll.add_child(_timetable_segment_rows)

	_timetable_depot_panel = PanelContainer.new()
	_timetable_depot_panel.custom_minimum_size = Vector2(320.0, 0.0)
	_timetable_depot_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(_timetable_depot_panel)
	var depot_margin := MarginContainer.new()
	depot_margin.add_theme_constant_override("margin_left", 12)
	depot_margin.add_theme_constant_override("margin_top", 10)
	depot_margin.add_theme_constant_override("margin_right", 12)
	depot_margin.add_theme_constant_override("margin_bottom", 10)
	_timetable_depot_panel.add_child(depot_margin)
	var depot_content := VBoxContainer.new()
	depot_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	depot_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	depot_content.add_theme_constant_override("separation", 8)
	depot_margin.add_child(depot_content)
	var depot_title := Label.new()
	depot_title.text = "Depot Operations"
	depot_content.add_child(depot_title)
	var depot_scroll := ScrollContainer.new()
	depot_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	depot_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	depot_content.add_child(depot_scroll)
	_timetable_depot_rows = VBoxContainer.new()
	_timetable_depot_rows.add_theme_constant_override("separation", 6)
	depot_scroll.add_child(_timetable_depot_rows)

	_timetable_message_label = Label.new()
	_timetable_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_timetable_message_label.text = ""
	content.add_child(_timetable_message_label)

func _ensure_line_selector_panel() -> void:
	if _line_selector_panel != null and is_instance_valid(_line_selector_panel):
		return
	_line_selector_panel = PanelContainer.new()
	_line_selector_panel.name = "LineSelectorPanel"
	_line_selector_panel.anchor_left = 0.016
	_line_selector_panel.anchor_top = 0.015
	_line_selector_panel.anchor_right = 0.24
	_line_selector_panel.anchor_bottom = 0.073
	add_child(_line_selector_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	_line_selector_panel.add_child(margin)

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)

	var label := Label.new()
	label.text = "Line"
	row.add_child(label)

	_line_selector_option = OptionButton.new()
	_line_selector_option.custom_minimum_size = Vector2(190.0, 30.0)
	_line_selector_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_line_selector_option.focus_mode = Control.FOCUS_NONE
	row.add_child(_line_selector_option)

	_manual_control_toggle = CheckButton.new()
	_manual_control_toggle.text = "Manual"
	_manual_control_toggle.button_pressed = true
	_manual_control_toggle.focus_mode = Control.FOCUS_NONE
	row.add_child(_manual_control_toggle)

func _refresh_line_selector_panel() -> void:
	if _line_selector_option == null or _corridor == null:
		return
	if _corridor.has_method("get_service_line_choices"):
		var choices: Array = _corridor.call("get_service_line_choices")
		var needs_rebuild := choices.size() != _line_selector_ids.size()
		if not needs_rebuild:
			for i in range(choices.size()):
				var choice: Dictionary = choices[i]
				if i >= _line_selector_ids.size() or String(choice.get("id", "")) != _line_selector_ids[i]:
					needs_rebuild = true
					break
		if needs_rebuild:
			_line_selector_syncing = true
			_line_selector_option.clear()
			_line_selector_ids.clear()
			for choice_variant in choices:
				var choice: Dictionary = choice_variant
				var line_id := String(choice.get("id", ""))
				if line_id == "":
					continue
				_line_selector_ids.append(line_id)
				_line_selector_option.add_item(String(choice.get("name", line_id)))
			_line_selector_syncing = false
	if _corridor.has_method("get_active_service_line_id"):
		var active_line_id := String(_corridor.call("get_active_service_line_id"))
		var active_idx := _line_selector_ids.find(active_line_id)
		if active_idx >= 0 and _line_selector_option.selected != active_idx:
			_line_selector_syncing = true
			_line_selector_option.select(active_idx)
			_line_selector_syncing = false
	if _manual_control_toggle != null and _corridor.has_method("is_driver_manual_control_enabled"):
		var manual_enabled := bool(_corridor.call("is_driver_manual_control_enabled"))
		_manual_control_toggle.set_pressed_no_signal(manual_enabled)
		_manual_control_toggle.text = "Manual" if manual_enabled else "Auto stops"

func _ensure_driver_dashboard() -> void:
	if _driver_dashboard_panel != null and is_instance_valid(_driver_dashboard_panel):
		return
	_driver_dashboard_panel = PanelContainer.new()
	_driver_dashboard_panel.name = "DriverDashboardPanel"
	_driver_dashboard_panel.visible = false
	_driver_dashboard_panel.anchor_left = 0.018
	_driver_dashboard_panel.anchor_top = 0.73
	_driver_dashboard_panel.anchor_right = 0.38
	_driver_dashboard_panel.anchor_bottom = 0.985
	add_child(_driver_dashboard_panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	_driver_dashboard_panel.add_child(margin)
	_driver_dashboard = AnalogCabDashboardScript.new()
	_driver_dashboard.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_driver_dashboard.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(_driver_dashboard)

func _on_line_selector_selected(index: int) -> void:
	if _line_selector_syncing:
		return
	if _corridor == null or not _corridor.has_method("set_active_service_line"):
		return
	if index < 0 or index >= _line_selector_ids.size():
		return
	_corridor.call("set_active_service_line", _line_selector_ids[index])

func _on_manual_control_toggled(pressed: bool) -> void:
	if _corridor == null or not _corridor.has_method("set_driver_manual_control"):
		return
	_corridor.call("set_driver_manual_control", pressed)

func _toggle_timetable_window(force_state: Variant = null) -> void:
	_ensure_timetable_window()
	if _timetable_window == null:
		return
	var next_visible := not _timetable_window.visible if force_state == null else bool(force_state)
	_timetable_window.visible = next_visible
	if next_visible:
		_timetable_refresh_accum = 0.0
		_refresh_timetable_window()

func _refresh_timetable_window() -> void:
	if _timetable_window == null or _timetable_segment_rows == null or _timetable_depot_rows == null:
		return
	var segments: Array = []
	var depots: Array = []
	if _corridor != null and _corridor.has_method("get_timetable_segments"):
		segments = _corridor.call("get_timetable_segments")
	if _corridor != null and _corridor.has_method("get_depot_operations_snapshot"):
		depots = _corridor.call("get_depot_operations_snapshot")
	_timetable_summary_label.text = "Live cars: %d | Timetable segments: %d | Depots: %d" % [
		int(_corridor.call("get_fleet_size")) if _corridor != null and _corridor.has_method("get_fleet_size") else 0,
		segments.size(),
		depots.size()
	]
	_clear_container_children(_timetable_segment_rows)
	_clear_container_children(_timetable_depot_rows)
	for segment_variant in segments:
		_add_timetable_segment_row(segment_variant)
	if segments.is_empty():
		_add_empty_window_row(_timetable_segment_rows, "No segment timetable is available yet.")
	for depot_variant in depots:
		_add_depot_row(depot_variant)
	if depots.is_empty():
		_add_empty_window_row(_timetable_depot_rows, "Build a depot to launch or store trolleys.")
	_timetable_message_label.text = _timetable_message

func _add_timetable_segment_row(segment_variant: Variant) -> void:
	var segment: Dictionary = segment_variant
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	_timetable_segment_rows.add_child(row)
	var title := Label.new()
	title.text = "%s  %s -> %s" % [
		String(segment.get("name", "Segment")),
		String(segment.get("start_name", "")),
		String(segment.get("end_name", ""))
	]
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(title)
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 6)
	row.add_child(action_row)
	var metrics := Label.new()
	metrics.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	metrics.text = "%.0f min target | %d active | %d suggested | %.1f mi" % [
		float(segment.get("headway_min", 0.0)),
		int(segment.get("active_cars", 0)),
		int(segment.get("suggested_cars", 0)),
		float(segment.get("length_m", 0.0)) / 1609.344
	]
	action_row.add_child(metrics)
	var minus_button := Button.new()
	minus_button.text = "-1"
	minus_button.focus_mode = Control.FOCUS_NONE
	minus_button.custom_minimum_size = Vector2(42.0, 28.0)
	_apply_button_style(minus_button, Color("6f4a2e"), Color("caa76a"), Color("a88563"))
	action_row.add_child(minus_button)
	var plus_button := Button.new()
	plus_button.text = "+1"
	plus_button.focus_mode = Control.FOCUS_NONE
	plus_button.custom_minimum_size = Vector2(42.0, 28.0)
	_apply_button_style(plus_button, Color("6f4a2e"), Color("caa76a"), Color("a88563"))
	action_row.add_child(plus_button)
	var segment_id := String(segment.get("id", ""))
	minus_button.pressed.connect(func(): _adjust_timetable_segment(segment_id, -1.0))
	plus_button.pressed.connect(func(): _adjust_timetable_segment(segment_id, 1.0))

func _add_depot_row(depot_variant: Variant) -> void:
	var depot: Dictionary = depot_variant
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	_timetable_depot_rows.add_child(row)
	var title := Label.new()
	title.text = String(depot.get("name", "Depot"))
	row.add_child(title)
	var metrics := Label.new()
	var distance_m := float(depot.get("distance_to_driver_m", INF))
	var distance_text := "%.0fm away" % distance_m if is_finite(distance_m) else "no controlled car"
	metrics.text = "Stock %d | Type 5 %d | PCC %d | %s" % [
		int(depot.get("stored_total", 0)),
		int(depot.get("type5", 0)),
		int(depot.get("pcc", 0)),
		distance_text
	]
	row.add_child(metrics)
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 6)
	row.add_child(action_row)
	var launch_button := Button.new()
	launch_button.text = "Launch"
	launch_button.focus_mode = Control.FOCUS_NONE
	launch_button.disabled = not bool(depot.get("launch_ready", false))
	_apply_button_style(launch_button, Color("6f4a2e"), Color("caa76a"), Color("a88563"))
	action_row.add_child(launch_button)
	var store_button := Button.new()
	store_button.text = "Store Current"
	store_button.focus_mode = Control.FOCUS_NONE
	store_button.disabled = not bool(depot.get("store_ready", false))
	_apply_button_style(store_button, Color("6f4a2e"), Color("caa76a"), Color("a88563"))
	action_row.add_child(store_button)
	var depot_id := String(depot.get("id", ""))
	launch_button.pressed.connect(func(): _launch_depot_trolley(depot_id))
	store_button.pressed.connect(func(): _store_depot_trolley(depot_id))

func _add_empty_window_row(container: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container.add_child(label)

func _adjust_timetable_segment(segment_id: String, delta_minutes: float) -> void:
	if _corridor == null or not _corridor.has_method("adjust_timetable_segment_headway"):
		return
	var result: Dictionary = _corridor.call("adjust_timetable_segment_headway", segment_id, delta_minutes)
	_timetable_message = String(result.get("message", ""))
	_refresh_timetable_window()

func _launch_depot_trolley(depot_id: String) -> void:
	if _corridor == null or not _corridor.has_method("launch_trolley_from_depot"):
		return
	var result: Dictionary = _corridor.call("launch_trolley_from_depot", depot_id)
	_timetable_message = String(result.get("message", ""))
	_refresh_timetable_window()

func _store_depot_trolley(depot_id: String) -> void:
	if _corridor == null or not _corridor.has_method("store_controlled_trolley_at_depot"):
		return
	var result: Dictionary = _corridor.call("store_controlled_trolley_at_depot", depot_id)
	_timetable_message = String(result.get("message", ""))
	_refresh_timetable_window()

func _clear_container_children(container: Node) -> void:
	if container == null:
		return
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _select_tab(tab_name: String) -> void:
	if not TAB_DATA.has(tab_name):
		return
	_current_tab = tab_name
	var payload = _finance_payload_for_tab(tab_name)
	if finance_header_label:
		finance_header_label.text = "Finances — %s" % payload.get("title", tab_name)
	_populate_rows(payload.get("rows", []), finance_rows)
	_populate_rows(payload.get("summary", []), finance_summary_rows)
	for button in finance_tab_buttons:
		if button is Button:
			button.disabled = (button.text == tab_name)
	_apply_row_colors()

func _populate_rows(data: Array, rows: Array) -> void:
	for i in range(rows.size()):
		var row = rows[i]
		if not row.has_method("set_data"):
			continue
		if i >= data.size():
			row.set_data("", "", 0.0, row.fill_color)
			continue
		var entry = data[i]
		row.set_data(entry.get("label", ""), entry.get("amount", ""), float(entry.get("value", 0.0)), entry.get("color", row.fill_color))

func _finance_payload_for_tab(tab_name: String) -> Dictionary:
	if _economy != null and _economy.has_method("get_finance_tab_payload"):
		var payload: Dictionary = _economy.call("get_finance_tab_payload", tab_name)
		if not payload.is_empty():
			return payload
	return TAB_DATA.get(tab_name, {"title": tab_name, "rows": [], "summary": []})

func _refresh_finance_window() -> void:
	_select_tab(_current_tab)
	if _economy != null and _economy.has_method("get_finance_history") and _finance_history_graph != null and _finance_history_graph.has_method("set_history"):
		_finance_history_graph.call("set_history", _economy.call("get_finance_history"))

func _setup_tool_actions() -> void:
	for button in tool_buttons:
		if not (button is Button):
			continue
		match button.text:
			"Routes":
				button.pressed.connect(_toggle_timetable_window)
			"Finance":
				button.pressed.connect(func(): _toggle_finance_window())
			"Overlay":
				button.pressed.connect(_toggle_overlay)
			"Build":
				button.pressed.connect(_toggle_build_mode)
			"Demo":
				button.pressed.connect(_cycle_camera)
			"Stops":
				button.pressed.connect(_activate_stop_tool)
			"Growth":
				button.pressed.connect(_spawn_suburbs_now)
			"Cam":
				button.pressed.connect(_reset_camera_iso)
			"Map":
				button.pressed.connect(_toggle_system_map_view)
			"Speed":
				button.pressed.connect(_speed_bump)
			"Pause":
				button.pressed.connect(_toggle_pause)
			"Help":
				button.pressed.connect(_show_help_toast)

func _focus_corridor_start() -> void:
	var cs = _corridor
	if cs and cs.has_method("get_mainline_points"):
		var pts: PackedVector3Array = cs.call("get_mainline_points")
		if pts.size() > 0:
			_move_camera_to(pts[0])
			return
	_move_camera_to(Vector3.ZERO)

func _focus_corridor_midpoint() -> void:
	var cs = _corridor
	if cs and cs.has_method("get_mainline_points"):
		var pts: PackedVector3Array = cs.call("get_mainline_points")
		if pts.size() > 1:
			var mid := (pts[0] + pts[pts.size() - 1]) * 0.5
			_move_camera_to(mid)
			return
	_move_camera_to(Vector3.ZERO)

func _ensure_system_map_panel() -> void:
	if _system_map_panel != null and is_instance_valid(_system_map_panel):
		return
	_system_map_panel = get_node_or_null("SystemMapPanel") as Control
	if _system_map_panel == null:
		_system_map_panel = SystemMapPanelScript.new()
		_system_map_panel.name = "SystemMapPanel"
		add_child(_system_map_panel)
	if _system_map_panel != null and _system_map_panel.has_method("set_corridor"):
		_system_map_panel.call("set_corridor", _corridor)
	if _system_map_panel != null and _system_map_panel.has_signal("navigation_requested"):
		var callable := Callable(self, "_on_map_navigation_requested")
		if not _system_map_panel.is_connected("navigation_requested", callable):
			_system_map_panel.connect("navigation_requested", callable)

func _toggle_system_map_view(force_state: Variant = null) -> void:
	_ensure_system_map_panel()
	if _system_map_panel == null:
		return
	var next_visible := not _system_map_panel.visible if force_state == null else bool(force_state)
	if _system_map_panel.has_method("set_open"):
		_system_map_panel.call("set_open", next_visible)
	else:
		_system_map_panel.visible = next_visible
	if not next_visible:
		return
	if _camera_rig and _camera_rig.has_method("set"):
		_camera_rig.set("target_mode", _camera_rig.get("CameraMode").STATE)
	_focus_corridor_midpoint()
	if _system_map_panel.has_method("refresh_snapshot"):
		_system_map_panel.call("refresh_snapshot")

func _show_map_view() -> void:
	_toggle_system_map_view(true)

func _move_camera_to(pos: Vector3) -> void:
	if _camera_rig and _camera_rig.has_method("set_focus_points"):
		_camera_rig.call("set_focus_points", pos, pos, Vector3.RIGHT)
	if _camera_rig and _camera_rig.has_method("set_subway_focus_points"):
		_camera_rig.call("set_subway_focus_points", pos, Vector3.RIGHT)
	if _camera_rig and (_camera_rig is Node3D):
		var rig := _camera_rig as Node3D
		rig.global_position = pos + Vector3(0.0, 4200.0, 3200.0)

func _on_map_navigation_requested(payload: Dictionary) -> void:
	var pos: Vector3 = payload.get("position", Vector3.ZERO)
	var kind := String(payload.get("kind", "map"))
	if kind == "trolley" and _corridor != null and _corridor.has_method("set_controlled_trolley_index"):
		var trolley_index := int(payload.get("trolley_index", -1))
		if trolley_index > 0 and bool(_corridor.call("set_controlled_trolley_index", trolley_index)):
			pos = _corridor.call("get_driver_world_position")
			_move_camera_to(pos)
			if _camera_rig and _camera_rig.has_method("set"):
				_camera_rig.set("target_mode", _camera_rig.get("CameraMode").STREET)
			_toggle_system_map_view(false)
			return
	_move_camera_to(pos)
	if _camera_rig and _camera_rig.has_method("set"):
		_camera_rig.set("target_mode", _camera_rig.get("CameraMode").ISOMETRIC)
	_toggle_system_map_view(false)

func _reset_camera_iso() -> void:
	if _camera_rig and _camera_rig.has_method("cycle_mode"):
		_camera_rig.set("target_mode", _camera_rig.get("CameraMode").ISOMETRIC)
	_move_camera_to(Vector3.ZERO)

func _toggle_overlay() -> void:
	if _overlay:
		if _overlay.has_method("toggle_overlay"):
			_overlay.call("toggle_overlay")
		else:
			_overlay.visible = not _overlay.visible

func _toggle_stop_tool() -> void:
	if _stop_placer == null:
		return
	if _stop_placer.has_method("set_active") and _has_property(_stop_placer, "active"):
		_stop_placer.call("set_active", not bool(_stop_placer.get("active")))
		return
	if _has_property(_stop_placer, "active"):
		_stop_placer.set("active", not bool(_stop_placer.get("active")))

func _activate_track_tool() -> void:
	if _stop_placer == null:
		return
	if build_mode_panel.visible and _stop_placer.has_method("get_tool_mode_name") and _has_property(_stop_placer, "active"):
		var same_mode: bool = _stop_placer.call("get_tool_mode_name") == "Track"
		var is_active := bool(_stop_placer.get("active"))
		if same_mode and is_active:
			_close_build_mode()
			return
	_select_build_tool("track")

func _activate_stop_tool() -> void:
	_select_build_tool("station")

func _toggle_build_mode(force_state: Variant = null) -> void:
	if build_mode_panel == null:
		return
	var next_visible := not build_mode_panel.visible if force_state == null else bool(force_state)
	if not next_visible:
		_close_build_mode()
		return
	_select_build_tool("track")

func _select_build_tool(mode_name: String) -> void:
	if build_mode_panel != null:
		build_mode_panel.visible = true
	if _stop_placer != null and _stop_placer.has_method("set_tool_mode_name"):
		_stop_placer.call("set_tool_mode_name", mode_name, true)
	_update_build_panel()

func _close_build_mode() -> void:
	if build_mode_panel != null:
		build_mode_panel.visible = false
	if _stop_placer != null and _stop_placer.has_method("set_active"):
		_stop_placer.call("set_active", false)
	_update_build_panel()

func _on_build_tool_state_changed(_active: bool, _tool_mode: int, _has_anchor: bool) -> void:
	_update_build_panel()

func _has_property(target: Object, prop_name: String) -> bool:
	if target == null:
		return false
	for prop in target.get_property_list():
		if String(prop.get("name", "")) == prop_name:
			return true
	return false

func _spawn_suburbs_now() -> void:
	if _towns and _towns.has_method("SpawnSuburbsForAllStops"):
		_towns.call_deferred("SpawnSuburbsForAllStops")

func _cycle_camera() -> void:
	if _camera_rig and _camera_rig.has_method("cycle_mode"):
		_camera_rig.call("cycle_mode")

func _speed_bump() -> void:
	var tree := get_tree()
	tree.time_scale = clamp(tree.time_scale + 0.25, 0.25, 3.0)

func _toggle_pause() -> void:
	var tree := get_tree()
	tree.paused = not tree.paused

func _show_help_toast() -> void:
	print("Controls: C cycle camera, X subway inspection camera, V driver/chase, hold Shift+W to notch up power, Space service brake, hold Shift+S to notch down or reverse, N trolley type, L cycle service line, K recover after an incident, M map, O overlay, mouse wheel zooms overlay, middle-drag pans overlay, F finances, R routes/timetable, 1-5 build tools, G cycles build tools, A autorail, Q/E rotate depots and stations, [ ] change station length or signal spacing, left click builds, right click cancels.")

func _update_status_panel() -> void:
	if signal_line_label == null or status_title_label == null or status_line_label == null or service_line_label == null or time_line_label == null:
		return
	time_line_label.text = "06:30  May 1, 1900"
	if _time_controller != null and _time_controller.has_method("get_hud_time_text"):
		time_line_label.text = String(_time_controller.call("get_hud_time_text"))
	if _corridor != null and _corridor.has_method("get_weather_status"):
		var weather_payload: Dictionary = _corridor.call("get_weather_status")
		var weather_text := String(weather_payload.get("hud_text", ""))
		if weather_text != "":
			time_line_label.text = "%s | %s" % [time_line_label.text, weather_text]
	status_title_label.text = "Running"
	status_line_label.text = "No station target"
	service_line_label.text = "Service: 78 | Line settling | Fare x1.00"
	if _corridor and _corridor.has_method("get_driver_incident_status"):
		var incident_payload: Dictionary = _corridor.call("get_driver_incident_status")
		if bool(incident_payload.get("active", false)):
			var incident_state := String(incident_payload.get("state", "INCIDENT"))
			var incident_message := String(incident_payload.get("message", "Emergency stop"))
			var incident_speed_mps := float(incident_payload.get("speed_mps", 0.0))
			status_title_label.text = "Incident: %s" % incident_state.capitalize()
			status_line_label.text = incident_message
			service_line_label.text = "Emergency stop | Impact %.0f mph | Press K to recover" % (incident_speed_mps * 2.23694)
			_apply_signal_head("RED")
			signal_line_label.text = "Signal: RED - Service blocked"
			signal_line_label.modulate = Color("b34a3f")
			return
	if _corridor and _corridor.has_method("get_driver_station_status"):
		var station_payload: Dictionary = _corridor.call("get_driver_station_status")
		var current_name := String(station_payload.get("current", ""))
		var next_name := String(station_payload.get("next", ""))
		var distance_m := float(station_payload.get("distance_m", -1.0))
		var current_waiting := int(station_payload.get("current_waiting", 0))
		var next_waiting := int(station_payload.get("next_waiting", 0))
		var onboard := int(station_payload.get("onboard", 0))
		var capacity := int(station_payload.get("capacity", 0))
		var last_boarded := int(station_payload.get("last_boarded", 0))
		var last_alighted := int(station_payload.get("last_alighted", 0))
		var last_waiting_after := int(station_payload.get("last_waiting_after", 0))
		var last_service_station := String(station_payload.get("last_service_station", ""))
		var last_service_age_s := float(station_payload.get("last_service_age_s", 999.0))
		var last_revenue := float(station_payload.get("last_revenue", 0.0))
		var needs_slowdown := bool(station_payload.get("needs_slowdown", false))
		var load_text := "Load: %d/%d" % [onboard, capacity]
		if current_name != "":
			status_title_label.text = "At Station: %s" % current_name
			var dwell_s := float(station_payload.get("dwell_seconds", 0.0))
			var target_dwell_s := float(station_payload.get("target_dwell_seconds", 0.0))
			var hold_for_headway := bool(station_payload.get("hold_for_headway", false))
			var dwell_text := ""
			if target_dwell_s > 0.05 and not needs_slowdown:
				dwell_text = " | Dwell %.1f/%.1fs" % [dwell_s, target_dwell_s]
			if needs_slowdown:
				status_line_label.text = "Slow to board | Waiting: %d | %s" % [current_waiting, load_text]
			elif last_service_station == current_name and last_service_age_s <= 7.0:
				status_line_label.text = "Boarded %d, alighted %d | Fare +$%.2f | Waiting: %d | %s" % [last_boarded, last_alighted, last_revenue, last_waiting_after, load_text]
			elif hold_for_headway:
				status_line_label.text = "Hold for spacing | Waiting: %d | %s%s" % [current_waiting, load_text, dwell_text]
			elif next_name != "":
				status_line_label.text = "Next stop: %s | Waiting here: %d | %s%s" % [next_name, current_waiting, load_text, dwell_text]
			else:
				status_line_label.text = "Standing in station | Waiting: %d | %s%s" % [current_waiting, load_text, dwell_text]
		elif next_name != "":
			status_title_label.text = "Next Stop: %s" % next_name
			var distance_text := "Distance: %.0fm" % distance_m if distance_m >= 0.0 else "Approaching station"
			status_line_label.text = "%s | Waiting: %d | %s" % [distance_text, next_waiting, load_text]
	if _corridor and _corridor.has_method("get_driver_service_status"):
		var service_payload: Dictionary = _corridor.call("get_driver_service_status")
		var rating := float(service_payload.get("rating", 78.0))
		var line_name := String(service_payload.get("line_name", ""))
		var last_event := String(service_payload.get("last_event", "Line settling"))
		var event_age_s := float(service_payload.get("last_event_age_s", 999.0))
		var headway_target := float(service_payload.get("headway_target_m", 0.0))
		var headway_ahead := float(service_payload.get("headway_ahead_m", -1.0))
		var fare_multiplier := float(service_payload.get("fare_multiplier", 1.0))
		var manual_enabled := bool(service_payload.get("manual_control_enabled", true))
		var drive_payload: Dictionary = service_payload.get("drive", {})
		var power_notch := int(drive_payload.get("power_notch", 0))
		var braking := bool(drive_payload.get("braking", false))
		var control_text := "Manual" if manual_enabled else "Auto"
		var drive_text := "Coast"
		if braking:
			drive_text = "Brake"
		elif power_notch > 0:
			drive_text = "Power N%d" % power_notch
		elif power_notch < 0:
			drive_text = "Reverse N%d" % abs(power_notch)
		if event_age_s <= 8.0 and last_event != "":
			service_line_label.text = "%s | Service: %.0f | %s | %s | %s | Fare x%.2f" % [line_name, rating, control_text, drive_text, last_event, fare_multiplier]
		elif headway_target > 0.0 and headway_ahead >= 0.0:
			service_line_label.text = "%s | Service: %.0f | %s | %s | Headway %.0f/%.0fm | Fare x%.2f" % [line_name, rating, control_text, drive_text, headway_ahead, headway_target, fare_multiplier]
		else:
			service_line_label.text = "%s | Service: %.0f | %s | %s | Fare x%.2f" % [line_name, rating, control_text, drive_text, fare_multiplier]
	var signal_aspect := "GREEN"
	var signal_text := "Signal: GREEN - Proceed"
	var signal_color := Color("6f8b52")
	if _corridor and _corridor.has_method("get_driver_signal_status"):
		var payload: Dictionary = _corridor.call("get_driver_signal_status")
		var aspect := String(payload.get("aspect", "GREEN"))
		var message := String(payload.get("message", "Proceed"))
		signal_aspect = aspect
		signal_text = "Signal: %s - %s" % [aspect, message]
		signal_color = payload.get("color", signal_color)
	_apply_signal_head(signal_aspect)
	signal_line_label.text = signal_text
	signal_line_label.modulate = signal_color

func _update_driver_dashboard() -> void:
	if _driver_dashboard_panel == null or _driver_dashboard == null:
		return
	if _corridor == null or not _corridor.has_method("get_driver_hud_status"):
		_driver_dashboard_panel.visible = false
		return
	var payload: Dictionary = _corridor.call("get_driver_hud_status")
	var active := bool(payload.get("active", false))
	_driver_dashboard_panel.visible = active
	if not active:
		return
	if _driver_dashboard.has_method("set_payload"):
		_driver_dashboard.call("set_payload", payload)

func _update_build_panel() -> void:
	if build_mode_panel == null or build_info_label == null or build_hint_label == null:
		return
	if _stop_placer == null or not _stop_placer.has_method("get_tycoon_build_state"):
		build_info_label.text = "Construction tools unavailable."
		build_hint_label.text = ""
		return
	var payload: Dictionary = _stop_placer.call("get_tycoon_build_state")
	var active := bool(payload.get("active", false))
	if not build_mode_panel.visible and not active:
		return
	var mode := String(payload.get("mode", "Track"))
	var cash := float(payload.get("cash", 0.0))
	var preview_cost := float(payload.get("preview_cost", 0.0))
	var frequency := float(payload.get("frequency", 6.0))
	var autorail_enabled := bool(payload.get("autorail_enabled", false))
	var rotation_deg := float(payload.get("rotation_deg", 0.0))
	var station_length_tiles := int(payload.get("station_length_tiles", 3))
	var station_track_count := int(payload.get("station_track_count", 2))
	var signal_run_spacing_m := float(payload.get("signal_run_spacing_m", 70.0))
	var cost_text := "No cost"
	if preview_cost > 0.0:
		cost_text = "Cost: $%s" % _money_text(preview_cost)
	elif preview_cost < 0.0:
		cost_text = "Refund: $%s" % _money_text(absf(preview_cost))
	build_info_label.text = "Mode: %s | Cash: $%s | %s%s" % [
		mode,
		_money_text(cash),
		cost_text,
		" | Headway %.0f min" % frequency if mode == "Station" else ""
	]
	var status := String(payload.get("status", ""))
	var tool_hint := "Left click to build, right click to cancel. Hotkeys: 1 Track, 2 Station, 3 Depot, 4 Signal, 5 Bulldoze."
	match mode:
		"Track":
			tool_hint = "A toggles autorail (%s). Click-drag from an anchor to lay terrain-following roadbed." % ("on" if autorail_enabled else "off")
		"Station":
			tool_hint = "[ ] set platform length (%d tiles). Q/E rotate. %d-track station snaps to live track." % [station_length_tiles, station_track_count]
		"Depot":
			tool_hint = "Q/E rotate depot frontage before placing. Depot lead snaps to track."
		"Signal":
			tool_hint = "Click once to start a signal run, click again to finish. [ ] adjust spacing (%.0fm)." % signal_run_spacing_m
	build_hint_label.text = "%s | Rotation %.0f°" % [status if status != "" else tool_hint, rotation_deg] if mode in ["Station", "Depot"] else (status if status != "" else tool_hint)
	_set_build_button_state(build_track_button, mode == "Track")
	_set_build_button_state(build_station_button, mode == "Station")
	_set_build_button_state(build_depot_button, mode == "Depot")
	_set_build_button_state(build_signal_button, mode == "Signal")
	_set_build_button_state(build_bulldoze_button, mode == "Bulldoze")

func _set_build_button_state(button: Button, active: bool) -> void:
	if button == null:
		return
	button.disabled = active

func _money_text(amount: float) -> String:
	return String.num(amount, 0)

func _update_announcement_banner() -> void:
	if announcement_strip == null or announcement_text_label == null:
		return
	announcement_strip.visible = false
	if _corridor == null or not _corridor.has_method("get_driver_announcement_status"):
		return
	var payload: Dictionary = _corridor.call("get_driver_announcement_status")
	var text := String(payload.get("text", ""))
	var age_s := float(payload.get("age_s", 999.0))
	if text == "" or age_s > 4.5:
		return
	announcement_text_label.text = text
	announcement_strip.visible = true
