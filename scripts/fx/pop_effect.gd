extends RichTextEffect

var bbcode := "pop"
var shared: Dictionary = {}

const DUR := 0.16
const LIFT := 7.0
const GROW := 0.6


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var times: Array = shared.get("times", [])
	var idx: int = char_fx.range.x
	if idx < 0 or idx >= times.size():
		return true
	var revealed: float = float(times[idx])
	if revealed <= 0.0:
		return true
	var age: float = float(shared.get("now", 0.0)) - revealed
	if age < 0.0 or age > DUR:
		return true
	var k: float = 1.0 - age / DUR
	k = k * k
	char_fx.offset += Vector2(0.0, -LIFT * k)
	var s: float = 1.0 + GROW * k
	char_fx.transform = char_fx.transform.scaled(Vector2(s, s))
	return true
