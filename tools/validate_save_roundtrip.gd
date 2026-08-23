extends SceneTree

const GameStateManagerScript := preload("res://scripts/sim/GameStateManager.gd")
const TrackBuilderScript := preload("res://scripts/builders/TrackBuilder.gd")
const EconomyScript := preload("res://scripts/sim/Economy.gd")
const CorridorSeedScript := preload("res://scripts/sim/transit/CorridorSeed.gd")

const TEST_SAVE_PATH := "user://saves/electric_avenue_validation.json"
const TEST_CASH := 424242.0

var _test_root: Node
var _transient_nodes: Array[Node] = []

class FakeCorridor:
	extends Node

	func is_world_seeded() -> bool:
		return true

	func get_save_state() -> Dictionary:
		return {"active_line_id": "validation_line"}

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main := Node.new()
	_test_root = main
	root.add_child(main)
	var world := Node.new()
	world.name = "WorldRoot"
	main.add_child(world)

	var track = TrackBuilderScript.new()
	track.name = "TrackNetwork"
	track.render_segments = false
	world.add_child(track)
	track.add_segment(PackedVector3Array([Vector3(10.0, 0.0, 20.0), Vector3(80.0, 1.0, 90.0)]), true)

	var economy = EconomyScript.new()
	economy.name = "Economy"
	world.add_child(economy)
	economy.cash = TEST_CASH
	economy.monthly_revenue = 3210.0

	var corridor := FakeCorridor.new()
	corridor.name = "CorridorSeed"
	world.add_child(corridor)

	var manager = GameStateManagerScript.new()
	manager.name = "GameStateManager"
	manager.save_path = TEST_SAVE_PATH
	manager.autosave_enabled = false
	main.add_child(manager)

	if not manager.save_game(false):
		_finish(false, "Temporary save failed.")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEST_SAVE_PATH))
	if not (parsed is Dictionary):
		_finish(false, "Written save is not valid JSON.")
		return
	var state: Dictionary = parsed.get("state", {})
	if int(parsed.get("save_version", 0)) != 1:
		_finish(false, "Save version is missing.")
		return
	if not is_equal_approx(float(state.get("economy", {}).get("cash", 0.0)), TEST_CASH):
		_finish(false, "Economy snapshot was not serialized.")
		return

	var restored_track = TrackBuilderScript.new()
	_transient_nodes.append(restored_track)
	restored_track.render_segments = false
	restored_track.apply_save_state(state.get("track", {}))
	if restored_track.segments.size() != 1 or not bool(restored_track.segments[0].get_meta("player_built", false)):
		_finish(false, "Player track did not restore.")
		return
	var restored_economy = EconomyScript.new()
	_transient_nodes.append(restored_economy)
	restored_economy.apply_save_state(state.get("economy", {}))
	if not is_equal_approx(restored_economy.cash, TEST_CASH) or not is_equal_approx(restored_economy.monthly_revenue, 3210.0):
		_finish(false, "Economy state did not restore.")
		return

	var operations = CorridorSeedScript.new()
	_transient_nodes.append(operations)
	operations.set("_depot_inventory", {
		"validation_depot": {
			"id": "validation_depot",
			"name": "Validation Carhouse",
			"position": Vector3(12.0, 3.0, 48.0),
			"stored": {"res://test_car.tscn": 2}
		}
	})
	var operations_json := JSON.stringify(operations.get_save_state())
	var parsed_operations: Dictionary = JSON.parse_string(operations_json)
	var restored_operations = CorridorSeedScript.new()
	_transient_nodes.append(restored_operations)
	restored_operations.call("_apply_depot_inventory_save_state", parsed_operations.get("depot_inventory", {}))
	var restored_inventory: Dictionary = restored_operations.get("_depot_inventory")
	var restored_position: Vector3 = restored_inventory.get("validation_depot", {}).get("position", Vector3.ZERO)
	if restored_position != Vector3(12.0, 3.0, 48.0):
		_finish(false, "Depot world position did not round-trip through JSON.")
		return
	_finish(true, "Versioned JSON and core campaign state round-tripped successfully.")

func _finish(success: bool, message: String) -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
	for node in _transient_nodes:
		if is_instance_valid(node):
			node.free()
	_transient_nodes.clear()
	if is_instance_valid(_test_root):
		_test_root.free()
	print("[SAVE ROUNDTRIP] %s: %s" % ["PASS" if success else "FAIL", message])
	quit(0 if success else 1)
