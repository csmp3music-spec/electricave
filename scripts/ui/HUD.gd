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
	"Operations": {
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

const TOP_MENU_DEFINITIONS := [
	{
		"key": "game",
		"title": "Game",
		"items": [
			{"id": 1, "label": "Pause / Resume", "command": "pause", "checkable": true},
			{"id": 2, "label": "Slow Speed", "command": "speed_slow"},
			{"id": 3, "label": "Normal Speed", "command": "speed_normal"},
			{"id": 4, "label": "Fast Speed", "command": "speed_fast"},
			{"separator": true},
			{"id": 5, "label": "Save Campaign (F5)", "command": "save"},
			{"id": 6, "label": "Load Campaign (F9)", "command": "load"},
			{"separator": true},
			{"id": 7, "label": "How To Play", "command": "help"}
		]
	},
	{
		"key": "build",
		"title": "Build",
		"items": [
			{"id": 10, "label": "Track / Autorail", "command": "build_track"},
			{"id": 11, "label": "Streetcar Stop Preset", "command": "preset_streetcar"},
			{"id": 12, "label": "Subway Transfer Preset", "command": "preset_subway"},
			{"id": 13, "label": "Interurban Preset", "command": "preset_interurban"},
			{"id": 14, "label": "Terminal Preset", "command": "preset_terminal"},
			{"separator": true},
			{"id": 15, "label": "Station Tool", "command": "build_station"},
			{"id": 16, "label": "Depot Tool", "command": "build_depot"},
			{"id": 17, "label": "Signal Run Tool", "command": "build_signal"},
			{"id": 18, "label": "Bulldoze Tool", "command": "build_bulldoze"},
			{"separator": true},
			{"id": 19, "label": "Autorail On / Off", "command": "toggle_autorail", "checkable": true},
			{"id": 20, "label": "Close Build Mode", "command": "build_close"}
		]
	},
	{
		"key": "operations",
		"title": "Operations",
		"items": [
			{"id": 30, "label": "Routes & Timetables", "command": "routes"},
			{"id": 31, "label": "Manual Controller", "command": "manual_on", "checkable": true},
			{"id": 32, "label": "Automatic Service", "command": "manual_off"},
			{"separator": true},
			{"id": 33, "label": "Next Line", "command": "line_next"},
			{"id": 34, "label": "Previous Line", "command": "line_prev"},
			{"id": 35, "label": "Next Trolley", "command": "trolley_next"},
			{"id": 36, "label": "Previous Trolley", "command": "trolley_prev"},
			{"separator": true},
			{"id": 37, "label": "Tighter Headways", "command": "headway_tighter"},
			{"id": 38, "label": "Looser Headways", "command": "headway_looser"},
			{"id": 39, "label": "Launch Car From Depot", "command": "depot_launch"},
			{"id": 40, "label": "Store Current Car", "command": "depot_store"},
			{"id": 41, "label": "Service Current Car", "command": "depot_service"},
			{"id": 42, "label": "Dispatch Road Crew", "command": "roadside_repair"}
		]
	},
	{
		"key": "view",
		"title": "View",
		"items": [
			{"id": 50, "label": "System Map", "command": "map"},
			{"id": 51, "label": "Historic Overlay", "command": "overlay"},
			{"separator": true},
			{"id": 52, "label": "Isometric Dispatch View", "command": "camera_iso"},
			{"id": 53, "label": "Cycle Camera", "command": "camera_cycle"},
			{"id": 54, "label": "Cab View", "command": "driver_cab"},
			{"id": 55, "label": "Chase View", "command": "driver_chase"},
			{"id": 56, "label": "Return To Main Camera", "command": "driver_off"}
		]
	},
	{
		"key": "company",
		"title": "Company",
		"items": [
			{"id": 60, "label": "Finances", "command": "finance"},
			{"id": 61, "label": "Force Growth Pass", "command": "growth"},
			{"id": 62, "label": "Service Map", "command": "map"},
			{"id": 63, "label": "Operations Ledger", "command": "routes"}
		]
	},
	{
		"key": "help",
		"title": "Help",
		"items": [
			{"id": 70, "label": "How To Play", "command": "help"},
			{"id": 71, "label": "Open Build Tools", "command": "build_track"},
			{"id": 72, "label": "Open Timetable", "command": "routes"}
		]
	}
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
@onready var bottom_tool_strip: PanelContainer = $BottomBar/BottomMargin/BottomContent/ToolStrip
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
@onready var _passenger_manager: Node = _main_scene.get_node_or_null("WorldRoot/PassengerManager") if _main_scene != null else null
@onready var _time_controller: Node = _main_scene.get_node_or_null("WorldRoot/TimeOfDay") if _main_scene != null else null
@onready var _game_state: Node = _main_scene.get_node_or_null("GameStateManager") if _main_scene != null else null
var _current_tab := "Overview"
var _system_map_panel: Control
var _top_menu_bar: PanelContainer
var _top_menu_buttons: Array[MenuButton] = []
var _top_menu_command_map := {}
var _finance_graph_panel: PanelContainer
var _finance_history_graph: Control
var _timetable_window: PanelContainer
var _timetable_header_panel: PanelContainer
var _timetable_control_panel: PanelContainer
var _timetable_control_label: Label
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
var _advisor_panel: PanelContainer
var _advisor_header_label: Label
var _advisor_summary_label: Label
var _advisor_action_label: Label
var _advisor_goal_label: Label
var _advisor_goal_bar: ProgressBar
var _advisor_contract_label: Label
var _advisor_contract_bar: ProgressBar
var _advisor_milestone_label: Label
var _advisor_milestone_bar: ProgressBar
var _driver_dashboard_panel: PanelContainer
var _driver_dashboard: Control
var _help_window: PanelContainer
var _help_close_button: Button
var _help_body_label: Label
var _build_restore_camera_mode := -1
var _build_camera_forced := false
var _save_status_text := ""
var _save_status_age_s := 999.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = ClassicThemeScript.build_theme()
	_ensure_top_menu_bar()
	_ensure_timetable_window()
	_ensure_line_selector_panel()
	_ensure_advisor_panel()
	_ensure_driver_dashboard()
	_ensure_help_window()
	_style_controls()
	_bind_signals()
	_bind_game_state_signals()
	_setup_tool_actions()
	_select_tab(_current_tab)
	_apply_row_colors()
	_update_status_panel()

func _process(_delta: float) -> void:
	_save_status_age_s += maxf(_delta, 0.0)
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
	_update_advisor_panel()
	_update_driver_dashboard()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			_save_campaign()
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_F9:
			_load_campaign()
			get_viewport().set_input_as_handled()
			return
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
		if _help_window != null and _help_window.visible:
			_toggle_help_window(false)
		if build_mode_panel != null and build_mode_panel.visible and (_stop_placer == null or not bool(_stop_placer.get("active"))):
			_close_build_mode()

func _apply_row_colors() -> void:
	for row in finance_rows + finance_summary_rows:
		if row.has_method("apply_theme"):
			row.apply_theme()

func _ensure_top_menu_bar() -> void:
	if _top_menu_bar != null and is_instance_valid(_top_menu_bar):
		return
	_top_menu_bar = PanelContainer.new()
	_top_menu_bar.name = "TopMenuBar"
	_top_menu_bar.anchor_left = 0.0
	_top_menu_bar.anchor_top = 0.0
	_top_menu_bar.anchor_right = 1.0
	_top_menu_bar.anchor_bottom = 0.0
	_top_menu_bar.offset_bottom = 42.0
	_top_menu_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_top_menu_bar)
	move_child(_top_menu_bar, get_child_count() - 1)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 5)
	_top_menu_bar.add_child(margin)

	var row := HBoxContainer.new()
	row.name = "TopMenuRow"
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.add_theme_constant_override("separation", 6)
	margin.add_child(row)

	_top_menu_buttons.clear()
	_top_menu_command_map.clear()
	for menu_variant in TOP_MENU_DEFINITIONS:
		var menu_def: Dictionary = menu_variant
		var menu_key := String(menu_def.get("key", "menu"))
		var button := MenuButton.new()
		button.name = "%sMenuButton" % menu_key.capitalize()
		button.text = String(menu_def.get("title", menu_key.capitalize()))
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(92.0, 30.0)
		button.tooltip_text = "Open %s commands." % button.text
		row.add_child(button)
		_top_menu_buttons.append(button)
		var popup := button.get_popup()
		popup.name = "%sPopup" % menu_key.capitalize()
		popup.id_pressed.connect(func(id: int): _on_top_menu_item_pressed(menu_key, id))
		popup.about_to_popup.connect(_sync_top_menu_checks)
		for item_variant in menu_def.get("items", []):
			var item: Dictionary = item_variant
			if bool(item.get("separator", false)):
				popup.add_separator()
				continue
			var id := int(item.get("id", 0))
			var label := String(item.get("label", "Command"))
			var command := String(item.get("command", ""))
			if bool(item.get("checkable", false)):
				popup.add_check_item(label, id)
			else:
				popup.add_item(label, id)
			_top_menu_command_map["%s:%d" % [menu_key, id]] = command

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	var status_hint := Label.new()
	status_hint.name = "TopMenuHint"
	status_hint.text = "Dispatcher menus: build, run, finance, map"
	status_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(status_hint)

