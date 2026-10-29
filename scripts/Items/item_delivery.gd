class_name ItemDelivery
extends Node

@export var showcase: ItemShowcase
@export var start_point: Marker3D
@export var end_point: Marker3D
@export var arc_height := 1.5
@export var travel_time := 0.8
@export var rise_distance := 1.0
@export var rise_time := 0.6
@export var fade_time := 1.0
@export var fade_delay := 0.1
@export var particles: Rising_Particles
@export_group("Physics")
## true = launch with a RigidBody3D, false = tweened arc
@export var use_rigidbody := false
## Max random tumble speed (rad/s) applied to the item in flight
@export var spin := 3.0
## Layers the item collides with in flight. 0 = flies freely (exact arc).
## Any collision will knock it off course, and it snaps to the end point on arrival.
@export_flags_3d_physics var collision_mask := 0
@export var launch_speed := 0.0

func play(item: Item) -> void:
	if item == null:
		return
	var p := showcase.claim_preview(item)
	if p == null:
		return

	var meshes: Array[GeometryInstance3D] = []
	for n in p.find_children("*", "GeometryInstance3D", true, false):
		meshes.append(n)
	_set_fade(0.0, meshes)

	var a := start_point.global_position
	var b := end_point.global_position
	p.global_position = a

	if use_rigidbody:
		await _deliver_physics(p, meshes, a, b)
	else:
		await _deliver_tween(p, meshes, a, b)

	p.hide()
	_set_fade(0.0, meshes)   # reset so the preview looks normal next time it's selected

# --- Tween version (original) ---------------------------------------------

func _deliver_tween(p: Node3D, meshes: Array[GeometryInstance3D], a: Vector3, b: Vector3) -> void:
	var t := create_tween()
	t.tween_method(_arc.bind(p, a, b), 0.0, 1.0, travel_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(_on_arrive)   # fires on arrival, before the rise starts
	_queue_rise_and_fade(t, p, meshes, b)
	await t.finished

# --- RigidBody version -----------------------------------------------------

func _on_arrive() -> void:
	if particles:
		particles.play()

func _deliver_physics(p: Node3D, meshes: Array[GeometryInstance3D], a: Vector3, b: Vector3) -> void:
	# Remember where the preview lives so we can put it back afterwards
	var old_parent := p.get_parent()
	var old_index := p.get_index()
	var old_local := p.transform

	# Build a temporary body at the preview's pose
	var body := RigidBody3D.new()
	body.collision_layer = 0
	body.collision_mask = collision_mask
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.1
	shape.shape = sphere
	body.add_child(shape)
	add_child(body)
	body.global_transform = Transform3D(p.global_basis, a)
	p.reparent(body, true)   # keeps its global transform, so it now sits at the body's origin

	# Flight time: from speed if set, otherwise from travel_time
	var flight_time := travel_time
	if launch_speed > 0.0:
		flight_time = maxf(a.distance_to(b) / launch_speed, 0.05)

	# Gravity chosen so the arc peaks arc_height above the straight line
	var default_g: float = ProjectSettings.get_setting("physics/3d/default_gravity")
	var g := 8.0 * arc_height / (flight_time * flight_time)
	body.gravity_scale = g / default_g

	# Launch velocity that lands exactly on b after flight_time
	body.linear_velocity = (b - a) / flight_time + Vector3.UP * (0.5 * g * flight_time)
	body.angular_velocity = Vector3(
		randf_range(-spin, spin), randf_range(-spin, spin), randf_range(-spin, spin))

	await get_tree().create_timer(flight_time, true, true).timeout   # physics-synced timer

	# Arrival: kill the physics and snap to the exact end point
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO
	body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	body.freeze = true
	body.global_position = b
	
	_on_arrive()

	var t := create_tween()
	_queue_rise_and_fade(t, body, meshes, b)
	await t.finished

	# Hand the preview back to where it came from, then drop the body
	if is_instance_valid(old_parent):
		p.reparent(old_parent, false)
		old_parent.move_child(p, mini(old_index, old_parent.get_child_count() - 1))
		p.transform = old_local
	body.queue_free()

func _queue_rise_and_fade(t: Tween, mover: Node3D, meshes: Array[GeometryInstance3D], b: Vector3) -> void:
	t.tween_property(mover, "global_position:y", b.y + rise_distance, rise_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.parallel().tween_method(_set_fade.bind(meshes), 0.0, 1.0, fade_time) \
		.set_delay(fade_delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# k goes 0 -> 1. The sine-shaped bump (4k(1-k)) peaks at 1 halfway through.
func _arc(k: float, p: Node3D, a: Vector3, b: Vector3) -> void:
	p.global_position = a.lerp(b, k) + Vector3.UP * arc_height * 4.0 * k * (1.0 - k)

func _set_fade(amount: float, meshes: Array[GeometryInstance3D]) -> void:
	for m in meshes:
		m.transparency = amount
