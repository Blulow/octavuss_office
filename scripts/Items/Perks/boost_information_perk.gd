# boost_information_perk.gd
class_name BoostInformationPerk
extends Perk

@export var multiplier: float = 1.25

func apply() -> void:
	print ("Information boosted by " + str(multiplier))
	PlayerData.boost_information(multiplier)
