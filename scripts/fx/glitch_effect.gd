extends RichTextEffect

var bbcode := "glitch"

const SHAKE := 6.0
const CORRUPT_CHANCE := 0.4
const RED := Color(1.0, 0.35, 0.35)
const GREEN := Color(0.4, 1.0, 0.6)


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var t: float = char_fx.elapsed_time
	var idx: float = float(char_fx.range.x)
	var bucket: float = floor(t * 12.0)
	var jitter := _noise(idx * 12.9898 + bucket * 78.233)
	char_fx.offset += Vector2((jitter - 0.5) * SHAKE, (jitter - 0.5) * SHAKE * 0.5)
	var corrupt := _noise(idx * 7.13 + bucket * 43.71)
	if corrupt < CORRUPT_CHANCE:
		var pick := _noise(idx * 3.7 + bucket * 91.7)
		if pick < 0.25:
			char_fx.visible = false
		elif pick < 0.6:
			char_fx.color = RED
		else:
			char_fx.color = GREEN
	return true


static func _noise(seed_value: float) -> float:
	var n := sin(seed_value) * 43758.5453
	return n - floor(n)
