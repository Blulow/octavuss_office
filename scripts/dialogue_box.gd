class_name DialogueBox
extends PanelContainer

signal typing_finished

const BASE_CPS := 30.0
const PUNCT_CHARS := ".!?…,;:"
const DEFAULT_PUNCT := 0.12
const SLIDE_PX := 14.0

const PopFxScript := preload("res://scripts/fx/pop_effect.gd")
const GlitchFxScript := preload("res://scripts/fx/glitch_effect.gd")

@export var speaker_label: Label
@export var text_label: RichTextLabel

var is_typing: bool = false

var _events: Array = []
var _event_i: int = 0
var _visible: float = 0.0
var _total: int = 0
var _speed_mult: float = 1.0
var _line_speed: float = 1.0
var _wait_left: float = 0.0
var _placed: bool = false
var _word_mode: bool = false
var _word_ends: PackedInt32Array = PackedInt32Array()
var _last_shown: int = 0
var _prev_speaker: String = ""
var _pending_shake: bool = false
var _move_tween: Tween
var _name_tween: Tween
var _shake_tween: Tween

var _fx_state: Dictionary = {"now": 0.0, "times": []}
var _pop_fx
var _glitch_fx


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_pop_fx = PopFxScript.new()
	_glitch_fx = GlitchFxScript.new()
	_pop_fx.shared = _fx_state
	text_label.install_effect(_pop_fx)
	text_label.install_effect(_glitch_fx)


func show_line(line: Dictionary, vars: Dictionary = {}) -> void:
	speaker_label.text = String(line.get("name", line.get("speaker", "")))
	speaker_label.visible = speaker_label.text != ""
	var speaker_changed := _prev_speaker != "" and speaker_label.text != _prev_speaker
	_prev_speaker = speaker_label.text
	_animate_speaker()
	var color_name := String(line.get("color", ""))
	if color_name != "":
		text_label.add_theme_color_override("default_color", Color.from_string(color_name, Color(0.227, 0.227, 0.227, 1.0)))
	else:
		#text_label.remove_theme_color_override("default_color")
		pass
	var parsed := parse_scripted_text(String(line.get("text", "")), {
		"vars": vars,
		"punct": _punct_seconds(line.get("punct", 0.0)),
	})
	text_label.text = parsed["text"]
	_events = parsed["events"]
	_event_i = 0
	_visible = 0.0
	_wait_left = 0.0
	_speed_mult = 1.0
	_line_speed = maxf(float(line.get("speed", 1.0)), 0.05)
	_total = text_label.get_total_character_count()
	_last_shown = 0
	_fx_state["times"] = _make_times(_total)
	_word_mode = bool(line.get("word", false))
	_word_ends = _compute_word_ends() if _word_mode else PackedInt32Array()
	_pending_shake = speaker_changed or bool(line.get("shake", false))
	text_label.visible_characters = 0
	show()
	is_typing = true
	if _total <= 0:
		_finish_typing()
	_fit_and_place()


func _fit_and_place() -> void:
	if not _placed:
		modulate.a = 0.0
	#var vp := get_viewport_rect().size
	custom_minimum_size = Vector2.ZERO
	#size.x = vp.x
	for i in 2:
		await get_tree().process_frame
	#size.y = get_combined_minimum_size().y
	#var target := Vector2(0.0, vp.y - size.y)
	#position = target + Vector2(0.0, SLIDE_PX)
	if _move_tween != null and _move_tween.is_valid():
		_move_tween.kill()
	_move_tween = create_tween()
	#_move_tween.tween_property(self, "position", target, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if not _placed:
		_placed = true
		_move_tween.parallel().tween_property(self, "modulate:a", 1.0, 0.12)
	if _pending_shake:
		_pending_shake = false
		_shake()


func skip() -> void:
	if not is_typing:
		return
	_visible = float(_total)
	_wait_left = 0.0
	_event_i = _events.size()
	_apply_visible()


func _process(delta: float) -> void:
	_fx_state["now"] = Time.get_ticks_msec() / 1000.0
	if not is_typing:
		return
	if _wait_left > 0.0:
		_wait_left -= delta
		if _wait_left > 0.0:
			return
	var target := _visible + BASE_CPS * _speed_mult * _line_speed * delta
	while _event_i < _events.size():
		var event: Dictionary = _events[_event_i]
		if float(event["index"]) > target:
			break
		_event_i += 1
		if event.has("speed"):
			_speed_mult = event["speed"]
		elif event.has("instant"):
			_visible = maxf(_visible, float(event["instant"]))
		else:
			_visible = float(event["index"])
			_wait_left = float(event["wait"])
			_apply_visible()
			return
	target = maxf(target, _visible)
	if _word_mode and not _word_ends.is_empty():
		var snapped := 0.0
		for end in _word_ends:
			if float(end) <= target:
				snapped = float(end)
			else:
				break
		_visible = target
		_apply_visible(snapped)
	else:
		_visible = target
		_apply_visible()


