class_name SelectIdleEffect
extends InteractEffect

@export var mover: SelectToDisplayEffect
@export var target: Node3D
@export var amplitude := 0.05
@export var period := 1.6
@export var spin_speed := 0.0   # radians/sec, try TAU * 0.25 to test constant rotation

var _tween: Tween
var _spinning := false

func _ready() -> void:
	super()
	trigger = Trigger.SELECT
	if target == null:
		target = interactable.get_parent() as Node3D
	assert(mover != null, "%s needs a mover" % name)
	mover.arrived.connect(_start_idle)

# Selecting alone doesn't start the idle. Arriving does (see _start_idle).
func activate() -> void: pass

func deactivate() -> void:
	_spinning = false
	if _tween: _tween.kill()

func _start_idle() -> void:
	var base_y := target.position.y
	_tween = create_tween().set_loops()
	_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(target, "position:y", base_y + amplitude, period * 0.5)
	_tween.tween_property(target, "position:y", base_y - amplitude, period * 0.5)
	_spinning = spin_speed != 0.0
