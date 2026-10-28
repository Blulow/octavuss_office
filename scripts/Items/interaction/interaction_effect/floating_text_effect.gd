class_name FloatingTextEffect
extends InteractEffect

@export var target: Node3D
@export var text_format := "$$ -%d"
@export var color := Color(1.0, 0.35, 0.3)
@export var font_size := 64
@export var rise := 0.6
@export var spawn_offset := Vector3(0, 0.3, 0)
@export var duration := 0.9

var _label: Label3D
var _tween: Tween

func _init() -> void:
	trigger = Trigger.SUCCESS   # default only, inspector can override

func _ready() -> void:
	super()
	if target == null:
		target = interactable.get_parent() as Node3D
	assert(target != null, "%s needs a Node3D target" % name)

	_label = Label3D.new()
	_label.font_size = font_size
	_label.pixel_size = 0.005
	_label.outline_size = 16
	_label.outline_modulate = Color.BLACK
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = true
	_label.hide()
	# Parented to the scene, not the item, so it doesn't move when the item does.
	# Deferred because the scene is still setting up its children during _ready().
	get_tree().current_scene.add_child.call_deferred(_label)

func _exit_tree() -> void:
	if _label != null:
		_label.queue_free()

func activate() -> void:
	var item := interactable.get_parent() as Item
	_label.text = text_format % item.price if item != null else text_format

	if _tween:
		_tween.kill()   # restart cleanly if triggered again mid-rise

	var start := target.global_position + spawn_offset
	_label.global_position = start
	_label.modulate = color      # full alpha again
	_label.show()

	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_label, "global_position:y", start.y + rise, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_label, "modulate:a", 0.0, duration)
	_tween.chain().tween_callback(_label.hide)
