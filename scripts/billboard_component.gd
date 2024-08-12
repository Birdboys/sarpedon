extends Node3D
@export var target_position := Vector3.ZERO
@export var do_billboard := true

func _process(_delta):
	if do_billboard:
		get_parent().look_at(target_position)
		get_parent().rotation = Vector3(0, get_parent().rotation.y, 0)
