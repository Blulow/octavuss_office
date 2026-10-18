# player.gd
class_name Player
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
	print ("Money: " + str(money))

	

func boost_deescalation(amount: float) -> void:
	print ("Information boosted by " + str(amount))
	deescalationMultiplier *= amount
	print ("Information is now at " + str (informationMultiplier))


func boost_information(amount: float) -> void:
	print ("Information boosted by " + str(amount))
	informationMultiplier *= amount
	print ("Information is now at " + str (informationMultiplier))
