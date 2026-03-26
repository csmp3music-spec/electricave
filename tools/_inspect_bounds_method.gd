extends SceneTree

func _init() -> void:
	var bounds = load("res://data/ma_bounds.tres")
	print("has get_value:", bounds.has_method("get_value"))
	if bounds.has_method("get_value"):
		for key in ["min_lon", "max_lon", "min_lat", "max_lat"]:
			print(key, " => ", bounds.call("get_value", key, -999.0))
	quit()
