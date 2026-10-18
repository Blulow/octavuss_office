extends Node

@export var scene: PackedScene
@export var layer: CanvasLayer

var canvas_instance: Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func show_ui():
	if not is_instance_valid(canvas_instance):
		canvas_instance = scene.instantiate()
		canvas_instance.process_mode = Node.PROCESS_MODE_ALWAYS
		layer.add_child(canvas_instance)
	else:
		canvas_instance.show()
	get_tree().paused = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if is_ui_open():
			hide_ui()
		else:
			show_ui()


func hide_ui() -> void:
	if canvas_instance:
		canvas_instance.hide()
	get_tree().paused = false

func is_ui_open() -> bool:

	return is_instance_valid(canvas_instance) and canvas_instance.visible
