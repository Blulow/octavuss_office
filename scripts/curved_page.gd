@tool
extends MeshInstance3D

@export var camera_pos: Vector3:
	set(value):
		camera_pos = value
		$CurvedPage/Camera3D.position = value

@export var camera_rot: Vector3:
	set(value):
		camera_rot = value
		$CurvedPage/Camera3D.rotation = value

@export var font_size: int:
	set(value):
		font_size = value
		$CurvedPage/SubViewport/Label.add_theme_font_size_override("font_size", value)

@export_multiline() var text: String:
	set(value):
		text = value
		if is_inside_tree() and has_node("CurvedPage/SubViewport/Label"):
			$CurvedPage/SubViewport/Label.text = value

func _ready() -> void:
	$CurvedPage/SubViewport/Label.text = text
