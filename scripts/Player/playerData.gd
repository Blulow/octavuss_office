# player_data.gd
extends Node

signal money_changed(new_amount: int)

var money: int = 500
var deescalationMultiplier: float = 1.0
var informationMultiplier: float = 1.0

func can_afford(cost: int) -> bool:
	return money >= cost

func spend(cost: int) -> void:
	money -= cost
	money_changed.emit(money)

func boost_deescalation(amount: float) -> void:
	deescalationMultiplier *= amount

func boost_information(amount: float) -> void:
	informationMultiplier *= amount

# Autoloads survive scene changes, so you need a manual reset
func reset() -> void:
	money = 500
	deescalationMultiplier = 1.0
	informationMultiplier = 1.0
	money_changed.emit(money)
