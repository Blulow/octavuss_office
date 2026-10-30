# player_data.gd
extends Node

signal money_changed(new_amount: int)
signal fact_added(new_fact: Fact)
signal facts_reset
signal game_start
signal game_end(ending: int)
signal reset_game
signal stat_applied

var money: int = 5
#var deescalationMultiplier: float = 1.0
#var informationMultiplier: float = 1.0

var facts_collected : Array[Fact]

var game_started : bool

var audio_settings: Dictionary = {
	"master": 100,
	"music": 50,
	"sfx": 100
}

class StatData:
	func _init(_value: float = 1, _multiplier: float = 1) -> void:
		value = _value
		multiplier = _multiplier
	
	var value: float
	var multiplier: float

var stats: Dictionary[String, StatData] = {
	"calm": StatData.new(2, 1),
	"fact": StatData.new(2, 1),
	"sp": StatData.new(6, 1),
}

var pending_fact: Fact = Fact.new()
var session_index: int = 0

func _ready() -> void:
	#await get_tree().create_timer(1.0).timeout
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(PlayerData.audio_settings.master / 100.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(PlayerData.audio_settings.music / 100.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(PlayerData.audio_settings.sfx / 100.0))
	
func can_afford(cost: int) -> bool:
	return money >= cost

func spend(cost: int) -> void:
	money -= cost
	money_changed.emit(money)
	
func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)
	
#func boost_deescalation(amount: float) -> void:
	#deescalationMultiplier *= amount
#
#func boost_information(amount: float) -> void:
	#informationMultiplier *= amount

func boost_stat_value(stat_name: String, amount: float) -> void:
	if not stats.has(stat_name):
		push_warning("boost_stat: unknown stat '%s'" % stat_name)
		return
	stats[stat_name].value += amount
	
func boost_stat_multiplier(stat_name: String, amount: float) -> void:
	if not stats.has(stat_name):
		push_warning("boost_stat: unknown stat '%s'" % stat_name)
		return
	stats[stat_name].multiplier += amount

func add_pending_fact() -> void:
	add_fact(pending_fact.id, pending_fact.text, pending_fact.fact_description)

func add_fact(id: String, text: String, description: String) -> void:
	# Avoid duplicates if the player can re-trigger the same discovery
	for f in facts_collected:
		if f.text == description:
			return
	var new_fact := Fact.new(id, text, description)
	facts_collected.append(new_fact)
	fact_added.emit(new_fact)

func apply_stat(id: String, value: float) -> void:
	stats[id].value += value * stats[id].multiplier
	stat_applied.emit()

func get_ending() -> void:
	var _ending: int = -1
	
	if stats.calm.value > 5 and stats.fact.value > 5 and stats.sp.value < 3:
		print("good ending")
		_ending = 0
	elif stats.calm.value > 5 and stats.fact.value <= 5 and stats.sp.value >= 3:
		print("calm ending")
		_ending = 1
	elif stats.calm.value <= 5 and stats.fact.value > 5 and stats.sp.value >= 3:
		print("fact ending")
		_ending = 2
	else:
		print("bad ending")
		_ending = 3
	
	game_end.emit(_ending)

func reset() -> void:
	money = 5
	
	#deescalationMultiplier = 1.0
	#informationMultiplier = 1.0
	
	stats.calm = StatData.new(2, 1)
	stats.fact = StatData.new(2, 1)
	stats.sp = StatData.new(6, 1)
	
	session_index = 0
	
	facts_collected.clear()   # your current reset() doesn't clear facts
	
	money_changed.emit(money)
	facts_reset.emit()
	reset_game.emit()
