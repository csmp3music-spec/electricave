extends SceneTree

func _init() -> void:
	var bounds = load("res://data/ma_bounds.tres")
	print("script=", bounds.get_script())
	print("class=", bounds.get_class())
	print("is Resource=", bounds is Resource)
	quit()
