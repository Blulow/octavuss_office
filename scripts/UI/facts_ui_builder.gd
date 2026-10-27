extends CanvasLayer

@export var facts_list: VBoxContainer

func open() -> void:
	PlayerData.add_pending_fact()
	_rebuild()
	show()

func close() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	# Esc (ui_cancel) or any mouse click closes it
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		get_tree().reload_current_scene()

func _rebuild() -> void:
	for child in facts_list.get_children():
		facts_list.remove_child(child)
		child.queue_free()

	if PlayerData.facts_collected.is_empty():
		_add_label("No facts collected yet.")
		return

	for f in PlayerData.facts_collected:
		_add_label(f.fact_description)

func _add_label(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	facts_list.add_child(label)
