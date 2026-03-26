extends Node3D
class_name StopMarker

@export var town_name := ""
@export var stop_kind := "regular"
@onready var label: Label3D = $Label
@onready var pole: MeshInstance3D = $Pole

func _ready() -> void:
	if town_name == "":
		town_name = label.text
	label.text = town_name
	_apply_kind_style()

func _apply_kind_style() -> void:
	if pole == null:
		return
	var mat := pole.material_override
	if mat == null:
		mat = StandardMaterial3D.new()
	if mat is StandardMaterial3D:
		match stop_kind:
			"park":
				mat.albedo_color = Color("4f7f5b")
				label.modulate = Color(0.9, 1.0, 0.9, 1.0)
			_:
				mat.albedo_color = Color("d2b78a")
				label.modulate = Color(1, 0.95, 0.8, 1)
		pole.material_override = mat
