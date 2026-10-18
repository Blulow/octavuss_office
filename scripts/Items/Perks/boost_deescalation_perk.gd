# boost_deescalation_perk.gd
class_name BoostDeescalationPerk
extends Perk

@export var multiplier: float = 1.25

func apply() -> void:
	print ("Deescalation boosted by " + str(multiplier))
	PlayerData.boost_deescalation(multiplier)
