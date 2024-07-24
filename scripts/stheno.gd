extends CharacterBody3D

@onready var maidenMesh := $maidenMesh
@onready var gorgonMesh := $sthenoMesh
@onready var navAgent := $navAgent
@onready var trigger1 := $trigger1
@onready var petrifyComp := $petrifyComponent
@onready var current_phase := "idle"
@onready var speed := 2.0

var player_target_pos : Vector3
var roam_target_pos := Vector3(-118.21, 3.41, 70.79)

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	match current_phase:
		"gorgon":
			#if not player_target_pos or not roam_target_pos: return
			navAgent.set_target_position(player_target_pos)
			var player_reachable = navAgent.is_target_reachable()
			if player_reachable:
				var current_agent_position: Vector3 = global_position
				var next_path_position: Vector3 = navAgent.get_next_path_position()
				velocity = current_agent_position.direction_to(next_path_position) * speed
			else:
				navAgent.set_target_position(roam_target_pos)
				var current_agent_position: Vector3 = global_position
				var next_path_position: Vector3 = navAgent.get_next_path_position()
				velocity = current_agent_position.direction_to(next_path_position) * speed
			move_and_slide()
		_:
			pass

func setTargetPos(pos):
	player_target_pos = pos

func changeToGorgon():
	maidenMesh.visible = false
	gorgonMesh.visible = true
	petrifyComp.enabled = true
	current_phase = "gorgon"
