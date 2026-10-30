extends CanvasLayer

@onready var notebook_button: AnimatedButton = $NotebookButton
@onready var money: Control = $Money
@onready var money_label: Label = $Money/Label
@onready var pause: AnimatedButton = $Pause
@onready var session_label: Label = $SessionLabel

@onready var settings_wiring: Node = $SettingsPanelWiring

@export var session_manager: SessionManager

func _ready() -> void:
	session_label.modulate.a = 0
	money_label.text = str(PlayerData.money)
	PlayerData.money_changed.connect(func(amount):
		money_label.text = str(amount))
	
	pause.pressed.connect(settings_wiring._on_button_pressed)
	
	notebook_button.visible = false
	money.visible = false
	pause.visible = false
	notebook_button.modulate.a = 0
	money.modulate.a = 0
	pause.modulate.a = 0
	
	PlayerData.game_start.connect(func():
		notebook_button.visible = true
		money.visible = true
		pause.visible = true
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(notebook_button, "modulate:a", 1, 0.3)
		tween.tween_property(money, "modulate:a", 1, 0.3)
		tween.tween_property(pause, "modulate:a", 1, 0.3)
		
		#session_label.modulate.a = 0
		#session_label.text = "SESSION: " + str(PlayerData.session_index + 1)
		#var tween2 = create_tween()
		#tween2.tween_property(session_label, "modulate:a", 0.5, 1.0)
		#tween2.tween_interval(1.0)
		#tween2.tween_property(session_label, "modulate:a", 0.0, 1.0)
	)
	
	PlayerData.game_end.connect(func(ending):
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(notebook_button, "modulate:a", 0, 0.3)
		tween.tween_property(money, "modulate:a", 0, 0.3)
		tween.tween_property(pause, "modulate:a", 0, 0.3)
		await tween.finished
		notebook_button.visible = false
		money.visible = false
		pause.visible = false
		)
	
	#session_manager.session_start.connect(func():
		#session_label.modulate.a = 0
		#session_label.text = "SESSION: " + str(PlayerData.session_index + 1)
		#var tween = create_tween()
		#tween.tween_property(session_label, "modulate:a", 0.5, 1.0)
		#tween.tween_interval(1.0)
		#tween.tween_property(session_label, "modulate:a", 0.0, 1.0)
		#)
