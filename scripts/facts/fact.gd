# fact.gd
class_name fact
extends RefCounted

var fact_description: String

func _init(description: String = "") -> void:
	fact_description = description
