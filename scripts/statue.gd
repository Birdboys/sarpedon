extends Node3D

@onready var mesh := $Armature/Skeleton3D/Cube
@onready var anim := $statueAnim
@onready var interactTrigger := $interactBox
@export_enum("ACCEPTANCE","ARMCOVER","BEHINDTREE","BOXER","CROSSLEG","FELLDOWN","FETAL","HEADLESS","HEADNARM","LEGS","LOOKBEHIND","LOOKINGOVER","LYINGDOWN","ONEKNEE","PICKUP","POKINGFIRE","SITTING","SWORDATTACK","TORSO","TPOSE","TURNING AWAY") var starting_anim := "TPOSE"

func _ready() -> void:
	anim.play(starting_anim)
	mesh.create_trimesh_collision()
	interactTrigger.interacted.connect(statueInteract)
	
func statueInteract():
	Dialogic.VAR.statue_desc = starting_anim
	#Dialogic.start("statueDescriptions")
