extends Node3D

@export var calm_value: float
@export var fact_value: float
@export var sp_value: float

func _ready() -> void:
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