func _apply_visible(display: float = -1.0) -> void:
	var shown := int(display if display >= 0.0 else _visible)
	if shown > _last_shown:
		var times: Array = _fx_state["times"]
		var now: float = _fx_state["now"]
		var stop := mini(shown, times.size())
		for i in range(_last_shown, stop):
			times[i] = now
		_last_shown = stop
	if shown >= _total:
		_finish_typing()
	else:
		text_label.visible_characters = shown


func _finish_typing() -> void:
	if not is_typing:
		return
	is_typing = false
	text_label.visible_characters = -1
	typing_finished.emit()


func _animate_speaker() -> void:
	if not speaker_label.visible:
		return
	speaker_label.pivot_offset = speaker_label.size * 0.5
	if _name_tween != null and _name_tween.is_valid():
		_name_tween.kill()
	speaker_label.scale = Vector2(1.25, 1.25)
	speaker_label.modulate = Color(1.6, 1.6, 1.6, 0.0)
	_name_tween = create_tween().set_parallel()
	_name_tween.tween_property(speaker_label, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_name_tween.tween_property(speaker_label, "modulate", Color.WHITE, 0.18)


func _shake() -> void:
	if _shake_tween != null and _shake_tween.is_valid():
		_shake_tween.kill()
	_shake_tween = create_tween()
	_shake_tween.tween_interval(0.08)
	for amp in [4.0, -4.0, 2.5, -2.5, 0.0]:
		_shake_tween.tween_property(self, "position:x", amp, 0.03)


func _compute_word_ends() -> PackedInt32Array:
	var ends := PackedInt32Array()
	var plain := text_label.get_parsed_text()
	var count := 0
	for i in plain.length():
		count += 1
		if plain[i] == " ":
			ends.append(count)
	if count > 0:
		ends.append(count)
	return ends


static func _make_times(count: int) -> Array:
	var times: Array = []
	times.resize(count)
	times.fill(0.0)
	return times


static func _punct_seconds(value: Variant) -> float:
	if value is bool:
		return DEFAULT_PUNCT if value else 0.0
	return maxf(float(value), 0.0)


static func parse_scripted_text(raw: String, ctx: Dictionary = {}) -> Dictionary:
	var out := ""
	var events: Array = []
	var vars: Dictionary = ctx.get("vars", {})
	var punct: float = float(ctx.get("punct", 0.0))
	var visible_count := 0
	var instant_depth := 0
	var instant_start := 0
	var i := 0
	while i < raw.length():
		var ch := raw[i]
		if ch == "[":
			var close := raw.find("]", i)
			if close == -1:
				out += ch
				visible_count += 1
				i += 1
				continue
			var tag := raw.substr(i + 1, close - i - 1)
			if tag == "instant":
				if instant_depth == 0:
					instant_start = visible_count
				instant_depth += 1
			elif tag == "/instant":
				if instant_depth > 0:
					instant_depth -= 1
					if instant_depth == 0 and visible_count > instant_start:
						_insert_event(events, {"index": instant_start, "instant": visible_count})
			elif tag == "/speed":
				events.append({"index": visible_count, "speed": 1.0})
			elif tag.begins_with("speed="):
				var mult := float(tag.substr(6))
				events.append({"index": visible_count, "speed": mult if mult > 0.0 else 1.0})
			elif tag.begins_with("delay="):
				var delay := float(tag.substr(6))
				if delay > 0.0:
					events.append({"index": visible_count, "speed": 1.0 / (1.0 + delay * BASE_CPS)})
			elif tag == "/delay":
				events.append({"index": visible_count, "speed": 1.0})
			elif tag.begins_with("wait="):
				if instant_depth == 0:
					events.append({"index": visible_count, "wait": maxf(float(tag.substr(5)), 0.0)})
			else:
				out += raw.substr(i, close - i + 1)
			i = close + 1
			continue
		elif ch == "{":
			var close2 := raw.find("}", i)
			if close2 == -1:
				out += ch
				visible_count += 1
				i += 1
				continue
			var key := raw.substr(i + 1, close2 - i - 1)
			if key.begins_with("w") and key.length() > 1 and key.substr(1).is_valid_float():
				if instant_depth == 0:
					events.append({"index": visible_count, "wait": maxf(float(key.substr(1)), 0.0)})
			elif vars.has(key):
				var value := String(vars[key])
				out += value
				visible_count += value.length()
			else:
				var literal := raw.substr(i, close2 - i + 1)
				out += literal
				visible_count += literal.length()
			i = close2 + 1
			continue
		out += ch
		visible_count += 1
		if punct > 0.0 and instant_depth == 0 and PUNCT_CHARS.contains(ch):
			events.append({"index": visible_count, "wait": punct})
		i += 1
	return {"text": out, "events": events}


static func _insert_event(events: Array, event: Dictionary) -> void:
	var pos := 0
	var idx := float(event["index"])
	while pos < events.size() and float(events[pos]["index"]) <= idx:
		pos += 1
	events.insert(pos, event)
