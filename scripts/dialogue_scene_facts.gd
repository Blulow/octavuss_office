extends DialogueScene

#@onready var facts_box: FactsBox = $FactsBox
@export var facts_box: FactsBox

var _facts: Array = []
var _unlocked: Dictionary = {}
var _current_options: Array = []

func _ready() -> void:
	super()
	facts_box.drag_started.connect(_on_fact_drag_started)
	facts_box.drag_ended.connect(_on_fact_drag_ended)

func start_session(path: String) -> void:
	super.start_session(path)
	#choice_box.fact_dropped.connect(_on_fact_dropped)
	if not _choosing:
		facts_box.show_facts(_facts, [])


func _load_dialog(path: String) -> void:
	super._load_dialog(path)
	_facts = PlayerData.facts_collected
	#_facts = _data.get("facts", [])


func _show_choices(options: Array) -> void:
	_current_options = options
	facts_box.show_facts(_facts, _usable_fact_ids())
	super(options)


func _filter_choices(options: Array) -> Array:
	var out: Array = []
	for option in super._filter_choices(options):
		var fact_id := String(option.get("fact", ""))
		if fact_id == "" or _unlocked.has(fact_id):
			out.append(option)
	return out


func _on_choice_chosen(index: int) -> void:
	#super(index)
	_choosing = false
	if index < 0 or index >= _choices.size():
		return
	
	var response: Dictionary = {}
	
	var choice: Dictionary = _choices[index]
	if choice_box.updated.any(func(e): return e.index == index):
		if choice.has("facts"):
			var facts: Array = _choices[index].facts
			
			for e in choice_box.updated:
				if e.index != index:
					continue
				for fact in facts:
					if e.fact_id != fact.fact:
						continue
					response = fact.response
	else:
		if choice.has("choices"):
			if choice.choices.size() <= 1 and choice.choices[0].condition == "default":
				response = choice.choices[0].response
			else:
				var default: Dictionary
				for c in choice.choices:
					if c.condition == "default":
						default = c.response
						continue
					else:
						var p = parse_condition(c.condition)
						if match_condition(PlayerData.stats[p.stat].value, p.operator, p.number):
							response = c.response
						
				if not response: response = default
		else:
			response = choice.response
	
	_show_message(response)
	facts_box.show_facts(_facts, [])

func parse_condition(text: String) -> Dictionary:
	var regex = RegEx.new()
	regex.compile("^([a-zA-Z_][a-zA-Z0-9_]*)\\s*(>=|<=|==|!=|>|<)\\s*(-?\\d+(?:\\.\\d+)?)$")

	var result = regex.search(text)

	if result == null:
		return {}

	return {
		"stat": result.get_string(1),
		"operator": result.get_string(2),
		"number": float(result.get_string(3))
	}

func match_condition(a: float, operator: String, b: float) -> bool:
	match operator:
		">":
			return a > b
		"<":
			return a < b
		">=":
			return a >= b
		"<=":
			return a <= b
		"==":
			return a == b
		"!=":
			return a != b
	
	printerr("invalid operator ", operator)
	return false

func _on_fact_drag_started() -> void:
	#choice_box.set_drop_active(true)
	pass


func _on_fact_drag_ended() -> void:
	#choice_box.set_drop_active(false)
	pass


#func _on_fact_dropped(fact_id: String) -> void:
	#if not _choosing or _unlocked.has(fact_id):
		#return
	#var option := _find_fact_option(fact_id)
	#if option.is_empty():
		#return
	#_unlocked[fact_id] = true
	#_choices.append(option)
	#choice_box.add_choice(option)
	#facts_box.show_facts(_facts, _usable_fact_ids())


func _find_fact_option(fact_id: String) -> Dictionary:
	for option in _current_options:
		if String(option.get("fact", "")) == fact_id:
			return option
	return {}


func _usable_fact_ids() -> Array:
	var ids: Array = []
	for option in _current_options:
		var facts: Array = option.get("facts", [])
		
		
		var fact_ids: Array = []
		
		for fact in facts:
			var fact_id: String = fact.get("fact", "")
			if fact_id == "" or _unlocked.has(fact_id):
				continue
			fact_ids.append(fact_id)
		
		
		#TODO: CONDITIONS
		#var condition := String(option.get("if", ""))
		#if condition != "" and not bool(_vars.get(condition, false)):
			#continue
		
		ids.append(fact_ids)
	
	return ids
