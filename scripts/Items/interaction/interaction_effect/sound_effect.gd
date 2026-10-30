class_name SoundEffect
extends InteractEffect


func activate() -> void:
	if has_node("PaperAudio"):
		get_node("PaperAudio").stream = preload("res://assets/sounds/sfx/paper_select_2.wav")
		get_node("PaperAudio").play()
