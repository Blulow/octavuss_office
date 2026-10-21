extends Control
class_name Strip2D

signal onclick
signal onhover
signal onexit

@export var label: String:
	set(value):
		$Label.text = value

@export var mask: Control
@export var parent: Control

var start_x: float
var end_x: float
@export var dist: float = 50

var tween

func _ready() -> void:
	start_x = global_position.x
	end_x = global_position.x - dist

func _on_mouse_entered() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "global_position:x", end_x, 0.1)
	tween.set_ease(Tween.EASE_OUT)
	
	
	if !mask or !parent:
		printerr("no mask no parent")
		return
	
	var p = global_position
	if get_parent() == mask: mask.remove_child(self)
	if get_parent() != parent: parent.call_deferred("add_child", self, true)
	set_deferred("global_position", p)
	
	onhover.emit()
#
func _on_mouse_exited() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "global_position:x", start_x, 0.1)
	tween.set_ease(Tween.EASE_OUT)
	
	if !mask or !parent:
		printerr("no mask no parent")
		return
		
	var p = global_position
	if get_parent() == parent: parent.remove_child(self)
	if get_parent() != mask: mask.call_deferred("add_child", self, true)
	set_deferred("global_position", p)
	
	onexit.emit()
	

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			onclick.emit()
