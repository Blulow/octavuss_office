extends Node

@export var open_button: Strip2D
@export var panel_scene: PackedScene
## A plain Control or CanvasLayer child, NOT a Container (containers fight the tween).
@export var parent: CanvasLayer
@export var direction: UITween.Direction = UITween.Direction.DOWN
@export var add_rotation: bool = true
@export var in_overshoot: float = 1.9
## Exits usually look better quicker and subtler than entrances.
@export var out_overshoot: float = 1.2

var instance: Control
@export var rest_pos: Vector2
var is_open := false
var _spawning := false  # blocks double-clicks during the one-frame wait below


func _ready() -> void:
	if not open_button: return
	open_button.onclick.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	if _spawning:
		return

	# First click (or the panel was freed elsewhere): create it.
	if not is_instance_valid(instance):
		await _spawn()

	is_open = not is_open
	if is_open:
		instance.show()
		UITween.slide_in(instance, rest_pos, direction, add_rotation,
				0.6, in_overshoot)
	else:
		UITween.slide_out(instance, rest_pos, direction, add_rotation,
				0.5, out_overshoot)


func _spawn() -> void:
	_spawning = true

	instance = panel_scene.instantiate()
	instance.hide()  # avoids a one-frame flash at the rest position
	parent.add_child(instance)

	# Reset the toggle if something else frees the panel later.
	instance.tree_exited.connect(func() -> void: is_open = false)

	# Let anchors and size resolve before reading position.
	await get_tree().process_frame
	rest_pos = instance.position  # the scene's authored position is the "on screen" spot

	_spawning = false
