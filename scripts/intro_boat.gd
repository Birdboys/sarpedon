extends Node3D

@onready var boatMesh := $boatMesh
@onready var introCam := $camAnchor/camNeck/introCam
@onready var camNeck := $camAnchor/camNeck
@onready var camAnchor := $camAnchor
@onready var introBlack := $camAnchor/camNeck/introCam/introBlack
@onready var tutorialPrompts := $camAnchor/camNeck/introCam/tutorialPrompts
@onready var boatAnim := $boatAnim
@onready var boat_angular_velocity := 0.0
@onready var current_phase := "idle"
@onready var sensitivity := .01
@onready var can_look := true
@export var real_boat : CharacterBody3D
signal activity_finished

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	boatMesh.mesh.surface_get_material(0).no_depth_test = true
	
func _process(_delta):
	match current_phase:
		"looking":
			var rot = Vector3(introCam.rotation.x, camNeck.rotation.y, 0)
			if rot.length() > 0.8: 
				current_phase = "tweening"
				var open_tween = get_tree().create_tween()
				open_tween.tween_property(tutorialPrompts, "modulate", Color.TRANSPARENT, 0.5)
				open_tween.tween_property(tutorialPrompts, "text", DataHandler.translate("OPEN [INTERACT]"), 0)
				open_tween.tween_property(tutorialPrompts, "modulate", Color.WHITE, 0.5)
				await open_tween.finished
				current_phase = "opening"
		"opening":
			if Input.is_action_just_pressed("interact"):
				current_phase = "tweening"
				tutorialPrompts.text = ""
				boatAnim.play("boat_open")
				await boatAnim.animation_finished
				current_phase = "exiting"
				tutorialPrompts.text = DataHandler.translate("EXIT [INTERACT]")
		"exiting":
			if Input.is_action_just_pressed("interact"):
				tutorialPrompts.text = ""
				current_phase = "tweening"
				boatAnim.play("boat_exit")
				AudioHandler.playSound3D("boat_exit", global_position)
				
func _unhandled_input(event):
	if not can_look: return
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			camNeck.rotate_y(-event.relative.x * sensitivity)
			camNeck.rotation.y = clamp(camNeck.rotation.y, deg_to_rad(-60), deg_to_rad(60))
			introCam.rotate_x(-event.relative.y * sensitivity)
			introCam.rotation.x = clamp(introCam.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func transitionCamera(initial_cam: Camera3D):
	initial_cam.current = false
	introCam.current = true
	introBlack.visible = false
	can_look = true
	tutorialPrompts.text = "USE MOUSE TO LOOK"
	current_phase = "looking"

func unTransitionCamera(initial_camera: Camera3D):
	var camera_tween = get_tree().create_tween().set_parallel(true)
	camera_tween.tween_property(introCam, "global_transform", initial_camera.global_transform, 1.0)
	camera_tween.tween_property(introCam, "fov", initial_camera.fov, 1.0)
	await camera_tween.finished
	AudioHandler.playSound3D("splash", initial_camera.get_parent().global_position)
	introCam.current = false
	initial_camera.current = true
	visible = false
	real_boat.visible = true
	return

func introDone():
	emit_signal("activity_finished")
	boatMesh.mesh.surface_get_material(0).no_depth_test = false
