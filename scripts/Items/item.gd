class_name Item
extends CSGBox3D

signal selected(item: Item)
signal purchased(item: Item)

@export var item_name: String
@export var price: int = 100
@export var item_description: String

var is_purchased: bool = false

func _ready() -> void:
	add_to_group("items")
	$StaticBody3D.input_event.connect(_on_input_event)

func _on_input_event(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		selected.emit(self)

# item.gd
func on_buy() -> bool:
	if is_purchased or not PlayerData.can_afford(price):
		return false

	PlayerData.spend(price)
	for child in get_children():
		if child is Perk:
			child.apply()

	is_purchased = true
	print("Bought ", item_name)
	purchased.emit(self)
	return true
