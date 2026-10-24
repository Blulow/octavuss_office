class_name FactsBox
extends Control

# A clipboard-styled panel listing the facts the player has collected.
# Click-drag the title bar to move it; the "-" button collapses it to a
# sliver at the bottom-left that shows only the button, and "+" restores it.
signal drag_started
signal drag_ended

const FactItemScript := preload("res://scripts/fact_item.gd")
const MARGIN := 16.0
const TWEEN_TIME := 0.3

@onready var header: HBoxContainer = $Header
@onready var list: VBoxContainer = $List
@onready var minimize: Button = $Header/Minimize

var _dragging := false          # a fact row is being dragged (not the header)
var _dragging_header := false   # the title bar is being dragged
var _collapsed := false
var _drag_offset := Vector2.ZERO
var _restore_position := Vector2.ZERO
var _tween: Tween


func _ready() -> void:
	header.gui_input.connect(_on_header_gui_input)
	minimize.pressed.connect(_toggle_collapsed)


func show_facts(facts: Array, usable_ids: Array) -> void:
	# Rebuild the list each time so it stays in sync with what's unlocked.
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	for fact in facts:
		var item = FactItemScript.new()
		item.facts_box = self
		item.setup(fact, usable_ids.has(String(fact.get("id", ""))))
		list.add_child(item)


func begin_drag() -> void:
	# Called by a FactItem when the player starts dragging it toward a choice.
	if _dragging:
		return
	_dragging = true
	drag_started.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and _dragging:
		_dragging = false
		drag_ended.emit()


func _on_header_gui_input(event: InputEvent) -> void:
	if _collapsed:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging_header = event.pressed
		_drag_offset = event.global_position - global_position
		accept_event()
	elif event is InputEventMouseMotion and _dragging_header:
		var viewport := get_viewport_rect().size
		global_position = (event.global_position - _drag_offset).clamp(Vector2.ZERO, viewport - size)
		accept_event()


func _collapsed_position() -> Vector2:
	# Slide left until only the minimise button pokes past the screen edge,
	# and drop it against the bottom edge (leaving a MARGIN gap).
	var viewport := get_viewport_rect().size
	var button_left := header.position.x + minimize.position.x
	var button_bottom := header.position.y + minimize.position.y + minimize.size.y
	return Vector2(MARGIN - button_left, viewport.y - MARGIN - button_bottom)


func _toggle_collapsed() -> void:
	if _tween and _tween.is_running():
		return
	_collapsed = not _collapsed
	minimize.text = "+" if _collapsed else "-"
	list.visible = not _collapsed
	var target := _collapsed_position() if _collapsed else _restore_position
	if _collapsed:
		_restore_position = position
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "position", target, TWEEN_TIME)
