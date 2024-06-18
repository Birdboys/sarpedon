extends CharacterBody3D


@export var walk_speed := 5.0
@export var jump_strength := 4.5
@export var sensitivity := .01
@export var gravity := 10.0

@onready var stateMachine := $stateMachine
@onready var camera := $neck/playerCam
@onready var uiCamera := $neck/playerCam/hudViewportContainer/hudViewport/uiCam
@onready var hoverRay := $hoverRay
@onready var lookRay := $neck/playerCam/lookRay
@onready var interactPrompt := $UI/UIBase/interactPrompt

var boat
#INTERACTION TYPES
#1) INTERACT TO PULL UP LISTENING DIALOGUE
#2) INTERACT TO PULL UP TALKING DIALOGUE
#3) INTERACT TO DO SOMETHING TO ITEM
func _ready():
	stateMachine.initialize(self) 
	Dialogic.signal_event.connect(handleDialogue)
	
func _process(delta):
	uiCamera.global_transform = camera.global_transform
func _physics_process(delta):
	handlePrompt()

func _unhandled_input(event):
	if stateMachine.current_state.camera_control: handleCamera(event)
	if Input.is_action_just_pressed("interact") and stateMachine.current_state.interact_control: 
		handleInteract()
	
func handlePrompt():
	if lookRay.is_colliding():
		if lookRay.get_collider().interactable:
			interactPrompt.text = lookRay.get_collider().getPrompt()
	else:
		interactPrompt.text = ""

func handleCamera(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * sensitivity)
			camera.rotate_x(-event.relative.y * sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(85))

func handleMovementInput(delta, speed):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed*10.0*delta)
		velocity.z = move_toward(velocity.z, 0, speed*10.0*delta)

func handleInteract():
	if lookRay.is_colliding():
		var collider = lookRay.get_collider()
		var ret = collider.interact()
		match ret:
			"boat_enter": 
				boat = collider.get_parent()
				stateMachine.on_state_transition(stateMachine.current_state, "playerBoat")
			"boat_exit":
				stateMachine.on_state_transition(stateMachine.current_state, "playerWalk")
			_: pass

func handleDialogue(type):
	match type:
		"blocking":
			stateMachine.on_state_transition(stateMachine.current_state, "playerTalk")
