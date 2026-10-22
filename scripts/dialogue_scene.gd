extends CanvasLayer

signal finished

const DIALOG_PATH := "res://assets/dialog/dialog_en.json"

@onready var box: DialogueBox = $DialogueBox
@onready var choice_box: ChoiceBox = $ChoiceBox

var _data: Dictionary = {}
var _lines: Array = []
var _vars: Dictionary = {}
var _index := -1
var _finished := false
var _choosing := false
var _choices: Array = []


func _ready() -> void:
	_load_dialog()
	choice_box.chosen.connect(_on_choice_chosen)
	_advance()


func _load_dialog() -> void:
	if not FileAccess.file_exists(DIALOG_PATH):
		push_error("dialogue_scene: missing dialogue file: " + DIALOG_PATH)
		return
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(DIALOG_PATH))
	if typeof(data) != TYPE_DICTIONARY:
		push_error("dialogue_scene: dialogue JSON is not an object: " + DIALOG_PATH)
		return
	_data = data
	_lines = data.get("lines", [])
	_vars = data.get("vars", {})


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		_advance()


func _advance() -> void:
	if _finished or _choosing:
		return
	if box.is_typing:
		box.skip()
		return
	_index += 1
	if _index >= _lines.size():
		_finished = true
		box.hide()
		finished.emit()
		return
	var entry: Dictionary = _lines[_index]
	if entry.has("choices"):
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
