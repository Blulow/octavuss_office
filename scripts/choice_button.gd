extends Button
class_name ChoiceButton

signal fact_dropped(choices: Array)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return visible and data is Dictionary and data.has("choices")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if _can_drop_data(_at_position, data):
		print(data)
		fact_dropped.emit(String(data["choices"]))
