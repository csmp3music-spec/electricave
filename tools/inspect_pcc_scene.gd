extends SceneTree

func _init() -> void:
	var scene := load("res://scenes/transit/PCCCar.tscn") as PackedScene
	if scene == null:
		push_error("failed to load PCCCar.tscn")
		quit(1)
		return
	var root := scene.instantiate()
	_dump_node(root, "")
	quit()

func _dump_node(node: Node, indent: String) -> void:
	var extra := ""
	if node is MeshInstance3D:
		var mesh_node := node as MeshInstance3D
		extra = " mesh=%s surfaces=%d" % [mesh_node.mesh.resource_path if mesh_node.mesh != null else "null", mesh_node.mesh.get_surface_count() if mesh_node.mesh != null else 0]
		if mesh_node.mesh != null:
			for surface_idx in range(mesh_node.mesh.get_surface_count()):
				var mat := mesh_node.get_active_material(surface_idx)
				if mat is BaseMaterial3D:
					var base := mat as BaseMaterial3D
					print("%s  material[%d]=%s color=%s" % [indent, surface_idx, mat.resource_name, str(base.albedo_color)])
				elif mat != null:
					print("%s  material[%d]=%s" % [indent, surface_idx, mat.resource_name])
	print("%s%s (%s)%s" % [indent, node.name, node.get_class(), extra])
	for child in node.get_children():
		_dump_node(child, indent + "  ")
