extends SceneTree

func _init() -> void:
	var bounds = load("res://data/ma_bounds.tres")
	print("path=", bounds.resource_path)
	quit()
