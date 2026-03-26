extends RefCounted
class_name ParcelGenerator

static func generate_ring(center: Vector3, radius: float, spacing: float, jitter: float) -> Array[Vector3]:
	var parcels: Array[Vector3] = []
	var int_radius := int(radius)
	for x in range(-int_radius, int_radius + 1, int(spacing)):
		for z in range(-int_radius, int_radius + 1, int(spacing)):
			var dist := Vector2(x, z).length()
			if dist > radius:
				continue
			var pos := center + Vector3(float(x) + randf_range(-jitter, jitter), 0.0, float(z) + randf_range(-jitter, jitter))
			parcels.append(pos)
	return parcels

static func generate_corridor(points: PackedVector3Array, spacing: float, half_width: float) -> Array[Vector3]:
	var parcels: Array[Vector3] = []
	for p in points:
		var offset := Vector3(randf_range(-half_width, half_width), 0.0, randf_range(-half_width, half_width))
		if randi() % 2 == 0:
			parcels.append(p + offset)
	return parcels
