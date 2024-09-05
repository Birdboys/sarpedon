extends CharacterBody3D

@onready var current_phase := "sleeping"
@onready var player_in_cave := false
@onready var medusaMesh := $medusaMesh
@onready var sleepMesh := $sleepMesh
@onready var headMesh := $headMesh
@onready var wingMesh := $wingMesh
@onready var deadMesh := $deadMesh
@onready var attackRadius := $attackRadius
@onready var attackCol := $attackRadius/attackCol
@onready var attackTimer := $attackTimer
@onready var moveTimer := $moveTimer
@onready var medusaPetrify := $medusaMesh/petrifyComponent2
@onready var sleepPetrify := $sleepMesh/petrifyComponent
@onready var headPetrify := $headMesh/petrifyComponent
@onready var deadHeadTrigger := $headMesh/interactBox
@onready var sleepHeadTrigger := $sleepMesh/interactBox
@onready var gorgonHeadTrigger := $medusaMesh/interactBox
@onready var anim := $medusaAnim
@onready var grabPos := $grabPos
@onready var navAgent := $navAgent
@onready var medusaPlayer := $medusaPlayer
@onready var home_pos := Vector3(-51, -3.63, -15)
@onready var speed := 2.0
@onready var attack_time := 3.0
@onready var target_closeness := 1.0
@onready var move_timeout := 1.0
@export var caveArea : Area3D

signal medusa_awake
signal medusa_slain
signal head_taken
signal activity_finished

var player
var player_target_pos

func _ready():
	caveArea.body_entered.connect(playerEnteredCave)
	caveArea.body_exited.connect(playerExitedCave)
	attackRadius.body_entered.connect(startAttack)
	attackRadius.body_exited.connect(stopAttack)
	attackTimer.timeout.connect(attackPlayer)
	moveTimer.timeout.connect(updatePathTarget)
	deadHeadTrigger.interacted.connect(headTaken)
	sleepHeadTrigger.activate()
	gorgonHeadTrigger.deactivate()
	deadHeadTrigger.deactivate()
	
	attackCol.disabled = true
	
func _physics_process(_delta):
	match current_phase:
		"awake":
			var current_agent_position: Vector3 = global_position
			var next_path_position: Vector3 = navAgent.get_next_path_position()
			navAgent.set_velocity(global_position.direction_to(next_path_position).normalized() * speed)
			velocity = await navAgent.velocity_computed
			if navAgent.distance_to_target() < target_closeness:
				velocity = velocity * 0.1
			move_and_slide()
			if velocity.length() > 0:
				anim.play("chase")
			else:
				anim.stop()
			
func playerEnteredCave(body):
	player_in_cave = true
	player = body
	player.footstep.connect(playerFootstep)
	
func playerExitedCave(_body):
	player_in_cave = false
	player.footstep.disconnect(playerFootstep)
	player = null
	
func playerFootstep(player_pos, type):
	if type == "sneak": return
	match current_phase:
		"sleeping":
			if type == "loud":
				Dialogic.start("medusaWaking1")
				current_phase = "waking_1"
		"waking_1":
			if type == "loud":
				Dialogic.start("medusaWaking2")
				current_phase = "waking_2"
		"waking_2":
			if type == "loud":
				wakeUp()
		"awake":
			setTargetPos(player_pos)

func wakeUp():
	AudioHandler.setPlayer("music", false)
	current_phase = "awake"
	sleepMesh.visible = false
	sleepPetrify.enabled = false
	sleepHeadTrigger.deactivate()
	updatePathTarget()
	attackCol.set_deferred("disabled", false)
	medusaMesh.visible = true
	medusaPetrify.enabled = true
	medusaPetrify.can_petrify = true
	gorgonHeadTrigger.activate()
	emit_signal("medusa_awake")
	AudioHandler.playSound3D("medusa_gasp", global_position)
	Dialogic.toggleAutoload(true)
	Dialogic.start("medusaMonologue")
	await Dialogic.timeline_started
	Dialogic.timeline_started.connect(handleAutoDialogue)
	
	
func slain():
	AudioHandler.setPlayer("music", false)
	Dialogic.start("medusaLastWords")
	attackCol.set_deferred("disabled", true)
	attackTimer.stop()
	moveTimer.stop()
	current_phase = "dead"
	sleepMesh.visible = false
	sleepPetrify.enabled = false
	sleepHeadTrigger.deactivate()
	
	medusaMesh.visible = false
	medusaPetrify.enabled = false
	medusaPetrify.can_petrify = false
	gorgonHeadTrigger.deactivate()
	
	headMesh.visible = true
	wingMesh.visible = true
	deadMesh.visible = true
	headPetrify.enabled = true
	headPetrify.can_petrify = true
	deadHeadTrigger.activate()
	medusaPlayer.stop()
	medusaPlayer.stream = AudioHandler.getAudio("decapitation")
	medusaPlayer.play()
	AudioHandler.playSound3D("medusa_gasp", global_position)
	emit_signal("medusa_slain")

func setTargetPos(pos):
	player_target_pos = pos

func updatePathTarget():
	print("MEDUSA PATH UPDATE")
	if player_target_pos != null:
		navAgent.target_position = player_target_pos
	moveTimer.start(move_timeout)
	
func headTaken():
	headMesh.visible = false
	deadHeadTrigger.deactivate()
	emit_signal("head_taken")

func startAttack(_body):
	if attackTimer.is_stopped():
		attackTimer.start(attack_time)

func attackPlayer():
	current_phase = "attacking"
	print("PLAYER ENTERED STARTING TIMER")
	attackTimer.stop()
	if player.stateMachine.current_state.name == "playerActivity" or player.stateMachine.current_state.name == "playerDied": return
	player.startActivity(self)
	Dialogic.start("medusaKill")
	
func stopAttack(_body):
	print("PLAYER EXIT")
	attackTimer.stop()

func transitionCamera(_initial_camera: Camera3D):
	grabPlayer()
	return

func unTransitionCamera(_initial_camera: Camera3D):
	return

func grabPlayer():
	var player_tween = get_tree().create_tween()
	player_tween.tween_property(player, "global_transform", grabPos.global_transform, 0.15)
	player_tween.tween_interval(0.25)
	player_tween.tween_callback(player.gorgonAttack)
	await player_tween.finished
	current_phase = "idle"

func gorgonFootstep():
	AudioHandler.playSound3D("footstep_cave", global_position)

func handleAutoDialogue():
	print("HANDLING AUTO DIALOG")
	Dialogic.timeline_started.disconnect(handleAutoDialogue)
	Dialogic.toggleAutoload(false)
	#print("HANDLING AUTO DIALOG, ", Dialogic.Inputs.auto_advance.enabled_forced)
