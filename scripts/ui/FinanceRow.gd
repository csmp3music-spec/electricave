extends HBoxContainer
class_name FinanceRow

@export var label_text := "Revenue"
@export var amount_text := ""
@export_range(0.0, 1.0, 0.01) var value := 0.75
@export var fill_color := Color("3f8a3a")
@export var bar_bg_color := Color("efe4cf")
@export var bar_border_color := Color("c9ad7a")

@onready var name_label: Label = $Name
@onready var amount_label: Label = $"Amount"
@onready var bar: ProgressBar = $Bar

func _ready() -> void:
	if label_text != "":
		name_label.text = label_text
	else:
		label_text = name_label.text
	if amount_label:
		if amount_text != "":
			amount_label.text = amount_text
	if value <= 0.0:
		value = bar.value / 100.0
	bar.value = clampf(value, 0.0, 1.0) * 100.0
	bar.show_percentage = false
	apply_theme()

func set_data(label: String, amount: String, ratio: float, color: Color = fill_color) -> void:
	label_text = label
	amount_text = amount
	value = clampf(ratio, 0.0, 1.0)
	fill_color = color
	if name_label:
		name_label.text = label_text
	if amount_label:
		amount_label.text = amount_text
	if bar:
		bar.value = value * 100.0
	apply_theme()

func apply_theme() -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = bar_bg_color
	bg.border_color = bar_border_color
	bg.set_border_width_all(1)
	bg.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("bg", bg)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("fill", fill)
