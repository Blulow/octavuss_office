# boost_information_perk.gd
class_name BoostInformationPerk
extends Perk

@export var multiplier: float = 1.25

func apply(player: Player) -> void:
	player.boost_information(multiplier)
