class_name Interactable
extends Node

signal hover_started
signal hover_ended
signal select_changed(is_selected: bool)
signal activated            # the click (a request, not a state change)
signal action_succeeded
signal action_failed

@export var body: CollisionObject3D
@export var disabled := false

var is_hovered := false
var is_selected := false

func _ready() -> void:
	assert(body != null, "%s needs a body assigned" % name)
	body.input_event.connect(_on_input_event)
	body.mouse_entered.connect(_on_mouse_entered)
	body.mouse_exited.connect(_on_mouse_exited)

func _on_input_event(_cam: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _idx: int) -> void:
	if disabled:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		activated.emit()

func _on_mouse_entered() -> void:
	if is_selected or disabled:
		return
	is_hovered = true
	hover_started.emit()

func _on_mouse_exited() -> void:
	if not is_hovered:
		return
	is_hovered = false
	hover_ended.emit()

func set_selected(value: bool) -> void:
	if value == is_selected:
		return
	is_selected = value
	if value and is_hovered:
		is_hovered = false
		hover_ended.emit()      # clean handoff from hover to select
	select_changed.emit(value)

# The owner reports outcomes; effects react to them.
func succeed() -> void: action_succeeded.emit()
func fail() -> void: action_failed.emit()