func _on_top_menu_item_pressed(menu_key: String, id: int) -> void:
	var command := String(_top_menu_command_map.get("%s:%d" % [menu_key, id], ""))
	if command == "":
		return
	_execute_menu_command(command)
	_sync_top_menu_checks()

func _sync_top_menu_checks() -> void:
	for button in _top_menu_buttons:
		if button == null or not is_instance_valid(button):
			continue
		var menu_key := String(button.name).replace("MenuButton", "").to_lower()
		var popup := button.get_popup()
		for i in range(popup.get_item_count()):
			if popup.is_item_separator(i):
				continue
			var command := String(_top_menu_command_map.get("%s:%d" % [menu_key, popup.get_item_id(i)], ""))
			if command == "":
				continue
			if popup.is_item_checkable(i):
				popup.set_item_checked(i, _is_menu_command_checked(command))

func _is_menu_command_checked(command: String) -> bool:
	match command:
		"pause":
			return get_tree().paused
		"toggle_autorail":
			return _stop_placer != null and _has_property(_stop_placer, "autorail_enabled") and bool(_stop_placer.get("autorail_enabled"))
		"manual_on":
			return _corridor != null and _corridor.has_method("is_driver_manual_control_enabled") and bool(_corridor.call("is_driver_manual_control_enabled"))
	return false

func _execute_menu_command(command: String) -> void:
	match command:
		"save":
			_save_campaign()
		"load":
			_load_campaign()
		"pause":
			_toggle_pause()
		"speed_slow":
			_set_sim_speed(0.5)
		"speed_normal":
			_set_sim_speed(1.0)
		"speed_fast":
			_set_sim_speed(2.0)
		"help":
			_toggle_help_window(true)
		"build_track":
			_select_build_tool("track")
		"build_station":
			_select_build_tool("station")
		"build_depot":
			_select_build_tool("depot")
		"build_signal":
			_select_build_tool("signal")
		"build_bulldoze":
			_select_build_tool("bulldoze")
		"build_close":
			_close_build_mode()
		"toggle_autorail":
			_toggle_autorail()
		"preset_streetcar":
			_apply_build_preset("streetcar")
		"preset_subway":
			_apply_build_preset("subway")
		"preset_interurban":
			_apply_build_preset("interurban")
		"preset_terminal":
			_apply_build_preset("terminal")
		"routes":
			_toggle_timetable_window(true)
		"manual_on":
			_set_manual_control(true)
		"manual_off":
			_set_manual_control(false)
		"line_next":
			_cycle_active_line(1)
		"line_prev":
			_cycle_active_line(-1)
		"trolley_next":
			_cycle_controlled_trolley(1)
		"trolley_prev":
			_cycle_controlled_trolley(-1)
		"headway_tighter":
			_adjust_active_line_headways(-1.0)
		"headway_looser":
			_adjust_active_line_headways(1.0)
		"depot_launch":
			_launch_first_ready_depot()
		"depot_store":
			_store_first_ready_depot()
		"depot_service":
			_service_first_ready_depot()
		"roadside_repair":
			_dispatch_roadside_repair()
		"map":
			_toggle_system_map_view(true)
		"overlay":
			_toggle_overlay()
		"camera_iso":
			_reset_camera_iso()
		"camera_cycle":
			_cycle_camera()
		"driver_cab":
			_set_driver_camera_view(true, false)
		"driver_chase":
			_set_driver_camera_view(true, true)
		"driver_off":
			_set_driver_camera_view(false, true)
		"finance":
			_toggle_finance_window(true)
		"growth":
			_spawn_suburbs_now()

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

	_apply_panel("TopMenuBar", header_panel)
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
	_hide_legacy_tool_strip()

	for button in finance_tab_buttons:
		if button is Button:
			if button.text == "Pricing":
				button.text = "Operations"
			_apply_button_style(button, wood_dark, brass, wood_light)

	for button in _top_menu_buttons:
		if button != null:
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
	if _timetable_control_panel != null:
		_timetable_control_panel.add_theme_stylebox_override("panel", inset_panel)
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
		if _advisor_panel != null:
			_advisor_panel.add_theme_stylebox_override("panel", header_panel)
		for bar in [_advisor_goal_bar, _advisor_contract_bar, _advisor_milestone_bar]:
			if bar != null:
				_apply_progress_bar_style(bar, brass, parchment_dark)
		if _help_window != null:
			_help_window.add_theme_stylebox_override("panel", wood_panel)
	if _help_close_button != null:
		_apply_button_style(_help_close_button, wood_dark, brass, wood_light)
	_apply_control_tooltips()

