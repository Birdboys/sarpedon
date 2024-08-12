extends Node3D
@onready var trigger1 := $trigger1
@onready var trigger2 := $trigger2
@onready var trigger3 := $trigger3
@onready var trigger4 := $trigger4
@onready var weaveHandler := $playArea/weaveGame
@onready var weaveCam := $weaveCam
@onready var weaveUI := $weaveCam/weaveUI
@onready var playArea := $playArea
@onready var athenaPlayer := $athenaPlayer
@onready var athenaMesh := $athenaMesh
@onready var current_phase := "idle"

signal activity_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	Dialogic.signal_event.connect(handleDialogue)
	trigger1.interacted.connect(introDialogue)
	trigger2.interacted.connect(startWeave)
	trigger3.interacted.connect(giveShield)
	trigger4.interacted.connect(repeatWeave)
	weaveHandler.weave_finished.connect(weaveFinished)
	weaveUI.visible = false 
	weaveCam.current = false
	playArea.size.x = weaveHandler.x_dim * weaveHandler.tile_size + 32
	playArea.size.y = weaveHandler.y_dim * weaveHandler.tile_size
	weaveHandler.setTapestryOffset(48)
	
func introDialogue():
	Dialogic.start("athenaIntro")
	trigger1.deactivate()
	trigger2.activate()
	athenaPlayer.stop()
	
func startWeave():
	current_phase = "weave_explanation"
	trigger2.deactivate()
	Dialogic.start("athenaWeaveExplanation")

func finishWeave():
	weaveUI.visible = false 
	trigger3.activate()
	current_phase = "finished"
	emit_signal("activity_finished")
	athenaPlayer.play()

func finishRepeatWeave():
	weaveUI.visible = false
	trigger4.activate()
	current_phase = "idle"
	athenaPlayer.play()
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
			weaveHandler.num_blockers = 18
		"weaveDone":
			finishWeave()
		"weaveRepeatDone":
			finishRepeatWeave()
			
func weaveFinished():
	match current_phase:
		"weave_explanation":
			await weaveHandler.revealThread(true)
			Dialogic.start("athenaWeaveExplanation2")
			current_phase = "weave_explanation_2"
		"weave_explanation_2":
			await weaveHandler.revealThread()
			weaveHandler.setTapestryOffset(24)
			Dialogic.start("athenaWeaveExplanation3")
			current_phase = "weave_explanation_3"
		"weave_explanation_3":
			await weaveHandler.revealThread(true)
			Dialogic.start("athenaUntangleFinished1")
			current_phase = "untangle_1"
		"untangle_1":
			await weaveHandler.revealThread()
			weaveHandler.setTapestryOffset(12, 0.05)
			Dialogic.start("athenaWeaveFinished1")
			current_phase = "weave_1"
		"weave_1":
			await weaveHandler.revealThread(true)
			Dialogic.start("athenaUntangleFinished2")
			current_phase = "untangle_2"
		"untangle_2":
			await weaveHandler.revealThread()
			weaveHandler.setTapestryOffset(0, 0)
			Dialogic.start("athenaWeaveFinished2")
			current_phase = "weave_2"
		"repeat_weave":
			await weaveHandler.revealThread(true)
			Dialogic.start("athenaRepeatCont")
			current_phase = "repeat_weave_cont"
		"repeat_weave_cont":
			await weaveHandler.revealThread()
			Dialogic.start("athenaRepeatFinished")
			current_phase = "idle"
			
			
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
	athenaMesh.visible = false
	return
	
func unTransitionCamera(initial_camera: Camera3D):
	var original_cam_trans = weaveCam.global_transform
	var original_cam_fov = weaveCam.fov
	athenaMesh.visible = true
	var camera_tween = get_tree().create_tween().set_parallel(true)
	camera_tween.tween_property(weaveCam, "global_transform", initial_camera.global_transform, 1.0)
	camera_tween.tween_property(weaveCam, "fov", initial_camera.fov, 1.0)
	await camera_tween.finished
	weaveCam.current = false
	initial_camera.current = true
	weaveCam.global_transform = original_cam_trans
	weaveCam.fov = original_cam_fov
	return

func giveShield():
	current_phase = "idle"
	DataHandler.athena_done = true
	trigger3.deactivate()
	trigger4.activate()
	athenaPlayer.play()

func alreadyFinished():
	weaveHandler.setTapestryOffset(0, 0)
	current_phase = "finished"
	trigger1.deactivate()
	trigger2.deactivate()
	trigger3.activate()
	trigger4.deactivate()

func repeatWeave():
	current_phase = "repeat_weave"
	Dialogic.start("athenaRepeat")
	athenaPlayer.stop()
	trigger4.deactivate()
