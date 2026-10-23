extends Control
class_name SessionManager

@export var dialogue_scene: DialogueScene

@export var sessions_files: Array[JSON]

func _ready():
	await get_tree().create_timer(3.0).timeout
	load_session(sessions_files[0])

func load_session(session_file: JSON) -> void:
	dialogue_scene.start_session(session_file.resource_path)
