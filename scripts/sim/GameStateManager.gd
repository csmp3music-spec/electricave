extends Node
class_name GameStateManager

signal save_completed(success: bool, message: String)
signal load_completed(success: bool, message: String)

const SAVE_VERSION := 1
const DEFAULT_SAVE_PATH := "user://saves/electric_avenue.json"

@export var autosave_interval_s := 180.0
@export var autosave_enabled := true
@export var save_path := DEFAULT_SAVE_PATH

static var _pending_load: Dictionary = {}

var _autosave_accum := 0.0
var _restore_in_progress := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not _pending_load.is_empty():
		call_deferred("_restore_pending_load")

func _process(delta: float) -> void:
	if not autosave_enabled or _restore_in_progress or get_tree().paused:
		return
	if not _world_ready():
		return
	_autosave_accum += delta
	if _autosave_accum >= maxf(30.0, autosave_interval_s):
		_autosave_accum = 0.0
		save_game(true)

func save_game(autosave := false) -> bool:
	if not _world_ready():
		var not_ready_message := "World is still starting; save was not written."
		emit_signal("save_completed", false, not_ready_message)
		return false
	var payload := {
		"save_version": SAVE_VERSION,
		"game": "Electric Avenue",
		"saved_at_unix": int(Time.get_unix_time_from_system()),
		"autosave": autosave,
		"state": _collect_state()
	}
	var save_dir := save_path.get_base_dir()
	var dir_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(save_dir))
	if dir_error != OK:
		var dir_message := "Could not create the save folder (error %d)." % dir_error
		emit_signal("save_completed", false, dir_message)
		return false
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		var open_message := "Could not open the save file (error %d)." % FileAccess.get_open_error()
		emit_signal("save_completed", false, open_message)
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.flush()
	file.close()
	var message := "Autosaved campaign." if autosave else "Campaign saved."
	emit_signal("save_completed", true, message)
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(save_path):
		emit_signal("load_completed", false, "No saved campaign exists yet.")
		return false
	var raw := FileAccess.get_file_as_string(save_path)
	var parsed: Variant = JSON.parse_string(raw)
	if not (parsed is Dictionary):
		emit_signal("load_completed", false, "The save file is damaged or incomplete.")
		return false
	var payload: Dictionary = parsed
	var version := int(payload.get("save_version", 0))
	if version <= 0 or version > SAVE_VERSION:
		emit_signal("load_completed", false, "Save version %d is not supported by this build." % version)
		return false
	var state: Variant = payload.get("state", {})
	if not (state is Dictionary):
		emit_signal("load_completed", false, "The save file contains no campaign state.")
		return false
	_pending_load = state.duplicate(true)
	_restore_in_progress = true
	get_tree().paused = false
	Engine.time_scale = 1.0
	var reload_error := get_tree().reload_current_scene()
	if reload_error != OK:
		_pending_load.clear()
		_restore_in_progress = false
		emit_signal("load_completed", false, "Could not rebuild the game world (error %d)." % reload_error)
		return false
	return true

func has_save_game() -> bool:
	return FileAccess.file_exists(save_path)

func get_save_path() -> String:
	return save_path

func _collect_state() -> Dictionary:
	return {
		"track": _component_state("WorldRoot/TrackNetwork"),
		"towns": _component_state("WorldRoot/TownGrowthManager"),
		"placements": _component_state("WorldRoot/StopPlacer"),
		"passengers": _component_state("WorldRoot/PassengerManager"),
		"time": _component_state("WorldRoot/TimeOfDay"),
		"economy": _component_state("WorldRoot/Economy"),
		"history": _component_state("WorldRoot/HistoricalEvents"),
		"operations": _component_state("WorldRoot/CorridorSeed")
	}

func _component_state(path: String) -> Dictionary:
	var component := get_parent().get_node_or_null(path)
	if component != null and component.has_method("get_save_state"):
		var state: Variant = component.call("get_save_state")
		if state is Dictionary:
			return state
	return {}

func _restore_pending_load() -> void:
	_restore_in_progress = true
	var corridor := get_parent().get_node_or_null("WorldRoot/CorridorSeed")
	for frame_index in range(600):
		if corridor != null and corridor.has_method("is_world_seeded") and bool(corridor.call("is_world_seeded")):
			break
		await get_tree().process_frame
		corridor = get_parent().get_node_or_null("WorldRoot/CorridorSeed")
	if corridor == null or not corridor.has_method("is_world_seeded") or not bool(corridor.call("is_world_seeded")):
		_pending_load.clear()
		_restore_in_progress = false
		emit_signal("load_completed", false, "The world did not finish starting; campaign load was cancelled.")
		return
	var state := _pending_load.duplicate(true)
	_pending_load.clear()
	_apply_component_state("WorldRoot/TrackNetwork", state.get("track", {}))
	_apply_component_state("WorldRoot/TownGrowthManager", state.get("towns", {}))
	_apply_component_state("WorldRoot/StopPlacer", state.get("placements", {}))
	_apply_component_state("WorldRoot/PassengerManager", state.get("passengers", {}))
	_apply_component_state("WorldRoot/TimeOfDay", state.get("time", {}))
	_apply_component_state("WorldRoot/Economy", state.get("economy", {}))
	_apply_component_state("WorldRoot/HistoricalEvents", state.get("history", {}))
	_apply_component_state("WorldRoot/CorridorSeed", state.get("operations", {}))
	_restore_in_progress = false
	_autosave_accum = 0.0
	emit_signal("load_completed", true, "Campaign loaded.")

func _apply_component_state(path: String, state: Variant) -> void:
	if not (state is Dictionary):
		return
	var component := get_parent().get_node_or_null(path)
	if component != null and component.has_method("apply_save_state"):
		component.call("apply_save_state", state)

func _world_ready() -> bool:
	var corridor := get_parent().get_node_or_null("WorldRoot/CorridorSeed")
	return corridor != null and corridor.has_method("is_world_seeded") and bool(corridor.call("is_world_seeded"))
