# boost_information_perk.gd
class_name BoostValuePerk
extends Perk

@export var amount: float = 1.0
@export var stat_name: String = "calm"

func apply() -> void:
	print (stat_name + " value boosted by " + str(amount))
	PlayerData.boost_stat_value(stat_name ,amount)
