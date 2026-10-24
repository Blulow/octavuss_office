extends Button

@export_file("*.tscn") var next_scene_path: String


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	print("PATH = '", next_scene_path, "'")
	if next_scene_path.is_empty():
		push_error("%s: next_scene_path is not assigned." % name)
		return
	get_tree().paused = false
	get_tree().change_scene_to_file(next_scene_path)
