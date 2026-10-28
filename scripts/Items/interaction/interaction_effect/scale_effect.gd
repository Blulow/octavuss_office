class_name ScaleEffect
extends TransitionEffect

@export var scale_multiplier := 1.3

func _init() -> void:
	overshoot = 0.25   # default only, inspector can override

func _property() -> String:
	return "scale"

func _away_value() -> Variant:
	return (_rest as Vector3) * scale_multiplier
