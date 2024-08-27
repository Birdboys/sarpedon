extends Node3D

@onready var stheno := $stheno
@onready var euryale := $euryale
@onready var sisterTalkCam := $sisterTalkCam
@onready var talk_cam_tween
@onready var current_phase := "angry"
@export var cave_trigger : Area3D
@export var cave_player_pos : Node3D
var player = null
signal activity_finished

func _ready():
	stheno.trigger1.interacted.connect(startIntroDialogue)
	euryale.trigger1.interacted.connect(startIntroDialogue)
	cave_trigger.body_entered.connect(playerEnteredCave)
	Dialogic.text_signal.connect(handleTextSignal)
	Dialogic.signal_event.connect(handleDialogue)
	
func setGorgonTargetPos(pos):
	stheno.setTargetPos(pos)
	euryale.setTargetPos(pos)

func startIntroDialogue():
	stheno.trigger1.deactivate()
	euryale.trigger1.deactivate()
	Dialogic.start("sistersMaidenIntro")
	current_phase = "intro"

func handleDialogue(type):
	match type:
		"introDone":
			emit_signal("activity_finished")
			current_phase = "aware"
		"warningOver":
			var player_tween = get_tree().create_tween()
			player_tween.tween_property(player, "global_position", cave_player_pos.position, 0.5)
			await player_tween.finished
			current_phase = "angry"
			player = null
			emit_signal("activity_finished")
		_: pass
		
func handleTextSignal(type):
	match type:
		"stheno_talk":
			var stheno_basis = sisterTalkCam.global_transform.looking_at(stheno.global_position)
			if talk_cam_tween is Tween:
				talk_cam_tween.kill()
			talk_cam_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
			talk_cam_tween.tween_property(sisterTalkCam, "global_transform", stheno_basis, 0.75)
		"euryale_talk":
			var euryale_basis = sisterTalkCam.global_transform.looking_at(euryale.global_position)
			if talk_cam_tween is Tween:
				talk_cam_tween.kill()
			talk_cam_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
			talk_cam_tween.tween_property(sisterTalkCam, "global_transform", euryale_basis, 0.75)
		_: pass

func playerEnteredCave(body):
	if body.is_invis: return
	player = body
	match current_phase:
		"idle":
			stheno.trigger1.deactivate()
			euryale.trigger1.deactivate()
			player.startActivity(self)
			Dialogic.start("sistersMaidenInterruption")
		"aware":
			stheno.trigger1.deactivate()
			euryale.trigger1.deactivate()
			player.startActivity(self)
			Dialogic.start("sistersMaidenWarning")
		"angry":
			current_phase = "gorgon"
			stheno.changeToGorgon()
			euryale.changeToGorgon()

func lament():
	current_phase = "gorgon"
	stheno.trigger1.deactivate()
	euryale.trigger1.deactivate()
	stheno.changeToGorgon()
	euryale.changeToGorgon()
	Dialogic.toggleAutoload(true)
	Dialogic.start("sistersGorgonRetaliation")
	await Dialogic.timeline_started
	Dialogic.timeline_started.connect(handleAutoDialogue)

func sisterAwake():
	current_phase = "angry"
	stheno.trigger1.deactivate()
	euryale.trigger1.deactivate()
	
func transitionCamera(initial_camera: Camera3D):
	sisterTalkCam.global_transform = initial_camera.global_transform
	
	var camera_tween = get_tree().create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
	var center_pos = (stheno.global_position + euryale.global_position)/2
	var final_tran = sisterTalkCam.global_transform.looking_at(center_pos)
	sisterTalkCam.global_transform = initial_camera.global_transform
	initial_camera.current = false
	sisterTalkCam.current = true
	camera_tween.tween_property(sisterTalkCam, "global_transform", final_tran, 0.75)
	await camera_tween.finished
	return

func unTransitionCamera(initial_camera: Camera3D):
	var camera_tween = get_tree().create_tween().set_parallel(true)
	camera_tween.tween_property(sisterTalkCam, "global_transform", initial_camera.global_transform, 1.0)
	camera_tween.tween_property(sisterTalkCam, "fov", initial_camera.fov, 1.0)
	await camera_tween.finished
	sisterTalkCam.current = false
	initial_camera.current = true
	return

func handleAutoDialogue():
	Dialogic.timeline_started.disconnect(handleAutoDialogue)
	Dialogic.toggleAutoload(false)
	
