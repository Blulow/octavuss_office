extends Control
class_name SessionManager

@export var dialogue_scene: DialogueScene
@export var sessions_files: Array[JSON]
@export var choice_ui_manager: ChoiceUIManager
@export var money_add_per_session: int

var index: int = 0

var accept_choices: bool = false

func _ready():
	dialogue_scene.finished.connect(_on_dialogue_finished)
	
	await get_tree().create_timer(1.0).timeout
	load_next_session(true)

func load_next_session(first = false) -> void:
	if index >= sessions_files.size(): 
		printerr("out of bounds")
		return
	
	dialogue_scene.start_session(sessions_files[index].resource_path)

func _on_dialogue_finished() -> void:
	index += 1
	
	if index >= sessions_files.size():
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
