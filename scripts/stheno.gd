extends CharacterBody3D

@onready var maidenMesh := $maidenMesh
@onready var gorgonMesh := $sthenoMesh
@onready var navAgent := $navAgent
@onready var trigger1 := $trigger1
@onready var petrifyComp := $petrifyComponent
@onready var attackRadius := $attackRadius
@onready var attackCol := $attackRadius/attackCol
@onready var attackTimer := $attackTimer
@onready var grabPos := $grabPos
@onready var anim := $sthenoAnim
@onready var current_phase := "idle"
@onready var speed := 4.75
@onready var attack_time := 2.0

var player_target_pos : Vector3
var roam_target_pos := Vector3(-118.21, 3.41, 70.79)
var player 

signal activity_finished
func _ready():
	attackRadius.body_entered.connect(startAttack)
	attackRadius.body_exited.connect(stopAttack)
	attackTimer.timeout.connect(attackPlayer)
	attackCol.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	match current_phase:
		"gorgon":
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
			
			if velocity.length() > 0:
				anim.play("run")
			else:
				anim.stop()
		_:
			pass

func setTargetPos(pos):
	player_target_pos = pos
	
func changeToGorgon():
	if current_phase == "gorgon": return
	attackCol.set_deferred("disabled", false)
	maidenMesh.visible = false
	gorgonMesh.visible = true
	petrifyComp.enabled = true
	petrifyComp.can_petrify = true
	trigger1.deactivate()
	current_phase = "gorgon"

func startAttack(body):
	player = body
	if attackTimer.is_stopped():
		attackTimer.start(attack_time)

func attackPlayer():
	current_phase = "attacking"
	print("PLAYER ENTERED STARTING TIMER")
	attackTimer.stop()
	if player.stateMachine.current_state.name == "playerActivity" or player.stateMachine.current_state.name == "playerDied": return
	player.startActivity(self)
	Dialogic.start("sthenoKill")
	
func stopAttack(body):
	player = null
	print("PLAYER EXIT")
	attackTimer.stop()
	
func transitionCamera(initial_camera: Camera3D):
	grabPlayer()
	return

func unTransitionCamera(initial_camera: Camera3D):
	return

func grabPlayer():
	var player_tween = get_tree().create_tween()
	player_tween.tween_property(player, "global_transform", grabPos.global_transform, 0.15)
	player_tween.tween_interval(0.25)
	player_tween.tween_callback(player.gorgonAttack)
	await player_tween.finished
	current_phase = "attacking"

func gorgonFootstep():
	AudioHandler.playSound3D("footstep_gorgon", global_position - Vector3.UP * 1)
