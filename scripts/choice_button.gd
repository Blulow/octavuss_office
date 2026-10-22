extends Button
class_name ChoiceButton

signal fact_dropped(choices: Array, fact_id: String)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return visible and data is Dictionary and data.has("choices") and data.has("fact_id")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if _can_drop_data(_at_position, data):
		fact_dropped.emit(data["choices"], data["fact_id"])
