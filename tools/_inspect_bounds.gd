extends SceneTree

func _init() -> void:
	var bounds = load("res://data/ma_bounds.tres")
	print(bounds)
	for key in ["min_lon", "max_lon", "min_lat", "max_lat"]:
		print(key, ": ", bounds.get(key))
	quit()
