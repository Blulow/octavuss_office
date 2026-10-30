extends Node2D

# The in-game notebook. Three tabs (History / Settings / Facts), each with
# pages you flip through with the side buttons.

enum Tab { HISTORY, SETTINGS, FACTS }

const LINES_PER_PAGE := 6
const FLIP_MIDPOINT := 0.3

@onready var flip: AnimatedTextureRect = $UI/FlipOverlay

@onready var prev_button: Button = $UI/PrevButton
@onready var next_button: Button = $UI/NextButton

@onready var history_page: Control = $UI/Content/HistoryPage
@onready var settings_page: Control = $UI/Content/SettingsPage
@onready var facts_page: Control = $UI/Content/FactsPage

@onready var history_label: RichTextLabel = $UI/Content/HistoryPage/HistoryLabel
@onready var facts_label: RichTextLabel = $UI/Content/FactsPage/FactsLabel

@onready var history_tab: Strip2D = $UI/Tabs/Mask1/HistoryTab
@onready var settings_tab: Strip2D = $UI/Tabs/Mask2/SettingsTab
@onready var facts_tab: Strip2D = $UI/Tabs/Mask3/FactsTab

@onready var music_slider: HSlider = $UI/Content/SettingsPage/MusicSlider
@onready var sfx_slider: HSlider = $UI/Content/SettingsPage/SfxSlider
@onready var master_slider: HSlider = $UI/Content/SettingsPage/MasterSlider

var current_tab := Tab.HISTORY
var current_page := 0


func _ready() -> void:
	history_tab.onclick.connect(_on_tab_clicked.bind(Tab.HISTORY))
	settings_tab.onclick.connect(_on_tab_clicked.bind(Tab.SETTINGS))
	facts_tab.onclick.connect(_on_tab_clicked.bind(Tab.FACTS))

	prev_button.pressed.connect(prev_page)
	next_button.pressed.connect(next_page)

	# Volume sliders (Music/SFX/Master all drive the Master bus for now).
	for slider: HSlider in [music_slider, sfx_slider, master_slider]:
		slider.value_changed.connect(_on_volume_changed)
	master_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))

	flip.visible = false
	_refresh()


func _on_tab_clicked(i: int) -> void:
	if i == current_tab:
		return
	current_tab = i
	current_page = 0
	await _flip(true)
	_refresh()


func prev_page() -> void:
	if current_page <= 0:
		return
	current_page -= 1
	await _flip(false)
	_refresh()


func next_page() -> void:
	if current_page >= page_count() - 1:
		return
	current_page += 1
	await _flip(true)
	_refresh()


func page_count() -> int:
	match current_tab:
		Tab.HISTORY:
			return maxi(1, ceili(PlayerData.history.size() / float(LINES_PER_PAGE)))
		Tab.FACTS:
			return maxi(1, ceili(PlayerData.facts_collected.size() / float(LINES_PER_PAGE)))
	return 1


func _flip(forward: bool) -> void:
	flip.animation = "open" if forward else "close"
	flip.visible = true
	flip.playing = true
	# Swap the content at the midpoint so it looks like a real page turn.
	await get_tree().create_timer(FLIP_MIDPOINT).timeout
	_refresh()
	await flip.finished
	flip.visible = false
	flip.playing = false


func _refresh() -> void:
	history_page.visible = current_tab == Tab.HISTORY
	settings_page.visible = current_tab == Tab.SETTINGS
	facts_page.visible = current_tab == Tab.FACTS
	prev_button.visible = current_page > 0
	next_button.visible = current_page < page_count() - 1

	if current_tab == Tab.HISTORY:
		_refresh_history()
	elif current_tab == Tab.FACTS:
		_refresh_facts()


func _refresh_history() -> void:
	var lines: Array = PlayerData.history
	var start: int = current_page * LINES_PER_PAGE
	var end: int = mini(start + LINES_PER_PAGE, lines.size())
	var text := ""
	for i in range(start, end):
		var entry: Dictionary = lines[i]
		text += "[b]%s[/b]: %s\n\n" % [entry.get("name", ""), entry.get("text", "")]
	history_label.text = text


func _refresh_facts() -> void:
	var facts: Array = PlayerData.facts_collected
	var start: int = current_page * LINES_PER_PAGE
	var end: int = mini(start + LINES_PER_PAGE, facts.size())
	var text := ""
	for i in range(start, end):
		text += "- %s\n\n" % facts[i].fact_description
	facts_label.text = text


func _on_volume_changed(value: float) -> void:
	# All three sliders currently control the Master bus; split them into
	# separate Music/SFX buses once those exist in the audio setup.
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
