# fact.gd
class_name Fact
extends RefCounted

var id: String
var text: String
var fact_description: String

func _init(_id: String = "", _text: String = "", description: String = "") -> void:
	id = _id
	text = _text
	fact_description = description
