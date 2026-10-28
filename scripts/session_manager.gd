extends Control
class_name SessionManager

@export var dialogue_scene: DialogueScene
@export var sessions_files: Array[JSON]
@export var choice_ui_manager: ChoiceUIManager
@export var money_add_per_session: int = 50

var accept_choices: bool = false

func _ready():
	dialogue_scene.finished.connect(_on_dialogue_finished)

func load_next_session(first = false) -> void:
	if PlayerData.session_index >= sessions_files.size(): 
		printerr("out of bounds")
		return
	
	dialogue_scene.start_session(sessions_files[PlayerData.session_index].resource_path)

func _on_dialogue_finished() -> void:
	PlayerData.session_index += 1
	
	if PlayerData.session_index >= sessions_files.size():
		PlayerData.get_ending()
		
		return
	
	accept_choices = true
	
	await choice_ui_manager.hidden
	load_next_session()
	PlayerData.add_money(money_add_per_session)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if not accept_choices: return
		choice_ui_manager.show_ui()
		accept_choices = false
