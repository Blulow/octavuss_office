extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Button.mouse_entered.connect(_on_btn_entered)
	$Button2.mouse_entered.connect(_on_btn2_entered)
	$Button3.mouse_entered.connect(_on_btn3_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	$VolumePanel.visible = true

func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_btn_entered() -> void:
	$StampAudio.stream = preload("res://assets/sounds/sfx/stamp_click.wav")
	$StampAudio.play()

func _on_btn2_entered() -> void:
	$StampAudio.stream = preload("res://assets/sounds/sfx/stamp_click.wav")
	$StampAudio.play()

func _on_btn3_entered() -> void:
	$StampAudio.stream = preload("res://assets/sounds/sfx/stamp_click.wav")
	$StampAudio.play()
