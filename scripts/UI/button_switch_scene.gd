extends Button

@export var next_scene: PackedScene

func _ready():
	pressed.connect(_on_pressed)
	mouse_entered.connect(func(): print("hover"))
	button_down.connect(func(): print("down"))

func _on_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_scene)
