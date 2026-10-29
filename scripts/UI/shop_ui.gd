class_name ShopUI
extends Control


var current_item: Item

@export var name_label: Label
@export var feedback_label: Label
#@export var buy_button: Button
@export var buy_button: StaticBody3D
@export var button_text3d : Label3D
@export var item_price: Label
@export var item_description_label : Label3D
@export var money_label : Label
var item_bought : bool = false
var items: Array[Item]
var bought_item: Item

signal bought

func _on_enter_shop() -> void:
	item_bought = false
	reset_item_selection()

func _ready() -> void:
	PlayerData.reset_game.connect(_on_reset_game)
	
	money_label.text = "Money: " + str(PlayerData.money)
	hide()
	#buy_button.pressed.connect(_on_buy_pressed)
	buy_button.input_event.connect(_buy_pressed)
	for item: Item in get_tree().get_nodes_in_group("items"):
		item.selected.connect(_on_item_selected)
		item.purchased.connect(_on_item_purchased)
		items.append(item)

func reset_item_selection() -> void:
	if current_item != null:
		current_item.set_selected(false)
		current_item = null
	_update_buy_button(current_item)

func _on_reset_game() -> void:
	reset_item_selection()
	
	for item: Item in items:
		item.is_purchased = false
		if item.get_node("Effects/AlphaEffect") is AlphaEffect:
			item.get_node("Effects/AlphaEffect").deactivate()

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
	bought_item = item          # new
	feedback_label.text = "Item purchased!"
	money_label.text = "Money: " + str(PlayerData.money)
	item_bought = true
	_update_buy_button(item)

	# wait 1 second, then fire the event (true = timer keeps running even if the tree is paused)
	await get_tree().create_timer(1.5, true).timeout
	bought.emit()
	


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_close()

func _on_buy_pressed() -> void:
	if current_item == null:
		return
	if item_bought:
		_shake_button(true)
		return
	if not current_item.on_buy():
		feedback_label.text = "Not enough money!"
		#_shake_button()
		_shake_button(true)

func _shake_button(use_parent: bool = false) -> void:
	if !use_parent:
		Shake.run(buy_button, 8.0)
	else:
		Shake.run(buy_button.get_parent(), 0.05)
	

func _buy_pressed(_cam: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_buy_pressed()

func _update_buy_button(item: Item) -> void:
	#buy_button.disabled = item.is_purchased
	#buy_button.text = "Purchased" if item.is_purchased else "Buy"
	if item == null:
		button_text3d.text = ""
	elif item.is_purchased:
		button_text3d.text = "Purchased"
	elif item_bought:
		button_text3d.text = "Already Bought an Item"
	else:
		button_text3d.text = "Buy"
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(buy_button, "scale", buy_button.scale + Vector3(0.1, 0.1, 0.1), 0.1)
		tween.tween_property(buy_button, "scale", buy_button.scale, 0.1)
