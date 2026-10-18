# boost_deescalation_perk.gd
class_name BoostDeescalationPerk
extends Perk

@export var multiplier: float = 1.25

func apply(player: Player) -> void:
	print ("Deescalation boosted by " + str(multiplier))
	player.boost_deescalation(multiplier)
