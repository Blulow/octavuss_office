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

	var t := create_tween()
	# 1) Travel from A to B along an arc.
	t.tween_method(_arc.bind(p, a, b), 0.0, 1.0, travel_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# 2) On arrival, rise while fading out.
	t.tween_property(p, "global_position:y", b.y + rise_distance, rise_time) \
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.parallel().tween_method(_set_fade.bind(meshes), 0.0, 1.0, fade_time) \
	.set_delay(fade_delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await t.finished
	p.hide()
	_set_fade(0.0, meshes)   # reset so the preview looks normal next time it's selected

# k goes 0 -> 1. The sine-shaped bump (4k(1-k)) peaks at 1 halfway through.
func _arc(k: float, p: Node3D, a: Vector3, b: Vector3) -> void:
	p.global_position = a.lerp(b, k) + Vector3.UP * arc_height * 4.0 * k * (1.0 - k)

func _set_fade(amount: float, meshes: Array[GeometryInstance3D]) -> void:
	for m in meshes:
		m.transparency = amount
