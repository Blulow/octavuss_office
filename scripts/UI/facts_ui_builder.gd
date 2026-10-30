extends CanvasLayer

## The duration (in seconds) it takes to fade in a single line
@export var line_fade_duration: float = 0.6
## The delay (in seconds) before the next line begins to fade in
@export var line_delay: float = 0.25

var line_alphas: Array[float] = []
# Stores the character index split-points for each wrapped line
var line_markers: Array[int] = [] 
# A clean backup of the original text string
var source_text: String = "" 

#@export var facts_list: VBoxContainer

@onready var background = $TextureRect
@onready var fact_label = $FactLabel
@onready var desc_label = $DescLabel
@onready var return_btn = $ReturnButton

@onready var facts_box: FactsBox = $FactsBox
@export var session_manager: SessionManager
@export var choice_ui: CanvasLayer
@export var dialogue_scene: DialogueScene

func _ready() -> void:
	facts_box.global_position.x = -600
	facts_box.rotation = 0.1
	
	#return_btn.mouse_entered.connect(func():
		#$PaperAudio.stream = preload("res://assets/sounds/sfx/paper_select_3.wav")
		#$PaperAudio.play()
		#)
	
	return_btn.pressed.connect(func():
		facts_box.global_position.x = -600
		facts_box.rotation = 0.1
		choice_ui.hide()
		var before_facts: Array = dialogue_scene._facts.duplicate()
		before_facts.pop_back()
		facts_box.show_facts(before_facts, [])
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(facts_box, "global_position:x", facts_box.global_position.x + 1000, 0.5)
		tween.parallel().tween_property(facts_box, "rotation", facts_box.rotation + 0.1, 0.5)
		tween.tween_interval(0.5)
		await tween.finished
		
		facts_box.show_facts(dialogue_scene._facts, [])
		var fact = facts_box.list.get_children()[-1]
		fact.pivot_offset_ratio = Vector2(0.5, 0.5)
		
		var fact_tween = create_tween()
		fact_tween.set_trans(Tween.TRANS_QUAD)
		fact_tween.set_ease(Tween.EASE_OUT)
		fact_tween.tween_property(fact, "scale", Vector2(1.3, 1.3), 0.3)
		fact_tween.parallel().tween_property(fact, "rotation", -0.1, 0.2)
		fact_tween.set_trans(Tween.TRANS_ELASTIC)
		fact_tween.set_ease(Tween.EASE_OUT)
		fact_tween.tween_property(fact, "scale", Vector2(1.0, 1.0), 0.4)
		fact_tween.parallel().tween_property(fact, "rotation", 0, 0.2)
		await fact_tween.finished
		
		var tween2 = create_tween()
		
		tween2.tween_interval(0.5)
		tween2.set_trans(Tween.TRANS_BACK)
		tween2.set_ease(Tween.EASE_IN)
		tween2.tween_property(facts_box, "global_position:x", facts_box.global_position.x + 2000, 0.5)
		tween2.parallel().tween_property(facts_box, "rotation", facts_box.rotation + 0.3, 0.5)
		
		tween2.set_trans(Tween.TRANS_LINEAR)
		tween2.set_ease(Tween.EASE_IN)
		tween2.tween_property(background.material, "shader_parameter/min_dist", 0.9, 0.3)
		tween2.parallel().tween_property(background.material, "shader_parameter/max_dist", 1.0, 0.3)
		tween2.parallel().tween_property(fact_label, "modulate:a", 0.0, 0.1)
		tween2.parallel().tween_property(return_btn, "modulate:a", 0.0, 0.1)
		await tween2.finished
		
		close()
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		
		session_manager.action_finish.emit()
	
		await session_manager.session_start
		
		session_manager.load_next_session()
		PlayerData.add_money(session_manager.money_add_per_session)
	)

func open() -> void:
	PlayerData.add_pending_fact()
	show()
	
	background.material.set_shader_parameter("min_dist", 0.9)
	background.material.set_shader_parameter("max_dist", 1.0)
	fact_label.modulate.a = 0.0
	return_btn.modulate.a = 0.0
	fact_label.text = ""
	desc_label.text = ""
	desc_label.visible_characters = 0
	
	_rebuild()

