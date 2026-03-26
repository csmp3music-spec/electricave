extends Resource
class_name TransitStop

@export var stop_id := ""
@export var frequency := 6.0 # vehicles per hour
@export var connectivity := 1.0
@export var travel_time := 6.0
@export var land_value := 1.0
@export var town_name := ""
@export var position := Vector3.ZERO
@export var stop_kind := "regular"

var ridership_demand := 0.0

func transit_score() -> float:
	return (frequency * connectivity) - travel_time
