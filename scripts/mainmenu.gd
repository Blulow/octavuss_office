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
@onready var book_audio: AudioStreamPlayer2D = $UI/BookAudio
var hovering: bool = false

@onready var paper: TextureRect = $UI/Paper
@onready var paper_label: Label = $UI/Paper/Label
@onready var book2: Control = $UI/Book2
@onready var restart: Strip2D = $UI/Book2/Strips/TextureRect/Strip
@onready var back: Strip2D = $UI/Book2/Strips/TextureRect2/Strip2

@onready var client: Node3D = $World/Client
var session_manager: SessionManager

@onready var dialogues: Node3D = $Game

@export_multiline var opening_text: String = """
Client: Leon Gaylord

Details:
1. The client’s brother was attempting to navigate
out of a dense crowd when he was pushed.
2. Physical contact was indirect or incidental rather
than a targeted, direct assault, resulting in a
fractured arm.
3. Online forum videos show a member of an external
visitor group causing the crowd displacement or
push that led to the injury.
4. More related videos of similar conduct were also
found in the forum.
5. Client is contemplating retaliatory actions.
"""
@onready var page_text: Node3D = $UI/Book/SubViewport/Page

@onready var page_states: Array = [
	{
		"pos": Vector3(0.02, 1.0, -0.145),
		"rot": Vector3(-1.565, 0.0, -0.03),
		"curve": 0.0
	},
	{
		"pos": Vector3(-0.31, 0.9, 0.1),
		"rot": Vector3(-1.46, 0.0, -0.055),
		"curve": 0.1
	},
	{
		"pos": Vector3(-0.8, 0.8, 0.0),
		"rot": Vector3(-1.555, 0.0, -0.01),
		"curve": 0.3
	},
	{
		"pos": Vector3(-3.0, 0.4, 0.2),
		"rot": Vector3(-1.575, 0.0, -0.01),
		"curve": 0.642
	}
]

var page_timer: float = 0.0
var page_interval: float = 1/10

var ending_texts = [
	"Thinking about everything, I guess retaliating might be too big of a move... I do want everyone in **(community name) to be in a better place, maybe we should work together towards that instead. I guess I'd say the proof of the videos might just be an influence after all, not sure why, but it needs more looking and finding. Well then, this might be a good decision, I’ll see what I can do.",
	"After all this, I still don’t understand why I shouldn’t make a move… Maybe the videos are fake, but it’s hard to get our reputation back like this… So, for **(community name), I will do this for us to be in a higher standing. I’ll give it my all.",
	"After everything… maybe the videos are fake, maybe I shouldn’t trust the forum. But I still want to make this move, for **(community name), I need to get our reputation back. So we all can be in a higher standing, and not fall back. Then, I guess I'll do my best.",
	"Everything considered, making a move still speaks out. The videos might be fake, but the reputation we lost might not be able to be regained... I'm doing this for **(community name), so we can be in a better place. I don’t care anymore, I have to do this."
]

func _ready() -> void:
	print("READY paused=", get_tree().paused,
		" time_scale=", Engine.time_scale,
		" game_started=", PlayerData.game_started,
		" process_mode=", process_mode,
		" mouse=", Input.mouse_mode)
	
	session_manager = dialogues.get_node("SessionManager")
	session_manager.session_end.connect(func():
		await client_swing_out()
		session_manager.action_start.emit())
	session_manager.action_finish.connect(func():
		await client_swing_in()
		session_manager.session_start.emit())
	
	PlayerData.game_end.connect(_on_game_end)
	
	start_game.active = true
	settings.active = true
	quit_game.active = true
	
	start_game.onclick.connect(_on_start_game_onclick)
	#settings.onclick.connect(_on_settings_onclick)
	quit_game.onclick.connect(_on_quit_game_onclick)
	restart.onclick.connect(_on_restart_onclick)
	back.onclick.connect(_on_back_onclick)
	start_game.onhover.connect(_on_start_game_onhover)
	settings.onhover.connect(_on_settings_onhover)
	quit_game.onhover.connect(_on_quit_game_onhover)
	start_game.onexit.connect(_on_start_game_onexit)
	settings.onexit.connect(_on_settings_onexit)
	quit_game.onexit.connect(_on_quit_game_onexit)
	
	trans_cam.make_current()
	trans_cam.global_position = start_cam.global_position
	trans_cam.global_rotation = start_cam.global_rotation
	
	paper.visible = false
	book2.visible = false
	paper.global_position.y += 1000
	book2.global_position.y += 1000
	
	book_sprite.visible = false
	
	page_text.set_deferred("text", opening_text)
	page_text.set_deferred("camera_pos", page_states[0].pos)
	page_text.set_deferred("camera_rot", page_states[0].rot)
	page_text.set_deferred("font_size", 7)
	page_text.get_surface_override_material(0).call_deferred("set_shader_parameter", "curve_strength", page_states[0].curve)
	
	if PlayerData.game_started:
		print("A")
		await get_tree().process_frame
		_on_start_game_onclick()
	
	$Music.stream = preload("res://assets/sounds/warmcoldroom.ogg")
	$Music.play()

