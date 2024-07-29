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
@onready var medusaPetrify := $medusaMesh/petrifyComponent2
@onready var sleepPetrify := $sleepMesh/petrifyComponent
@onready var headPetrify := $headMesh/petrifyComponent
@onready var deadHeadTrigger := $headMesh/interactBox
@onready var sleepHeadTrigger := $sleepMesh/interactBox
@onready var gorgonHeadTrigger := $medusaMesh/interactBox
@onready var grabPos := $grabPos
@onready var navAgent := $navAgent
@onready var home_pos := Vector3(-51, -3.63, -15)
@onready var speed := 2.0
@onready var attack_time := 3.0
@export var caveArea : Area3D

signal medusa_slain
signal head_taken
signal activity_finished

var player
var target_pos : Vector3

func _ready():
	caveArea.body_entered.connect(playerEnteredCave)
	caveArea.body_exited.connect(playerExitedCave)
	attackRadius.body_entered.connect(startAttack)
	attackRadius.body_exited.connect(stopAttack)
	attackTimer.timeout.connect(attackPlayer)
	deadHeadTrigger.interacted.connect(headTaken)
	sleepHeadTrigger.activate()
	gorgonHeadTrigger.deactivate()
	deadHeadTrigger.deactivate()
	
	attackCol.disabled = true
func _process(delta):
	pass
	
func _physics_process(delta):
	match current_phase:
		"awake_idle":
			if medusaPetrify.can_see_player and player: 
				setPlayerPos(player.global_position)
				current_phase = "awake_chasing"
				return
		"awake_chasing":
			if navAgent.is_target_reached():
				current_phase = "awake_idle"
				return
			if medusaPetrify.can_see_player and player:
				setPlayerPos(player.global_position)
			var next_pos = navAgent.get_next_path_position()
			var next_dir = next_pos - global_position
			velocity = next_dir * speed
			move_and_slide()
			
func playerEnteredCave(body):
	player_in_cave = true
	player = body
	player.footstep.connect(playerFootstep)
	
func playerExitedCave(body):
	player_in_cave = false
	player.footstep.disconnect(playerFootstep)
	player = null
	
func playerFootstep(player_pos, type):
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
				Dialogic.start("medusaWaking3")
				wakeUp()
		"awake_idle":
			current_phase = "awake_chasing"
			setPlayerPos(player_pos)
		"awake_chasing":
			setPlayerPos(player_pos)

func wakeUp():
	current_phase = "awake_idle"
	sleepMesh.visible = false
	sleepPetrify.enabled = false
	sleepHeadTrigger.deactivate()
	
	attackCol.set_deferred("disabled", false)
	medusaMesh.visible = true
	medusaPetrify.enabled = true
	medusaPetrify.can_petrify = true
	gorgonHeadTrigger.activate()

func slain():
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
	emit_signal("medusa_slain")
	
func setPlayerPos(pos):
	target_pos = pos
	navAgent.set_target_position(target_pos)

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
	
func stopAttack(_body):
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
	current_phase = "idle"
