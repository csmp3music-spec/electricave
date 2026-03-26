extends Resource
class_name GeoBounds

@export var min_lat: float = 41.2
@export var max_lat: float = 42.9
@export var min_lon: float = -73.6
@export var max_lon: float = -69.9

func size() -> Vector2:
	return Vector2(max_lon - min_lon, max_lat - min_lat)

func get_value(name: String, fallback: float = 0.0) -> float:
	match name:
		"min_lat":
			return min_lat
		"max_lat":
			return max_lat
		"min_lon":
			return min_lon
		"max_lon":
			return max_lon
	return fallback
