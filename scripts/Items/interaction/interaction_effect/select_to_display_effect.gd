class_name SelectToDisplayEffect
extends TransitionEffect

@export var display_point: Marker3D

func _property() -> String:
	return "global_position"

func _away_value() -> Variant:
	return display_point.global_position

func _should_return() -> bool:
	var item := target as Item
	return item == null or not item.is_purchased   # bought items don't go back to the shelf
