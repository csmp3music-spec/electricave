extends SceneTree

func _init() -> void:
	var bounds = load("res://data/ma_bounds.tres")
	for key in ["min_lon", "max_lon", "min_lat", "max_lat"]:
		print(key, " get_indexed=", bounds.get_indexed(NodePath(key)))
	quit()
