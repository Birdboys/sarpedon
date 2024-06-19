extends Node3D

@onready var trigger1 := $trigger1
@onready var trigger2 := $trigger2
@onready var monteCam := $monteCam
@onready var billboardComp := $graeaeMesh/billboardComponent
@onready var graeaeMesh := $graeaeMesh
@onready var monteHandler := $monteHandler

signal activity_finished

func _ready():
	Dialogic.signal_event.connect(handleDialogue)
	trigger1.interacted.connect(firstInteraction)
	trigger2.interacted.connect(monteRound1)

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

func handleDialogue(type):
	match type:
		"swapCups": monteHandler.swapRandomCups()
		_: pass
	
func firstInteraction():
	Dialogic.start("graeaeIntro")
	trigger1.deactivate()
	trigger2.activate()

func secondInteraction():
	Dialogic.start("graeaeExplanation")
	trigger1.deactivate()
	trigger2.activate()
	billboardComp.do_billboard = false
	graeaeMesh.rotation.y = 0

func monteRound1():
	Dialogic.start("graeaeMonte1")
