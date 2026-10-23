# fact.gd
class_name Fact
extends RefCounted

var id: String
var fact_description: String

func _init(_id: String = "", description: String = "") -> void:
	id = _id
	fact_description = description