func _on_start_game_onclick():
	start_game.active = false
	settings.active = false
	quit_game.active = false
	
	$Music.stream = preload("res://assets/sounds/warmcoldroom_2.ogg")
	$Music.play()
	
	#name_stand.visible = false
	PlayerData.game_started = true
	PlayerData.game_start.emit()
	var tween = create_tween()
	start_game_tween(tween)
	await tween.finished
	
	book.visible = false
	title.visible = false
	session_manager.load_next_session(true)

func _on_quit_game_onclick():
	get_tree().quit()

func _on_restart_onclick():
	restart.active = false
	back.active = false
	
	PlayerData.reset()
	PlayerData.game_started = true
	PlayerData.game_start.emit()
	
	await close_end_tween()
	
	session_manager.load_next_session(true)

func _on_back_onclick():
	restart.active = false
	back.active = false
	
	PlayerData.reset()
	
	await close_end_tween(true)
	
	book.visible = true
	title.visible = true
	start_game.reset()
	settings.reset()
	quit_game.reset()
	start_game.active = true
	settings.active = true
	quit_game.active = true
	
	page_text.camera_pos = page_states[0].pos
	page_text.camera_rot = page_states[0].rot
	page_text.get_surface_override_material(0).set_shader_parameter("curve_strength", page_states[0].curve)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(book, "global_position:y", book.global_position.y - 1000, 0.3)
	tween.tween_property(title, "global_position:y", title.global_position.y - 1000, 0.3)

func start_game_tween (tween : Tween):
	client.global_position.x -= 20
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel()
	tween.tween_property(trans_cam, "global_position", player_cam.global_position, 0.3)
	tween.tween_property(trans_cam, "global_rotation", player_cam.global_rotation, 0.3)
	tween.tween_property(book, "global_position:y", book.global_position.y + 1000, 0.3)
	tween.tween_property(title, "global_position:y", title.global_position.y + 1000, 0.3)
	
	tween.set_parallel(false)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(client, "global_position:x", client.global_position.x + 20, 1.0)
	tween.tween_interval(1.0)

