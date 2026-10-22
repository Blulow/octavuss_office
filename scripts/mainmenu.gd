extends Node3D

@onready var trans_cam: Camera3D = $TransCam
@onready var start_cam: Camera3D = $StartCam
@onready var player_cam: Camera3D = $Player/PlayerCam

#@onready var book: Node3D = $MainMenuUI/Book
#@onready var title: Node3D = $MainMenuUI/Title
#@onready var name_stand: Node3D = $MainMenuUI/NameStand
@onready var book: Control = $UI/Book
@onready var title: Control = $UI/Title

#@onready var start_game: Strip = $MainMenuUI/Book/Strips/Strip
@onready var start_game: Strip2D = $UI/Book/Strips/TextureRect/Strip
@onready var settings: Strip2D = $UI/Book/Strips/TextureRect2/Strip2
@onready var quit_game: Strip2D = $UI/Book/Strips/TextureRect3/Strip3
@onready var book_sprite: AnimatedTextureRect = $UI/Book/AnimatedTextureRect

func _ready() -> void:
	start_game.onclick.connect(_on_start_game_onclick)
	start_game.onhover.connect(_on_start_game_onhover)
	settings.onhover.connect(_on_settings_onhover)
	quit_game.onhover.connect(_on_quit_game_onhover)
	start_game.onexit.connect(_on_start_game_onexit)
	settings.onexit.connect(_on_settings_onexit)
	quit_game.onexit.connect(_on_quit_game_onexit)
	
	trans_cam.make_current()
	trans_cam.global_position = start_cam.global_position
	trans_cam.global_rotation = start_cam.global_rotation
	
	book_sprite.visible = false

func _on_start_game_onclick():
	book.visible = false
	title.visible = false
	#name_stand.visible = false
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(trans_cam, "global_position", player_cam.global_position, 0.3)
	tween.parallel().tween_property(trans_cam, "global_rotation", player_cam.global_rotation, 0.3)

func _on_start_game_onhover():
	if book_sprite.animation == "open" and book_sprite.playing:
		return
	book_sprite.animation = "open"
	book_sprite.visible = true
	await get_tree().create_timer(1/5).timeout
	book_sprite.play()
	await book_sprite.finished
	book_sprite.visible = false
	
func _on_settings_onhover():
	if book_sprite.animation == "open" and book_sprite.playing:
		return
	book_sprite.animation = "open"
	book_sprite.visible = true
	await get_tree().create_timer(1/5).timeout
	book_sprite.play()
	await book_sprite.finished
	book_sprite.visible = false
	
func _on_quit_game_onhover():
	if book_sprite.animation == "open" and book_sprite.playing:
		return
	book_sprite.animation = "open"
	book_sprite.visible = true
	await get_tree().create_timer(1/5).timeout
	book_sprite.play()
	await book_sprite.finished
	book_sprite.visible = false

func _on_start_game_onexit():
	if book_sprite.animation == "close" and book_sprite.playing:
		return
	book_sprite.animation = "close"
	book_sprite.visible = true
	await get_tree().create_timer(1/10).timeout
	book_sprite.play()
	await book_sprite.finished
	book_sprite.visible = false
	
func _on_settings_onexit():
	if book_sprite.animation == "close" and book_sprite.playing:
		return
	book_sprite.animation = "close"
	book_sprite.visible = true
	await get_tree().create_timer(1/10).timeout
	book_sprite.play()
	await book_sprite.finished
	book_sprite.visible = false
	
func _on_quit_game_onexit():
	if book_sprite.animation == "close" and book_sprite.playing:
		return
	book_sprite.animation = "close"
	book_sprite.visible = true
	await get_tree().create_timer(1/10).timeout
	book_sprite.play()
	await book_sprite.finished
	book_sprite.visible = false
