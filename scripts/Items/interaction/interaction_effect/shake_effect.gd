class_name ShakeEffect
extends InteractEffect

@export var target: Node3D
@export var strength := 0.03
@export var duration := 0.3


func _ready() -> void:
	super()
	if target == null:
		target = interactable.get_parent() as Node3D
	assert(target != null, "%s needs a Node3D target" % name)

func activate() -> void:
	Shake.run(target, strength, duration)
