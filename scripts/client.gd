extends Node3D

@export var calm_value: float
@export var fact_value: float
@export var sp_value: float

func _ready() -> void:
	PlayerData.stat_applied.connect(update_values)
	update_values()

func update_values() -> void:
	calm_value = clamp(PlayerData.stats.calm.value, -5, 15)
	fact_value = clamp(PlayerData.stats.fact.value, -5, 15)
	sp_value = clamp(PlayerData.stats.sp.value, -5, 15)
	
	$Stats/CalmStat.amount = remap(calm_value, -5, 15, 0, 100)
	$Stats/FactStat.amount = remap(fact_value, -5, 15, 0, 100)
	$Stats/SPStat.amount = remap(sp_value, -5, 15, 0, 100)
