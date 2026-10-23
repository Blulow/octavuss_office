extends Control

func _on_close_button_pressed() -> void:
	await $CloseButton.tweened
	queue_free()