func _hide_legacy_tool_strip() -> void:
	if bottom_tool_strip != null:
		bottom_tool_strip.visible = false
		bottom_tool_strip.custom_minimum_size = Vector2.ZERO
	var status_panel := get_node_or_null("BottomBar/BottomMargin/BottomContent/StatusPanel") as Control
	if status_panel != null:
		status_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

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

func _apply_progress_bar_style(bar: ProgressBar, fill_color: Color, bg_color: Color) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = bg_color
	bg.border_color = fill_color.darkened(0.25)
	bg.set_border_width_all(1)
	bg.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("bg", bg)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("fill", fill)

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
	if _help_close_button != null:
		_help_close_button.pressed.connect(func(): _toggle_help_window(false))

func _bind_game_state_signals() -> void:
	if _game_state == null:
		return
	if _game_state.has_signal("save_completed"):
		var save_callable := Callable(self, "_on_save_completed")
		if not _game_state.is_connected("save_completed", save_callable):
			_game_state.connect("save_completed", save_callable)
	if _game_state.has_signal("load_completed"):
		var load_callable := Callable(self, "_on_load_completed")
		if not _game_state.is_connected("load_completed", load_callable):
			_game_state.connect("load_completed", load_callable)

func _save_campaign() -> void:
	if _game_state == null or not _game_state.has_method("save_game"):
		_on_save_completed(false, "Save system unavailable.")
		return
	_game_state.call("save_game", false)

func _load_campaign() -> void:
	if _game_state == null or not _game_state.has_method("load_game"):
		_on_load_completed(false, "Load system unavailable.")
		return
	_game_state.call("load_game")

func _on_save_completed(success: bool, message: String) -> void:
	_save_status_text = ("[SAVED] " if success else "[SAVE ERROR] ") + message
	_save_status_age_s = 0.0

func _on_load_completed(success: bool, message: String) -> void:
	_save_status_text = ("[LOADED] " if success else "[LOAD ERROR] ") + message
	_save_status_age_s = 0.0

func _toggle_finance_window(force_state: Variant = null) -> void:
	var target := finance_window.visible if force_state == null else bool(force_state)
	finance_window.visible = (not target) if force_state == null else target
	if finance_window.visible:
		_ensure_finance_graph_panel()
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

func _add_timetable_command_button(parent: Node, label: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(78.0, 28.0)
	_apply_button_style(button, Color("6f4a2e"), Color("caa76a"), Color("a88563"))
	button.pressed.connect(action)
	parent.add_child(button)
	return button

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

	_timetable_control_panel = PanelContainer.new()
	_timetable_control_panel.custom_minimum_size = Vector2(0.0, 74.0)
	content.add_child(_timetable_control_panel)
	var control_margin := MarginContainer.new()
	control_margin.add_theme_constant_override("margin_left", 10)
	control_margin.add_theme_constant_override("margin_top", 8)
	control_margin.add_theme_constant_override("margin_right", 10)
	control_margin.add_theme_constant_override("margin_bottom", 8)
	_timetable_control_panel.add_child(control_margin)
	var control_content := VBoxContainer.new()
	control_content.add_theme_constant_override("separation", 6)
	control_margin.add_child(control_content)
	_timetable_control_label = Label.new()
	_timetable_control_label.text = "Dispatcher controls"
	_timetable_control_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	control_content.add_child(_timetable_control_label)
	var control_row := HBoxContainer.new()
	control_row.add_theme_constant_override("separation", 6)
	control_content.add_child(control_row)
	_add_timetable_command_button(control_row, "Manual/Auto", func(): _toggle_manual_control_from_ui())
	_add_timetable_command_button(control_row, "Prev Line", func(): _cycle_active_line(-1))
	_add_timetable_command_button(control_row, "Next Line", func(): _cycle_active_line(1))
	_add_timetable_command_button(control_row, "Prev Car", func(): _cycle_controlled_trolley(-1))
	_add_timetable_command_button(control_row, "Next Car", func(): _cycle_controlled_trolley(1))
	_add_timetable_command_button(control_row, "- Headway", func(): _adjust_active_line_headways(-1.0))
	_add_timetable_command_button(control_row, "+ Headway", func(): _adjust_active_line_headways(1.0))
	_add_timetable_command_button(control_row, "Launch", func(): _launch_first_ready_depot())
	_add_timetable_command_button(control_row, "Store", func(): _store_first_ready_depot())
	_add_timetable_command_button(control_row, "Build", func(): _select_build_tool("track"))

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
	_line_selector_panel.anchor_top = 0.064
	_line_selector_panel.anchor_right = 0.24
	_line_selector_panel.anchor_bottom = 0.122
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

func _ensure_advisor_panel() -> void:
	if _advisor_panel != null and is_instance_valid(_advisor_panel):
		return
	_advisor_panel = PanelContainer.new()
	_advisor_panel.name = "AdvisorPanel"
	_advisor_panel.anchor_left = 0.70
	_advisor_panel.anchor_top = 0.064
	_advisor_panel.anchor_right = 0.985
	_advisor_panel.anchor_bottom = 0.334
	_advisor_panel.custom_minimum_size = Vector2(330.0, 188.0)
	add_child(_advisor_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	_advisor_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 4)
	margin.add_child(content)

	_advisor_header_label = Label.new()
	_advisor_header_label.text = "Dispatcher: waiting for orders"
	_advisor_header_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_advisor_header_label.max_lines_visible = 2
	_advisor_header_label.clip_text = true
	content.add_child(_advisor_header_label)

	_advisor_summary_label = Label.new()
	_advisor_summary_label.text = "No network summary yet."
	_advisor_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_advisor_summary_label.max_lines_visible = 2
	_advisor_summary_label.clip_text = true
	content.add_child(_advisor_summary_label)

	_advisor_action_label = Label.new()
	_advisor_action_label.text = "Do next: build, run, and watch the network."
	_advisor_action_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_advisor_action_label.max_lines_visible = 3
	_advisor_action_label.clip_text = true
	content.add_child(_advisor_action_label)

	_advisor_goal_label = Label.new()
	_advisor_goal_label.text = "Goal: waiting for the first report."
	_advisor_goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_advisor_goal_label.max_lines_visible = 2
	_advisor_goal_label.clip_text = true
	content.add_child(_advisor_goal_label)
	_advisor_goal_bar = _make_advisor_progress_bar()
	content.add_child(_advisor_goal_bar)

	_advisor_contract_label = Label.new()
	_advisor_contract_label.text = "Contract: none"
	_advisor_contract_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_advisor_contract_label.max_lines_visible = 2
	_advisor_contract_label.clip_text = true
	content.add_child(_advisor_contract_label)
	_advisor_contract_bar = _make_advisor_progress_bar()
	content.add_child(_advisor_contract_bar)

	_advisor_milestone_label = Label.new()
	_advisor_milestone_label.text = "Next milestone: none yet."
	_advisor_milestone_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_advisor_milestone_label.max_lines_visible = 2
	_advisor_milestone_label.clip_text = true
	content.add_child(_advisor_milestone_label)
	_advisor_milestone_bar = _make_advisor_progress_bar()
	content.add_child(_advisor_milestone_bar)

func _make_advisor_progress_bar() -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0.0, 8.0)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.show_percentage = false
	bar.value = 0.0
	return bar

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

