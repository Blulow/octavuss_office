extends Area3D

@export var label: String:
	set(value):
		$Label3D.text = value
@onready var original_position: Vector3 = position




func _on_area_3d_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:x", original_position.x - 0.5, 0.2)
	



func _on_area_3d_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:x", original_position.x, 0.2)
