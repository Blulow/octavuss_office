extends Button
class_name AnimatedButton
@onready var volume_panel: Control = $VolumePanel

signal tweened

var _default_scale: Vector2
var _default_position: Vector2

func _ready() -> void:
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	
	# Hubungkan signal hover mouse
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	pivot_offset = size / 2.0
	
	_default_scale = scale
	_default_position = position
	
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

# Efek saat mouse masuk (Hover)
func _on_mouse_entered() -> void:
	var tween = create_tween().set_parallel(true)
	# Mengubah scale menjadi 1.1 kali lebih besar dari ukuran default (bisa diubah sesuai selera)
	tween.tween_property(self, "scale", _default_scale * 1.1, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# Efek saat mouse keluar (Kembali ke posisi normal)
func _on_mouse_exited() -> void:
	var tween = create_tween().set_parallel(true)
	# Mengembalikan scale ke ukuran _default_scale
	tween.tween_property(self, "scale", _default_scale, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
