extends Node3D

@onready var mesh := $Armature/Skeleton3D/Cube
@onready var anim := $statueAnim
@export_enum("ACCEPTANCE","CROSSLEG","FETAL","HEADLESS","LEGS","LOOKBEHIND","SITTING","TORSO","TPOSE") var starting_anim : String 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play(starting_anim)
	mesh.create_trimesh_collision()
	
