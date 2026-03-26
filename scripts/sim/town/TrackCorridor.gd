extends Node
class_name TrackCorridor

@export var influence_radius := 180.0

var segments: Array[Curve3D] = []

func set_segments(curves: Array[Curve3D]) -> void:
	segments = curves

func corridor_points(sample_step := 60.0) -> PackedVector3Array:
	var points := PackedVector3Array()
	for curve in segments:
		var length := curve.get_baked_length()
		if length <= 0.1:
			continue
		var dist := 0.0
		while dist < length:
			points.append(curve.sample_baked(dist))
			dist += sample_step
	return points
