extends Node3D
@onready var trigger1 := $trigger1
@onready var trigger2 := $trigger2
@onready var trigger3 := $trigger3
@onready var weaveHandler := $playArea/weaveGame
@onready var weaveCam := $weaveCam
@onready var weaveUI := $weaveCam/weaveUI
@onready var playArea := $playArea
@onready var current_phase := "idle"

signal activity_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	Dialogic.signal_event.connect(handleDialogue)
	trigger1.interacted.connect(introDialogue)
	trigger2.interacted.connect(startWeave)
	trigger3.interacted.connect(giveShield)
	weaveHandler.weave_finished.connect(weaveFinished)
	weaveUI.visible = false 
	weaveCam.current = false
	playArea.size.x = weaveHandler.x_dim * weaveHandler.tile_size + 32
	playArea.size.y = weaveHandler.y_dim * weaveHandler.tile_size

func introDialogue():
	Dialogic.start("athenaIntro")
	trigger1.deactivate()
	trigger2.activate()

func startWeave():
	current_phase = "weave_explanation"
	trigger2.deactivate()
	Dialogic.start("athenaWeaveExplanation")

func finishWeave():
	weaveUI.visible = false 
	weaveHandler.showTapestry()
	trigger3.activate()
	current_phase = "idle"
	emit_signal("activity_finished")
	
func handleDialogue(type):
	match type:
		"startWeave": 
			weaveUI.visible = true
			weaveHandler.newProblem()
		"continueWeave":
			weaveHandler.continueProblem()
		"hideTapestry":
			weaveHandler.clearBoard()
			weaveHandler.hideTapestry()
		"showTapestry":
			weaveHandler.showTapestry()
		"upgradeLoom":
			weaveHandler.x_dim = 6
			weaveHandler.y_dim = 8
			playArea.size.x = weaveHandler.x_dim * weaveHandler.tile_size + 32
			playArea.size.y = weaveHandler.y_dim * weaveHandler.tile_size
		"finishDone":
			finishWeave()
			
func weaveFinished():
	match current_phase:
		"weave_explanation":
			await weaveHandler.revealThread(true)
			Dialogic.start("athenaWeaveExplanation2")
			current_phase = "weave_explanation_2"
		"weave_explanation_2":
			await weaveHandler.revealThread()
			Dialogic.start("athenaWeave1")
			current_phase = "weave_1"
		"weave_1":
			await weaveHandler.revealThread()
			Dialogic.start("athenaWeave1Cont")

func transitionCamera(initial_camera: Camera3D):
	var original_transform = weaveCam.global_transform
	var original_fov = weaveCam.fov
	var camera_tween = get_tree().create_tween().set_parallel(true)
	weaveCam.global_transform = initial_camera.global_transform
	weaveCam.fov = initial_camera.fov
	weaveCam.current = true
	initial_camera.current = false
	camera_tween.tween_property(weaveCam, "global_transform", original_transform, 2.0)
	camera_tween.tween_property(weaveCam, "fov", original_fov, 2.0)
	await camera_tween.finished
	return
	
func unTransitionCamera(initial_camera: Camera3D):
	var camera_tween = get_tree().create_tween().set_parallel(true)
	camera_tween.tween_property(weaveCam, "global_transform", initial_camera.global_transform, 1.0)
	camera_tween.tween_property(weaveCam, "fov", initial_camera.fov, 1.0)
	await camera_tween.finished
	weaveCam.current = false
	initial_camera.current = true
	return

func giveShield():
	trigger3.deactivate()
