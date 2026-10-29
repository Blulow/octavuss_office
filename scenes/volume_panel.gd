extends Control

@onready var music_slider: HSlider = $ScrollContainer/VBoxContainer/PanelContainer/HBoxContainer/HSlider
@onready var sfx_slider: HSlider = $ScrollContainer/VBoxContainer/PanelContainer2/HBoxContainer/HSlider
@onready var master_slider: HSlider = $ScrollContainer/VBoxContainer/PanelContainer3/HBoxContainer/HSlider

func _ready() -> void:
	master_slider.value_changed.connect(_on_master_value_changed)
	music_slider.value_changed.connect(_on_music_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_value_changed)
	
	master_slider.value = PlayerData.audio_settings.master
	music_slider.value = PlayerData.audio_settings.music
	sfx_slider.value = PlayerData.audio_settings.sfx

func _on_close_button_pressed() -> void:
	visible = false

func _on_music_value_changed(value: float) -> void:
	PlayerData.audio_settings.music = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / 100.0))

func _on_sfx_value_changed(value: float) -> void:
	PlayerData.audio_settings.sfx = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))

func _on_master_value_changed(value: float) -> void:
	PlayerData.audio_settings.master = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100.0))
