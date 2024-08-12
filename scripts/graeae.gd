extends Node3D

@onready var trigger1 := $trigger1
@onready var trigger2 := $trigger2
@onready var trigger3 := $trigger3
@onready var trigger4 := $trigger4
@onready var monteCam := $monteCam
@onready var billboardComp := $graeaeMesh/billboardComponent
@onready var graeaeMesh := $graeaeMesh
@onready var monteHandler := $monteHandler
@onready var monteUI := $monteCam/monteUI
@onready var sisterMeshes := [$sisterMesh1, $sisterMesh2]
@onready var cupAudio := $cupAudio
@onready var graeaeAnim := $graeaeAnim
@onready var show_sisters := false
@onready var sister_noise := FastNoiseLite.new()
@onready var current_phase := "idle"
@onready var third_round_tries := 1
signal activity_finished

func _ready():
	Dialogic.signal_event.connect(handleDialogue)
	trigger1.interacted.connect(introDialogue)
	trigger2.interacted.connect(monteExplanation)
	trigger3.interacted.connect(giveInvisHelmet)
	trigger4.interacted.connect(startRepeatMonte)
	monteHandler.choice_made.connect(handleChoiceMade)
	monteUI.visible = false
	monteHandler.visible = false
	graeaeAnim.play("cupping")
	
func _process(_delta):
	if show_sisters:
		for sister in sisterMeshes:
			sister.mesh.material.set_shader_parameter("transparency", sister_noise.get_noise_1d(Time.get_ticks_msec()/10.0)-0.2)


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
	var original_cam_trans = monteCam.global_transform
	var original_cam_fov = monteCam.fov
	var camera_tween = get_tree().create_tween().set_parallel(true)
	camera_tween.tween_property(monteCam, "global_transform", initial_camera.global_transform, 1.0)
	camera_tween.tween_property(monteCam, "fov", initial_camera.fov, 1.0)
	await camera_tween.finished
	monteCam.current = false
	initial_camera.current = true
	monteHandler.helmetBillboard.do_billboard = true
	monteCam.fov = original_cam_fov
	monteCam.global_transform = original_cam_trans
	return

func handleDialogue(type):
	match type:
		"swapCups": monteHandler.swapRandomCups()
		"rotateCups": monteHandler.rotateCups(randf() > 0.5)
		"randomMove": monteHandler.swapRandomCups() if randf() > 0.5 else monteHandler.rotateCups(randf() > 0.5)
		"toggleSecretOn": monteHandler.toggleSecretCup(true)
		"toggleSecretOff": monteHandler.toggleSecretCup(false)
		"showSecret": monteHandler.showSecretCup()
		"startRandomShuffle": 
			monteHandler.randomMoveTimer()
			show_sisters = true
		"stopRandomShuffle": 
			monteHandler.moveTimer.stop()
			hideSisters()
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
			print("STARTING CHOISE")
			monteUI.visible = true
			monteHandler.startChoice()
		"repeatGame":
			monteHandler.repeatGame()
		"repeatDone":
			repeatActivityDone()
		_: pass
	
func introDialogue():
	graeaeAnim.stop()
	current_phase = "intro"
	Dialogic.start("graeaeIntro")
	trigger1.deactivate()
	trigger2.activate()

func monteExplanation():
	monteHandler.visible = true
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

func repeatActivityDone():
	current_phase = "idle"
	trigger4.activate()
	billboardComp.do_billboard = true
	emit_signal("activity_finished")
	graeaeAnim.play("cupping")
	
func giveInvisHelmet():
	trigger3.deactivate()
	monteHandler.visible = true
	monteHandler.setUpCups()
	DataHandler.graeae_done = true
	graeaeAnim.play("cupping")
	
func handleChoiceMade(correct: bool):
	print("CHOICE MADE")
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
		"repeat_monte":
			print("REPEAT WON", correct)
			if correct: Dialogic.start("graeaeRepeatWin")
			else: Dialogic.start("graeaeRepeatLose")
			monteHandler.showSecretCup()
		_:
			pass

func hideSisters():
	show_sisters = false
	for sister in sisterMeshes:
			sister.mesh.material.set_shader_parameter("transparency", 0.0)

func alreadyFinished():
	current_phase = "idle"
	trigger1.deactivate()
	trigger2.deactivate()
	trigger3.activate()

func cupMoveSound():
	if cupAudio.playing: cupAudio.stop()
	cupAudio.stream = AudioHandler.getAudio("cup_slide")
	cupAudio.play()

func startRepeatMonte():
	current_phase = "repeat_monte"
	monteHandler.visible = true
	graeaeAnim.stop()
	trigger4.deactivate()
	billboardComp.do_billboard = false
	graeaeMesh.rotation.y = 0
	Dialogic.start("graeaeRepeatIntro")
