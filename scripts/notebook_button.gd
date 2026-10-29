extends AnimatedButton

# Toggles the notebook overlay. On open it slides up from the bottom, then a
# blur slowly fades in behind it. Clicking anywhere outside the notebook
# closes it: the blur fades out over a second while the notebook slides down.
const BLUR_TARGET := 4.0
const BLUR_TIME := 3.0
const BLUR_OUT_TIME := 0.3
const CLOSE_BLUR_TIME := 1.0
const SLIDE_TIME := 0.6

# The book's visible (opaque) area, in texture pixels. Used to tell whether a
# click landed on the notebook or somewhere else.
const BOOK_OPAQUE := Rect2(85, 164, 1825, 916)

@export var overlay: CanvasLayer
@onready var notebook: Node2D = overlay.get_node("NoteBook")
@onready var notebook_ui: CanvasLayer = notebook.get_node("UI")
@onready var blur: ColorRect = overlay.get_node("Blur")

@onready var notebook_audio: AudioStreamPlayer2D = $NotebookAudio

var _open := false
var _animating := false


func _ready() -> void:
	pressed.connect(_toggle)
	blur.gui_input.connect(_on_blur_gui_input)
	
	var offscreen: float = get_viewport_rect().size.y
	notebook.position.y = offscreen
	notebook_ui.offset.y = offscreen
	_set_blur(0.0)


func _toggle() -> void:
	if _animating:
		return
	_animating = true
	_open = not _open
	overlay.visible = true
	if _open:
		notebook_audio.stream = preload("res://assets/sounds/sfx/woosh_in.wav")
		notebook_audio.play()
		await _open_notebook()
	else:
		notebook_audio.stream = preload("res://assets/sounds/sfx/woosh_out.wav")
		notebook_audio.play()
		await _close_notebook()
	_animating = false


func _open_notebook() -> void:
	# Start fully clear, slide the notebook up, then fade the blur in.
	_set_blur(0.0)
	await _slide(0.0)
	await _fade_blur(BLUR_TARGET, BLUR_TIME)


func _close_notebook() -> void:
	# Button close: fade the blur out, then slide down.
	await _fade_blur(0.0, BLUR_OUT_TIME)
	await _slide(get_viewport_rect().size.y)
	overlay.visible = false


func _on_blur_gui_input(event: InputEvent) -> void:
	# A click on the blurred background (outside the notebook) closes it.
	if not _open or _animating:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not _is_over_notebook(event.global_position):
			_close_from_click()


func _close_from_click() -> void:
	# Fade the blur out over a second while the notebook slides back down.
	_animating = true
	_open = false
	var offscreen: float = get_viewport_rect().size.y
	var blur_tween := create_tween()
	blur_tween.tween_method(_set_blur, _current_blur(), 0.0, CLOSE_BLUR_TIME)
	var slide_tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	slide_tween.tween_property(notebook, "position:y", offscreen, SLIDE_TIME)
	slide_tween.tween_property(notebook_ui, "offset:y", offscreen, SLIDE_TIME)
	await slide_tween.finished
	await blur_tween.finished
	overlay.visible = false
	_animating = false


func _is_over_notebook(pos: Vector2) -> bool:
	var book: Sprite2D = notebook.get_node("CheckpointUiBukuV3")
	return _opaque_rect(book, BOOK_OPAQUE).has_point(pos)


func _opaque_rect(sprite: Sprite2D, tex_rect: Rect2) -> Rect2:
	# Convert a rectangle in texture pixels to the sprite's global space.
	var scale: Vector2 = sprite.scale
	var origin: Vector2 = sprite.global_position - sprite.texture.get_size() * scale * 0.5
	return Rect2(origin + tex_rect.position * scale, tex_rect.size * scale)


func _slide(target_y: float) -> void:
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(notebook, "position:y", target_y, SLIDE_TIME)
	tween.tween_property(notebook_ui, "offset:y", target_y, SLIDE_TIME)
	await tween.finished


func _fade_blur(target: float, duration: float) -> void:
	var material: ShaderMaterial = blur.material as ShaderMaterial
	var tween := create_tween()
	tween.tween_method(_set_blur, material.get_shader_parameter("radius"), target, duration)
	await tween.finished


func _set_blur(value: float) -> void:
	var material: ShaderMaterial = blur.material as ShaderMaterial
	material.set_shader_parameter("radius", value)


func _current_blur() -> float:
	return (blur.material as ShaderMaterial).get_shader_parameter("radius")
