extends Node3D

@onready var trigger1 := $trigger1
@onready var trigger2 := $trigger2
@onready var trigger3 := $trigger3
@onready var monteCam := $monteCam
@onready var billboardComp := $graeaeMesh/billboardComponent
@onready var graeaeMesh := $graeaeMesh
@onready var monteHandler := $monteHandler
@onready var monteUI := $monteCam/monteUI
@onready var current_phase := "idle"
@onready var third_round_tries := 1
signal activity_finished

func _ready():
	Dialogic.signal_event.connect(handleDialogue)
	trigger1.interacted.connect(introDialogue)
	trigger2.interacted.connect(monteExplanation)
	trigger3.interacted.connect(giveInvisHelmet)
	monteHandler.choice_made.connect(handleChoiceMade)
	monteUI.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func transitionCamera(initial_camera: Camera3D):
	var original_transform = monteCam.global_transform
	var original_fov = monteCam.fov
	var camera_tween = get_tree().create_tween().set_parallel(true)
	monteCam.global_transform = initial_camera.global_transform
	monteCam.fov = initial_camera.fov
	monteCam.current = true
	initial_camera.current = false
	camera_tween.tween_property(monteCam, "global_transform", original_transform, 2.0)
	camera_tween.tween_property(monteCam, "fov", original_fov, 2.0)
	await camera_tween.finished
	return

func unTransitionCamera(initial_camera: Camera3D):
	var camera_tween = get_tree().create_tween().set_parallel(true)
	camera_tween.tween_property(monteCam, "global_transform", initial_camera.global_transform, 1.0)
	camera_tween.tween_property(monteCam, "fov", initial_camera.fov, 1.0)
	await camera_tween.finished
	monteCam.current = false
	initial_camera.current = true
	monteHandler.helmetBillboard.do_billboard = true
	return

func handleDialogue(type):
	match type:
		"swapCups": monteHandler.swapRandomCups()
		"rotateCups": monteHandler.rotateCups(randf() > 0.5)
		"randomMove": monteHandler.swapRandomCups() if randf() > 0.5 else monteHandler.rotateCups(randf() > 0.5)
		"toggleSecretOn": monteHandler.toggleSecretCup(true)
		"toggleSecretOff": monteHandler.toggleSecretCup(false)
		"showSecret": monteHandler.showSecretCup()
		"startRandomShuffle": monteHandler.randomMoveTimer()
		"stopRandomShuffle": monteHandler.moveTimer.stop()
		"revealHelmet": monteHandler.revealInvisHelmet()
		"hideHelmet": monteHandler.hideInvisHelmet()
		"monteFinished": 
			activityDone()
		"monteRound1":
			Dialogic.start("graeaeMonte1")
			current_phase = "monte_round1"
		"monteRound2":
			Dialogic.start("graeaeMonte2")
			current_phase = "monte_round2"
		"monteRound3":
			Dialogic.start("graeaeMonte3")
			current_phase = "monte_round3"
		"startChoice": 
			monteUI.visible = true
			monteHandler.startChoice()
		_: pass
	
func introDialogue():
	current_phase = "intro"
	Dialogic.start("graeaeIntro")
	trigger1.deactivate()
	trigger2.activate()

func monteExplanation():
	monteCam.current = true
	current_phase = "explanation"
	Dialogic.start("graeaeExplanation")
	trigger2.deactivate()
	billboardComp.do_billboard = false
	graeaeMesh.rotation.y = 0
	
func activityDone():
	current_phase = "idle"
	trigger3.activate()
	billboardComp.do_billboard = true
	emit_signal("activity_finished")

func giveInvisHelmet():
	trigger3.deactivate()
	monteHandler.setUpCups()
	
func handleChoiceMade(correct: bool):
	monteUI.visible = false
	match current_phase:
		"explanation":
			if correct: Dialogic.start("graeaeExplanationSuccess")
			else: Dialogic.start("graeaeExplanationFail")
			monteHandler.showSecretCup()
		"monte_round1":
			if correct: Dialogic.start("graeaeMonte1Success")
			else: Dialogic.start("graeaeMonte1Fail")
			monteHandler.showSecretCup()
		"monte_round2":
			if correct: Dialogic.start("graeaeMonte2Success")
			else: Dialogic.start("graeaeMonte2Fail")
			monteHandler.showSecretCup()
		"monte_round3":
			Dialogic.start("graeaeMonte3Reveal%s" % third_round_tries)
			third_round_tries += 1
		_:
			pass
