# boost_deescalation_perk.gd
class_name BoostMultiplierPerk
extends Perk

@export var multiplier: float = 1.25
@export var stat_name: String = "calm"

func apply() -> void:
	print (stat_name + " Multiplier boosted by " + str(multiplier))
	PlayerData.boost_stat_multiplier(stat_name , multiplier)
