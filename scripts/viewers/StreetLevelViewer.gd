extends Node3D
class_name StreetLevelViewer

@export var active := false

func enter_view() -> void:
	active = true
	visible = true

func exit_view() -> void:
	active = false
	visible = false
