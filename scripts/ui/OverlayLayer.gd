extends Sprite2D
class_name OverlayLayer

@export var overlay_enabled := false
@export var overlay_path := "res://assets/maps/historic_overlay.jpg"
@export var fallback_path := "res://assets/maps/historic_overlay_placeholder.png"
@export_range(0.0, 1.0, 0.01) var overlay_opacity := 0.6
@export var overlay_visible := true
@export var overlay_scale := Vector2(1.0, 1.0)
@export_range(0.05, 1.0, 0.01) var zoom_step := 0.14
@export var min_zoom := 0.45
@export var max_zoom := 3.5
@export var generated_overlay_size := Vector2i(2048, 2048)

var _base_scale := Vector2.ONE
var _current_zoom := 1.0
var _dragging := false

func _ready() -> void:
	if not overlay_enabled:
		visible = false
		return
	centered = true
	texture = _load_texture()
	modulate.a = overlay_opacity
	visible = overlay_visible
	_base_scale = overlay_scale
	_current_zoom = 1.0
	_apply_zoom()
	_center_in_viewport()
	get_viewport().size_changed.connect(_center_in_viewport)

func _unhandled_input(event: InputEvent) -> void:
	if not overlay_enabled:
		return
	if event.is_action_pressed("toggle_overlay"):
		toggle_overlay()
		get_viewport().set_input_as_handled()
		return
	if not overlay_visible:
		return
	if event.is_action_pressed("zoom_in"):
		_zoom_to(_current_zoom * (1.0 + zoom_step), get_viewport().get_mouse_position())
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("zoom_out"):
		_zoom_to(_current_zoom / (1.0 + zoom_step), get_viewport().get_mouse_position())
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		_dragging = event.pressed
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion and _dragging:
		position += event.relative
		_clamp_position()
		get_viewport().set_input_as_handled()

func set_opacity(value: float) -> void:
	overlay_opacity = clampf(value, 0.0, 1.0)
	modulate.a = overlay_opacity

func toggle_overlay() -> void:
	overlay_visible = !overlay_visible
	visible = overlay_visible
	if overlay_visible:
		_clamp_position()

func reset_view() -> void:
	_current_zoom = 1.0
	_apply_zoom()
	_center_in_viewport()

func _load_texture() -> Texture2D:
	var texture: Texture2D = null
	if ResourceLoader.exists(overlay_path):
		texture = load(overlay_path) as Texture2D
	if texture == null:
		texture = _load_runtime_texture(overlay_path)
	if texture == null and ResourceLoader.exists(fallback_path) and not fallback_path.ends_with("historic_overlay_placeholder.png"):
		texture = load(fallback_path) as Texture2D
	if texture == null:
		texture = _load_runtime_texture(fallback_path)
	if texture == null:
		return _generate_placeholder_texture()
	if texture.get_width() < 16 or texture.get_height() < 16:
		return _generate_placeholder_texture()
	return texture

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
	return ImageTexture.create_from_image(image)

func _generate_placeholder_texture() -> Texture2D:
	var image := Image.create(generated_overlay_size.x, generated_overlay_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.29, 0.22, 0.14, 0.0))
	var parchment := Color(0.92, 0.84, 0.66, 0.28)
	image.fill_rect(Rect2i(0, 0, generated_overlay_size.x, generated_overlay_size.y), parchment)
	var frame := Color(0.40, 0.28, 0.18, 0.42)
	image.fill_rect(Rect2i(64, 64, generated_overlay_size.x - 128, 12), frame)
	image.fill_rect(Rect2i(64, generated_overlay_size.y - 76, generated_overlay_size.x - 128, 12), frame)
	image.fill_rect(Rect2i(64, 64, 12, generated_overlay_size.y - 128), frame)
	image.fill_rect(Rect2i(generated_overlay_size.x - 76, 64, 12, generated_overlay_size.y - 128), frame)
	var route := Color(0.12, 0.55, 0.86, 0.62)
	var glow := Color(0.95, 0.96, 0.70, 0.32)
	var left := 360
	var right := generated_overlay_size.x - 320
	var mid_y := generated_overlay_size.y / 2
	image.fill_rect(Rect2i(left, mid_y - 8, right - left, 16), route)
	image.fill_rect(Rect2i(left, mid_y - 22, right - left, 44), glow)
	for marker_x in [left, 620, 880, 1140, 1420, 1700, right]:
		image.fill_rect(Rect2i(marker_x - 14, mid_y - 28, 28, 56), Color(0.55, 0.19, 0.17, 0.56))
	return ImageTexture.create_from_image(image)

func _center_in_viewport() -> void:
	var rect := get_viewport_rect()
	position = rect.size * 0.5
	_clamp_position()

func _apply_zoom() -> void:
	scale = _base_scale * _current_zoom
	_clamp_position()

func _zoom_to(next_zoom: float, focus_screen_pos: Vector2) -> void:
	var clamped_zoom := clampf(next_zoom, min_zoom, max_zoom)
	if is_equal_approx(clamped_zoom, _current_zoom):
		return
	var previous_zoom := _current_zoom
	_current_zoom = clamped_zoom
	var ratio := _current_zoom / maxf(previous_zoom, 0.001)
	position = focus_screen_pos + (position - focus_screen_pos) * ratio
	_apply_zoom()

func _clamp_position() -> void:
	if texture == null:
		return
	var viewport_size := get_viewport_rect().size
	var pixel_size := Vector2(texture.get_width(), texture.get_height()) * scale.abs()
	var half := pixel_size * 0.5
	if pixel_size.x <= viewport_size.x:
		position.x = viewport_size.x * 0.5
	else:
		position.x = clampf(position.x, viewport_size.x - half.x, half.x)
	if pixel_size.y <= viewport_size.y:
		position.y = viewport_size.y * 0.5
	else:
		position.y = clampf(position.y, viewport_size.y - half.y, half.y)
