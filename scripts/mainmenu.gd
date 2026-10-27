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
var hovering: bool = false

@onready var paper: TextureRect = $UI/Paper
@onready var book2: Control = $UI/Book2
@onready var restart: Strip2D = $UI/Book2/Strips/TextureRect/Strip
@onready var back: Strip2D = $UI/Book2/Strips/TextureRect2/Strip2

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

# 0
# pos: (0.02, 1.0, -0.145)
# rot: (1.565, 0.0, -0.03)
# curve: 0.0
# 1
# pos: (-0.31, 0.9, 0.1)
# rot: (-1.46, 0.0, -0.055)
# curve: 0.1
# 2
# pos: (-0.8, 0.8, 0.0)
# rot: (-1.555, 0.0, -0.01)
# curve: 0.3
# 3
# pos: (-3.0, 0.4, 0.2)
# rot: (-1.575, 0.0, -0.01)
# curve: 0.642

var page_timer: float = 0.0
var page_interval: float = 1/10

func _ready() -> void:
	PlayerData.game_end.connect(_on_game_end)
	
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
	
	paper.visible = false
	book2.visible = false
	
	book_sprite.visible = false
	
	page_text.set_deferred("text", opening_text)
	page_text.set_deferred("camera_pos", page_states[0].pos)
	page_text.set_deferred("camera_rot", page_states[0].rot)
	page_text.set_deferred("font_size", 13)
	page_text.get_surface_override_material(0).call_deferred("set_shader_parameter", "curve_strength", page_states[0].curve)
	
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

func _on_game_end() -> void:
	paper.global_position.y += 1000
	book2.global_position.y += 1000
	paper.visible = true
	book2.visible = true
	
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

func _on_start_game_onhover():
	hovering = true
	if book_sprite.animation == "open" and book_sprite.playing:
		return
	book_sprite.animation = "open"
	book_sprite.visible = true
	await get_tree().create_timer(1/5).timeout
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
	book_sprite.play()
	await book_sprite.finished
	book_sprite.visible = false
