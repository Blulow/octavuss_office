class_name UITween
extends RefCounted

enum Direction { LEFT, RIGHT, UP, DOWN, NEAREST_EDGE }

const META_KEY := &"_ui_tween"


## Slides the control in from off-screen and settles it at rest_pos (overshoots).
static func slide_in(
		control: Control,
		rest_pos: Vector2,
		direction: Direction = Direction.DOWN,
		add_rot: bool = true,
		duration: float = 0.6,
		overshoot: float = 1.9,
		tilt_deg: float = 20.0) -> Tween:

	if not is_instance_valid(control):
		return null
	_kill_existing(control)

	var off := _off_screen_pose(control, rest_pos, direction, tilt_deg)
	var start_rot: float = off.rot if add_rot else 0.0

	control.pivot_offset = control.size / 2.0
	control.position = off.pos
	control.rotation = start_rot

	return _run(control, off.pos, rest_pos, start_rot, 0.0, duration, overshoot, false, false)


## Slides the control from where it currently is to off-screen (pulls back first, then exits).
## direction:       side to exit toward. Use the same value as slide_in for an exact reverse.
## hide_when_done:  hides the control afterwards so it can't be clicked while off-screen.
static func slide_out(
		control: Control,
		rest_pos: Vector2,
		direction: Direction = Direction.DOWN,
		add_rot: bool = true,
		duration: float = 0.5,
		overshoot: float = 1.9,
		tilt_deg: float = 20.0,
		hide_when_done: bool = true) -> Tween:

	if not is_instance_valid(control) or not control.visible:
		return null
	_kill_existing(control)

	var off := _off_screen_pose(control, rest_pos, direction, tilt_deg)
	var end_rot: float = off.rot if add_rot else 0.0

	control.pivot_offset = control.size / 2.0

	# Starts from the CURRENT position/rotation, so interrupting a slide_in
	# mid-flight reverses smoothly instead of jumping to rest_pos first.
	return _run(control, control.position, off.pos, control.rotation, end_rot,
			duration, overshoot, true, hide_when_done)


# ---------------------------------------------------------------------------

## Shared animation routine. One 0 -> 1 tween drives both position and rotation.
## ease_in = false -> ease-out-back (overshoots at the end, used for entering)
## ease_in = true  -> ease-in-back  (pulls back at the start, used for exiting)
static func _run(
		control: Control,
		from_pos: Vector2, to_pos: Vector2,
		from_rot: float, to_rot: float,
		duration: float, overshoot: float,
		ease_in: bool, hide_when_done: bool) -> Tween:

	var tween := control.create_tween()
	control.set_meta(META_KEY, tween)

	tween.tween_method(func(t: float) -> void:
		var e := _ease_in_back(t, overshoot) if ease_in else _ease_out_back(t, overshoot)
		control.position = from_pos.lerp(to_pos, e)
		control.rotation = lerpf(from_rot, to_rot, e)
	, 0.0, 1.0, duration)

	tween.finished.connect(func() -> void:
		if is_instance_valid(control):
			control.position = to_pos
			control.rotation = to_rot
			if hide_when_done:
				control.hide())

	return tween


## Computes the off-screen position and tilt for a direction.
## Returns { "pos": Vector2, "rot": float (radians) }.
static func _off_screen_pose(
		control: Control, rest_pos: Vector2, direction: Direction, tilt_deg: float) -> Dictionary:
	var vp_size := control.get_viewport_rect().size
	var dir := _resolve_direction(direction, rest_pos, control.size, vp_size)
	var tilt_sign := -1.0 if (dir.x < 0.0 or dir.y < 0.0) else 1.0
	return {
		"pos": rest_pos + dir * (vp_size + control.size),
		"rot": deg_to_rad(tilt_deg * tilt_sign),
	}


static func _kill_existing(control: Control) -> void:
	if control.has_meta(META_KEY):
		var old: Tween = control.get_meta(META_KEY)
		if old and old.is_valid():
			old.kill()


static func _resolve_direction(
		direction: Direction, rest_pos: Vector2, size: Vector2, vp_size: Vector2) -> Vector2:
	match direction:
		Direction.LEFT:  return Vector2.LEFT
		Direction.RIGHT: return Vector2.RIGHT
		Direction.UP:    return Vector2.UP
		Direction.DOWN:  return Vector2.DOWN

	var gaps := {
		Vector2.LEFT:  rest_pos.x,
		Vector2.RIGHT: vp_size.x - (rest_pos.x + size.x),
		Vector2.UP:    rest_pos.y,
		Vector2.DOWN:  vp_size.y - (rest_pos.y + size.y),
	}
	var best := Vector2.DOWN
	var best_gap := INF
	for d in gaps:
		if gaps[d] < best_gap:
			best_gap = gaps[d]
			best = d
	return best


static func _ease_out_back(t: float, s: float) -> float:
	t = clampf(t, 0.0, 1.0) - 1.0
	return 1.0 + t * t * ((s + 1.0) * t + s)


## Mirror of ease-out-back: dips below 0 first (the wind-up), then accelerates to 1.
static func _ease_in_back(t: float, s: float) -> float:
	t = clampf(t, 0.0, 1.0)
	return t * t * ((s + 1.0) * t - s)
