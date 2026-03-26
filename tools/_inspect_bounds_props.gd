extends SceneTree

func _init() -> void:
	var bounds = load("res://data/ma_bounds.tres")
	for p in bounds.get_property_list():
		if String(p.name).contains("lon") or String(p.name).contains("lat"):
			print(p)
	print("dict access min_lon:", bounds["min_lon"] if "min_lon" in bounds else "missing")
	quit()
