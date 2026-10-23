extends Node

@export var canvas_instance: Node
@export var facts_canvas: CanvasLayer
@export var facts_button: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	facts_button.pressed.connect(facts_canvas.open)


func show_ui():
	canvas_instance.show()
	get_tree().paused = true
	print(facts_button.can_process())

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept"):
		#if is_ui_open():
			#hide_ui()
		#else:
			#show_ui()




func hide_ui() -> void:
	if canvas_instance:
		canvas_instance.hide()
	get_tree().paused = false

func is_ui_open() -> bool:

	return is_instance_valid(canvas_instance) and canvas_instance.visible
