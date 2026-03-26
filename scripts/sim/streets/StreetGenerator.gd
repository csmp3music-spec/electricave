extends Node
class_name StreetGenerator

@export var main_street_length := 520.0
@export var cross_street_length := 320.0
@export var grid_spacing := 80.0
@export var branch_count := 3

var street_points: PackedVector3Array = []

func generate_for_stop(center: Vector3, forward: Vector3, district_name: String = "") -> PackedVector3Array:
	var template := _boston_core_template(district_name)
	if not template.is_empty():
		var template_points := _segments_from_template(center, template)
		_append_street_points(template_points)
		return template_points
	var local_points: PackedVector3Array = PackedVector3Array()
	var dir: Vector3 = forward.normalized()
	if dir.length() < 0.01:
		dir = Vector3.FORWARD
	var main_half: float = main_street_length * 0.5
	local_points.append(center - dir * main_half)
	local_points.append(center + dir * main_half)
	var left: Vector3 = Vector3(-dir.z, 0.0, dir.x)
	var cross_half: float = cross_street_length * 0.5
	local_points.append(center - left * cross_half)
	local_points.append(center + left * cross_half)
	for i in range(1, branch_count + 1):
		var offset: Vector3 = dir * (i * grid_spacing)
		local_points.append(center + offset - left * cross_half)
		local_points.append(center + offset + left * cross_half)
		local_points.append(center - offset - left * cross_half)
		local_points.append(center - offset + left * cross_half)
	_append_street_points(local_points)
	return local_points

func nearest_street_direction(pos: Vector3) -> Vector3:
	if street_points.size() < 2:
		return Vector3.ZERO
	var best: Vector3 = Vector3.ZERO
	var best_dist: float = INF
	for i in range(0, street_points.size(), 2):
		var a: Vector3 = street_points[i]
		var b: Vector3 = street_points[i + 1]
		var p: Vector3 = _closest_point_on_segment(pos, a, b)
		var d: float = pos.distance_to(p)
		if d < best_dist:
			best_dist = d
			best = (b - a).normalized()
	return best

func _closest_point_on_segment(p: Vector3, a: Vector3, b: Vector3) -> Vector3:
	var ab: Vector3 = b - a
	var t: float = (p - a).dot(ab) / max(0.0001, ab.dot(ab))
	t = clampf(t, 0.0, 1.0)
	return a + ab * t

func _append_street_points(points: PackedVector3Array) -> void:
	for p in points:
		street_points.append(p)

func _segments_from_template(center: Vector3, template: Array) -> PackedVector3Array:
	var points := PackedVector3Array()
	for segment in template:
		if segment.size() < 2:
			continue
		var a: Vector2 = segment[0]
		var b: Vector2 = segment[1]
		points.append(center + Vector3(a.x, 0.0, a.y))
		points.append(center + Vector3(b.x, 0.0, b.y))
	return points

func _boston_core_template(district_name: String) -> Array:
	match district_name:
		"Park Street":
			return [
				[Vector2(-90.0, -260.0), Vector2(70.0, 250.0)],
				[Vector2(-260.0, 60.0), Vector2(230.0, -20.0)],
				[Vector2(-210.0, -140.0), Vector2(90.0, -205.0)],
				[Vector2(-40.0, 230.0), Vector2(180.0, 150.0)]
			]
		"Boylston":
			return [
				[Vector2(-250.0, 25.0), Vector2(250.0, -35.0)],
				[Vector2(-70.0, -220.0), Vector2(60.0, 220.0)],
				[Vector2(-220.0, -110.0), Vector2(200.0, -155.0)]
			]
		"Arlington":
			return [
				[Vector2(-260.0, 20.0), Vector2(250.0, -40.0)],
				[Vector2(-80.0, -240.0), Vector2(70.0, 250.0)],
				[Vector2(-220.0, 120.0), Vector2(180.0, 160.0)]
			]
		"Copley":
			return [
				[Vector2(-280.0, 30.0), Vector2(260.0, -40.0)],
				[Vector2(-110.0, -220.0), Vector2(90.0, 250.0)],
				[Vector2(-230.0, -120.0), Vector2(220.0, -165.0)],
				[Vector2(-200.0, 150.0), Vector2(230.0, 180.0)]
			]
		"Scollay Square":
			return [
				[Vector2(-260.0, -35.0), Vector2(230.0, 85.0)],
				[Vector2(-230.0, -130.0), Vector2(190.0, -70.0)],
				[Vector2(-130.0, 170.0), Vector2(90.0, 15.0)],
				[Vector2(10.0, -220.0), Vector2(70.0, 220.0)]
			]
		"Haymarket":
			return [
				[Vector2(-60.0, -260.0), Vector2(50.0, 250.0)],
				[Vector2(-240.0, -50.0), Vector2(210.0, 80.0)],
				[Vector2(-160.0, 180.0), Vector2(80.0, 40.0)],
				[Vector2(-180.0, -170.0), Vector2(140.0, -110.0)]
			]
		"North Station":
			return [
				[Vector2(-280.0, -10.0), Vector2(260.0, 15.0)],
				[Vector2(-45.0, -240.0), Vector2(55.0, 220.0)],
				[Vector2(-220.0, -180.0), Vector2(180.0, 70.0)],
				[Vector2(-210.0, 120.0), Vector2(180.0, 150.0)]
			]
		"State":
			return [
				[Vector2(-260.0, -30.0), Vector2(250.0, 25.0)],
				[Vector2(-40.0, -230.0), Vector2(35.0, 250.0)],
				[Vector2(-180.0, 140.0), Vector2(130.0, 55.0)],
				[Vector2(-150.0, -160.0), Vector2(100.0, -70.0)]
			]
		"Atlantic":
			return [
				[Vector2(-30.0, -280.0), Vector2(40.0, 280.0)],
				[Vector2(-250.0, -60.0), Vector2(220.0, 45.0)],
				[Vector2(-220.0, 145.0), Vector2(210.0, 175.0)],
				[Vector2(-180.0, -190.0), Vector2(120.0, -120.0)]
			]
		_:
			return []
