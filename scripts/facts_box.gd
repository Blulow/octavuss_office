class_name FactsBox
extends Control

signal drag_started
signal drag_ended

const FactItemScript := preload("res://scripts/fact_item.gd")

@export var margin := 16.0
@export var tween_time := 0.45
@export var hop_px := 18.0
@export var hop_time := 0.4
@export var attention_gap := 0.1
@export var attention_wait := 1.0

@export var choice_box: ChoiceBox
@export var header: HBoxContainer
@export var list: VBoxContainer
@export var minimize: AnimatedButton
@export var clipboard_audio: AudioStreamPlayer2D

var _dragging := false          # a fact row is being dragged
var _dragging_box := false      # the panel itself is being dragged
var _collapsed := false
var _drag_offset := Vector2.ZERO
var _restore_position := Vector2.ZERO
var _tween: Tween
var _attention := false
var _attention_tween: Tween

func _ready() -> void:
	# Wire up the minimise/restore button. Dragging is handled by _gui_input
	# below, which fires on any free space of the panel.
	minimize.pressed.connect(_toggle_collapsed)

func show_facts(facts: Array, usable_ids: Array) -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	
	for fact in facts:
		var item = FactItemScript.new()
		item.facts_box = self
		item.setup(fact, usable_ids)
		list.add_child(item)
	
	set_attention(not usable_ids.is_empty())
	# usable_ids stuff


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

# TODO
func _gui_input(event: InputEvent) -> void:
	# Dragging is disabled while collapsed so the button stays clickable.
	if _collapsed:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Remember where the pointer grabbed the panel so it doesn't jump.
		_dragging_box = event.pressed
		_drag_offset = event.global_position - global_position
		accept_event()

	elif event is InputEventMouseMotion and _dragging_box:
		# Follow the pointer, but keep the panel inside the screen.
		var viewport_size: Vector2 = get_viewport_rect().size
		var next_position: Vector2 = event.global_position - _drag_offset
		global_position = next_position.clamp(Vector2.ZERO, viewport_size - size)
		accept_event()

func _collapsed_position() -> Vector2:
	# The spot that leaves only the minimise button visible: slide the panel
	# left until just the button pokes past the edge, and rest it on the bottom.
	var viewport_size: Vector2 = get_viewport_rect().size
	var button_left: float = header.position.x + minimize.position.x
	var button_bottom: float = header.position.y + minimize.position.y + minimize.size.y
	return Vector2(margin - button_left, viewport_size.y - margin - button_bottom)

func set_attention(active: bool) -> void:
	# Turn the reminder hop on or off. Called by show_facts whenever the set
	# of usable facts changes.
	if _attention == active:
		return
	_attention = active

	# If a collapse/expand animation is already running it will sort the hop
	# out when it finishes, so leave it alone for now.
	if _tween != null and _tween.is_running():
		return

	_refresh_attention()


func _refresh_attention() -> void:
	# Restart the hop when we are collapsed with usable facts; otherwise make
	# sure the panel is resting in its corner.
	_stop_attention()
	if _collapsed and _attention:
		_start_attention()
	elif _collapsed:
		position = _collapsed_position()


func _start_attention() -> void:
	# Loop "hop, wait, hop, wait" forever to catch the player's eye.
	var start_position: Vector2 = _collapsed_position()
	position = start_position

	_attention_tween = create_tween()
	_attention_tween.set_loops()
	_attention_tween.set_trans(Tween.TRANS_QUAD)
	_hop(start_position)
	_attention_tween.tween_interval(attention_gap)
	_hop(start_position)
	_attention_tween.tween_interval(attention_wait)
	
	
func _hop(start_position: Vector2) -> void:
	# One bounce: up by hop_px, then back down to where it started.
	_attention_tween.set_ease(Tween.EASE_OUT)
	_attention_tween.tween_property(self, "position", start_position + Vector2(0.0, -hop_px), hop_time * 0.5)
	_attention_tween.set_ease(Tween.EASE_IN)
	_attention_tween.tween_property(self, "position", start_position, hop_time * 0.5)

func _stop_attention() -> void:
	# Cancel the reminder hop if it is currently playing.
	if _attention_tween != null and _attention_tween.is_valid():
		_attention_tween.kill()
		_attention_tween = null


func _toggle_collapsed() -> void:
	# Slide the panel between its expanded spot and the collapsed corner, with
	# a little hop at the start. Ignore the click if an animation is playing.
	if _tween != null and _tween.is_running():
		return

	_stop_attention()

	# When expanding, settle the panel onto the corner first so the hop starts
	# from a clean resting spot.
	if _collapsed:
		position = _collapsed_position()

	_collapsed = not _collapsed

	if _collapsed:
		#minimize.text = "+"
		minimize.get_node("TextureRect").texture = preload("res://assets/images/maximize.png")
		clipboard_audio.stream = preload("res://assets/sounds/sfx/clipboard_close.wav")
		clipboard_audio.play()
		_restore_position = position
	else:
		#minimize.text = "-"
		minimize.get_node("TextureRect").texture = preload("res://assets/images/minimize.png")
		clipboard_audio.stream = preload("res://assets/sounds/sfx/clipboard_open.wav")
		clipboard_audio.play()
		list.show()

	var start_position: Vector2 = position
	var target_position: Vector2 = _collapsed_position() if _collapsed else _restore_position

	_tween = create_tween()

	# A quick hop (pop up, then back to the start) before gliding to the target.
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position", start_position + Vector2(0.0, -hop_px), hop_time * 0.5)
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "position", start_position, hop_time * 0.5)
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "position", target_position, tween_time)

	if _collapsed:
		_tween.tween_callback(list.hide)
	_tween.tween_callback(_refresh_attention)
