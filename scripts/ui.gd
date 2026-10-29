extends CanvasLayer

@onready var notebook_button: AnimatedButton = $NotebookButton
@onready var money: Control = $Money
@onready var money_label: Label = $Money/Label
@onready var pause: AnimatedButton = $Pause

@onready var settings_wiring: Node = $SettingsPanelWiring

func _ready() -> void:
	money_label.text = str(PlayerData.money)
	PlayerData.money_changed.connect(func(amount):
		money_label.text = amount)
	
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
		tween.tween_property(pause, "modulate:a", 1, 0.3))
	
	PlayerData.game_end.connect(func(ending):
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(notebook_button, "modulate:a", 0, 0.3)
		tween.tween_property(money, "modulate:a", 0, 0.3)
		tween.tween_property(pause, "modulate:a", 0, 0.3)
		await tween.finished
		notebook_button.visible = false
		money.visible = false
		pause.visible = false)
