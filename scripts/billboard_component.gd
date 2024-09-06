extends Node3D
@export var target_position := Vector3.ZERO
@export var do_billboard := true
var parent 
func _ready():
	parent = get_parent()
func _process(_delta):
	if do_billboard:
		var new_rot = parent.global_transform.looking_at(target_position)
		parent.global_transform = new_rot
		parent.rotation = Vector3(0, parent.rotation.y, 0)
		#get_parent().look_at(target_position)
		#get_parent().rotation = Vector3(0, get_parent().rotation.y, 0)
