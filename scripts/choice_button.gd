extends Button
class_name ChoiceButton

signal fact_dropped(choices: Array, fact_id: String)
signal return_btn_pressed

var return_btn_scene: PackedScene = preload("res://scenes/return_fact_button.tscn")

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return visible and data is Dictionary and data.has("choices") and data.has("fact_id")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if _can_drop_data(_at_position, data):
		fact_dropped.emit(data["choices"], data["fact_id"])

func add_return_button() -> void:
	var return_btn: ReturnFactButton = return_btn_scene.instantiate()
	add_child(return_btn)
	return_btn.position = Vector2(-30, 0)
	return_btn.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	return_btn.pressed.connect(return_btn_pressed.emit)
