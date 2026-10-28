class_name FallAndHide
extends Node

signal finished(body: RigidBody3D)

@export var pop_x := Vector2(1.0, 2.5)      # sideways
@export var pop_y := Vector2(2.5, 4.0)      # upward
@export var pop_z := Vector2(-3.0, -5.0)      # forward (kept above pop_x so forward > sideways)
@export var tumble := 6.0            # max random spin speed
@export var lifetime := 1.5          # seconds before it hides
@export var speed := 1.6   # 1.0 = current feel, higher = faster arc, same height
var _active: Dictionary = {}         # RigidBody3D -> true

func is_falling(body: RigidBody3D) -> bool:
	return _active.has(body)

func start(body: RigidBody3D) -> void:
	_active[body] = true
	body.freeze = false
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO
	body.gravity_scale = speed * speed       # time shrinks by 1/speed, so gravity grows by speed²

	var cam := get_viewport().get_camera_3d()
	var right := cam.global_basis.x if cam else Vector3.RIGHT
	var forward := -cam.global_basis.z if cam else Vector3.FORWARD
	forward.y = 0.0                          # keep forward push horizontal
	forward = forward.normalized()

	var side := 1.0 if randf() < 0.5 else -1.0
	var v := right * side * randf_range(pop_x.x, pop_x.y)
	v += forward * randf_range(pop_z.x, pop_z.y)
	v.y = randf_range(pop_y.x, pop_y.y)

	body.apply_central_impulse(v * speed * body.mass)
	body.apply_torque_impulse(Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * tumble * speed * body.mass)

	get_tree().create_timer(lifetime / speed).timeout.connect(_finish.bind(body))
	
func cancel(body: RigidBody3D) -> void:
	_active.erase(body)
	body.freeze = true

func _finish(body: RigidBody3D) -> void:
	if not _active.has(body):
		return                   # cancelled or already reselected
	_active.erase(body)
	body.hide()
	body.freeze = true
	finished.emit(body)
