class_name SelectToDisplayEffect
extends InteractEffect

signal arrived

@export var target: Node3D
@export var display_point: Marker3D   # place this in the scene where the item should float
@export var duration := 0.5

var _home_pos: Vector3
var _tween: Tween

func _ready() -> void:
	super()
	trigger = Trigger.SELECT
	if target == null:
		target = interactable.get_parent() as Node3D
	_home_pos = target.global_position

func activate() -> void:
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.tween_property(target, "global_position", display_point.global_position, duration) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_callback(arrived.emit)

func deactivate() -> void:
	if _tween: _tween.kill()
	if target is Item and target.is_purchased:
		return   # bought items shouldn't go back to the shelf
	_tween = create_tween()
	_tween.tween_property(target, "global_position", _home_pos, duration) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
