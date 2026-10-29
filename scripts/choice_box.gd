class_name ChoiceBox
extends PanelContainer

signal chosen(index: int)
signal fact_dropped(fact_id: String)

const GAP := 12.0
const HIGHLIGHT_BLUE := Color(0.405, 0.706, 0.969, 1.0)
const HIGHLIGHT_GREEN := Color(0.479, 0.965, 0.725, 1.0)

@export var width := 900.0
@export var center_offset_x := 0.0

@export var facts_box: Control

#@onready var list: VBoxContainer = $VBox
@onready var btn1: ChoiceButton = $Buttons/ChoiceButton
@onready var btn2: ChoiceButton = $Buttons/ChoiceButton2
@onready var btn3: ChoiceButton = $Buttons/ChoiceButton3

var _buttons: Array[Button] = []
var _anchor_y := 0.0
var _drop_active := false
var _options: Array

var updated: Array = []

func _ready() -> void:
	btn1.mouse_entered.connect(choice_button_hover.bind(btn1))
	btn2.mouse_entered.connect(choice_button_hover.bind(btn2))
	btn3.mouse_entered.connect(choice_button_hover.bind(btn3))
	btn1.mouse_exited.connect(choice_button_exit.bind(btn1))
	btn2.mouse_exited.connect(choice_button_exit.bind(btn2))
	btn3.mouse_exited.connect(choice_button_exit.bind(btn3))
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	#list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()
	if facts_box: facts_box.hide()

func choice_button_hover(button: Button) -> void:
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)

func choice_button_exit(button: Button) -> void:
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)

func show_choices(options: Array, above_y: float) -> void:
	_anchor_y = above_y
	
	for button in _buttons:
		button.queue_free()
	_buttons.clear()
	
	_options = options
	for i in options.size():
		_add_button(options[i], i)
	show()
	if facts_box: facts_box.show()
	#_fit_and_place(above_y)

func refresh_choices() -> void:
	#for button in _buttons:
		#button.queue_free()
	#_buttons.clear()
	
	for i in _options.size():
		_add_button(_options[i], i)
	show()
	#_fit_and_place(_anchor_y)

#func add_choice(option: Dictionary) -> void:
	#_add_button(option, _buttons.size())
	#_fit_and_place(_anchor_y)


func set_drop_active(active: bool) -> void:
	_drop_active = active
	for button in _buttons:
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE if active else Control.MOUSE_FILTER_STOP


func _add_button(option: Dictionary, index: int) -> void:
	if _options.size() == 1:
		global_position.x += 350
		btn1.visible = true
		btn2.visible = false
		btn3.visible = false
		if index == 0:
			btn1.get_node("Label").text = String(option.get("text", "Option %d" % (index + 1)))
	elif _options.size() == 2:
		btn1.visible = true
		btn2.visible = true
		btn3.visible = false
		if index == 0:
			btn1.get_node("Label").text = String(option.get("text", "Option %d" % (index + 1)))
		if index == 1:
			btn2.get_node("Label").text = String(option.get("text", "Option %d" % (index + 1)))
	elif _options.size() == 3:
		btn1.visible = true
		btn2.visible = true
		btn3.visible = true
		if index == 0:
			btn1.get_node("Label").text = String(option.get("text", "Option %d" % (index + 1)))
		if index == 1:
			btn2.get_node("Label").text = String(option.get("text", "Option %d" % (index + 1)))
		if index == 2:
			btn3.get_node("Label").text = String(option.get("text", "Option %d" % (index + 1)))
	
	#var button := ChoiceButton.new()
	#button.text = String(option.get("text", "Option %d" % (index + 1)))
	#button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	#button.mouse_filter = Control.MOUSE_FILTER_IGNORE if _drop_active else Control.MOUSE_FILTER_STOP
	#if String(option.get("highlight", "")) == "blue":
		#_highlight_blue(button)
	
	var button: Button = [btn1, btn2, btn3][index]
	button.get_node("TextureRect").modulate = Color.WHITE
	if button.has_node("ReturnFactButton"): button.get_node("ReturnFactButton").queue_free()
	
	for e in updated:
		if e.index != index: continue
		if not option.has("facts"): continue
		
		var facts: Array = option.get("facts")
		for fact in facts:
			if fact.fact == e.fact_id:
				button.get_node("Label").text = fact.text
				_highlight("blue", button)
				button.add_return_button()
	
	button.pressed.connect(_on_button_pressed.bind(index))
	button.fact_dropped.connect(_on_button_fact_dropped.bind(index))
	button.return_btn_pressed.connect(_on_button_return_pressed.bind(index))
	
	#list.add_child(button)
	#_buttons.append(button)


func _fit_and_place(above_y: float) -> void:
	custom_minimum_size = Vector2(width, 0.0)
	var vp := get_viewport_rect().size
	for i in 2:
		await get_tree().process_frame
	size = Vector2(maxf(width, get_combined_minimum_size().x), get_combined_minimum_size().y)
	position = Vector2((vp.x - size.x) * 0.5 + center_offset_x, above_y - size.y - GAP)
	if _buttons.size() > 0:
		_buttons[0].grab_focus()


func _highlight(color: String, button: Button) -> void:
	var HIGHLIGHT_COL: Color 
	if color == "blue":
		HIGHLIGHT_COL = HIGHLIGHT_BLUE
	elif color == "green":
		HIGHLIGHT_COL = HIGHLIGHT_GREEN
	
	button.get_node("TextureRect").modulate = HIGHLIGHT_COL
	#button.add_theme_color_override("font_color", HIGHLIGHT_COL)
	#button.add_theme_color_override("font_hover_color", HIGHLIGHT_COL.lightened(0.3))
	#button.add_theme_color_override("font_focus_color", HIGHLIGHT_COL.lightened(0.3))
	#button.add_theme_color_override("font_pressed_color", HIGHLIGHT_COL)
	#for state in ["normal", "hover", "focus", "pressed"]:
		#var box := StyleBoxFlat.new()
		#box.bg_color = Color(HIGHLIGHT_COL.r, HIGHLIGHT_COL.g, HIGHLIGHT_COL.b, 0.12 if state == "normal" else 0.22)
		#box.border_color = HIGHLIGHT_COL
		#box.set_border_width_all(1)
		#box.set_corner_radius_all(6)
		#box.content_margin_left = 10.0
		#box.content_margin_right = 10.0
		#box.content_margin_top = 5.0
		#box.content_margin_bottom = 5.0
		#button.add_theme_stylebox_override(state, box)

func _on_button_pressed(index: int) -> void:
	hide()
	if facts_box: facts_box.hide()
	chosen.emit(index)

func _on_button_fact_dropped(choices: Array, fact_id: String, index: int) -> void:
	if not choices.has(index): return
	
	updated.append({ "index": index, "fact_id": fact_id })

func _on_button_return_pressed(index: int):
	updated = updated.filter(func(e): return e.index != index)
	refresh_choices()
