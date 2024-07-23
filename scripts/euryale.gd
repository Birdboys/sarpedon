extends CharacterBody3D

@onready var maidenMesh := $maidenMesh
@onready var gorgonMesh := $euryaleMesh
@onready var navAgent := $navAgent
@onready var trigger1 := $trigger1
@onready var current_phase := "idle"

var target_pos : Vector3

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setTargetPos(pos):
	target_pos = pos
	navAgent.set_target_position(pos)
