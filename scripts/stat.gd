@tool
extends Node3D

@export var stat_texture: Texture2D:
	set(value):
		stat_texture = value
		$Sprite3D.texture = value
@export var stat_bar_texture: Texture2D:
	set(value):
		stat_bar_texture = value
		$Bar/StatBar/SubViewport/TextureProgressBar.texture_progress = value
@export var amount: int:
	set(value):
		amount = value
		$Bar/StatBar/SubViewport/TextureProgressBar.value = value

func shake() -> void:
	var tween = create_tween()
	tween.tween_interval(0.08)
	for amp in [0.02, -0.02, 0.01, -0.01, 0.0]:
		tween.tween_property($Bar, "position:x", amp, 0.06)
