extends Control

@onready var paper_audio: AudioStreamPlayer2D = $PaperAudio

func _on_fact_check_mouse_entered() -> void:
	paper_audio.stream = preload("res://assets/sounds/sfx/paper_select_1.wav")
	paper_audio.play()

func _on_buy_something_mouse_entered() -> void:
	paper_audio.stream = preload("res://assets/sounds/sfx/paper_select_1.wav")
	paper_audio.play()