func _ensure_help_window() -> void:
	if _help_window != null and is_instance_valid(_help_window):
		return
	_help_window = PanelContainer.new()
	_help_window.name = "HelpWindow"
	_help_window.visible = false
	_help_window.anchor_left = 0.18
	_help_window.anchor_top = 0.12
	_help_window.anchor_right = 0.82
	_help_window.anchor_bottom = 0.78
	add_child(_help_window)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	_help_window.add_child(margin)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)

	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 8)
	content.add_child(header_row)

	var title := Label.new()
	title.text = "How To Play"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_row.add_child(title)

	_help_close_button = Button.new()
	_help_close_button.text = "Close"
	_help_close_button.custom_minimum_size = Vector2(84.0, 30.0)
	_help_close_button.focus_mode = Control.FOCUS_NONE
	header_row.add_child(_help_close_button)

	_help_body_label = Label.new()
	_help_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_help_body_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_help_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_help_body_label.text = _help_window_text()
	content.add_child(_help_body_label)

func _help_window_text() -> String:
	return "\n".join([
		"START HERE",
		"1. Use the top Build menu to lay track, choose a station preset, and add a depot.",
		"2. Use Operations > Routes & Timetables to adjust headways, launch cars, store cars, and switch active lines.",
		"3. Watch the monthly goal and the next milestone. Those are the fastest way to know what matters next.",
		"",
		"CAMERA AND WINDOWS",
		"The top menus replace the old bottom buttons: Game, Build, Operations, View, Company, and Help.",
		"Game > Save Campaign or F5 saves progress. Game > Load Campaign or F9 restores the last save. Autosave runs every three minutes.",
		"M opens the map, F opens finance, R opens operations and timetables, O toggles the overlay.",
		"C cycles camera mode. The line selector under the menus changes the active service line.",
		"",
		"BUILD TOOLS",
		"Build presets set platform length, track count, signal spacing, and station headway in one click.",
		"1 Track, 2 Station, 3 Depot, 4 Signal, 5 Bulldoze. G cycles tools. A toggles autorail.",
		"Green previews can be built; red previews now explain the exact blocker before you click.",
		"Q and E rotate depots and stations. [ and ] change platform length or signal spacing.",
		"",
		"DRIVING",
		"Operations can switch manual/auto control, cycle lines, cycle the controlled trolley, and tighten or loosen headways.",
		"Shift+W adds power, Space applies the service brake, Shift+S reduces power or reverses, K recovers after an incident.",
		"The status panel shows the next stop, signal aspect, and live running state. The Dispatcher panel explains what to fix next."
	])

func _apply_control_tooltips() -> void:
	var tool_tips := {
		"Routes": "Open live timetable controls and depot actions.",
		"Finance": "Open finances and network operations metrics.",
		"Overlay": "Toggle the historic map overlay.",
		"Build": "Open construction tools for track, stops, depots, and signals.",
		"Demo": "Cycle the camera mode.",
		"Stops": "Jump straight to station placement mode.",
		"Growth": "Force a suburban growth pass around the served stops.",
		"Cam": "Reset the camera to a broad isometric view.",
		"Map": "Open the system map and navigation shortcuts.",
		"Speed": "Raise simulation speed.",
		"Pause": "Pause or resume the simulation.",
		"Help": "Open the in-game controls and starter guide."
	}
	for button in tool_buttons:
		if button is Button:
			button.tooltip_text = String(tool_tips.get(button.text, ""))
	var finance_tab_tips := {
		"Overview": "Read the high-level monthly summary.",
		"Revenue": "See where income is coming from.",
		"Expenses": "See what is draining cash.",
		"Operations": "See goals, milestones, and crowding pressure."
	}
	for button in finance_tab_buttons:
		if button is Button:
			button.tooltip_text = String(finance_tab_tips.get(button.text, ""))
	if _line_selector_option != null:
		_line_selector_option.tooltip_text = "Choose which service line the driver tools focus on."
	if _manual_control_toggle != null:
		_manual_control_toggle.tooltip_text = "Toggle between manual driving and automatic station work."
	if build_track_button != null:
		build_track_button.tooltip_text = "Lay new track."
	if build_station_button != null:
		build_station_button.tooltip_text = "Place a station on live track."
	if build_depot_button != null:
		build_depot_button.tooltip_text = "Build a depot for launches and storage."
	if build_signal_button != null:
		build_signal_button.tooltip_text = "Place signal runs on a route."
	if build_bulldoze_button != null:
		build_bulldoze_button.tooltip_text = "Remove trackside assets and get a partial refund."
	if build_close_button != null:
		build_close_button.tooltip_text = "Close build mode."

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

