class_name Shake

# Static: call it as Shake.run(node, strength) from anywhere, no node needed in the scene.
# node: what to shake (Node3D or Control). strength: max sideways distance.
# duration: total shake time in seconds. shakes: number of back-and-forth swings.
static func run(node: Node, strength: float, duration := 0.3, shakes := 5) -> Tween:
	# If a shake is still running, stop it and put the node back first,
	# so the new rest position is never a half-shaken one.

	# Look up the tween from the previous shake, stored on the node itself.
	# get_meta(name, default) returns null if no shake has ever run on this node.
	var old: Tween = node.get_meta(&"_shake_tween", null)
	# Only interrupt if that tween exists, hasn't been freed, and is still playing.
	if old and old.is_valid() and old.is_running():
		# Stop the old shake immediately.
		old.kill()
		# Snap the node back to the rest position saved when that shake began.
		node.position.x = node.get_meta(&"_shake_rest")

	# Read the node's current local x. This is the "home" the shake returns to.
	# Done after the cleanup above, so it can't be a mid-shake value.
	var rest_x: float = node.position.x   # saved right now, before moving anything
	# Store it on the node so a later interrupted shake can restore it.
	node.set_meta(&"_shake_rest", rest_x)

	# Create a tween owned by the node (it is freed if the node is freed).
	var t := node.create_tween()
	# Store it on the node so the next call can find and kill it.
	node.set_meta(&"_shake_tween", t)
	# Split the total duration evenly: one step per swing, plus one for returning home.
	var step := duration / (shakes + 1)
	# One iteration per swing.
	for i in shakes:
		# Goes from 1.0 down toward 0, so each swing is smaller than the last.
		var falloff := 1.0 - float(i) / shakes
		# Alternates right (+1), left (-1), right, left...
		var dir := 1.0 if i % 2 == 0 else -1.0
		# Queue a move to rest_x offset by direction * strength * falloff.
		# Tweens run in the order they are added, one after another.
		t.tween_property(node, "position:x", rest_x + dir * strength * falloff, step)
	# Final step: slide back to the exact rest position.
	t.tween_property(node, "position:x", rest_x, step)
	# Return the tween so the caller can await it or kill it if needed.
	return t
