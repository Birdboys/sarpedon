extends Node3D

@onready var hermesMesh := $hermesMesh
@onready var trigger1 := $trigger1
@onready var trigger2 := $trigger2
@onready var trigger3 := $trigger3
@onready var trigger4 := $trigger4
@onready var trigger5 := $trigger5
@onready var discusCam := $discusHandler/discusCam
@onready var discusHandler := $discusHandler
@onready var pathFollow := $pathFollow
@onready var runningPoint := $pathFollow/runningPoint
@onready var runTimer := $runTimer
@onready var footstepper := $footstepper
@onready var runAnim := $runAnim
@onready var current_phase := "running"
@onready var path_progress := 0.0
@onready var running_speed := 3.5
@onready var num_throw_responses := 9
@export var runningPath : Path3D
@export var discusPos : Node3D


signal activity_finished

func _ready():
	Dialogic.signal_event.connect(handleDialogue)
	trigger1.interacted.connect(introDialogue)
	trigger2.interacted.connect(startDiscus)
	trigger3.interacted.connect(giveWingedSandals)
	trigger4.interacted.connect(startDiscusRepeat)
	trigger5.interacted.connect(startThrowRepeat)
	discusHandler.discus_landed.connect(discusLanded)
	runTimer.timeout.connect(startRun)
	pathFollow.reparent(runningPath)
	runAnim.play("run")
	
func _process(delta):
	match current_phase:
		"running":
			pathFollow.progress += delta * running_speed
			global_position = global_position.move_toward(runningPoint.global_position, delta * running_speed)
			
func handleDialogue(type):
	match type:
		"goToDiscus":
			goToDiscusPos()
		"goToDiscusRepeat":
			goToDiscusPos(true)
		"hermesThrow":
			discusHandler.startAutoThrow()
			hermesMesh.visible = false
		"playerThrow":
			discusHandler.startThrow()
			hermesMesh.visible = false
		"giveSandals":
			trigger3.activate()
		"repeatDone":
			finishRepeatThrow()
		_:
			pass
	pass

func introDialogue():
	runAnim.stop()
	trigger1.deactivate()
	current_phase = "setting_up"
	Dialogic.start("hermesIntro")

func goToDiscusPos(repeat=false):
	runAnim.play("run")
	var setup_tween = get_tree().create_tween()
	setup_tween.tween_property(self, "global_transform", discusPos.global_transform, global_position.distance_to(discusPos.global_position)/5.0)
	await setup_tween.finished
	runAnim.stop()
	pathFollow.progress = 0
	if not repeat:
		trigger2.activate()
	else: 
		trigger5.activate()
	
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
	var original_cam_trans = discusCam.transform
	var original_cam_fov = discusCam.fov
	var camera_tween = get_tree().create_tween().set_parallel(true)
	camera_tween.tween_property(discusCam, "global_transform", initial_camera.global_transform, 1.0)
	camera_tween.tween_property(discusCam, "fov", initial_camera.fov, 1.0)
	await camera_tween.finished
	discusCam.current = false
	initial_camera.current = true
	discusCam.transform = original_cam_trans
	discusCam.rotation = Vector3.ZERO
	discusCam.fov = original_cam_fov
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
			hermesMesh.visible = true
			emit_signal("activity_finished")
			Dialogic.start("hermesDiscusAfter3")
		"discus_repeat_throw":
			Dialogic.start("hermesRepeatFinished")
		"discus_repeat_1":
			current_phase = "discus_repeat_2"
			var throw_response = randi_range(0, num_throw_responses)
			while throw_response == Dialogic.VAR.discus_repeat:
				throw_response = randi_range(0, num_throw_responses)
			Dialogic.VAR.discus_repeat = throw_response
			Dialogic.start("hermesDiscusRepeat1")
		"discus_repeat_2":
			current_phase = "discus_repeat_3"
			var throw_response = randi_range(0, num_throw_responses)
			while throw_response == Dialogic.VAR.discus_repeat:
				throw_response = randi_range(0, num_throw_responses)
			Dialogic.VAR.discus_repeat = throw_response
			Dialogic.start("hermesDiscusRepeat1")
		"discus_repeat_3":
			Dialogic.start("hermesRepeatFinished")
		_: 
			pass

func giveWingedSandals():
	print("GIVING SANDALS")
	trigger3.deactivate()
	trigger4.activate()
	current_phase = "running"
	runAnim.play("run")
	DataHandler.hermes_done = true

func alreadyFinished():
	footstepper.stop()
	current_phase = "discus_done"
	trigger1.deactivate()
	trigger2.deactivate()
	trigger3.activate()

func footstep():
	var step = load("res://assets/sounds/footstep/%s.wav" % randi_range(0, 4))
	if footstepper.playing: footstepper.stop()
	footstepper.stream = step
	footstepper.play()

func startDiscusRepeat():
	runTimer.stop()
	runAnim.stop()
	current_phase = "discus_repeat"
	trigger4.deactivate()
	Dialogic.start("hermesRepeat")

func startThrowRepeat():
	runTimer.stop()
	current_phase = "discus_repeat_1"
	trigger5.deactivate()
	Dialogic.start("hermesRepeatDiscus")

func startRun():
	trigger5.deactivate()
	trigger4.activate()
	current_phase = "running"

func finishRepeatThrow():
	hermesMesh.visible = true
	emit_signal("activity_finished")
	current_phase = "idle"
	await get_tree().create_timer(0.5).timeout
	trigger5.activate()
	runTimer.start(15)
