extends Control
class_name SessionManager

signal session_start
signal session_end
signal action_start
signal action_finish

@export var dialogue_scene: DialogueScene
@export var sessions_files: Array[JSON]
@export var choice_ui_manager: ChoiceUIManager
@export var money_add_per_session: int = 5

var accept_choices: bool = false
@export var session_popup: SessionUIManager

func _ready():
	action_start.connect(_on_action_start)
	dialogue_scene.finished.connect(_on_dialogue_finished)
	session_popup.sequence_finished.connect(_start_dialogue)
	
func load_next_session(first = false) -> void:
	if PlayerData.session_index >= sessions_files.size(): 
		printerr("out of bounds")
		return
	session_popup.play("SESSION " + str(PlayerData.session_index + 1))

func _start_dialogue():
	dialogue_scene.start_session(sessions_files[PlayerData.session_index].resource_path)


func _on_dialogue_finished() -> void:
	PlayerData.session_index += 1
	
	if PlayerData.session_index >= sessions_files.size():
		PlayerData.get_ending()
		
		return
	
	accept_choices = true
	
	await choice_ui_manager.hidden
	action_finish.emit()
	
	await session_start
	load_next_session()
	PlayerData.add_money(money_add_per_session)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		if not accept_choices: return
		accept_choices = false
		
		session_end.emit()

func _on_action_start() -> void:
	choice_ui_manager.show_ui()
