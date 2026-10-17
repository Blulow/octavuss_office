class_name ChoiceBox
extends PanelContainer

signal chosen(index: int)

const WIDTH := 900.0
const GAP := 12.0

@onready var list: VBoxContainer = $VBox

var _buttons: Array[Button] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func show_choices(options: Array, above_y: float) -> void:
	for button in _buttons:
		button.queue_free()
	_buttons.clear()
	for i in options.size():
		var option: Dictionary = options[i]
		var button := Button.new()
		button.text = String(option.get("text", "Option %d" % (i + 1)))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_button_pressed.bind(i))
		list.add_child(button)
		_buttons.append(button)
	show()
	_fit_and_place(above_y)


func _fit_and_place(above_y: float) -> void:
	custom_minimum_size = Vector2(WIDTH, 0.0)
	var vp := get_viewport_rect().size
	for i in 2:
		await get_tree().process_frame
	size = Vector2(maxf(WIDTH, get_combined_minimum_size().x), get_combined_minimum_size().y)
	position = Vector2((vp.x - size.x) * 0.5, above_y - size.y - GAP)
	if _buttons.size() > 0:
		_buttons[0].grab_focus()


func _on_button_pressed(index: int) -> void:
	hide()
	chosen.emit(index)
