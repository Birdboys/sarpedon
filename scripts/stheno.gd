extends CharacterBody3D

@onready var maidenMesh := $maidenMesh
@onready var gorgonMesh := $sthenoMesh
@onready var navAgent := $navAgent
@onready var trigger1 := $trigger1
@onready var current_phase := "idle"

var target_pos : Vector3

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	match current_phase:
		"chasing":
			if navAgent.is_navigation_finished(): return
			if not target_pos: return
			var current_agent_position: Vector3 = global_position
			var next_path_position: Vector3 = navAgent.get_next_path_position()

			velocity = current_agent_position.direction_to(next_path_position) * 5.0
			move_and_slide()
		_:
			pass

func setTargetPos(pos):
	target_pos = pos
	navAgent.set_target_position(pos)
