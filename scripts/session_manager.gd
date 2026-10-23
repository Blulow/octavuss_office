extends Control
class_name SessionManager

@export var dialogue_scene: DialogueScene
@export var sessions_files: Array[JSON]

var index: int = 0

func _ready():
	dialogue_scene.finished.connect(_on_dialogue_finished)
	
	await get_tree().create_timer(1.0).timeout
	load_next_session(true)

func load_session(session_file: JSON) -> void:
	dialogue_scene.start_session(session_file.resource_path)

func load_next_session(first = false) -> void:
	if !first: index += 1
	
	if index >= sessions_files.size(): 
		printerr("out of bounds")
		return
	load_session(sessions_files[index])

func _on_dialogue_finished() -> void:
	load_next_session()
