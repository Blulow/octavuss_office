class_name ShopUI
extends Control

@export var player: PlayerData

var current_item: Item

@export var name_label: Label
@export var feedback_label: Label
@export var buy_button: Button
@export var item_price: Label
@export var item_description_label : Label

func _ready() -> void:
	hide()
	buy_button.pressed.connect(_on_buy_pressed)
	for item: Item in get_tree().get_nodes_in_group("items"):
		item.selected.connect(_on_item_selected)
		item.purchased.connect(_on_item_purchased)

func _on_item_selected(item: Item) -> void:
	current_item = item
	name_label.text = item.item_name
	item_description_label.text = item.item_description
	item_price.text = "$$ " + str(item.price)
	feedback_label.text = "Already purchased" if item.is_purchased else ""
	_update_buy_button(item)
	show()

func _on_buy_pressed() -> void:
	if current_item == null:
		return
	if not current_item.on_buy():
		feedback_label.text = "Not enough money!"

func _on_item_purchased(item: Item) -> void:
	if item != current_item:
		return
	feedback_label.text = "Item purchased!"
	_update_buy_button(item)

	await get_tree().create_timer(1.5).timeout
	if current_item == item:
		hide()

func _update_buy_button(item: Item) -> void:
	buy_button.disabled = item.is_purchased
	buy_button.text = "Purchased" if item.is_purchased else "Buy"
