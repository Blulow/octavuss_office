# player_data.gd
extends Node

signal money_changed(new_amount: int)
signal fact_added(new_fact: Fact)
signal facts_reset

var money: int = 500
#var deescalationMultiplier: float = 1.0
#var informationMultiplier: float = 1.0

var facts_collected : Array[Fact]

var stats: Dictionary[String, int] = {
	"calm": 2,
	"fact": 2,
	"sp": 6,
}
var multipliers: Array[int] = [1, 1, 1]

func _ready() -> void:
	_seed_facts()

func _seed_facts() -> void:
	add_fact("fact1", "fact1 text")
	add_fact("fact2", "fact2 text")
	add_fact("fact3", "fact3 text")
	add_fact("fact4", "fact4 text")

func can_afford(cost: int) -> bool:
	return money >= cost

func spend(cost: int) -> void:
	money -= cost
	money_changed.emit(money)

#func boost_deescalation(amount: float) -> void:
	#deescalationMultiplier *= amount
#
#func boost_information(amount: float) -> void:
	#informationMultiplier *= amount

func add_fact(id: String, description: String) -> void:
	# Avoid duplicates if the player can re-trigger the same discovery
	for f in facts_collected:
		if f.fact_description == description:
			return
	var new_fact := Fact.new(id, description)
	facts_collected.append(new_fact)
	fact_added.emit(new_fact)

func reset() -> void:
	money = 500
	
	multipliers = [1.0, 1.0, 1.0]
	#deescalationMultiplier = 1.0
	#informationMultiplier = 1.0
	
	stats.calm = 2
	stats.fact = 2
	stats.sp = 6
	
	facts_collected.clear()   # your current reset() doesn't clear facts
	
	money_changed.emit(money)
	facts_reset.emit()
