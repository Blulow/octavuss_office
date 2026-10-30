extends Control
class_name SessionUIManager
@export var blur_rect: ColorRect   ## the ColorRect with your blur shader
@export var popup: Control         ## the element that slides in
@export var blur_radius := 8.0
@export var hold_time := 1.5
@export var in_duration := 0.6
@export var out_duration := 0.5
@export var message : Label
signal sequence_finished


var _blur_tween: Tween
var _playing := false


func _ready() -> void:
	_set_blur(0.0)
	blur_rect.hide()
	popup.hide()


func play(show_message: String) -> void:
	if _playing:
		return
	_playing = true
	message.text = show_message
	var rest_pos := (get_viewport_rect().size - popup.size) / 2.0

	# --- In: blur up while the popup drops from the top to center ---
	blur_rect.show()
	popup.show()
	_fade_blur(blur_radius, in_duration)
	var t_in := UITween.slide_in(popup, rest_pos, UITween.Direction.UP, true, in_duration)
	await t_in.finished

	# --- Hold ---
	await get_tree().create_timer(hold_time).timeout

	# --- Out: blur down while the popup exits the opposite way (bottom) ---
	_fade_blur(0.0, out_duration)
	var t_out := UITween.slide_out(popup, rest_pos, UITween.Direction.DOWN, true, out_duration)
	await t_out.finished

	blur_rect.hide()
	_playing = false
	sequence_finished.emit()


func _fade_blur(target: float, duration: float) -> void:
	if _blur_tween:
		_blur_tween.kill()
	_blur_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_blur_tween.tween_method(_set_blur, _get_blur(), target, duration)


func _set_blur(value: float) -> void:
	(blur_rect.material as ShaderMaterial).set_shader_parameter("radius", value)


func _get_blur() -> float:
	return (blur_rect.material as ShaderMaterial).get_shader_parameter("radius")
