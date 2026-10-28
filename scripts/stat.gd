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