func _toggle_help_window(force_state: Variant = null) -> void:
	_ensure_help_window()
	if _help_window == null:
		return
	_help_window.visible = not _help_window.visible if force_state == null else bool(force_state)

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
	if _timetable_control_label != null:
		_timetable_control_label.text = _active_line_control_text(segments, depots)
	var line_summary := _line_operations_summary_text()
	var station_summary := _station_operations_summary_text()
	var detail_lines := ""
	if line_summary != "":
		detail_lines += "\n%s" % line_summary
	if station_summary != "":
		detail_lines += "\n%s" % station_summary
	_timetable_summary_label.text = "Live cars: %d | Timetable segments: %d | Depots: %d%s" % [
		int(_corridor.call("get_fleet_size")) if _corridor != null and _corridor.has_method("get_fleet_size") else 0,
		segments.size(),
		depots.size(),
		detail_lines
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

func _active_line_control_text(segments: Array, depots: Array) -> String:
	var line_name := "No line selected"
	var line_id := ""
	if _corridor != null:
		if _corridor.has_method("get_active_service_line_id"):
			line_id = String(_corridor.call("get_active_service_line_id"))
		if _corridor.has_method("get_service_line_choices"):
			for choice_variant in _corridor.call("get_service_line_choices"):
				var choice: Dictionary = choice_variant
				if String(choice.get("id", "")) == line_id:
					line_name = String(choice.get("name", line_id))
					break
	var manual := _corridor != null and _corridor.has_method("is_driver_manual_control_enabled") and bool(_corridor.call("is_driver_manual_control_enabled"))
	var active_segment_count := 0
	for segment_variant in segments:
		var segment: Dictionary = segment_variant
		if String(segment.get("line_id", line_id)) == line_id:
			active_segment_count += 1
	var ready_depots := 0
	for depot_variant in depots:
		var depot: Dictionary = depot_variant
		if bool(depot.get("launch_ready", false)):
			ready_depots += 1
	return "%s | %s | %d editable headway segments | %d ready depot%s" % [
		line_name,
		"manual controller" if manual else "automatic service",
		active_segment_count,
		ready_depots,
		"" if ready_depots == 1 else "s"
	]

func _line_operations_summary_text() -> String:
	if _corridor == null or not _corridor.has_method("get_line_operations_snapshot"):
		return ""
	var line_payload: Variant = _corridor.call("get_line_operations_snapshot")
	if not (line_payload is Array):
		return ""
	var active_line := {}
	var worst_line := {}
	var worst_pressure := -1.0
	for line_variant in line_payload:
		if not (line_variant is Dictionary):
			continue
		var line: Dictionary = line_variant
		var pressure := float(line.get("capacity_pressure", 0.0))
		if bool(line.get("active", false)):
			active_line = line
		if pressure > worst_pressure:
			worst_pressure = pressure
			worst_line = line
	var display_line: Dictionary = active_line if not active_line.is_empty() else worst_line
	if display_line.is_empty():
		return ""
	return "Line stats: %s | %d/%d cars | %.0f%% condition | %.1f min headway | %s" % [
		String(display_line.get("name", "")),
		int(display_line.get("available_cars", display_line.get("fleet_count", 0))),
		int(display_line.get("suggested_cars", 1)),
		float(display_line.get("average_condition_percent", 100.0)),
		float(display_line.get("average_headway_min", 0.0)),
		String(display_line.get("recommendation", "Service stable"))
	]

func _station_operations_summary_text() -> String:
	if _passenger_manager == null or not _passenger_manager.has_method("get_station_operations_snapshot"):
		return ""
	var station_payload: Variant = _passenger_manager.call("get_station_operations_snapshot", 1)
	if not (station_payload is Array) or station_payload.is_empty():
		return ""
	var station_variant: Variant = station_payload[0]
	if not (station_variant is Dictionary):
		return ""
	var station: Dictionary = station_variant
	return "Station watch: %s | %d waiting | %.0f rating | %.1f min wait | %s" % [
		String(station.get("stop_name", "")),
		int(station.get("waiting", 0)),
		float(station.get("rating", 75.0)),
		float(station.get("perceived_wait_min", 0.0)),
		String(station.get("recommendation", "Maintain service"))
	]

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
	metrics.text = "Stock %d | Type 5 %d | PCC %d | Car %.0f%% %s | Service $%.0f | %s" % [
		int(depot.get("stored_total", 0)),
		int(depot.get("type5", 0)),
		int(depot.get("pcc", 0)),
		float(depot.get("current_condition_percent", 100.0)),
		String(depot.get("maintenance_status", "GOOD")),
		float(depot.get("service_cost", 0.0)),
		distance_text
	]
	metrics.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	var service_button := Button.new()
	service_button.text = "Service"
	service_button.focus_mode = Control.FOCUS_NONE
	service_button.disabled = not bool(depot.get("service_ready", false))
	_apply_button_style(service_button, Color("6f4a2e"), Color("caa76a"), Color("a88563"))
	action_row.add_child(service_button)
	var depot_id := String(depot.get("id", ""))
	launch_button.pressed.connect(func(): _launch_depot_trolley(depot_id))
	store_button.pressed.connect(func(): _store_depot_trolley(depot_id))
	service_button.pressed.connect(func(): _service_depot_trolley(depot_id))

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

func _service_depot_trolley(depot_id: String) -> void:
	if _corridor == null or not _corridor.has_method("service_controlled_trolley_at_depot"):
		return
	var result: Dictionary = _corridor.call("service_controlled_trolley_at_depot", depot_id)
	_timetable_message = String(result.get("message", ""))
	_refresh_timetable_window()

func _dispatch_roadside_repair() -> void:
	if _corridor == null or not _corridor.has_method("dispatch_roadside_repair"):
		return
	var result: Dictionary = _corridor.call("dispatch_roadside_repair")
	_timetable_message = String(result.get("message", ""))
	if _timetable_window != null and _timetable_window.visible:
		_refresh_timetable_window()

func _toggle_manual_control_from_ui() -> void:
	if _corridor == null or not _corridor.has_method("is_driver_manual_control_enabled"):
		return
	_set_manual_control(not bool(_corridor.call("is_driver_manual_control_enabled")))

func _set_manual_control(enabled: bool) -> void:
	if _corridor == null or not _corridor.has_method("set_driver_manual_control"):
		return
	_corridor.call("set_driver_manual_control", enabled)
	if _manual_control_toggle != null:
		_manual_control_toggle.set_pressed_no_signal(enabled)
		_manual_control_toggle.text = "Manual" if enabled else "Auto stops"
	_timetable_message = "Manual controller enabled." if enabled else "Automatic service enabled."
	if _timetable_window != null and _timetable_window.visible:
		_refresh_timetable_window()

func _cycle_active_line(step: int) -> void:
	_refresh_line_selector_panel()
	if _line_selector_ids.is_empty() or _corridor == null or not _corridor.has_method("set_active_service_line"):
		return
	var current_idx := _line_selector_option.selected if _line_selector_option != null else 0
	if current_idx < 0:
		current_idx = 0
	var next_idx := posmod(current_idx + step, _line_selector_ids.size())
	if bool(_corridor.call("set_active_service_line", _line_selector_ids[next_idx])):
		if _line_selector_option != null:
			_line_selector_syncing = true
			_line_selector_option.select(next_idx)
			_line_selector_syncing = false
			_timetable_message = "Active line changed to %s." % _line_selector_option.get_item_text(next_idx)
		else:
			_timetable_message = "Active line changed."
		if _timetable_window != null and _timetable_window.visible:
			_refresh_timetable_window()

func _cycle_controlled_trolley(step: int) -> void:
	if _corridor == null or not _corridor.has_method("cycle_controlled_trolley"):
		return
	if bool(_corridor.call("cycle_controlled_trolley", step)):
		_timetable_message = "Controlled trolley changed."
	if _timetable_window != null and _timetable_window.visible:
		_refresh_timetable_window()

func _adjust_active_line_headways(delta_minutes: float) -> void:
	if _corridor == null or not _corridor.has_method("get_timetable_segments"):
		return
	var active_line_id := String(_corridor.call("get_active_service_line_id")) if _corridor.has_method("get_active_service_line_id") else ""
	var changed := 0
	var last_message := ""
	for segment_variant in _corridor.call("get_timetable_segments"):
		var segment: Dictionary = segment_variant
		if active_line_id != "" and String(segment.get("line_id", active_line_id)) != active_line_id:
			continue
		var segment_id := String(segment.get("id", ""))
		if segment_id == "":
			continue
		var result: Dictionary = _corridor.call("adjust_timetable_segment_headway", segment_id, delta_minutes)
		if bool(result.get("ok", false)):
			changed += 1
			last_message = String(result.get("message", ""))
	_timetable_message = "%d segment headway%s adjusted." % [changed, "" if changed == 1 else "s"] if changed > 1 else last_message
	if _timetable_window != null and _timetable_window.visible:
		_refresh_timetable_window()

func _launch_first_ready_depot() -> void:
	if _corridor == null or not _corridor.has_method("get_depot_operations_snapshot"):
		return
	for depot_variant in _corridor.call("get_depot_operations_snapshot"):
		var depot: Dictionary = depot_variant
		if bool(depot.get("launch_ready", false)):
			_launch_depot_trolley(String(depot.get("id", "")))
			return
	_timetable_message = "No depot has a car or enough cash for launch."
	if _timetable_window != null and _timetable_window.visible:
		_refresh_timetable_window()

func _store_first_ready_depot() -> void:
	if _corridor == null or not _corridor.has_method("get_depot_operations_snapshot"):
		return
	var best_id := ""
	var best_distance := INF
	for depot_variant in _corridor.call("get_depot_operations_snapshot"):
		var depot: Dictionary = depot_variant
		if not bool(depot.get("store_ready", false)):
			continue
		var distance := float(depot.get("distance_to_driver_m", INF))
		if distance < best_distance:
			best_distance = distance
			best_id = String(depot.get("id", ""))
	if best_id != "":
		_store_depot_trolley(best_id)
		return
	_timetable_message = "Bring the controlled trolley onto a depot lead before storing it."
	if _timetable_window != null and _timetable_window.visible:
		_refresh_timetable_window()

func _service_first_ready_depot() -> void:
	if _corridor == null or not _corridor.has_method("get_depot_operations_snapshot"):
		return
	var best_id := ""
	var best_distance := INF
	for depot_variant in _corridor.call("get_depot_operations_snapshot"):
		var depot: Dictionary = depot_variant
		if not bool(depot.get("service_ready", false)):
			continue
		var distance := float(depot.get("distance_to_driver_m", INF))
		if distance < best_distance:
			best_distance = distance
			best_id = String(depot.get("id", ""))
	if best_id != "":
		_service_depot_trolley(best_id)
		return
	_timetable_message = "Bring a car needing maintenance onto a depot lead."
	if _timetable_window != null and _timetable_window.visible:
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
	_ensure_finance_graph_panel()
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
	_enter_build_camera(true)
	_update_build_panel()

func _close_build_mode() -> void:
	if build_mode_panel != null:
		build_mode_panel.visible = false
	if _stop_placer != null and _stop_placer.has_method("set_active"):
		_stop_placer.call("set_active", false)
	_exit_build_camera()
	_update_build_panel()

func _toggle_autorail() -> void:
	if _stop_placer == null:
		return
	if _stop_placer.has_method("toggle_autorail"):
		var enabled := bool(_stop_placer.call("toggle_autorail"))
		_timetable_message = "Autorail %s." % ("enabled" if enabled else "disabled")
	elif _has_property(_stop_placer, "autorail_enabled"):
		var enabled := not bool(_stop_placer.get("autorail_enabled"))
		_stop_placer.set("autorail_enabled", enabled)
		_timetable_message = "Autorail %s." % ("enabled" if enabled else "disabled")
	_update_build_panel()

func _apply_build_preset(preset_name: String) -> void:
	if _stop_placer == null or not _stop_placer.has_method("apply_build_preset"):
		_select_build_tool("station")
		return
	var result: Dictionary = _stop_placer.call("apply_build_preset", preset_name)
	var mode := String(result.get("mode", "station"))
	if mode != "":
		_select_build_tool(mode)
	else:
		_select_build_tool("station")
	_timetable_message = String(result.get("message", "Build preset applied."))
	_update_build_panel()

func _on_build_tool_state_changed(active: bool, _tool_mode: int, _has_anchor: bool) -> void:
	if not active and build_mode_panel != null and build_mode_panel.visible:
		_close_build_mode()
		return
	if active and build_mode_panel != null and build_mode_panel.visible:
		_enter_build_camera(false)
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
	if build_mode_panel != null and build_mode_panel.visible:
		return
	if _camera_rig and _camera_rig.has_method("cycle_mode"):
		_camera_rig.call("cycle_mode")

func _camera_mode_value(mode_name: String, fallback: int) -> int:
	if _camera_rig == null:
		return fallback
	var modes: Variant = _camera_rig.get("CameraMode")
	if modes is Dictionary and modes.has(mode_name):
		return int(modes[mode_name])
	return fallback

func _current_camera_mode() -> int:
	if _camera_rig == null or not _has_property(_camera_rig, "target_mode"):
		return _camera_mode_value("ISOMETRIC", 1)
	return int(_camera_rig.get("target_mode"))

func _resolve_build_camera_focus() -> Vector3:
	if _stop_placer != null and _stop_placer.has_method("get_tycoon_build_state"):
		var payload: Dictionary = _stop_placer.call("get_tycoon_build_state")
		if bool(payload.get("has_camera_focus", false)):
			var focus_variant: Variant = payload.get("camera_focus_point", Vector3.ZERO)
			if focus_variant is Vector3:
				return focus_variant
	if _camera_rig != null and _camera_rig.has_method("get_active_focus_point"):
		return _camera_rig.call("get_active_focus_point")
	return Vector3.ZERO

func _enter_build_camera(force_refocus: bool) -> void:
	if _camera_rig == null:
		return
	if not _build_camera_forced:
		_build_restore_camera_mode = _current_camera_mode()
	var focus := _resolve_build_camera_focus()
	if _camera_rig.has_method("enter_build_mode"):
		_camera_rig.call("enter_build_mode", focus)
	elif _camera_rig.has_method("set"):
		if _camera_rig.has_method("set_build_focus_point"):
			_camera_rig.call("set_build_focus_point", focus, force_refocus)
		_camera_rig.set("target_mode", _camera_mode_value("BUILD", 2))
	_build_camera_forced = true

func _exit_build_camera() -> void:
	if not _build_camera_forced or _camera_rig == null:
		return
	var restore_mode := _build_restore_camera_mode
	if restore_mode == _camera_mode_value("BUILD", 2) or restore_mode < 0:
		restore_mode = _camera_mode_value("ISOMETRIC", 1)
	if _camera_rig.has_method("leave_build_mode"):
		_camera_rig.call("leave_build_mode", restore_mode)
	elif _camera_rig.has_method("set"):
		_camera_rig.set("target_mode", restore_mode)
	_build_camera_forced = false
	_build_restore_camera_mode = -1

func _speed_bump() -> void:
	_set_sim_speed(Engine.time_scale + 0.25)

func _set_sim_speed(scale: float) -> void:
	Engine.time_scale = clampf(scale, 0.25, 3.0)
	if Engine.time_scale > 0.0:
		get_tree().paused = false

func _toggle_pause() -> void:
	var tree := get_tree()
	tree.paused = not tree.paused

func _set_driver_camera_view(active: bool, chase_view: bool) -> void:
	if _corridor == null:
		return
	if _corridor.has_method("set_driver_view_active"):
		_corridor.call("set_driver_view_active", active, chase_view)
		return
	if active and _corridor.has_method("toggle_driver_view"):
		_corridor.call("toggle_driver_view", chase_view)

func _show_help_toast() -> void:
	_toggle_help_window()

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
	var run_state := "Paused" if get_tree().paused else "Running x%.2f" % Engine.time_scale
	status_title_label.text = run_state
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
			if incident_state == "MECHANICAL":
				var repair_cost := 0.0
				if _corridor.has_method("get_driver_maintenance_status"):
					repair_cost = float(_corridor.call("get_driver_maintenance_status").get("roadside_repair_cost", 0.0))
				service_line_label.text = "Mechanical failure | Press K to dispatch road crew ($%.0f)" % repair_cost
			else:
				service_line_label.text = "Emergency stop | Impact %.0f mph | Press K to recover" % (incident_speed_mps * 2.23694)
			_apply_signal_head("RED")
			signal_line_label.text = "Signal: RED - Service blocked"
			signal_line_label.modulate = Color("b34a3f")
			return
	if _corridor and _corridor.has_method("get_driver_station_status"):
		var station_payload: Dictionary = _corridor.call("get_driver_station_status")
		var current_name := _hud_trim(String(station_payload.get("current", "")), 24)
		var next_name := _hud_trim(String(station_payload.get("next", "")), 24)
		var distance_m := float(station_payload.get("distance_m", -1.0))
		var current_waiting := int(station_payload.get("current_waiting", 0))
		var next_waiting := int(station_payload.get("next_waiting", 0))
		var onboard := int(station_payload.get("onboard", 0))
		var capacity := int(station_payload.get("capacity", 0))
		var last_boarded := int(station_payload.get("last_boarded", 0))
		var last_alighted := int(station_payload.get("last_alighted", 0))
		var last_waiting_after := int(station_payload.get("last_waiting_after", 0))
		var last_service_station := _hud_trim(String(station_payload.get("last_service_station", "")), 24)
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
		var line_name := _hud_trim(String(service_payload.get("line_name", "")), 22)
		var last_event := _hud_trim(String(service_payload.get("last_event", "Line settling")), 40)
		var event_age_s := float(service_payload.get("last_event_age_s", 999.0))
		var headway_target := float(service_payload.get("headway_target_m", 0.0))
		var headway_ahead := float(service_payload.get("headway_ahead_m", -1.0))
		var fare_multiplier := float(service_payload.get("fare_multiplier", 1.0))
		var manual_enabled := bool(service_payload.get("manual_control_enabled", true))
		var maintenance: Dictionary = service_payload.get("maintenance", {})
		var condition := float(maintenance.get("condition_percent", 100.0))
		var condition_status := String(maintenance.get("status", "GOOD"))
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
			service_line_label.text = "%s | Service %.0f | Car %.0f%% %s | %s | %s | Fare x%.2f" % [line_name, rating, condition, condition_status, control_text, drive_text, last_event, fare_multiplier]
		elif headway_target > 0.0 and headway_ahead >= 0.0:
			service_line_label.text = "%s | Service %.0f | Car %.0f%% %s | %s | %s | Headway %.0f/%.0fm | Fare x%.2f" % [line_name, rating, condition, condition_status, control_text, drive_text, headway_ahead, headway_target, fare_multiplier]
		else:
			service_line_label.text = "%s | Service %.0f | Car %.0f%% %s | %s | %s | Fare x%.2f" % [line_name, rating, condition, condition_status, control_text, drive_text, fare_multiplier]
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

func _update_advisor_panel() -> void:
	if _advisor_panel == null:
		return
	if _economy == null or not _economy.has_method("get_advisor_payload"):
		_advisor_panel.visible = false
		return
	var payload: Dictionary = _economy.call("get_advisor_payload")
	if payload.is_empty():
		_advisor_panel.visible = false
		return
	_advisor_panel.visible = true
	var severity := String(payload.get("severity", "good"))
	var severity_prefix := "[GOOD]"
	match severity:
		"setup":
			severity_prefix = "[SETUP]"
		"watch":
			severity_prefix = "[WATCH]"
		"urgent":
			severity_prefix = "[URGENT]"
	_advisor_header_label.text = _hud_trim("%s %s" % [severity_prefix, String(payload.get("headline", "Dispatcher"))], 54)
	_advisor_summary_label.text = _hud_trim(String(payload.get("summary_text", "")), 72)
	_advisor_action_label.text = "Do next: %s" % _hud_trim(String(payload.get("recommendation_text", "")), 118)
	_advisor_goal_label.text = _hud_trim(String(payload.get("goal_text", "")), 76)
	var contract_text := String(payload.get("contract_text", ""))
	var milestone_text := String(payload.get("milestone_text", ""))
	if _advisor_contract_label != null:
		_advisor_contract_label.text = _hud_trim(contract_text, 76)
	_advisor_milestone_label.text = _hud_trim(milestone_text, 76)
	var header_color := Color("6f8b52")
	match severity:
		"setup":
			header_color = Color("8c6a4a")
		"watch":
			header_color = Color("caa76a")
		"urgent":
			header_color = Color("b34a3f")
	_advisor_header_label.modulate = header_color
	if _advisor_goal_bar != null:
		_advisor_goal_bar.value = clampf(float(payload.get("goal_progress_ratio", 0.0)), 0.0, 1.0) * 100.0
	if _advisor_contract_bar != null:
		_advisor_contract_bar.value = clampf(float(payload.get("contract_progress_ratio", 0.0)), 0.0, 1.0) * 100.0
	if _advisor_milestone_bar != null:
		_advisor_milestone_bar.value = clampf(float(payload.get("milestone_progress_ratio", 0.0)), 0.0, 1.0) * 100.0

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
	var preview_valid := bool(payload.get("preview_valid", false))
	var frequency := float(payload.get("frequency", 6.0))
	var autorail_enabled := bool(payload.get("autorail_enabled", false))
	var has_anchor := bool(payload.get("has_anchor", false))
	var rotation_deg := float(payload.get("rotation_deg", 0.0))
	var station_length_tiles := int(payload.get("station_length_tiles", 3))
	var station_track_count := int(payload.get("station_track_count", 2))
	var signal_run_spacing_m := float(payload.get("signal_run_spacing_m", 70.0))
	var cost_text := "No cost"
	if preview_cost > 0.0:
		cost_text = "Cost: $%s" % _money_text(preview_cost)
	elif preview_cost < 0.0:
		cost_text = "Refund: $%s" % _money_text(absf(preview_cost))
	var anchor_text := " | Anchor set" if has_anchor else ""
	var readiness := "READY" if preview_valid else "AIM"
	build_info_label.text = "Build: %s | Mode: %s | Cash: $%s | %s%s%s" % [
		readiness,
		mode,
		_money_text(cash),
		cost_text,
		" | Headway %.0f min" % frequency if mode == "Station" else "",
		anchor_text
	]
	var status := String(payload.get("status", ""))
	var last_result := String(payload.get("last_result", ""))
	var tool_hint := "Left click builds at the green preview. Red preview explains what is blocking it. 1-5 switch tools."
	match mode:
		"Track":
			tool_hint = "A toggles autorail (%s). Click once for an anchor, click again to build. Keep clicking to extend from the last endpoint." % ("on" if autorail_enabled else "off")
			if has_anchor:
				tool_hint = "Anchor locked. Move and click to extend track from the current endpoint."
		"Station":
			tool_hint = "Stations snap to nearby built or seeded track. [ ] length (%d tiles). Q/E rotate. Current layout: %d track%s." % [station_length_tiles, station_track_count, "" if station_track_count == 1 else "s"]
		"Depot":
			tool_hint = "Depots snap to track and add a carhouse asset. Q/E rotates frontage before placing."
		"Signal":
			tool_hint = "Click once to start a signal run, click again to finish. [ ] spacing (%.0fm)." % signal_run_spacing_m
		"Bulldoze":
			tool_hint = "Click track, stations, depots, or signals to remove them and recover part of the cost."
	var camera_hint := "Build camera: edge pan or arrow keys, mouse wheel zoom, Esc/right click cancels, Close exits."
	var hint_text := status if status != "" else tool_hint
	if last_result != "" and status != "":
		hint_text = "%s | Last: %s" % [status, last_result]
	elif last_result != "":
		hint_text = "%s | %s" % [last_result, tool_hint]
	if mode in ["Station", "Depot"]:
		build_hint_label.text = "%s | Rotation %.0f° | %s" % [hint_text, rotation_deg, camera_hint]
	else:
		build_hint_label.text = "%s | %s" % [hint_text, camera_hint]
	_set_build_button_state(build_track_button, mode == "Track")
	_set_build_button_state(build_station_button, mode == "Station")
	_set_build_button_state(build_depot_button, mode == "Depot")
	_set_build_button_state(build_signal_button, mode == "Signal")
	_set_build_button_state(build_bulldoze_button, mode == "Bulldoze")

func _set_build_button_state(button: Button, active: bool) -> void:
	if button == null:
		return
	button.disabled = false
	button.modulate = Color(1.0, 0.90, 0.70, 1.0) if active else Color.WHITE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _money_text(amount: float) -> String:
	return String.num(amount, 0)

func _hud_trim(text: String, max_chars: int = 64) -> String:
	if max_chars <= 4 or text.length() <= max_chars:
		return text
	return text.substr(0, max_chars - 3).strip_edges() + "..."

func _update_announcement_banner() -> void:
	if announcement_strip == null or announcement_text_label == null:
		return
	announcement_strip.visible = false
	if _save_status_text != "" and _save_status_age_s <= 4.5:
		announcement_text_label.text = _hud_trim(_save_status_text, 112)
		announcement_strip.visible = true
		return
	if _corridor != null and _corridor.has_method("get_driver_announcement_status"):
		var payload: Dictionary = _corridor.call("get_driver_announcement_status")
		var text := String(payload.get("text", ""))
		var age_s := float(payload.get("age_s", 999.0))
		if text != "" and age_s <= 4.5:
			announcement_text_label.text = _hud_trim(text, 112)
			announcement_strip.visible = true
			return
	if _economy != null and _economy.has_method("get_gameplay_banner_payload"):
		var gameplay_payload: Dictionary = _economy.call("get_gameplay_banner_payload")
		var gameplay_text := String(gameplay_payload.get("text", ""))
		if gameplay_text != "":
			announcement_text_label.text = _hud_trim(gameplay_text, 112)
			announcement_strip.visible = true
			return
	if _passenger_manager != null and _passenger_manager.has_method("get_network_gameplay_snapshot"):
		var network_payload: Dictionary = _passenger_manager.call("get_network_gameplay_snapshot")
		if int(network_payload.get("severe_stop_count", 0)) > 0 or int(network_payload.get("urgent_crowding_alarm_count", 0)) > 0:
			var advisory_text := String(network_payload.get("advisory_text", ""))
			if advisory_text != "":
				announcement_text_label.text = _hud_trim(advisory_text, 112)
				announcement_strip.visible = true
				return
