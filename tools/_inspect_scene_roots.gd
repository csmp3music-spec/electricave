extends SceneTree

func _init() -> void:
	var root = Node3D.new()
	var track = Node3D.new()
	track.name = "Track"
	root.add_child(track)
	var town = Node.new()
	town.name = "Town"
	root.add_child(town)
	var seed = load("res://scripts/sim/transit/CorridorSeed.gd").new()
	seed.auto_seed = false
	seed.town_manager_path = NodePath("../Town")
	seed.track_builder_path = NodePath("../Track")
	root.add_child(seed)
	print("loaded")
	quit()