func close() -> void:
	hide()

#func _input(event: InputEvent) -> void:
	#if not visible:
		#return
	## Esc (ui_cancel) or any mouse click closes it
	#if event.is_action_pressed("ui_cancel"):
		#close()
		#get_viewport().set_input_as_handled()
		#get_tree().paused = false
		#get_tree().reload_current_scene()

func _rebuild() -> void:
	
	fact_label.text = PlayerData.pending_fact.text
	desc_label.text = PlayerData.pending_fact.fact_description
	
	var tween = create_tween()
	tween.tween_property(background.material, "shader_parameter/min_dist", -0.1, 0.3)
	tween.parallel().tween_property(background.material, "shader_parameter/max_dist", 0.0, 0.3)
	tween.tween_property(fact_label, "modulate:a", 1.0, 0.1)
	tween.tween_property(return_btn, "modulate:a", 1.0, 0.1)
	await tween.finished
	
	await get_tree().process_frame
	animate_line_by_line()
	
	#for child in facts_list.get_children():
		#facts_list.remove_child(child)
		#child.queue_free()
#
	#if PlayerData.facts_collected.is_empty():
		#_add_label("No facts collected yet.")
		#return
#
	#for f in PlayerData.facts_collected:
		#_add_label(f.fact_description)

#func _add_label(text: String) -> void:
	#var label := Label.new()
	#label.text = text
	#label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	#label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#facts_list.add_child(label)

#var added_alphad = false
var original = ""
var char_markers = []

func animate_line_by_line() -> void:
	# Get the markers where each wrapped line ends
	var line_end_markers = get_line_end_markers()
	if line_end_markers.is_empty():
		return

	var tween = create_tween()
	var current_char_marker = 0

	original = desc_label.text

	var i = 0
	for next_char_marker in line_end_markers:
		# Animate visible_characters from the start of this line to the end of this line
		tween.tween_property(
			desc_label,
			"visible_characters", 
			next_char_marker, 
			line_fade_duration
		).from(current_char_marker).set_trans(Tween.TRANS_LINEAR)
		
		#tween.tween_method((func(alpha: float, index: int):
			#print(alpha)
			##var alphad_margin = (25 if added_alphad else 0)
			##var alphad_left_margin = (17 if added_alphad else 0)
			#
			#for j in range(index):
				#var alphad = "[color=#ffffffff]" + original.substr(0 if i == 0 else line_end_markers[i - 1], line_end_markers[i]) + "[/color]"
				#desc_label.text = original.erase(current_char_marker, next_char_marker - current_char_marker)
				#desc_label.text = original.insert(current_char_marker, alphad)
				#
			#print(desc_label.text)
			#
			##if not added_alphad: added_alphad = true
			##desc_label.text = desc_label.text.left(current_char_marker + 25 * i) + alphad + desc_label.text.right(-next_char_marker + 25 * i)
			#).bind(i)
			#,0.0, 1.0, 0.3)
		
		# (Optional) If you want a pause between lines, uncomment the line below:
		# tween.tween_interval(0.3)
		
		i += 1
		current_char_marker = next_char_marker

## Maps out the total accumulated characters up to the end of each wrapped line
func get_line_end_markers() -> Array[int]:
	var total_chars = desc_label.get_total_character_count()
	if total_chars == 0:
		return []
		
	var markers: Array[int] = []
	var current_line = 0
	
	# Loop through every single character index to see which line it belongs to
	for i in range(total_chars):
		var char_line = desc_label.get_character_line(i) # Returns the wrapped line index for this character
		
		# When we notice the line index has advanced, the previous character 'i' 
		# was the final character of the previous line.
		if char_line > current_line:
			markers.append(i)
			current_line = char_line
			
	# Don't forget to add the very last character marker for the final line
	markers.append(total_chars)
	return markers
