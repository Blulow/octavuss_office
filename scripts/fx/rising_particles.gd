extends GPUParticles3D
class_name Rising_Particles

## Glowing particles that rise upward and fade to 0 opacity over their lifetime.
## `amount` and `lifetime` already exist on GPUParticles3D, so set those in the
## inspector's normal Particles section.

@export_group("Motion")
@export var direction := Vector3.UP:
	set(value):
		direction = value
		_queue_rebuild()
@export_range(0.0, 180.0, 0.1) var spread := 20.0:
	set(value):
		spread = value
		_queue_rebuild()
@export var velocity_min := 1.0:
	set(value):
		velocity_min = value
		_queue_rebuild()
@export var velocity_max := 2.0:
	set(value):
		velocity_max = value
		_queue_rebuild()
@export var particle_gravity := Vector3.ZERO:
	set(value):
		particle_gravity = value
		_queue_rebuild()

@export_group("Size")
@export var scale_min := 0.5:
	set(value):
		scale_min = value
		_queue_rebuild()
@export var scale_max := 1.0:
	set(value):
		scale_max = value
		_queue_rebuild()
@export var quad_size := Vector2(0.2, 0.2):
	set(value):
		quad_size = value
		_queue_rebuild()

@export_group("Look")
@export var glow_color := Color(0.4, 0.9, 1.0):
	set(value):
		glow_color = value
		_queue_rebuild()
## Multiplies the color above 1.0 so it passes the WorldEnvironment glow threshold.
@export_range(1.0, 10.0, 0.1) var glow_intensity := 2.0:
	set(value):
		glow_intensity = value
		_queue_rebuild()
@export_range(0.0, 1.0, 0.01) var end_opacity := 0.0:
	set(value):
		end_opacity = value
		_queue_rebuild()
@export var particle_texture: Texture2D:
	set(value):
		particle_texture = value
		_queue_rebuild()
@export var additive_blend := true:
	set(value):
		additive_blend = value
		_queue_rebuild()
@export_group("Trigger")
## Time to scale up to peak, and also the time to scale back down
@export var enter_exit_time := 0.4
## Time spent holding at peak scale
@export var hold_time := 1.0
@export var scale_target: Node3D            # the object to scale (use Node2D / Vector2 for 2D)
@export var start_scale := Vector3.ONE
@export var peak_scale := Vector3.ONE * 1.5

var _scale_tween: Tween
var _stop_timer: SceneTreeTimer

## Total length of one play: enter + hold + exit. Particles last this long.
func get_play_duration() -> float:
	return enter_exit_time * 2.0 + hold_time

func play() -> void:
	var duration := get_play_duration()
	emitting = true
	_play_scale_pulse()

	_stop_timer = get_tree().create_timer(duration)
	var this_timer := _stop_timer
	await this_timer.timeout
	# Ignore this timeout if play() was called again in the meantime
	if this_timer == _stop_timer:
		emitting = false

func _play_scale_pulse() -> void:
	if scale_target == null:
		return

	# Kill any tween still running from a previous play() call
	if _scale_tween and _scale_tween.is_valid():
		_scale_tween.kill()

	# Make sure we begin from the start scale
	scale_target.scale = start_scale

	_scale_tween = create_tween()
	# Enter: scale up to peak
	_scale_tween.tween_property(scale_target, "scale", peak_scale, enter_exit_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Hold at peak
	_scale_tween.tween_interval(hold_time)
	# Exit: scale back to start
	_scale_tween.tween_property(scale_target, "scale", start_scale, enter_exit_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)





func _ready() -> void:
	_build()


# Setters fire while the scene is loading, before the node is ready, so only
# rebuild once we're in the tree. This also gives live preview in the editor.
func _queue_rebuild() -> void:
	if is_node_ready():
		_build()


func _build() -> void:
	var mat := ParticleProcessMaterial.new()
	mat.direction = direction
	mat.spread = spread
	mat.initial_velocity_min = velocity_min
	mat.initial_velocity_max = velocity_max
	mat.gravity = particle_gravity
	mat.scale_min = scale_min
	mat.scale_max = scale_max

	# Full opacity at birth, end_opacity at death
	var start_color := Color(
		glow_color.r * glow_intensity,
		glow_color.g * glow_intensity,
		glow_color.b * glow_intensity,
		1.0)
	var end_color := Color(start_color.r, start_color.g, start_color.b, end_opacity)

	var gradient := Gradient.new()
	gradient.set_color(0, start_color)
	gradient.set_color(1, end_color)

	var ramp := GradientTexture1D.new()
	ramp.gradient = gradient
	ramp.use_hdr = true  # Godot 4.3+; needed so values above 1.0 survive
	mat.color_ramp = ramp

	process_material = mat

	var quad := QuadMesh.new()
	quad.size = quad_size

	var draw_mat := StandardMaterial3D.new()
	draw_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	draw_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	draw_mat.blend_mode = (
		BaseMaterial3D.BLEND_MODE_ADD if additive_blend
		else BaseMaterial3D.BLEND_MODE_MIX)
	draw_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	draw_mat.vertex_color_use_as_albedo = true
	draw_mat.albedo_texture = particle_texture
	quad.material = draw_mat

	draw_pass_1 = quad
