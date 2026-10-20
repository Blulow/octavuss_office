class_name OutlineEffect
extends InteractEffect

@export var mesh: GeometryInstance3D

func _ready() -> void:
	super()
	if mesh == null:
		mesh = interactable.get_parent() as GeometryInstance3D
	assert(mesh != null, "%s needs a mesh (GeometryInstance3D)" % name)
	mesh.set_instance_shader_parameter("show", false)

func activate() -> void:
	mesh.set_instance_shader_parameter("show", true)

func deactivate() -> void:
	mesh.set_instance_shader_parameter("show", false)
