extends Node3D

@onready var trigger1 := $trigger1
@onready var trigger2 := $trigger2
@onready var trigger3 := $trigger3
@onready var discusCam := $discusHandler/discusCam
@onready var discusHandler := $discusHandler
@onready var pathFollow := $pathFollow
@onready var runningPoint := $pathFollow/runningPoint
@onready var current_phase := "running"
@onready var path_progress := 0.0
@onready var running_speed := 4.5
@export var runningPath : Path3D
@export var discusPos : Node3D


signal activity_finished

func _ready():
	Dialogic.signal_event.connect(handleDialogue)
	trigger1.interacted.connect(introDialogue)
	trigger2.interacted.connect(startDiscus)
	trigger3.interacted.connect(giveWingedSandals)
	discusHandler.discus_landed.connect(discusLanded)
	pathFollow.reparent(runningPath)
	
func _process(delta):
	match current_phase:
		"running":
			pathFollow.progress += delta * running_speed
			global_position = global_position.move_toward(runningPoint.global_position, delta * running_speed)
			
func handleDialogue(type):
	match type:
		"goToDiscus":
			goToDiscusPos()
		"hermesThrow":
			discusHandler.startAutoThrow()
		"playerThrow":
			discusHandler.startThrow()
		"giveSandals":
			trigger3.activate()
		_:
			pass
	pass

func introDialogue():
	trigger1.deactivate()
	current_phase = "setting_up"
	Dialogic.start("hermesIntro")

func goToDiscusPos():
	var setup_tween = get_tree().create_tween()
	setup_tween.tween_property(self, "global_transform", discusPos.global_transform, global_position.distance_to(discusPos.global_position)/7.0)
	await setup_tween.finished
	trigger2.activate()
	
func startDiscus():
	trigger2.deactivate()
	current_phase = "discus_explanation"
	Dialogic.start("hermesDiscusExplanation")
	
func transitionCamera(initial_camera: Camera3D):
	var original_transform = discusCam.global_transform
	var original_fov = discusCam.fov
	var camera_tween = get_tree().create_tween().set_parallel(true)
	discusCam.global_transform = initial_camera.global_transform
	discusCam.fov = initial_camera.fov
	discusCam.current = true
	initial_camera.current = false
	camera_tween.tween_property(discusCam, "global_transform", original_transform, 2.0)
	camera_tween.tween_property(discusCam, "fov", original_fov, 2.0)
	await camera_tween.finished
	return

func unTransitionCamera(initial_camera: Camera3D):
	var camera_tween = get_tree().create_tween().set_parallel(true)
	camera_tween.tween_property(discusCam, "global_transform", initial_camera.global_transform, 1.0)
	camera_tween.tween_property(discusCam, "fov", initial_camera.fov, 1.0)
	await camera_tween.finished
	discusCam.current = false
	initial_camera.current = true
	return

func discusLanded():
	match current_phase:
		"discus_explanation":
			current_phase = "player_throw_1"
			Dialogic.start("hermesDiscusExplanation2")
		"player_throw_1":
			current_phase = "player_throw_2"
			Dialogic.start("hermesDiscusAfter1")
		"player_throw_2":
			current_phase = "player_throw_3"
			Dialogic.start("hermesDiscusAfter2")
		"player_throw_3":
			current_phase = "discus_done"
			Dialogic.start("hermesDiscusAfter3")
		_: 
			pass

func giveWingedSandals():
	trigger3.deactivate()
	current_phase = "running"
	DataHandler.hermes_done = true

func alreadyFinished():
	current_phase = "discus_done"
	trigger1.deactivate()
	trigger2.deactivate()
	trigger3.activate()
