extends Node
class_name PhotorealSkyController

@export var environment_path: NodePath
@export var weather_path: NodePath
@export_file("*.jpg", "*.jpeg", "*.png", "*.hdr", "*.exr") var clear_panorama_path := "res://assets/sky/farm_field_puresky.jpg"
@export_file("*.jpg", "*.jpeg", "*.png", "*.hdr", "*.exr") var cloudy_panorama_path := "res://assets/sky/quadrangle_cloudy.jpg"

var _clear_sky: Sky
var _cloudy_sky: Sky

@onready var _world_environment: WorldEnvironment = _resolve_node(environment_path) as WorldEnvironment
@onready var _weather: Node = _resolve_node(weather_path)

func _ready() -> void:
	_clear_sky = _build_panorama_sky(clear_panorama_path)
	_cloudy_sky = _build_panorama_sky(cloudy_panorama_path)
	if _weather != null and _weather.has_signal("weather_changed"):
		_weather.connect("weather_changed", Callable(self, "_on_weather_changed"))
	_apply_sky()

func _on_weather_changed(_payload: Dictionary) -> void:
	_apply_sky()

func _apply_sky() -> void:
	if _world_environment == null or _world_environment.environment == null:
		return
	var env := _world_environment.environment
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	var payload := {}
	if _weather != null and _weather.has_method("get_weather_payload"):
		payload = _weather.call("get_weather_payload")
	var cloudy := bool(payload.get("rain_active", false)) or bool(payload.get("snow_active", false)) or bool(payload.get("rare_storm", false))
	var target_sky := _cloudy_sky if cloudy else _clear_sky
	if target_sky != null:
		env.sky = target_sky

func _build_panorama_sky(resource_path: String) -> Sky:
	var texture := _load_runtime_texture(resource_path)
	if texture == null:
		return null
	var material := PanoramaSkyMaterial.new()
	material.panorama = texture
	var sky := Sky.new()
	sky.sky_material = material
	return sky

func _load_runtime_texture(resource_path: String) -> Texture2D:
	if resource_path == "":
		return null
	var absolute_path := ProjectSettings.globalize_path(resource_path)
	if not FileAccess.file_exists(absolute_path):
		return null
	var image := Image.new()
	var err := image.load(absolute_path)
	if err != OK:
		return null
	if image.get_width() > 4096:
		var target_width := 4096
		var target_height := int(round(float(image.get_height()) * (float(target_width) / float(image.get_width()))))
		image.resize(target_width, max(1, target_height), Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(image)

func _resolve_node(path: NodePath) -> Node:
	if path == NodePath(""):
		return null
	return get_node_or_null(path)
