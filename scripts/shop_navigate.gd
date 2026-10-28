extends Node

@export var choice_ui: ChoiceUIManager
@export var destination_node: Node3D
@export var move_time : float = 0.5
@export var rot_time : float = 1
@export var rotate_deg: Vector3 = Vector3(0, -90, 0)
@export var btn : Button
@export var shop: ShopUI
@export var session: SessionManager
@export_group("Follower")
@export var follower: Node3D
@export var follower_start: Node3D
@export var follower_destination: Node3D
@export var delivery: ItemDelivery

var _tween: Tween

# Saved state so we can reverse
var _moved_obj: Node3D
var _origin_position: Vector3
var _origin_rotation: Vector3
var _follower_origin: Vector3
var _has_moved: bool = false

func _ready() -> void:
	btn.pressed.connect(_on_pressed)
	if shop and shop.has_signal("bought"):
		shop.bought.connect(reverse_move)

func _on_pressed() -> void:
	get_tree().paused = false
	choice_ui.hide_ui()
	shop._on_enter_shop()
	rotate_then_move(rotate_deg, destination_node, rot_time, move_time)

func rotate_then_move(
		rotation_offset_degrees: Vector3,
		destination: Node3D,
		rotate_time: float = 1.0,
		moving_time: float = 1.0,
		obj: Node3D = null
) -> void:
	if obj == null:
		obj = get_viewport().get_camera_3d()

	if obj == null or destination == null:
		push_warning("rotate_then_move: missing target object or destination")
		return

	if _tween and _tween.is_running():
		_tween.kill()

	_reset_follower_to_start()

	# Save where everything began, but only if we're not mid-reversed-state
	if not _has_moved:
		_moved_obj = obj
		_origin_position = obj.global_position
		_origin_rotation = obj.rotation_degrees
		if follower:
			_follower_origin = follower.global_position
	_has_moved = true

	var end_rotation: Vector3 = obj.rotation_degrees + rotation_offset_degrees

	_tween = get_tree().create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)

	_tween.tween_property(obj, "rotation_degrees", end_rotation, rotate_time)
	_tween.tween_property(obj, "global_position", destination.global_position, moving_time)

	if follower and follower_destination:
		_tween.parallel().tween_property(
			follower, "global_position", follower_destination.global_position, moving_time
		)

func reverse_move() -> void:
	if not _has_moved or not is_instance_valid(_moved_obj):
		return

	if _tween and _tween.is_running():
		_tween.kill()

	_tween = get_tree().create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)

	# Reverse order: move back first (follower in sync), then rotate back
	_tween.tween_property(_moved_obj, "global_position", _origin_position, move_time)
	if follower:
		_tween.parallel().tween_property(follower, "global_position", _follower_origin, move_time)
	_tween.tween_property(_moved_obj, "rotation_degrees", _origin_rotation, rot_time)

	_tween.finished.connect(func(): _has_moved = false)
	
	await _tween.finished
	_has_moved = false
	
	if shop.bought_item != null and delivery != null:
		await delivery.play(shop.bought_item)    # new
	
	await get_tree().create_timer(1, true).timeout  
	session.load_next_session()
	

func _reset_follower_to_start() -> void:
	if follower == null or follower_start == null:
		return
	if not follower.global_position.is_equal_approx(follower_start.global_position):
		follower.global_position = follower_start.global_position
