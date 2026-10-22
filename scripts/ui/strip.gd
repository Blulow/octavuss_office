extends MeshInstance3D
class_name Strip

signal onclick

@export var label: String:
	set(value):
		$Label3D.text = value

func _on_area_3d_mouse_entered() -> void:	
	var tween = create_tween()
	tween.tween_property(self, "position:x", -0.2, 0.1)
	tween.set_ease(Tween.EASE_IN)

func _on_area_3d_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:x", 0, 0.1)
	tween.set_ease(Tween.EASE_IN)

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			onclick.emit()
