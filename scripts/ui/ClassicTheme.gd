extends RefCounted
class_name ClassicTheme

static func build_theme() -> Theme:
	var theme := Theme.new()

	var body_font := SystemFont.new()
	body_font.font_names = PackedStringArray(["Palatino", "Baskerville", "Garamond", "Times New Roman"])

	var heading_font := SystemFont.new()
	heading_font.font_names = PackedStringArray(["Goudy Old Style", "Baskerville", "Palatino", "Times New Roman"])

	theme.default_font = body_font
	theme.set_font("font", "Label", body_font)
	theme.set_font("font", "Button", body_font)
	theme.set_font("font", "TabContainer", heading_font)
	theme.set_font("font", "TabBar", heading_font)
	theme.set_font("font", "ProgressBar", body_font)
	theme.set_font_size("font_size", "Label", 15)
	theme.set_font_size("font_size", "Button", 14)
	theme.set_font_size("font_size", "TabBar", 14)

	var ink := Color("2a1e14")
	var parchment := Color("e6d8c2")
	var wood_mid := Color("8c6a4a")
	var wood_dark := Color("6f4a2e")
	var brass := Color("caa76a")
	var brass_dark := Color("a4814f")
	var green := Color("3f8a3a")
	var red := Color("b34b3f")

	theme.set_color("font_color", "Label", ink)
	theme.set_color("font_color", "Button", ink)
	theme.set_color("font_color", "ProgressBar", ink)
	theme.set_color("font_color", "TabBar", ink)

	var panel := StyleBoxFlat.new()
	panel.bg_color = wood_mid
	panel.border_color = brass
	panel.set_border_width_all(2)
	panel.set_corner_radius_all(6)
	panel.shadow_color = Color(0, 0, 0, 0.28)
	panel.shadow_size = 8
	theme.set_stylebox("panel", "PanelContainer", panel)
	theme.set_stylebox("panel", "Panel", panel)

	var parchment_panel := StyleBoxFlat.new()
	parchment_panel.bg_color = parchment
	parchment_panel.border_color = brass_dark
	parchment_panel.set_border_width_all(2)
	parchment_panel.set_corner_radius_all(4)
	parchment_panel.shadow_color = Color(0, 0, 0, 0.22)
	parchment_panel.shadow_size = 6
	theme.set_stylebox("panel", "PopupPanel", parchment_panel)

	var button := StyleBoxFlat.new()
	button.bg_color = wood_dark
	button.border_color = brass
	button.set_border_width_all(2)
	button.set_corner_radius_all(4)
	button.shadow_color = Color(0, 0, 0, 0.25)
	button.shadow_size = 6
	theme.set_stylebox("normal", "Button", button)

	var button_hover := button.duplicate()
	button_hover.bg_color = wood_mid
	theme.set_stylebox("hover", "Button", button_hover)

	var button_pressed := button.duplicate()
	button_pressed.bg_color = brass_dark
	theme.set_stylebox("pressed", "Button", button_pressed)

	var tab := StyleBoxFlat.new()
	tab.bg_color = wood_dark
	tab.border_color = brass
	tab.set_border_width_all(2)
	tab.set_corner_radius_all(4)
	theme.set_stylebox("tab_selected", "TabBar", tab)

	var tab_unselected := tab.duplicate()
	tab_unselected.bg_color = wood_mid
	theme.set_stylebox("tab_unselected", "TabBar", tab_unselected)

	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.24, 0.2, 0.16, 0.65)
	bar_bg.border_color = brass_dark
	bar_bg.set_border_width_all(1)
	bar_bg.set_corner_radius_all(3)
	theme.set_stylebox("bg", "ProgressBar", bar_bg)

	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = green
	bar_fill.set_corner_radius_all(3)
	theme.set_stylebox("fill", "ProgressBar", bar_fill)

	var bar_fill_low := StyleBoxFlat.new()
	bar_fill_low.bg_color = red
	theme.set_stylebox("fill_low", "ProgressBar", bar_fill_low)

	return theme
