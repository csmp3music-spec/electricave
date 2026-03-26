extends Node3D
class_name AnimatedPassenger

var _phase := 0.0
var _anim_speed := 1.0
var _base_yaw := 0.0
var _walk_style := false

var _body: Node3D
var _torso: MeshInstance3D
var _head: MeshInstance3D
var _left_arm: Node3D
var _right_arm: Node3D
var _left_leg: Node3D
var _right_leg: Node3D

func _ready() -> void:
	_build_mesh()

func configure(seed: int, walk_style: bool = false) -> void:
	_walk_style = walk_style
	_phase = float(seed % 360) * PI / 180.0
	_anim_speed = 0.75 + float(seed % 7) * 0.08
	_base_yaw = deg_to_rad(float((seed / 7) % 360))
	rotation.y = _base_yaw
	_build_mesh()
	_apply_palette(seed)

func _process(delta: float) -> void:
	if _body == null:
		return
	_phase += delta * (_anim_speed * (2.0 if _walk_style else 1.2))
	var sway := sin(_phase)
	var bob := sin(_phase * 2.0) * (0.035 if _walk_style else 0.012)
	_body.position.y = bob
	_body.rotation.y = sin(_phase * 0.35) * (0.08 if _walk_style else 0.04)
	_left_arm.rotation.x = sway * (0.52 if _walk_style else 0.16)
	_right_arm.rotation.x = -sway * (0.52 if _walk_style else 0.16)
	_left_leg.rotation.x = -sway * (0.44 if _walk_style else 0.10)
	_right_leg.rotation.x = sway * (0.44 if _walk_style else 0.10)

func _build_mesh() -> void:
	if _body != null and is_instance_valid(_body):
		return
	_body = Node3D.new()
	_body.name = "Body"
	add_child(_body)

	_torso = MeshInstance3D.new()
	var torso_mesh := BoxMesh.new()
	torso_mesh.size = Vector3(0.34, 0.60, 0.20)
	_torso.mesh = torso_mesh
	_torso.position = Vector3(0.0, 1.02, 0.0)
	_body.add_child(_torso)

	_head = MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.15
	head_mesh.height = 0.30
	_head.mesh = head_mesh
	_head.position = Vector3(0.0, 1.47, 0.0)
	_body.add_child(_head)

	_left_arm = _make_limb(Vector3(-0.24, 1.04, 0.0), Vector3(0.10, 0.48, 0.10))
	_right_arm = _make_limb(Vector3(0.24, 1.04, 0.0), Vector3(0.10, 0.48, 0.10))
	_left_leg = _make_limb(Vector3(-0.10, 0.42, 0.0), Vector3(0.12, 0.62, 0.12))
	_right_leg = _make_limb(Vector3(0.10, 0.42, 0.0), Vector3(0.12, 0.62, 0.12))

	var hat := MeshInstance3D.new()
	var hat_mesh := BoxMesh.new()
	hat_mesh.size = Vector3(0.26, 0.06, 0.26)
	hat.mesh = hat_mesh
	hat.position = Vector3(0.0, 1.64, 0.0)
	hat.visible = false
	hat.name = "Hat"
	_body.add_child(hat)

func _make_limb(pos: Vector3, size: Vector3) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = pos
	_body.add_child(pivot)
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = Vector3(0.0, -size.y * 0.5 + 0.02, 0.0)
	pivot.add_child(mesh_instance)
	return pivot

func _apply_palette(seed: int) -> void:
	var coat_colors := [
		Color("51463e"),
		Color("3e4a58"),
		Color("6b563e"),
		Color("4f5a47"),
		Color("6f4a3f")
	]
	var trouser_colors := [
		Color("3b3532"),
		Color("4a4f56"),
		Color("5d5247"),
		Color("35383c")
	]
	var skin_colors := [
		Color(0.94, 0.81, 0.68, 1.0),
		Color(0.83, 0.67, 0.52, 1.0),
		Color(0.70, 0.54, 0.40, 1.0),
		Color(0.56, 0.40, 0.29, 1.0)
	]
	var coat: Color = coat_colors[seed % coat_colors.size()]
	var trousers: Color = trouser_colors[(seed / 5) % trouser_colors.size()]
	var skin: Color = skin_colors[(seed / 11) % skin_colors.size()]
	_apply_material(_torso, coat)
	_apply_material(_head, skin)
	_apply_limb_material(_left_arm, coat.darkened(0.04))
	_apply_limb_material(_right_arm, coat.darkened(0.04))
	_apply_limb_material(_left_leg, trousers)
	_apply_limb_material(_right_leg, trousers)
	var hat := _body.get_node_or_null("Hat") as MeshInstance3D
	if hat != null:
		hat.visible = seed % 4 == 0
		_apply_material(hat, coat.darkened(0.18))

func _apply_limb_material(limb: Node3D, color: Color) -> void:
	if limb == null or limb.get_child_count() == 0:
		return
	var mesh_instance := limb.get_child(0) as MeshInstance3D
	_apply_material(mesh_instance, color)

func _apply_material(mesh_instance: MeshInstance3D, color: Color) -> void:
	if mesh_instance == null:
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.92
	mat.metallic = 0.02
	mesh_instance.set_surface_override_material(0, mat)
