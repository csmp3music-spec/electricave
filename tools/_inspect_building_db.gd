extends SceneTree

func _init() -> void:
	var db = load("res://data/buildings/default_building_db.tres")
	print("script=", db.get_script())
	print("class=", db.get_class())
	print("has get_category_entries=", db.has_method("get_category_entries"))
	quit()
