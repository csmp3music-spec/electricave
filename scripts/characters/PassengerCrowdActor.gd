extends Node3D
class_name PassengerCrowdActor

const FallbackPassengerScript := preload("res://scripts/characters/AnimatedPassenger.gd")
const IMPORTED_SCENE_PATHS := [
	"res://assets/models/passengers/quaternius/Male_Casual.fbx",
	"res://assets/models/passengers/quaternius/Male_Suit.fbx",
	"res://assets/models/passengers/quaternius/Female_Casual.fbx",
	"res://assets/models/passengers/quaternius/Female_Dress.fbx"
]

static var _scene_cache := {}

@export var prefer_imported_models := false
@export var target_height_m := 1.72

var _seed := 0
var _phase := 0.0
var _anim_speed := 1.0
var _base_yaw := 0.0
var _walk_style := false
var _motion_root: Node3D
var _fallback: Node3D
var _imported_root: Node3D
var _animation_player: AnimationPlayer
var _has_imported_animation := false

func _ready() -> void:
	_ensure_motion_root()

func configure(seed: int, walk_style: bool = false) -> void:
	_seed = seed
	_walk_style = walk_style
	_phase = float(seed % 360) * PI / 180.0
	_anim_speed = 0.8 + float(seed % 7) * 0.08
	_base_yaw = deg_to_rad(float((seed / 5) % 360))
	rotation.y = _base_yaw
	_swap_visual(seed)

func set_prefer_imported_models(enabled: bool) -> void:
	if prefer_imported_models == enabled:
		return
	prefer_imported_models = enabled
	if is_inside_tree():
		_swap_visual(_seed)

func _process(delta: float) -> void:
	if _motion_root == null:
		return
	if _fallback != null and is_instance_valid(_fallback):
		return
	_phase += delta * (_anim_speed * (1.8 if _walk_style else 1.05))
	var sway := sin(_phase)
	var bob := sin(_phase * 2.0) * (0.03 if _walk_style else 0.012)
	_motion_root.position.y = bob
	if not _has_imported_animation:
		_motion_root.rotation.y = sway * (0.05 if _walk_style else 0.025)

func _swap_visual(seed: int) -> void:
	_clear_visuals()
	_ensure_motion_root()
	if not _should_use_imported_models():
		_spawn_fallback(seed)
		return
	if IMPORTED_SCENE_PATHS.is_empty():
		_spawn_fallback(seed)
		return
	var packed := _load_imported_scene(seed)
	if packed == null:
		_spawn_fallback(seed)
		return
	var root := packed.instantiate() as Node3D
	if root == null:
		_spawn_fallback(seed)
		return
	_imported_root = root
	_motion_root.add_child(root)
	_fit_imported_model(root)
	_animation_player = _find_animation_player(root)
	_has_imported_animation = _play_best_animation(seed)

func _should_use_imported_models() -> bool:
	return prefer_imported_models

func _clear_visuals() -> void:
	if _motion_root == null:
		return
	for child in _motion_root.get_children():
		_motion_root.remove_child(child)
		child.queue_free()
	_fallback = null
	_imported_root = null
	_animation_player = null
	_has_imported_animation = false
	_motion_root.position = Vector3.ZERO
	_motion_root.rotation = Vector3.ZERO

func _spawn_fallback(seed: int) -> void:
	_fallback = FallbackPassengerScript.new()
	_motion_root.add_child(_fallback)
	_fallback.call("configure", seed, _walk_style)

func _load_imported_scene(seed: int) -> PackedScene:
	var path := String(IMPORTED_SCENE_PATHS[seed % IMPORTED_SCENE_PATHS.size()])
	if _scene_cache.has(path):
		return _scene_cache[path] as PackedScene
	if not ResourceLoader.exists(path):
		_scene_cache[path] = null
		return null
	var loaded := load(path) as PackedScene
	_scene_cache[path] = loaded
	return loaded

func _ensure_motion_root() -> void:
	if _motion_root != null and is_instance_valid(_motion_root):
		return
	_motion_root = get_node_or_null("MotionRoot") as Node3D
	if _motion_root == null:
		_motion_root = Node3D.new()
		_motion_root.name = "MotionRoot"
		add_child(_motion_root)

func _fit_imported_model(root: Node3D) -> void:
	var bounds := _gather_bounds(root)
	var height := bounds.size.y
	if height <= 0.01:
		root.scale = Vector3.ONE
		return
	var height_scale := target_height_m / height
	root.scale = Vector3.ONE * height_scale
	bounds = _gather_bounds(root)
	root.position.y -= bounds.position.y

func _gather_bounds(root: Node) -> AABB:
	var state := {
		"has_bounds": false,
		"bounds": AABB()
	}
	_accumulate_bounds(root, Transform3D.IDENTITY, state)
	if not bool(state.get("has_bounds", false)):
		return AABB(Vector3.ZERO, Vector3.ONE)
	var bounds: AABB = state.get("bounds", AABB(Vector3.ZERO, Vector3.ONE))
	return bounds

func _accumulate_bounds(node: Node, current_xform: Transform3D, state: Dictionary) -> void:
	var next_xform := current_xform
	if node is Node3D:
		next_xform = current_xform * (node as Node3D).transform
	if node.has_method("get_aabb"):
		var local_aabb: AABB = node.call("get_aabb")
		var world_aabb := _transform_aabb(local_aabb, next_xform)
		if bool(state.get("has_bounds", false)):
			var existing: AABB = state.get("bounds", AABB())
			state["bounds"] = existing.merge(world_aabb)
		else:
			state["bounds"] = world_aabb
			state["has_bounds"] = true
	for child in node.get_children():
		_accumulate_bounds(child, next_xform, state)

func _transform_aabb(aabb: AABB, xform: Transform3D) -> AABB:
	var corners := [
		Vector3(aabb.position.x, aabb.position.y, aabb.position.z),
		Vector3(aabb.end.x, aabb.position.y, aabb.position.z),
		Vector3(aabb.position.x, aabb.end.y, aabb.position.z),
		Vector3(aabb.position.x, aabb.position.y, aabb.end.z),
		Vector3(aabb.end.x, aabb.end.y, aabb.position.z),
		Vector3(aabb.end.x, aabb.position.y, aabb.end.z),
		Vector3(aabb.position.x, aabb.end.y, aabb.end.z),
		Vector3(aabb.end.x, aabb.end.y, aabb.end.z)
	]
	var first: Vector3 = xform * corners[0]
	var transformed := AABB(first, Vector3.ZERO)
	for i in range(1, corners.size()):
		transformed = transformed.expand(xform * corners[i])
	return transformed

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null

func _play_best_animation(seed: int) -> bool:
	if _animation_player == null:
		return false
	var names := _animation_player.get_animation_list()
	if names.is_empty():
		return false
	var chosen := String(names[0])
	for name in names:
		var lowered := String(name).to_lower()
		if _walk_style and "walk" in lowered:
			chosen = String(name)
			break
		if not _walk_style and ("idle" in lowered or "breath" in lowered):
			chosen = String(name)
			break
	_animation_player.speed_scale = 0.88 + float(seed % 5) * 0.05
	_animation_player.play(chosen)
	var anim := _animation_player.get_animation(chosen)
	if anim != null and anim.length > 0.05:
		_animation_player.seek(fmod(float(seed) * 0.37, anim.length), true)
	return true
