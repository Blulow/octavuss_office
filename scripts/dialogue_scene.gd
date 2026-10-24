extends CanvasLayer
class_name DialogueScene

signal finished

#const DIALOG_PATH := "res://assets/dialog/session1.json"

#@onready var box: DialogueBox = $DialogueBox
#@onready var choice_box: ChoiceBox = $ChoiceBox
@export var box: DialogueBox
@export var choice_box: ChoiceBox

var _data: Dictionary = {}
var _sets: Array = []
var _vars: Dictionary = {}
var _index := -1
var _set_index := 0
var _finished := true
var _choosing := false
var _choices: Array = []

func _ready() -> void:
	choice_box.chosen.connect(_on_choice_chosen)

func start_session(path: String):
	_finished = false
	_index = -1
	_set_index = 0
	_load_dialog(path)
	_advance()

func _load_dialog(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("dialogue_scene: missing dialogue file: " + path)
		return
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(data) != TYPE_DICTIONARY:
		push_error("dialogue_scene: dialogue JSON is not an object: " + path)
		return
	_data = data
	_sets = data.get("sets", [])
	_vars = data.get("vars", {})
	
	PlayerData.pending_fact.id = data.get("pending_fact").id
	PlayerData.pending_fact.fact_description = data.get("pending_fact").text

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		if _finished: return
		
		_advance()


func _advance() -> void:
	if _finished or _choosing:
		return
	if box.is_typing:
		box.skip()
		return
	
	var _set: Array = _sets[_set_index]
	_index += 1
	if _index >= _set.size():
		_set_index += 1
		if _set_index >= _sets.size():
			_finished = true
			box.hide()
			finished.emit()
			return
		else:
			_index = 0
	
	var entry: Dictionary = _sets[_set_index][_index]
	if entry.has("choices"):
		box.hide()
		_show_choices(entry["choices"])
	else:
		_show_message(entry)


func _show_choices(options: Array) -> void:
	_choosing = true
	_choices = _filter_choices(options)
	choice_box.show_choices(_choices, box.position.y)


func _filter_choices(options: Array) -> Array:
	var out: Array = []
	for option in options:
		var condition := String(option.get("if", ""))
		if condition == "" or bool(_vars.get(condition, false)):
			out.append(option)
	return out


func _on_choice_chosen(index: int) -> void:
	_choosing = false
	if index < 0 or index >= _choices.size():
		return
	var choice: Dictionary = _choices[index]

	_show_message(choice.get("response", {}))


func _show_message(msg: Dictionary) -> void:
	box.show_line(msg, _vars)
	
	if not msg.has("effects"): return
	
	var effects: Dictionary = msg.get("effects")
	#PlayerData.stats.calm.value += effects.get("calm", "0").to_int()
	#PlayerData.stats.fact.value += effects.get("fact", "0").to_int()
	#PlayerData.stats.sp.value += effects.get("sp", "0").to_int()
	PlayerData.apply_stat("calm", float(effects.get("calm", "0")))
	PlayerData.apply_stat("fact", float(effects.get("fact", "0")))
	PlayerData.apply_stat("sp", float(effects.get("sp", "0")))
	
	$StatsLabel.text = "CALM: %d | FACT: %d | SP: %d" % [PlayerData.stats.calm.value, PlayerData.stats.fact.value, PlayerData.stats.sp.value]
	PlayerData.update_character_expression()
