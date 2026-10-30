class_name Item
extends Node3D

signal selected(item: Item)
signal purchased(item: Item)

@export var interactable: Interactable
@export var item_name: String
@export var price: int = 100
@export_multiline() var item_description: String
@export var perks : Array[Perk]
@export var preview_scene: PackedScene   # the physical 3D model for this sticky note
var is_purchased: bool = false

@export var label3d: Label3D

func _ready() -> void:
	add_to_group("items")
	interactable.activated.connect(func(): selected.emit(self))
	
	label3d.text = "$" + str(price)

func set_selected(value: bool) -> void:
	interactable.set_selected(value)

func on_buy() -> bool:
	if is_purchased:
		return false
	if not PlayerData.can_afford(price):
		interactable.fail()
		return false

	PlayerData.spend(price)
	for perk in perks:
		perk.apply()

	is_purchased = true
	interactable.succeed()
	purchased.emit(self)
	return true
