class_name SelectIdleEffect
extends InteractEffect

@export var mover: TransitionEffect   # optional: if set, idle waits for it to arrive
@export var target: Node3D
@export var amplitude := 0.05
@export var period := 1.6
@export var spin_speed := 0.0   # radians/sec, try TAU * 0.25 to test constant rotation

var _tween: Tween
var _spinning := false

func _init() -> void:
	trigger = Trigger.SELECT   # default only, inspector can override

func _ready() -> void:
	super()
	set_process(false)   # only runs while spinning
	if target == null:
		target = interactable.get_parent() as Node3D
	assert(target != null, "%s needs a Node3D target" % name)
	if mover != null:
		mover.arrived.connect(_start_idle)

func activate() -> void:
	# With a mover, wait for it to arrive. Without one, start straight away.
	if mover == null:
		_start_idle()

var _base_y: float
var _base_rot_y: float

func _start_idle() -> void:
	_stop_idle(false)   # kill any old idle without animating back
	_base_y = target.position.y
	_base_rot_y = target.rotation.y
	_tween = create_tween().set_loops()
	_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(target, "position:y", _base_y + amplitude, period * 0.5)
	_tween.tween_property(target, "position:y", _base_y - amplitude, period * 0.5)
	_spinning = spin_speed != 0.0
	set_process(_spinning)

func deactivate() -> void:
	_stop_idle(true)

func _stop_idle(restore: bool) -> void:
	var was_idling := _tween != null
	_spinning = false
	set_process(false)
	if _tween:
		_tween.kill()
		_tween = null
	if restore and was_idling:
		var t := create_tween().set_parallel(true)
		t.tween_property(target, "rotation:y", _base_rot_y, 0.2)
		# With a mover, it tweens position home itself, so only restore height without one.
		if mover == null:
			t.tween_property(target, "position:y", _base_y, 0.2)

func _process(delta: float) -> void:
	if _spinning:
		target.rotate_y(spin_speed * delta)
