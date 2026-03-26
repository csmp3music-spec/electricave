extends SceneTree

func _init() -> void:
	var script := load("res://scripts/sim/transit/CorridorSeed.gd")
	var seed: Node = script.new()
	var names = seed.get("mainline_towns")
	var points: PackedVector3Array = seed.call("_mainline_stop_points")
	var north_names = seed.get("north_subway_station_names")
	var north_points: PackedVector3Array = seed.call("_north_subway_surface_points")
	print("MAINLINE")
	for i in range(points.size()):
		print(i, "|", names[i], "|", points[i])
	print("NORTH")
	for i in range(north_points.size()):
		print(i, "|", north_names[i], "|", north_points[i])
	quit()
