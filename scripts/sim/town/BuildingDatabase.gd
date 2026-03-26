extends Resource
class_name BuildingDatabase

@export var residential_low: Array[PackedScene] = []
@export var residential_medium: Array[PackedScene] = []
@export var residential_high: Array[PackedScene] = []
@export var commercial_low: Array[PackedScene] = []
@export var commercial_high: Array[PackedScene] = []
@export var industrial: Array[PackedScene] = []
@export var civic: Array[PackedScene] = []
@export var farms: Array[PackedScene] = []
@export var transit: Array[PackedScene] = []

func pick(list: Array[PackedScene]) -> PackedScene:
	if list.is_empty():
		return null
	return list[randi() % list.size()]
