extends Button
class_name AnimatedButton

signal tweened

var _default_scale: Vector2

func _ready() -> void:
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	
	# Atur pivot ke titik tengah tombol agar efek scaling berpusat di tengah
	pivot_offset = size / 2.0
	
	# Simpan skala awal node
	_default_scale = scale
	
	# Sambungkan signal jika ukuran tombol berubah agar pivot tetap di tengah
	resized.connect(_on_resized)

func _on_resized() -> void:
	pivot_offset = size / 2.0

func _on_button_down() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", _default_scale * 0.8, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(0.8, 0.8, 0.8), 0.1)

func _on_button_up() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", _default_scale, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)
	tweened.emit()
	
	


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_button_5_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/button.tscn")



func _on_quitgame_pressed() -> void:
	get_tree().quit()
