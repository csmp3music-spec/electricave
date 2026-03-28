extends Node
class_name PhotorealSkyController

@export var environment_path: NodePath
@export var weather_path: NodePath
@export var time_controller_path: NodePath = NodePath("../TimeOfDay")
@export var cloud_texture_width := 384
@export var cloud_texture_height := 192
@export var cloud_update_interval_s := 1.6
@export var cloud_noise_scale := 2.4
@export var cloud_detail_scale := 5.6
@export var cloud_wind_scroll_scale := 0.013
@export var cloud_seed := 1900

var _weather_payload := {}
var _sky: Sky
var _sky_material: ProceduralSkyMaterial
var _noise_primary := FastNoiseLite.new()
var _noise_detail := FastNoiseLite.new()
var _cloud_phase := Vector2.ZERO
var _cloud_update_accum := 999.0

@onready var _world_environment: WorldEnvironment = _resolve_node(environment_path) as WorldEnvironment
@onready var _weather: Node = _resolve_node(weather_path)
@onready var _time_controller: Node = _resolve_node(time_controller_path)

func _ready() -> void:
	_setup_sky()
	_configure_noise()
	if _weather != null and _weather.has_signal("weather_changed"):
		_weather.connect("weather_changed", Callable(self, "_on_weather_changed"))
	if _weather != null and _weather.has_method("get_weather_payload"):
		_weather_payload = _weather.call("get_weather_payload")
	_rebuild_cloud_texture()
	_apply_sky()

func _process(delta: float) -> void:
	var wind_speed := float(_weather_payload.get("wind_speed_mps", 4.0))
	_cloud_phase += Vector2(wind_speed * delta * cloud_wind_scroll_scale, wind_speed * delta * cloud_wind_scroll_scale * 0.63)
	_cloud_update_accum += delta
	_apply_sky()
	if _cloud_update_accum >= maxf(0.35, cloud_update_interval_s):
		_cloud_update_accum = 0.0
		_rebuild_cloud_texture()

func _on_weather_changed(payload: Dictionary) -> void:
	_weather_payload = payload.duplicate(true)
	_cloud_update_accum = 999.0
	_apply_sky()

func _setup_sky() -> void:
	if _world_environment == null or _world_environment.environment == null:
		return
	_sky_material = ProceduralSkyMaterial.new()
	_sky_material.energy_multiplier = 1.0
	_sky_material.sky_energy_multiplier = 1.0
	_sky_material.ground_energy_multiplier = 0.82
	_sky_material.sun_angle_max = 26.0
	_sky_material.sun_curve = 0.18
	_sky_material.sky_curve = 0.12
	_sky_material.ground_curve = 0.02
	_sky = Sky.new()
	_sky.sky_material = _sky_material
	var env := _world_environment.environment
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.sky = _sky
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.adjustment_enabled = true

func _configure_noise() -> void:
	_noise_primary.seed = cloud_seed
	_noise_primary.frequency = 0.0105
	_noise_primary.fractal_type = FastNoiseLite.FRACTAL_FBM
	_noise_primary.fractal_octaves = 5
	_noise_primary.fractal_gain = 0.48
	_noise_primary.fractal_lacunarity = 2.0
	_noise_detail.seed = cloud_seed + 271
	_noise_detail.frequency = 0.024
	_noise_detail.fractal_type = FastNoiseLite.FRACTAL_FBM
	_noise_detail.fractal_octaves = 4
	_noise_detail.fractal_gain = 0.52
	_noise_detail.fractal_lacunarity = 2.1

