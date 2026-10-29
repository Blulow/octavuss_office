class_name PanelCloser
extends Node
## Slides a panel off-screen and (optionally) frees it.
## Use it two ways:
##   1. Drop it under the panel root and assign a close button (no code needed).
##   2. Call PanelCloser.close_panel(panel, ...) from anywhere (Escape key, etc.).

## Meta key the spawner uses to hand the panel's rest position to this script.
const REST_POS_META := &"_rest_pos"
const CLOSING_META := &"_closing"

## Swap the type for Button and `onclick` for `pressed` if you use a normal Button.
@export var close_button: Button
## Panel to close. Leave empty to use this node's parent.
@export var panel: Control
## Use the same direction as the spawner for an exact reverse.
@export var direction: UITween.Direction = UITween.Direction.DOWN
@export var add_rotation: bool = true
@export var duration: float = 0.5
## For exits this is the size of the wind-up pull-back. 1.0 to 1.4 looks best.
@export var overshoot: float = 1.2
## true = free the panel after it exits, false = just hide it.
@export var free_when_done := true

@onready var clipboard_audio: AudioStreamPlayer2D = $"../ClipboardAudio"


func _ready() -> void:
	if panel == null:
		panel = get_parent() as Control
	close_button.pressed.connect(close)


func close() -> void:
	close_panel(panel, direction, add_rotation, duration, overshoot, free_when_done)
	clipboard_audio.stream = preload("res://assets/sounds/sfx/clipboard_close.wav")
	clipboard_audio.play()


static func close_panel(
		target: Control,
		dir: UITween.Direction = UITween.Direction.DOWN,
		add_rot: bool = true,
		time: float = 0.5,
		overshoot_amount: float = 1.2,
		free_when_done: bool = true) -> void:

	# Ignore invalid panels and repeat clicks while it is already leaving.
	if not is_instance_valid(target) or target.has_meta(CLOSING_META):
		return

	# Prefer the stored rest position. Reading target.position now would be wrong
	# if the panel is still mid slide-in.
	var rest_pos: Vector2 = target.get_meta(REST_POS_META, target.position)

	var tween := UITween.slide_out(target, rest_pos, dir, add_rot, time, overshoot_amount)
	if tween == null:  # panel was hidden already
		return

	target.set_meta(CLOSING_META, true)
	tween.finished.connect(func() -> void:
		if not is_instance_valid(target):
			return
		target.remove_meta(CLOSING_META)
		if free_when_done:
			target.queue_free())
