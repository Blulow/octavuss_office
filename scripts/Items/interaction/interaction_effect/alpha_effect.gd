class_name AlphaEffect
extends InteractEffect

signal finished

@export var target: Node                      # what fades (CanvasItem, Label3D, Sprite3D, or a mesh)
@export_range(0.0, 1.0) var target_alpha := 1.0
@export var from_alpha := -1.0                # -1 = start from the current alpha
@export var duration := 0.4
@export var reveal_node: Node                 # unhidden when the tween finishes (optional)
@export var restore_on_deactivate := true     # state triggers (HOVER/SELECT) fade back

var _original_alpha: float
var _tween: Tween

func _init() -> void:
	trigger = Trigger.SUCCESS   # default only, inspector can override

func _ready() -> void:
	super()
	if target == null:
		target = interactable.get_parent()
	assert(target != null, "%s needs a target" % name)

func activate() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	else:
		_original_alpha = _get_alpha()   # saved right now, same lesson as the shake
	if from_alpha >= 0.0:
		_set_alpha(from_alpha)

	_tween = create_tween()
	_tween.tween_method(_set_alpha, _get_alpha(), target_alpha, duration)
	_tween.tween_callback(_on_done)

func deactivate() -> void:
	if not restore_on_deactivate:
		return
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_alpha, _get_alpha(), _original_alpha, duration)

func _on_done() -> void:
	if reveal_node != null:
		reveal_node.set("visible", true)   # works for both CanvasItem and Node3D
	finished.emit()

# --- alpha access, so one script covers 2D, UI, labels and meshes ---

func _get_alpha() -> float:
	if target is GeometryInstance3D:
		return 1.0 - target.transparency
	return target.modulate.a

func _set_alpha(a: float) -> void:
	if target is GeometryInstance3D:
		target.transparency = 1.0 - a
	else:
		var c: Color = target.modulate
		c.a = a
		target.modulate = c
