class_name FactsBox
extends PanelContainer

signal drag_started
signal drag_ended


const FactItemScript := preload("res://scripts/fact_item.gd")

@export var choice_box: ChoiceBox
@onready var list: VBoxContainer = $VBox/List

var _dragging := false


func show_facts(facts: Array, usable_ids: Array) -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	
	for fact in facts:
		var item = FactItemScript.new()
		item.facts_box = self
		item.setup(fact, usable_ids)
		list.add_child(item)


func begin_drag() -> void:
	if _dragging:
		return
	_dragging = true
	drag_started.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and _dragging:
		_dragging = false
		choice_box.refresh_choices()
		drag_ended.emit()
