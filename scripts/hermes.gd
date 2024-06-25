extends Node3D

@onready var trigger1 := $trigger1
@onready var trigger2 := $trigger2
@onready var current_phase := "idle"
@onready var discusCam := $discusHandler/discusCam
@onready var discusHandler := $discusHandler

signal activity_finished

func _ready():
	Dialogic.signal_event.connect(handleDialogue)
	trigger1.interacted.connect(introDialogue)
	discusHandler.discus_thrown.connect(discusThrown)
	#trigger2.interacted.connect(startDiscus)
	
func handleDialogue(type):
	pass

func introDialogue():
	current_phase = "intro"
	Dialogic.start("hermesIntro")
	trigger1.deactivate()
	trigger2.activate()

#func startDiscus():
	#discusHandler.startThrow()

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
	discusHandler.startThrow()
	return

func unTransitionCamera(initial_camera: Camera3D):
	var camera_tween = get_tree().create_tween().set_parallel(true)
	camera_tween.tween_property(discusCam, "global_transform", initial_camera.global_transform, 1.0)
	camera_tween.tween_property(discusCam, "fov", initial_camera.fov, 1.0)
	await camera_tween.finished
	discusCam.current = false
	initial_camera.current = true
	return

func discusThrown():
	emit_signal("activity_finished")
