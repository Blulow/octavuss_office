class_name FactItem
extends PanelContainer

const HIGHLIGHT_BLUE := Color(0.45, 0.7, 1.0)
const DIM_COLOR := Color(0.62, 0.65, 0.72)
const DISABLED_BORDER := Color(1, 1, 1, 0.12)

var fact_id := ""
var enabled := false
var facts_box: FactsBox

var choices: Array = []

var _label: Label


func setup(fact: Dictionary, usable_ids: Array) -> void:
	var usables: Array = []
	for id in usable_ids:
		usables.append_array(id)
	
	var usable: bool = usables.has(String(fact.get("id", "")))
	fact_id = String(fact.get("id", ""))
	
	choices = get_choices_from_facts(fact_id, usable_ids)
	
	enabled = usable
	mouse_filter = Control.MOUSE_FILTER_STOP
	if _label == null:
		_label = Label.new()
		_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_label.add_theme_font_size_override("font_size", 17)
		add_child(_label)
	_label.text = String(fact.get("text", ""))
	_label.add_theme_color_override("font_color", Color.WHITE if usable else DIM_COLOR)
	add_theme_stylebox_override("panel", _make_panel(usable))

func get_choices_from_facts(fact_id: String, usable_ids: Array):
	if !usable_ids: return []
	
	var _choices: Array[int]
	
	for i in usable_ids.size():
		if usable_ids[i].has(fact_id):
			_choices.append(i)
	
	return _choices

func _make_panel(usable: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.09, 0.13, 0.9)
	style.border_color = HIGHLIGHT_BLUE if usable else DISABLED_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func _get_drag_data(_at_position: Vector2) -> Variant:
	if not enabled:
		return null
	if facts_box:
		facts_box.begin_drag()
	var preview := PanelContainer.new()
	preview.add_theme_stylebox_override("panel", _make_panel(true))
	var label := Label.new()
	label.text = _label.text
	label.add_theme_font_size_override("font_size", 17)
	preview.add_child(label)
	preview.modulate = Color(1, 1, 1, 0.9)
	set_drag_preview(preview)
	
	var choice_box: ChoiceBox = facts_box.choice_box
	
	var buttons := choice_box.list.get_children()
	
	for i in buttons.size():
		if choices.has(i):
			choice_box._highlight_blue(buttons[i])
	
	return {"choices": choices}
