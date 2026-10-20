class_name LiftEffect
extends InteractEffect

@export var target: Node3D
@export var lift := 0.1
@export var duration := 0.12

var _rest_y: float
var _tween: Tween

func _ready() -> void:
	super()
	if target == null:
		target = interactable.get_parent() as Node3D
	_rest_y = target.position.y

func activate() -> void: _go_to(_rest_y + lift)
func deactivate() -> void: _go_to(_rest_y)

func _go_to(y: float) -> void:
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.tween_property(target, "position:y", y, duration)
