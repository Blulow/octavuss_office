class_name ItemShowcase
extends Node3D

@export var spawn_point: Marker3D        # where the preview appears from
@export var display_point: Marker3D      # where it ends up
@export var appear_duration := 0.6
@export var overshoot := 0.25
@export var settle_fraction := 0.35
@export var start_scale := 0.1
@export var bob_amplitude := 0.05
@export var bob_period := 1.6
@export var rotate_on_appear := true                         # toggle for testing
@export var lean_degrees := 20.0         # how far it leans toward the travel direction at the peak@export_range(0.0, 1.0) var rotation_overshoot := 0.25       # how far past the final rotation it spins
# drop_distance is gone: nothing animates on deselect anymore
var _previews: Dictionary = {}           # Item -> Node3D (the pool)

@export var faller: FallAndHide

func _ready() -> void:
	assert(spawn_point != null and display_point != null and faller != null, "%s is missing an export" % name)
	for item: Item in get_tree().get_nodes_in_group("items"):
		item.interactable.select_changed.connect(_on_select_changed.bind(item))
		item.purchased.connect(_on_purchased)    # this is the line that triggers the fall


func _get_preview(item: Item) -> RigidBody3D:      # was Node3D
	if not _previews.has(item):
		var p := item.preview_scene.instantiate() as RigidBody3D
		p.set_meta(&"rest_scale", p.scale)
		p.set_meta(&"rest_rotation", p.rotation)
		p.visible = false
		add_child(p)
		_previews[item] = p
	return _previews[item]

func _on_purchased(item: Item) -> void:
	if not _previews.has(item):
		return
	var p: RigidBody3D = _previews[item]
	if not p.visible:
		return
	var old: Tween = p.get_meta(&"tween", null)
	if old and old.is_valid():
		old.kill()          # stop the bob so it doesn't fight the physics
	faller.start(p)

# Hands the bought item's preview to something else to animate.
func claim_preview(item: Item) -> RigidBody3D:
	if not _previews.has(item):
		return null
	var p: RigidBody3D = _previews[item]
	faller.cancel(p)    # refreezes it, and its pending hide timer becomes a no-op
	var old: Tween = p.get_meta(&"tween", null)
	if old and old.is_valid():
		old.kill()
	p.scale = p.get_meta(&"rest_scale")
	p.rotation = p.get_meta(&"rest_rotation")
	p.show()            # FallAndHide hid it after the fall
	return p


func _disappear(item: Item) -> void:
	if not _previews.has(item):
		return
	var p: RigidBody3D = _previews[item]
	if faller.is_falling(p):
		return              # let the fall finish, it hides itself
	var old: Tween = p.get_meta(&"tween", null)
	if old and old.is_valid():
		old.kill()
	p.hide()


func _appear(item: Item) -> void:
	var p := _get_preview(item)
	var rest_scale: Vector3 = p.get_meta(&"rest_scale")
	var rest_rot: Vector3 = p.get_meta(&"rest_rotation")

	var from := spawn_point.global_position
	var target := display_point.global_position
	var dir := (target - from).normalized()
	var peak := from + (target - from) * (1.0 + overshoot)
	var out_t := appear_duration * (1.0 - settle_fraction)
	var settle_t := appear_duration * settle_fraction

	# Always restart from the spawn point, upright and tiny.
	p.global_position = from
	p.scale = rest_scale * start_scale
	p.rotation = rest_rot
	p.visible = true

	var t := _new_tween(p)

	# Out phase: fly past the display point, grow slightly past full size,
	# and lean toward the direction of travel.
	t.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(p, "global_position", peak, out_t)
	t.parallel().tween_property(p, "scale", rest_scale * (1.0 + overshoot * 0.5), out_t)
	if rotate_on_appear:
		t.parallel().tween_property(p, "rotation", _leaned_rotation(rest_rot, dir), out_t)

	# Settle phase: ease back onto the display point, true scale, upright.
	t.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(p, "global_position", target, settle_t)
	t.parallel().tween_property(p, "scale", rest_scale, settle_t)
	if rotate_on_appear:
		t.parallel().tween_property(p, "rotation", rest_rot, settle_t)

	t.tween_callback(_start_bob.bind(p, target.y))
func deg_to_rad_vec(v: Vector3) -> Vector3:
	return Vector3(deg_to_rad(v.x), deg_to_rad(v.y), deg_to_rad(v.z))


func _on_select_changed(is_selected: bool, item: Item) -> void:
	if item.preview_scene == null:
		return
	if is_selected:
		_appear(item)
	else:
		_disappear(item)

# Rotation (in the showcase's local space) of `rest_rot` leaned toward `dir`.
func _leaned_rotation(rest_rot: Vector3, dir: Vector3) -> Vector3:
	var local_dir := global_basis.inverse() * dir
	var axis := Vector3.UP.cross(local_dir)
	if axis.length_squared() < 0.0001:
		return rest_rot                      # moving straight up or down: no sideways lean
	var lean := Basis(axis.normalized(), deg_to_rad(lean_degrees))
	return (lean * Basis.from_euler(rest_rot)).get_euler()


func _start_bob(p: Node3D, base_y: float) -> void:
	var t := _new_tween(p).set_loops()
	t.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(p, "global_position:y", base_y + bob_amplitude, bob_period * 0.5)
	t.tween_property(p, "global_position:y", base_y - bob_amplitude, bob_period * 0.5)



# One tween per preview: starting a new one kills the old one for that preview only,
# so a preview flying out never gets cut off by a different item appearing.
func _new_tween(p: Node3D) -> Tween:
	var old: Tween = p.get_meta(&"tween", null)
	if old and old.is_valid():
		old.kill()
	var t := create_tween()
	p.set_meta(&"tween", t)
	return t
