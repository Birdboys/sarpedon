extends CharacterBody3D

@onready var maidenMesh := $maidenMesh
@onready var gorgonMesh := $sthenoMesh
@onready var navAgent := $navAgent
@onready var trigger1 := $trigger1
@onready var petrifyComp := $petrifyComponent
@onready var attackRadius := $attackRadius
@onready var attackCol := $attackRadius/attackCol
@onready var attackTimer := $attackTimer
@onready var moveTimer := $moveTimer
@onready var grabPos := $grabPos
@onready var anim := $sthenoAnim
@onready var hisser := $hisser
@onready var current_phase := "idle"
@onready var speed := 4.75
@onready var attack_time := 2.0
@onready var target_closeness := 1.0
@onready var move_timeout := 1.0

var player_target_pos
var player 

signal activity_finished
func _ready():
	attackRadius.body_entered.connect(startAttack)
	attackRadius.body_exited.connect(stopAttack)
	attackTimer.timeout.connect(attackPlayer)
	moveTimer.timeout.connect(updatePathTarget)
	attackCol.disabled = true
	hisser.play(2.5)

func _physics_process(_delta):
	match current_phase:
		"gorgon":
			var current_agent_position: Vector3 = global_position
			var next_path_position: Vector3 = navAgent.get_next_path_position()
			navAgent.set_velocity(global_position.direction_to(next_path_position).normalized() * speed)
			velocity = await navAgent.velocity_computed
			if navAgent.distance_to_target() < target_closeness:
				velocity = velocity * 0.1
			move_and_slide()
			if velocity.length() > 0:
				anim.play("run")
			else:
				anim.stop()
		_:
			pass

func setTargetPos(pos):
	player_target_pos = pos

func updatePathTarget():
	if player_target_pos != null:
		navAgent.target_position = player_target_pos
	moveTimer.start(move_timeout)
	
func changeToGorgon():
	if current_phase == "gorgon": 
		AudioHandler.playSound3D("stheno_cry", global_position)
		return
	attackCol.set_deferred("disabled", false)
	maidenMesh.visible = false
	gorgonMesh.visible = true
	petrifyComp.enabled = true
	petrifyComp.can_petrify = true
	trigger1.deactivate()
	updatePathTarget()
	current_phase = "gorgon"
	AudioHandler.playSound3D("stheno_cry", global_position)

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
	AudioHandler.playSound3D("stheno_cry", global_position)
	Dialogic.start("sthenoKill")
	
func stopAttack(_body):
	player = null
	print("PLAYER EXIT")
	attackTimer.stop()
	
func transitionCamera(_initial_camera: Camera3D):
	grabPlayer()
	return

func unTransitionCamera(_initial_camera: Camera3D):
	return

func grabPlayer():
	var player_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	player_tween.tween_property(player, "global_transform", grabPos.global_transform, 0.25)
	player_tween.tween_interval(0.5)
	player_tween.tween_callback(player.gorgonAttack.bind("stheno"))
	await player_tween.finished
	current_phase = "attacking"

func gorgonFootstep():
	AudioHandler.playSound3D("footstep_gorgon", global_position - Vector3.UP * 1)
