extends CharacterBody3D

@onready var maidenMesh := $maidenMesh
@onready var gorgonMesh := $euryaleMesh
@onready var navAgent := $navAgent
@onready var trigger1 := $trigger1
@onready var petrifyComp := $petrifyComponent
@onready var current_phase := "idle"
@onready var speed := 2.0

var target_pos : Vector3

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	match current_phase:
		"gorgon":
			if not target_pos: return
			navAgent.set_target_position(target_pos)
			#if not navAgent.is_target_reachable(): return
			var current_agent_position: Vector3 = global_position
			var next_path_position: Vector3 = navAgent.get_next_path_position()
			velocity = current_agent_position.direction_to(next_path_position) * speed
			move_and_slide()
		_:
			pass

func setTargetPos(pos):
	target_pos = pos
	navAgent.set_target_position(pos)

func changeToGorgon():
	maidenMesh.visible = false
	gorgonMesh.visible = true
	petrifyComp.enabled = true
	current_phase = "gorgon"
	
