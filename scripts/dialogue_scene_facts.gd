extends "res://scripts/dialogue_scene.gd"

@onready var facts_box: FactsBox = $FactsBox

var _facts: Array = []
var _unlocked: Dictionary = {}
var _current_options: Array = []


func _ready() -> void:
	super()
	choice_box.fact_dropped.connect(_on_fact_dropped)
	facts_box.drag_started.connect(_on_fact_drag_started)
	facts_box.drag_ended.connect(_on_fact_drag_ended)
	if not _choosing:
		facts_box.show_facts(_facts, [])


func _load_dialog() -> void:
	super._load_dialog()
	_facts = _data.get("facts", [])


func _show_choices(options: Array) -> void:
	_current_options = options
	facts_box.show_facts(_facts, _usable_fact_ids())
	super(options)


func _filter_choices(options: Array) -> Array:
	var out: Array = []
	for option in super._filter_choices(options):
		var fact_id := String(option.get("fact", ""))
		if fact_id == "" or _unlocked.has(fact_id):
			out.append(option)
	return out


func _on_choice_chosen(index: int) -> void:
	super(index)
	facts_box.show_facts(_facts, [])


func _on_fact_drag_started() -> void:
	choice_box.set_drop_active(true)


func _on_fact_drag_ended() -> void:
	choice_box.set_drop_active(false)


func _on_fact_dropped(fact_id: String) -> void:
	if not _choosing or _unlocked.has(fact_id):
		return
	var option := _find_fact_option(fact_id)
	if option.is_empty():
		return
	_unlocked[fact_id] = true
	_choices.append(option)
	choice_box.add_choice(option)
	facts_box.show_facts(_facts, _usable_fact_ids())


func _find_fact_option(fact_id: String) -> Dictionary:
	for option in _current_options:
		if String(option.get("fact", "")) == fact_id:
			return option
	return {}


func _usable_fact_ids() -> Array:
	var ids: Array = []
	for option in _current_options:
		var fact_id := String(option.get("fact", ""))
		if fact_id == "" or _unlocked.has(fact_id):
			continue
		var condition := String(option.get("if", ""))
		if condition != "" and not bool(_vars.get(condition, false)):
			continue
		ids.append(fact_id)
	return ids
