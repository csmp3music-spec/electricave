extends Node
class_name GISImporter

signal import_complete(success: bool)

const GeoProjectorScript := preload("res://scripts/geo/GeoProjector.gd")

@export var bounds: Resource
@export var world_size_meters := Vector2(350000.0, 240000.0)
@export var heightmap_path := "res://data/heightmaps/ma_height.tif"
@export var osm_path := "res://data/osm/ma.osm.pbf"
@export var historic_overlay_path := "res://assets/maps/bw_airline_1908.jpg"

func _ready() -> void:
	if bounds == null:
		bounds = preload("res://data/ma_bounds.tres")

func import_all() -> void:
	# Placeholder pipeline. Wire to GDAL/OSM tooling or pre-baked assets for MVP.
	print("[GIS] Importing heightmap:", heightmap_path)
	print("[GIS] Importing OSM:", osm_path)
	var resolved := _resolved_bounds()
	print("[GIS] Bounds:", resolved.min_lat, resolved.max_lat, resolved.min_lon, resolved.max_lon)
	emit_signal("import_complete", true)

func lon_lat_to_world(lon: float, lat: float) -> Vector3:
	return GeoProjectorScript.lon_lat_to_world(lon, lat, _resolved_bounds(), world_size_meters)

func _resolved_bounds() -> Dictionary:
	var resolved := {
		"min_lat": 41.2,
		"max_lat": 42.9,
		"min_lon": -73.6,
		"max_lon": -69.9
	}
	var raw_bounds: Variant = bounds
	if raw_bounds is Dictionary:
		for key in resolved.keys():
			if raw_bounds.has(key):
				resolved[key] = float(raw_bounds[key])
		return resolved
	var bounds_path := "res://data/ma_bounds.tres"
	if raw_bounds is Resource and String(raw_bounds.resource_path) != "":
		bounds_path = String(raw_bounds.resource_path)
	if not ResourceLoader.exists(bounds_path):
		return resolved
	var file := FileAccess.open(bounds_path, FileAccess.READ)
	if file == null:
		return resolved
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty() or line.begins_with("[") or not line.contains("="):
			continue
		var parts := line.split("=", false, 1)
		if parts.size() != 2:
			continue
		var key := parts[0].strip_edges()
		if not resolved.has(key):
			continue
		resolved[key] = float(parts[1].strip_edges())
	return resolved
