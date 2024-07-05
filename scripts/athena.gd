extends Node3D
@onready var trigger1 := $trigger1
@onready var trigger2 := $trigger2
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
	weaveHandler.weave_finished.connect(weaveFinished)
	weaveUI.visible = false 
	playArea.size.x = weaveHandler.x_dim * weaveHandler.tile_size + 32
	playArea.size.y = weaveHandler.y_dim * weaveHandler.tile_size
	
func _process(delta):
	pass

func introDialogue():
	Dialogic.start("athenaIntro")
	trigger1.deactivate()
	trigger2.activate()

func startWeave():
	trigger2.deactivate()
	Dialogic.start("athenaWeaveExplanation")
	
func handleDialogue(type):
	match type:
		"startWeave": 
			weaveUI.visible = true
			weaveHandler.newProblem()
		"hideTapestry":
			weaveHandler.hideTapestry()

func weaveFinished():
	weaveHandler.x_dim *= 2
	weaveHandler.y_dim *= 2
	playArea.size.x = weaveHandler.x_dim * weaveHandler.tile_size + 32
	playArea.size.y = weaveHandler.y_dim * weaveHandler.tile_size
	weaveHandler.newProblem()
	print(weaveHandler.x_dim, weaveHandler.y_dim)

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