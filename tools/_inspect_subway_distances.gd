extends SceneTree

func _init() -> void:
	var seed: Node = load("res://scripts/sim/transit/CorridorSeed.gd").new()
	var names = seed.get("mainline_towns")
	var points: PackedVector3Array = seed.call("_mainline_stop_points")
	print("MAINLINE_DISTANCES")
	for i in range(points.size() - 1):
		print(names[i], " -> ", names[i + 1], ": ", snapped(points[i].distance_to(points[i + 1]), 0.1))
	var north_names = seed.get("north_subway_station_names")
	var north_points: PackedVector3Array = seed.call("_north_subway_surface_points")
	print("NORTH_DISTANCES")
	for i in range(north_points.size() - 1):
		print(north_names[i], " -> ", north_names[i + 1], ": ", snapped(north_points[i].distance_to(north_points[i + 1]), 0.1))
	quit()
