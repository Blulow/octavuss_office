class_name ChoiceBox
extends PanelContainer

signal chosen(index: int)
signal fact_dropped(fact_id: String)

const GAP := 12.0
const HIGHLIGHT_BLUE := Color(0.45, 0.7, 1.0)

@export var width := 900.0
@export var center_offset_x := 0.0

@onready var list: VBoxContainer = $VBox

var _buttons: Array[Button] = []
var _anchor_y := 0.0
var _drop_active := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()


func show_choices(options: Array, above_y: float) -> void:
	_anchor_y = above_y
	for button in _buttons:
		button.queue_free()
	_buttons.clear()
	for i in options.size():
		_add_button(options[i], i)
	show()
	_fit_and_place(above_y)


#func add_choice(option: Dictionary) -> void:
	#_add_button(option, _buttons.size())
	#_fit_and_place(_anchor_y)


func set_drop_active(active: bool) -> void:
	_drop_active = active
	for button in _buttons:
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE if active else Control.MOUSE_FILTER_STOP


func _add_button(option: Dictionary, index: int) -> void:
	var button := ChoiceButton.new()
	button.text = String(option.get("text", "Option %d" % (index + 1)))
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE if _drop_active else Control.MOUSE_FILTER_STOP
	if String(option.get("highlight", "")) == "blue":
		_highlight_blue(button)
	button.pressed.connect(_on_button_pressed.bind(index))
	button.fact_dropped.connect(_on_button_fact_dropped)
	list.add_child(button)
	_buttons.append(button)


func _fit_and_place(above_y: float) -> void:
	custom_minimum_size = Vector2(width, 0.0)
	var vp := get_viewport_rect().size
	for i in 2:
		await get_tree().process_frame
	size = Vector2(maxf(width, get_combined_minimum_size().x), get_combined_minimum_size().y)
	position = Vector2((vp.x - size.x) * 0.5 + center_offset_x, above_y - size.y - GAP)
	if _buttons.size() > 0:
		_buttons[0].grab_focus()


func _highlight_blue(button: Button) -> void:
	button.add_theme_color_override("font_color", HIGHLIGHT_BLUE)
	button.add_theme_color_override("font_hover_color", HIGHLIGHT_BLUE.lightened(0.3))
	button.add_theme_color_override("font_focus_color", HIGHLIGHT_BLUE.lightened(0.3))
	button.add_theme_color_override("font_pressed_color", HIGHLIGHT_BLUE)
	for state in ["normal", "hover", "focus", "pressed"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color(HIGHLIGHT_BLUE.r, HIGHLIGHT_BLUE.g, HIGHLIGHT_BLUE.b, 0.12 if state == "normal" else 0.22)
		box.border_color = HIGHLIGHT_BLUE
		box.set_border_width_all(1)
		box.set_corner_radius_all(6)
		box.content_margin_left = 10.0
		box.content_margin_right = 10.0
		box.content_margin_top = 5.0
		box.content_margin_bottom = 5.0
		button.add_theme_stylebox_override(state, box)

func _on_button_pressed(index: int) -> void:
	hide()
	chosen.emit(index)

func _on_button_fact_dropped(fact_id: String) -> void:
	pass
