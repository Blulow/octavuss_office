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

@onready var dialogues: Node3D = $Game

func _ready() -> void:

	
	start_game.onclick.connect(_on_start_game_onclick)
	#settings.onclick.connect(_on_settings_onclick)
	quit_game.onclick.connect(_on_quit_game_onclick)
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
	if PlayerData.game_started:
		print("A")
		await get_tree().process_frame
		_on_start_game_onclick()

func _on_start_game_onclick():
	#name_stand.visible = false
	PlayerData.game_started = true
	var tween = create_tween()
	start_game_tween(tween)
	await tween.finished
	
	book.visible = false
	title.visible = false
	dialogues.get_node("SessionManager").load_next_session(true)

func _on_quit_game_onclick():
	get_tree().quit()

func start_game_tween (tween : Tween):
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel()
	tween.tween_property(trans_cam, "global_position", player_cam.global_position, 0.3)
	tween.tween_property(trans_cam, "global_rotation", player_cam.global_rotation, 0.3)
	tween.tween_property(book, "global_position:y", book.global_position.y + 1000, 0.3)
	tween.tween_property(title, "global_position:y", title.global_position.y + 1000, 0.3)

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
