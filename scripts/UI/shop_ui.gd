class_name ShopUI
extends Control


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
	if current_item != null and current_item != item:
		current_item.set_selected(false)
	current_item = item
	item.set_selected(true)

	name_label.text = item.item_name
	item_description_label.text = item.item_description
	item_price.text = "$$ " + str(item.price)
	feedback_label.text = "Already purchased" if item.is_purchased else ""
	_update_buy_button(item)
	show()

func _close() -> void:
	if current_item != null:
		current_item.set_selected(false)
	current_item = null
	hide()

func _on_item_purchased(item: Item) -> void:
	if item != current_item:
		return
	feedback_label.text = "Item purchased!"
	_update_buy_button(item)


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_close()

func _on_buy_pressed() -> void:
	if current_item == null:
		return
	if not current_item.on_buy():
		feedback_label.text = "Not enough money!"
		_shake_button()

func _shake_button() -> void:
	Shake.run(buy_button, 8.0)
	
	
func _update_buy_button(item: Item) -> void:
	buy_button.disabled = item.is_purchased
	buy_button.text = "Purchased" if item.is_purchased else "Buy"
