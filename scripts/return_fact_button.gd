extends TextureButton
class_name ReturnFactButton

func _pressed() -> void:
	call_deferred("queue_free")
