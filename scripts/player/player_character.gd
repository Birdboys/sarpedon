extends CharacterBody3D


@export var walk_speed := 5.0
@export var jump_strength := 4.5
@export var sensitivity := .01
@export var gravity := 10.0

@onready var stateMachine := $stateMachine
@onready var camera := $neck/playerCam
@onready var uiCamera := $neck/playerCam/hudViewportContainer/hudViewport/uiCam
@onready var backCamera := $backViewport/backCamera
@onready var hoverRay := $hoverRay
@onready var lookRay := $neck/playerCam/lookRay
@onready var interactPrompt := $UI/UIBase/interactPrompt
@onready var inventoryHandler := $UI/UIBase/inventory
@onready var swordMesh := $neck/playerCam/swordMesh
@onready var shieldMesh := $neck/playerCam/shieldMesh
@onready var shieldAnim := $anims/shieldAnim
@onready var swordAnim := $anims/swordAnim
@onready var postProcessAnim := $anims/postProcessAnim
@onready var invisEffect := $postProcess/invisEffect

@export var has_invis_helmet := true
@export var has_winged_sandals := true
@export var has_sword := false
@export var has_shield := false
@export var has_bag := false
@export var shield_hold := false
@export var is_invis := false

@onready var sword_up := false
@onready var shield_up := false

var boat
var activityHandler

func _ready():
	stateMachine.initialize(self) 
	Dialogic.signal_event.connect(handleDialogue)
	PauseMenu.visibility_changed.connect(pauseToggled)
	
func _process(delta):
	$UI/UIBase/fpsCounter.text = "FPS:%s" % Engine.get_frames_per_second()
	uiCamera.global_transform = camera.global_transform

func _physics_process(delta):
	handlePrompt()
	
func _unhandled_input(event):
	if stateMachine.current_state.camera_control: handleCamera(event)
	if stateMachine.current_state.interact_control:
		if Input.is_action_just_pressed("interact"):
			handleInteract()
			
		if has_sword:
			if Input.is_action_just_pressed("sword_equip"):
				toggleSword()
			if sword_up and Input.is_action_just_pressed("sword_attack"):
				swordAnim.play("sword_attack")
				
		if has_shield:
			if Input.is_action_just_pressed("shield_equip"):
				toggleShield()
			if shield_up and Input.is_action_just_pressed("shield_hold"):
				setShieldHold(true)
			if shield_up and shield_hold and Input.is_action_just_released("shield_hold"):
				setShieldHold(false)
				

func handlePrompt():
	if not stateMachine.current_state.interact_control:
		return
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
			"graeae_explanation":
				activityHandler = collider.get_parent()
				stateMachine.on_state_transition(stateMachine.current_state, "playerActivity")
			"hermes_discus":
				activityHandler = collider.get_parent()
				stateMachine.on_state_transition(stateMachine.current_state, "playerActivity")
			"graeae_take_helmet":
				has_invis_helmet = true
				inventoryHandler.acquireItem("invis_helmet")
				stateMachine.on_state_transition(stateMachine.current_state, "playerInventory")
			"hermes_take_sandals":
				has_winged_sandals = true
				inventoryHandler.acquireItem("winged_sandals")
				stateMachine.on_state_transition(stateMachine.current_state, "playerInventory")
			"athena_weave":
				activityHandler = collider.get_parent()
				stateMachine.on_state_transition(stateMachine.current_state, "playerActivity")
			"sisters_intro":
				activityHandler = collider.get_parent().get_parent()
				print(activityHandler)
				stateMachine.on_state_transition(stateMachine.current_state, "playerActivity")
			_: pass

func handleDialogue(type):
	match type:
		"blocking":
			if stateMachine.current_state.name == "playerBoat":
				stateMachine.current_state.boat_dialogue = true
				stateMachine.on_state_transition(stateMachine.current_state, "playerBoatTalk")
			else:
				stateMachine.on_state_transition(stateMachine.current_state, "playerTalk")

func startActivity(handler):
	activityHandler = handler
	stateMachine.on_state_transition(stateMachine.current_state, "playerActivity")
	
func setSword(on := true):
	swordMesh.visible = on

func setShield(on := true):
	shieldMesh.visible = on
	
func toggleSword():
	if sword_up:
		swordAnim.play_backwards("sword_equip")
	else:
		swordAnim.play("sword_equip")
	sword_up = not sword_up
	
func toggleShield():
	if shield_up:
		shieldAnim.play_backwards("shield_equip")
		print("EQUIPPING SHIELD")
	else:
		shieldAnim.play("shield_equip")
		print("HOLSTERING SHIELD")
	shield_up = not shield_up
	shield_hold = false
	
func setShieldHold(raising):
	if raising:
		shieldAnim.play("shield_hold")
	else:
		shieldAnim.play_backwards("shield_hold")

func syncCameras():
	uiCamera.global_transform = camera.global_transform
	backCamera.global_transform = camera.global_transform
	backCamera.rotate_y(deg_to_rad(180))
	backCamera.rotation.x *= -1
	backCamera.rotation.x -= deg_to_rad(5)

func pauseToggled():
	if PauseMenu.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
