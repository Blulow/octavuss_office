class_name InteractEffect
extends Node

enum Trigger { HOVER, SELECT, SUCCESS, FAIL }

@export var interactable: Interactable
@export var trigger: Trigger = Trigger.HOVER

func _ready() -> void:
	if interactable == null:
		interactable = _find_interactable()
	assert(interactable != null, "%s can't find an Interactable" % name)

	interactable.hover_started.connect(func(): _enter(Trigger.HOVER))
	interactable.hover_ended.connect(func(): _exit(Trigger.HOVER))
	interactable.select_changed.connect(_on_select_changed)
	interactable.action_succeeded.connect(func(): _enter(Trigger.SUCCESS))
	interactable.action_failed.connect(func(): _enter(Trigger.FAIL))

# Walks up the tree and returns the first Interactable that is a child of an ancestor.
func _find_interactable() -> Interactable:
	var n := get_parent()
	while n != null:
		for c in n.get_children():
			if c is Interactable:
				return c
		n = n.get_parent()
	return null

func _on_select_changed(is_selected: bool) -> void:
	if is_selected:
		_enter(Trigger.SELECT)
	else:
		_exit(Trigger.SELECT)

func _enter(t: Trigger) -> void:
	if t == trigger:
		activate()

func _exit(t: Trigger) -> void:
	if t == trigger:
		deactivate()

# Subclasses override these two only.
func activate() -> void: pass
func deactivate() -> void: pass   # one-shot triggers (SUCCESS/FAIL) never call this