func close_end_tween(down: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	if not down:
		tween.tween_property(trans_cam, "global_position", player_cam.global_position, 0.3)
		tween.tween_property(trans_cam, "global_rotation", player_cam.global_rotation, 0.3)
	tween.tween_property(paper, "global_position:y", paper.global_position.y + 1000, 0.3)
	tween.tween_property(book2, "global_position:y", book2.global_position.y + 1000, 0.3)

func _on_game_end(ending: int) -> void:
	PlayerData.game_started = false
	
	$Music.stream = preload("res://assets/sounds/warmcoldroom.ogg")
	$Music.play()
	
	paper.visible = true
	book2.visible = true
	restart.reset()
	back.reset()
	restart.active = true
	back.active = true
	
	paper_label.text = ending_texts[ending]
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(trans_cam, "global_position", start_cam.global_position, 0.3)
	tween.tween_property(trans_cam, "global_rotation", start_cam.global_rotation, 0.3)
	tween.tween_property(paper, "global_position:y", paper.global_position.y - 1000, 0.3)
	tween.tween_property(book2, "global_position:y", book2.global_position.y - 1000, 0.3)

func _process(delta: float) -> void:
	if not book.visible: return
	
	var is_open = book_sprite.animation == "open"
	
	if not book_sprite.visible:
		if not hovering:
			page_text.camera_pos = page_states[0].pos
			page_text.camera_rot = page_states[0].rot
			page_text.get_surface_override_material(0).set_shader_parameter("curve_strength", page_states[0].curve)
	elif book_sprite.frame == 0:
		page_text.camera_pos = page_states[1 if is_open else 3].pos
		page_text.camera_rot = page_states[1 if is_open else 3].rot
		page_text.get_surface_override_material(0).set_shader_parameter("curve_strength", page_states[1 if is_open else 3].curve)
	elif book_sprite.frame == 1:
		page_text.camera_pos = page_states[2].pos
		page_text.camera_rot = page_states[2].rot
		page_text.get_surface_override_material(0).set_shader_parameter("curve_strength", page_states[2].curve)
	elif book_sprite.frame == 2:
		page_text.camera_pos = page_states[3 if is_open else 1].pos
		page_text.camera_rot = page_states[3 if is_open else 1].rot
		page_text.get_surface_override_material(0).set_shader_parameter("curve_strength", page_states[3 if is_open else 1].curve)

func client_swing_in() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(client, "global_position:x", client.global_position.x + 20, 1.0)
	await tween.finished

func client_swing_out() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(client, "global_position:x", client.global_position.x - 20, 0.7)
	await tween.finished

func _on_start_game_onhover():
	hovering = true
	if book_sprite.animation == "open" and book_sprite.playing:
		return
	book_sprite.animation = "open"
	book_sprite.visible = true
	
	await get_tree().create_timer(1/5).timeout
	
	book_audio.stream = preload("res://assets/sounds/sfx/page_open.wav")
	book_audio.play()
	
	book_sprite.play()
	await book_sprite.finished
	book_sprite.visible = false
	
func _on_settings_onhover():
	hovering = true
	if book_sprite.animation == "open" and book_sprite.playing:
		return
	book_sprite.animation = "open"
	book_sprite.visible = true
	
	await get_tree().create_timer(1/5).timeout
	
	book_audio.stream = preload("res://assets/sounds/sfx/page_open.wav")
	book_audio.play()
	
	book_sprite.play()
	await book_sprite.finished
	book_sprite.visible = false
	
func _on_quit_game_onhover():
	hovering = true
	if book_sprite.animation == "open" and book_sprite.playing:
		return
	book_sprite.animation = "open"
	book_sprite.visible = true
	
	await get_tree().create_timer(1/5).timeout
	
	book_audio.stream = preload("res://assets/sounds/sfx/page_open.wav")
	book_audio.play()
	
	book_sprite.play()
	await book_sprite.finished
	book_sprite.visible = false

func _on_start_game_onexit():
	hovering = false
	if book_sprite.animation == "close" and book_sprite.playing:
		return
	book_sprite.animation = "close"
	book_sprite.visible = true
	
	await get_tree().create_timer(1/10).timeout
	
	book_audio.stream = preload("res://assets/sounds/sfx/page_close.wav")
	book_audio.play()
	
	book_sprite.play()
	await book_sprite.finished
	book_sprite.visible = false
	
func _on_settings_onexit():
	hovering = false
	if book_sprite.animation == "close" and book_sprite.playing:
		return
	book_sprite.animation = "close"
	book_sprite.visible = true
	
	await get_tree().create_timer(1/10).timeout
	
	book_audio.stream = preload("res://assets/sounds/sfx/page_close.wav")
	book_audio.play()
	
	book_sprite.play()
	await book_sprite.finished
	book_sprite.visible = false
	
func _on_quit_game_onexit():
	hovering = false
	if book_sprite.animation == "close" and book_sprite.playing:
		return
	book_sprite.animation = "close"
	book_sprite.visible = true
	
	await get_tree().create_timer(1/10).timeout
	
	book_audio.stream = preload("res://assets/sounds/sfx/page_close.wav")
	book_audio.play()
	
	book_sprite.play()
	await book_sprite.finished
	book_sprite.visible = false
