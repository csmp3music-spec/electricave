extends RefCounted
class_name GeoProjector

static func lon_lat_to_world(lon: float, lat: float, bounds, world_size: Vector2) -> Vector3:
	if bounds == null:
		return Vector3.ZERO
	var min_lon := _safe_prop(bounds, "min_lon", -180.0)
	var max_lon := _safe_prop(bounds, "max_lon", 180.0)
	var min_lat := _safe_prop(bounds, "min_lat", -90.0)
	var max_lat := _safe_prop(bounds, "max_lat", 90.0)
	var u: float = (lon - min_lon) / max(0.000001, max_lon - min_lon)
	var v: float = (lat - min_lat) / max(0.000001, max_lat - min_lat)
	var x: float = (u - 0.5) * world_size.x
	var z: float = (0.5 - v) * world_size.y
	return Vector3(x, 0.0, z)

static func world_to_lon_lat(pos: Vector3, bounds, world_size: Vector2) -> Vector2:
	if bounds == null:
		return Vector2.ZERO
	var min_lon := _safe_prop(bounds, "min_lon", -180.0)
	var max_lon := _safe_prop(bounds, "max_lon", 180.0)
	var min_lat := _safe_prop(bounds, "min_lat", -90.0)
	var max_lat := _safe_prop(bounds, "max_lat", 90.0)
	var u: float = (pos.x / world_size.x) + 0.5
	var v: float = 0.5 - (pos.z / world_size.y)
	var lon: float = min_lon + u * (max_lon - min_lon)
	var lat: float = min_lat + v * (max_lat - min_lat)
	return Vector2(lon, lat)

static func _safe_prop(obj, name: String, fallback: float) -> float:
	if obj == null:
		return fallback
	if obj is Dictionary:
		return float(obj.get(name, fallback))
	var source: Variant = obj
	if not source is Object:
		return fallback
	if obj.has_method("get_value"):
		var method_value = obj.call("get_value", name, fallback)
		return float(method_value) if method_value != null else fallback
	if obj.has_method("has_property") and obj.has_property(name) and obj.has_method("get"):
		var v = obj.get(name)
		return float(v) if v != null else fallback
	if obj.has_method("get"):
		var v = obj.get(name)
		return float(v) if v != null else fallback
	return fallback