func _apply_sky() -> void:
	if _world_environment == null or _world_environment.environment == null or _sky_material == null:
		return
	var time_payload: Dictionary = _time_controller.call("get_time_payload") if _time_controller != null and _time_controller.has_method("get_time_payload") else {}
	var hour := int(time_payload.get("hour", 12))
	var minute := int(time_payload.get("minute", 0))
	var day_phase := (float(hour) + float(minute) / 60.0) / 24.0
	var solar := sin((day_phase - 0.25) * TAU)
	var daylight := smoothstep(-0.12, 0.18, solar)
	var noonness := clampf(1.0 - absf((day_phase - 0.5) * 2.0), 0.0, 1.0)
	var warmness := daylight * (1.0 - noonness)
	var cloud_cover := clampf(float(_weather_payload.get("cloud_cover", 0.12)), 0.0, 1.0)
	var storminess := clampf(float(_weather_payload.get("storminess", 0.0)), 0.0, 1.0)
	var wetness := clampf(float(_weather_payload.get("surface_wetness", 0.0)), 0.0, 1.0)
	var top_day := Color(0.31, 0.50, 0.72, 1.0)
	var top_dusk := Color(0.86, 0.55, 0.30, 1.0)
	var top_night := Color(0.05, 0.08, 0.15, 1.0)
	var horizon_day := Color(0.71, 0.79, 0.84, 1.0)
	var horizon_dusk := Color(0.98, 0.73, 0.53, 1.0)
	var horizon_night := Color(0.10, 0.13, 0.21, 1.0)
	var sky_top := top_night.lerp(top_day.lerp(top_dusk, warmness), daylight)
	var sky_horizon := horizon_night.lerp(horizon_day.lerp(horizon_dusk, warmness), daylight)
	sky_top = sky_top.lerp(Color(0.18, 0.22, 0.28, 1.0), storminess * 0.72 + cloud_cover * 0.16)
	sky_horizon = sky_horizon.lerp(Color(0.28, 0.30, 0.34, 1.0), storminess * 0.62 + wetness * 0.18)
	_sky_material.sky_top_color = sky_top
	_sky_material.sky_horizon_color = sky_horizon
	_sky_material.ground_horizon_color = sky_horizon.darkened(0.24)
	_sky_material.ground_bottom_color = Color(0.12, 0.11, 0.10, 1.0).lerp(Color(0.20, 0.17, 0.13, 1.0), daylight * 0.55)
	_sky_material.sky_energy_multiplier = lerpf(0.10, 1.08, daylight) * lerpf(0.92, 0.72, storminess)
	_sky_material.ground_energy_multiplier = lerpf(0.28, 0.88, daylight)
	_sky_material.sky_cover_modulate = Color(
		lerpf(0.55, 1.0, daylight),
		lerpf(0.58, 1.0, daylight),
		lerpf(0.64, 1.0, daylight),
		clampf(0.10 + cloud_cover * 0.82 + storminess * 0.12, 0.0, 1.0)
	)
	var env := _world_environment.environment
	env.adjustment_brightness = lerpf(0.68, 1.08, daylight) * lerpf(1.0, 0.88, storminess)
	env.adjustment_contrast = lerpf(1.02, 1.14, daylight)
	env.adjustment_saturation = lerpf(0.72, 1.02, daylight) * lerpf(1.0, 0.84, storminess)

func _rebuild_cloud_texture() -> void:
	if _sky_material == null:
		return
	var coverage := clampf(float(_weather_payload.get("cloud_cover", 0.12)), 0.0, 1.0)
	var storminess := clampf(float(_weather_payload.get("storminess", 0.0)), 0.0, 1.0)
	var image := Image.create(cloud_texture_width, cloud_texture_height, false, Image.FORMAT_RGBA8)
	var threshold := lerpf(0.92, 0.38, coverage)
	for y in range(cloud_texture_height):
		var v := float(y) / float(maxi(1, cloud_texture_height - 1))
		for x in range(cloud_texture_width):
			var u := float(x) / float(maxi(1, cloud_texture_width - 1))
			var primary := _noise_primary.get_noise_2d((u + _cloud_phase.x) * cloud_noise_scale * 100.0, (v + _cloud_phase.y) * cloud_noise_scale * 100.0)
			var detail := _noise_detail.get_noise_2d((u - _cloud_phase.x * 0.4) * cloud_detail_scale * 100.0, (v + _cloud_phase.y * 0.7) * cloud_detail_scale * 100.0)
			var bands := sin((u + _cloud_phase.x) * TAU * 2.2) * 0.08 + cos((v - _cloud_phase.y) * TAU * 3.1) * 0.06
			var density := primary * 0.72 + detail * 0.28 + bands
			var mask := smoothstep(threshold, threshold + 0.18 - storminess * 0.06, density)
			var brightness := lerpf(0.70, 1.0, clampf(density * 0.5 + 0.5, 0.0, 1.0))
			var storm_tint := Color(0.72, 0.75, 0.80, 1.0).lerp(Color(0.52, 0.55, 0.60, 1.0), storminess)
			image.set_pixel(x, y, Color(storm_tint.r * brightness * mask, storm_tint.g * brightness * mask, storm_tint.b * brightness * mask, mask))
	image.generate_mipmaps()
	_sky_material.sky_cover = ImageTexture.create_from_image(image)

func _resolve_node(path: NodePath) -> Node:
	if path == NodePath(""):
		return null
	return get_node_or_null(path)
