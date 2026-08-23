extends Node
class_name HistoricalEvents

signal event_triggered(event_id: String)

@export var start_year := 1900
@export var current_year := 1900

var timeline := [
	{"id": "ww1_shortages", "year": 1917, "effect": "maintenance_up"},
	{"id": "auto_competition", "year": 1922, "effect": "demand_down"},
	{"id": "great_depression", "year": 1929, "effect": "credit_tight"}
]

func advance_year() -> void:
	current_year += 1
	for entry in timeline:
		if entry["year"] == current_year:
			emit_signal("event_triggered", entry["id"])

func get_save_state() -> Dictionary:
	return {"current_year": current_year}

func apply_save_state(state: Dictionary) -> void:
	current_year = maxi(start_year, int(state.get("current_year", current_year)))
