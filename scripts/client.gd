extends Node3D

@export var calm_value: float
@export var fact_value: float
@export var sp_value: float

@onready var sprite: Sprite3D = $Sprite3D
var negative: bool = false
var state: String = "calm"

var timer: float = 0.0
var interval: float = 3.0
var speeds = []
var remove_all: bool = false

@onready var shapes = [
	$Sprite3D/Shapes/Sprite3D,
	$Sprite3D/Shapes/Sprite3D2,
	$Sprite3D/Shapes/Sprite3D3,
	$Sprite3D/Shapes/Sprite3D4,
]
@onready var shapes_node = $Sprite3D/Shapes

@onready var angry_head = $Sprite3D/AngryHead
@onready var confused_head = $Sprite3D/ConfusedHead
@onready var distressed_head = $Sprite3D/DistressedHead

func _ready() -> void:
	for i in range(4):
		speeds.append((1 if randf() > 0.5 else -1) * randf_range(1, 4))
	
	for shape in shapes:
		shape.visible = false
	
	PlayerData.stat_applied.connect(update_values)
	update_values()

func update_values() -> void:
	var _calm = calm_value
	var _fact = fact_value
	var _sp = sp_value
	
	calm_value = clamp(PlayerData.stats.calm.value, -5, 15)
	fact_value = clamp(PlayerData.stats.fact.value, -5, 15)
	sp_value = clamp(PlayerData.stats.sp.value, -5, 15)
	
	if calm_value != _calm: $Stats/CalmStat.shake()
	if fact_value != _fact: $Stats/FactStat.shake()
	if sp_value != _sp: $Stats/SPStat.shake()
	
	$Stats/CalmStat.amount = remap(calm_value, -5, 15, 0, 100)
	$Stats/FactStat.amount = remap(fact_value, -5, 15, 0, 100)
	$Stats/SPStat.amount = remap(sp_value, -5, 15, 0, 100)
	
	var calm_change = calm_value - _calm
	var fact_change = fact_value - _fact
	var sp_change = sp_value - _sp
	
	var inc = [
		{"type": "calm", "value": calm_change},
		{"type": "fact", "value": fact_change},
		{"type": "sp", "value": sp_change}
	]
	inc.sort_custom(func(a, b): return a["value"] < b["value"])
	
	match inc[2].type:
		"calm":
			if calm_change < 0:
				state = "angry"
				sprite.texture = preload("res://assets/images/characters/lvl1_client_angry.png")
				negative = true
			else:
				state = "calm"
				sprite.texture = preload("res://assets/images/characters/lvl1_client_calm.png")
				negative = false
				remove_all = true
		"fact":
			if fact_change < 0:
				state = "confused"
				sprite.texture = preload("res://assets/images/characters/lvl1_client_confused.png")
				negative = true
			else:
				state = "insightful"
				sprite.texture = preload("res://assets/images/characters/lvl1_client_insightful.png")
				negative = false
				remove_all = true
		"sp":
			if sp_change > 0:
				state = "distressed"
				sprite.texture = preload("res://assets/images/characters/lvl1_client_distressed.png")
				negative = true
			else:
				state = "confident"
				sprite.texture = preload("res://assets/images/characters/lvl1_client_confident.png")
				negative = false
				remove_all = true
		
	#if abs(inc[0].value - inc[1].value) < abs(inc[1].value - inc[2].value):
		#match inc[2].type:
			#"calm":
				#sprite.texture = preload("res://assets/images/characters/lvl1_client_calm.png")
			#"fact":
				#sprite.texture = preload("res://assets/images/characters/lvl1_client_insightful.png")
			#"sp":
				#sprite.texture = preload("res://assets/images/characters/lvl1_client_confident.png")
	#else:
		#match inc[0].type:
			#"calm":
				#sprite.texture = preload("res://assets/images/characters/lvl1_client_angry.png")
			#"fact":
				#sprite.texture = preload("res://assets/images/characters/lvl1_client_confused.png")
			#"sp":
				#sprite.texture = preload("res://assets/images/characters/lvl1_client_distressed.png")

var i = 0
func _process(delta: float) -> void:
	if not negative:
		if remove_all:
			remove_all = false
			i = 0
		
		if i < shapes.size():
			if timer < interval / 3:
				timer += delta
				return
			else:
				shapes[i].visible = false
				i += 1
				timer = 0.0
		return
	
	match state:
		"angry":
			shapes_node.position = angry_head.position
		"confused":
			shapes_node.position = confused_head.position
		"distressed":
			shapes_node.position = distressed_head.position
	
	for i in shapes.size():
		shapes[i].rotation.z += delta * speeds[i]
	
	if timer < interval:
		timer += delta
		return
	else:
		timer = 0.0
	
	if i >= shapes.size(): i = 0
	shapes[i].visible = true
	shapes[i].position = Vector3(randf_range(-1, 1), randf_range(-1, 1), shapes[i].position.z)
	i += 1
