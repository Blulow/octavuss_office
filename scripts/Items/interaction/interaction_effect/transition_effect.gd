class_name TransitionEffect
extends InteractEffect

signal arrived     # reached the "away" value
signal returned    # back at the rest value

@export var target: Node3D
@export var duration := 0.5
@export var trans: Tween.TransitionType = Tween.TRANS_CUBIC          # going away
@export var return_trans: Tween.TransitionType = Tween.TRANS_CUBIC   # coming back
var _rest: Variant          # value to return to
var _has_rest := false      # true from the moment we leave rest until we're back
var _tween: Tween
@export_range(0.0, 1.0) var overshoot := 0.0        # 0.25 = go 25% past the target, then settle
@export_range(0.1, 0.9) var settle_fraction := 0.35 # share of `duration` spent settling back

func _init() -> void:
	trigger = Trigger.SELECT   # default only, inspector can override

func _ready() -> void:
	super()
	if target == null:
		target = interactable.get_parent() as Node3D
	assert(target != null, "%s needs a Node3D target" % name)

func activate() -> void:
	if not _has_rest:
		_rest = target.get(_property())
		_has_rest = true

	var away: Variant = _away_value()
	var t: Tween
	if overshoot > 0.0:
		# Peak is measured from rest through the target, then extended by `overshoot`.
		var peak: Variant = _rest + (away - _rest) * (1.0 + overshoot)
		var out_time := duration * (1.0 - settle_fraction)
		t = _go(peak, trans, Tween.EASE_OUT, out_time)
		t.tween_property(target, _property(), away, duration * settle_fraction) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		t = _go(away, trans, Tween.EASE_OUT, duration)
	t.tween_callback(arrived.emit)

func deactivate() -> void:
	if not _has_rest:
		return
	if not _should_return():
		if _tween: _tween.kill()
		_has_rest = false
		return
	_go(_rest, return_trans, Tween.EASE_IN_OUT, duration).tween_callback(_on_returned)

func _go(value: Variant, trans_type: Tween.TransitionType, easing: Tween.EaseType, time: float) -> Tween:
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.tween_property(target, _property(), value, time) \
		.set_trans(trans_type).set_ease(easing)
	return _tween

	
func _on_returned() -> void:
	_has_rest = false
	returned.emit()


# --- subclasses override these three ---
func _property() -> String:
	push_error("%s must override _property()" % name)
	return ""

func _away_value() -> Variant:
	push_error("%s must override _away_value()" % name)
	return null

func _should_return() -> bool:
	return true
