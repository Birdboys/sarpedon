extends CharacterBody3D

@onready var maidenMesh := $maidenMesh
@onready var maidenCam := $maidenCam
@onready var leaveTrigger := $leaveTrigger
@onready var maidenAnim := $maidenAnim
@onready var current_phase := "idle"
@onready var spawn_radius := 3.0
@export var summonArea : Area3D
var player = null

signal activity_finished
signal maiden_left
# Called when the node enters the scene tree for the first time.
func _ready():
	summonArea.body_exited.connect(startInteraction)
	leaveTrigger.body_exited.connect(goAway)
	maidenMesh.visible = false
	maidenMesh.transparency = 0.0
	Dialogic.signal_event.connect(handleDialogue)

func startInteraction(body):
	var player_pos = body.global_position
	var target_offset = Vector3(body.camera.global_basis.z.x, 0, body.camera.global_basis.z.z).normalized() * spawn_radius
	var new_pos = player_pos + target_offset
	AudioHandler.playSound3D("maiden_interrupt", new_pos)
	current_phase = "interject"
	player = body
	maidenMesh.visible = true
	global_position = new_pos
	#apply_floor_snap() 
	body.startActivity(self)
	summonArea.queue_free()
	Dialogic.start("maidenInterject")
	maidenAnim.play("sway")

func handleDialogue(type):
	match type: 
		"interjectDone":
			rotatePlayer()
			Dialogic.start("maidenIntro")
		"introDone":
			leaveTrigger.monitoring = true
			leaveTrigger.global_position = player.global_position
			emit_signal("activity_finished")

func transitionCamera(_initial_camera: Camera3D):
	return
	
func unTransitionCamera(initial_camera: Camera3D):
	var camera_tween = get_tree().create_tween()
	camera_tween.tween_property(maidenCam, "global_transform", initial_camera.global_transform, 1.0)
	await camera_tween.finished
	maidenCam.current = false
	player.camera.current = true
	return

func goAway(_body):
	AudioHandler.playSound3D("maiden_leave", global_position)
	print("WENT AAWAY")	
	emit_signal("maiden_left")
	leaveTrigger.set_deferred("monitoring", false)
	AudioHandler.tweenPlayer("music", 0.0, 3.0)
	var leave_pos = global_position + Vector3(Vector3(global_position - player.global_position).x, 0, Vector3(global_position - player.global_position).z).normalized() * 20
	var leave_tween = get_tree().create_tween().set_parallel(true).set_ease(Tween.EASE_IN)
	leave_tween.tween_property(self, "global_position", leave_pos, 1.5)
	leave_tween.tween_property(maidenMesh, "transparency", 1.0, 1.5)
	await leave_tween.finished
	player = null
	queue_free()
	
func rotatePlayer():
	maidenCam.global_transform = player.camera.global_transform
	maidenCam.current = true
	player.camera.current = false
	var new_player_transform = player.global_basis.looking_at(global_position)
	var cam_transform = maidenCam.global_transform.looking_at(global_position)
	var player_tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_parallel(true)
	player_tween.tween_property(player, "global_basis", new_player_transform, 0.5)
	player_tween.tween_property(maidenCam, "global_transform", cam_transform, 0.5)
