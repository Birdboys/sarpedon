extends CharacterBody3D

@export var jump_strength := 4.5
@export var sensitivity := .01
@export var gravity := 10.0

@onready var stateMachine := $stateMachine
@onready var walkState := $stateMachine/playerWalk
@onready var camera := $neck/playerCam
@onready var uiCamera := $neck/playerCam/hudViewportContainer/hudViewport/uiCam
@onready var backCamera := $backViewport/backCamera
@onready var hoverRay := $hoverRay
@onready var lookRay := $neck/playerCam/lookRay
@onready var backLookRay := $backViewport/backCamera/lookRay
@onready var interactPrompt := $UI/UIBase/interactPrompt
@onready var inventoryHandler := $UI/UIBase/inventory
@onready var footstepRay := $footstepRay
@onready var swordMesh := $neck/playerCam/swordMesh
@onready var shieldMesh := $neck/playerCam/shieldMesh
@onready var shieldAnim := $anims/shieldAnim
@onready var swordAnim := $anims/swordAnim
@onready var postProcessAnim := $anims/postProcessAnim
@onready var camAnim := $neck/playerCam/camAnim
@onready var invisEffect := $postProcess/invisEffect
@onready var petrifyPostProcess := $neck/playerCam/petrifyPostProcess
@onready var groundPoint := $groundArm/groundPoint
@onready var footstepPoint := $footstepPoint
@onready var petrifyTimer := $petrifyTimer
@onready var petrifyPlayer := $petrifyPlayer
@onready var flutterPlayer := $flutterPlayer
@onready var petrify_val := 0.0
@onready var petrify_rate := 0.3
@onready var petrify_cleanse_rate := 0.1
@onready var death_type := ""

@export var has_invis_helmet := true
@export var has_winged_sandals := true
@export var has_sword := false
@export var has_shield := false
@export var has_bag := false
@export var shield_hold := false
@export var is_invis := false

@onready var sword_up := false
@onready var shield_up := false
@onready var petrified := false
@onready var petrified_perma := false

var boat
var activityHandler

signal player_died(death_type)
signal footstep(pos, type)

func _ready():
	stateMachine.initialize(self) 
	Dialogic.signal_event.connect(handleDialogue)
	petrifyTimer.timeout.connect(deathByPetrify)
	PauseMenu.settingsMenu.sens_changed.connect(sensChanged)
	
func _process(delta):
	$UI/UIBase/fpsCounter.text = "FPS:%s" % Engine.get_frames_per_second()
	uiCamera.global_transform = camera.global_transform
	
func _physics_process(delta):
	petrified = false
	handlePrompt()
	handlePetrify(delta)
	
func _unhandled_input(event):
	if stateMachine.current_state.camera_control: handleCamera(event)
	if stateMachine.current_state.interact_control:
		if Input.is_action_just_pressed("interact"):
			handleInteract()
			
		if has_sword:
			if Input.is_action_just_pressed("equip_sword"):
				toggleSword()
			if sword_up and Input.is_action_just_pressed("use_sword"):
				swordAnim.play("sword_attack")
				
		if has_shield:
			if Input.is_action_just_pressed("equip_shield"):
				toggleShield()
			if shield_up and Input.is_action_just_pressed("use_shield"):
				setShieldHold(true)
			if shield_up and shield_hold and Input.is_action_just_released("use_shield"):
				setShieldHold(false)
				

func handlePrompt():
	if not stateMachine.current_state.interact_control:
		interactPrompt.text = ""
		return
	if lookRay.is_colliding():
		if lookRay.get_collider().interactable:
			interactPrompt.text = lookRay.get_collider().getPrompt()
	elif shield_hold and backLookRay.is_colliding():
		if backLookRay.get_collider().interactable:
			interactPrompt.text = backLookRay.get_collider().getPrompt()
	else:
		interactPrompt.text = ""
	interactPrompt.text = DataHandler.translate(interactPrompt.text)

func handleCamera(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * sensitivity)
			camera.rotate_x(-event.relative.y * sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(85))

func handleMovementInput(delta, speed):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed * (1.0 - petrify_val)
		velocity.z = direction.z * speed * (1.0 - petrify_val)
	else:
		velocity.x = move_toward(velocity.x, 0, speed*10.0*delta)
		velocity.z = move_toward(velocity.z, 0, speed*10.0*delta)

func handleInteract():
	var ret
	var collider
	if lookRay.is_colliding():
		collider = lookRay.get_collider()	
	elif shield_hold and backLookRay.is_colliding():
		collider = backLookRay.get_collider()
	else: return
	ret = collider.interact()
	match ret:
		"boat_take_supplies":
			has_bag = true
			has_sword = true
			walkState.movement_control = true
			stateMachine.on_state_transition(stateMachine.current_state, "playerInventory")
			
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
			stateMachine.on_state_transition(stateMachine.current_state, "playerActivity")
		"athena_take_shield":
			has_shield = true
			shield_up = false
			inventoryHandler.acquireItem("shield")
			stateMachine.on_state_transition(stateMachine.current_state, "playerInventory")
		"medusa_slain":
			pass
		"take_medusa_head":
			inventoryHandler.acquireItem("gorgoneion")
			stateMachine.on_state_transition(stateMachine.current_state, "playerInventory")
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
		AudioHandler.playSound("sword_unequip")
	else:
		swordAnim.play("sword_equip")
		AudioHandler.playSound("sword_equip")
	sword_up = not sword_up
	
func toggleShield():
	if shield_up:
		shieldAnim.play_backwards("shield_equip")
		AudioHandler.playSound("shield_unequip")
		print("EQUIPPING SHIELD")
	else:
		shieldAnim.play("shield_equip")
		AudioHandler.playSound("shield_equip")
		print("HOLSTERING SHIELD")
	shield_up = not shield_up
	shield_hold = false
	
func setShieldHold(raising):
	if raising:
		shieldAnim.play("shield_hold")
		AudioHandler.playSound("shield_hold")
	else:
		shieldAnim.play_backwards("shield_hold")
		AudioHandler.playSound("shield_hold_reverse")
		
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

func handlePetrify(delta):
	await get_tree().physics_frame
	if petrified_perma:
		petrifyPostProcess.mesh.material.set_shader_parameter("petrify_val", 1.0)
		petrifyPostProcess.visible = true
		return
	if petrified and not shield_hold: 
		petrify_val = move_toward(petrify_val, 1.0, petrify_rate * delta)
	else:
		petrify_val = move_toward(petrify_val, 0.0, petrify_cleanse_rate * delta)
	if petrify_val == 0:
		petrifyPostProcess.visible = false
		petrifyPlayer.stop()
	else:
		petrifyPostProcess.mesh.material.set_shader_parameter("petrify_val", petrify_val)
		petrifyPostProcess.visible = true
		if not petrifyPlayer.playing: petrifyPlayer.play()
		petrifyPlayer.volume_db = remap(clamp(petrify_val, 0, 0.5), 0, 0.5, -25, 0)
	if petrify_val > 0.9:
		if petrifyTimer.is_stopped():
			petrifyTimer.start(2)
	else:
		petrifyTimer.stop()

func petrify():
	petrified = true

func deathByPetrify():
	petrified_perma = true
	death_type = "petrify"
	stateMachine.on_state_transition(stateMachine.current_state, "playerDied")
	
func getGroundPos():
	return groundPoint.global_position

func exitingShallows(body):
	print("EXITING SHALLOWS")
	if stateMachine.current_state.name == "playerBoat" or stateMachine.current_state.name == "playerDied": return
	Dialogic.start("nearingDeepWater")

func enteringDeep(_body):
	if stateMachine.current_state.name == "playerBoat" or stateMachine.current_state.name == "playerDied": return
	death_type = "drowning"
	stateMachine.on_state_transition(stateMachine.current_state, "playerDied")

func sirenAttack():
	death_type = "siren"
	if stateMachine.current_state.name == "playerBoat": stateMachine.current_state.boat_death = true
	stateMachine.on_state_transition(stateMachine.current_state, "playerDied")

func gorgonAttack():
	if sword_up: toggleSword()
	if shield_up: toggleShield()
	camera.setTrauma(0.5, true)
	await get_tree().create_timer(1.5).timeout
	camera.setTrauma(0.0, false)
	death_type = "gorgon"
	stateMachine.on_state_transition(stateMachine.current_state, "playerDied")
	#petrified_perma = true
	
func handleFootstep(type=null):
	footstepRay.force_raycast_update()
	var ground_surface = footstepRay.get_collider()
	if ground_surface == null: return
	var surface_type = ground_surface.get_collision_layer()
	var footstep_pos = footstepPoint.global_position + velocity.normalized() * 0.1
	match surface_type:
		257: #cave
			AudioHandler.playSound3D("footstep_cave", footstep_pos)
		256: #grass
			AudioHandler.playSound3D("footstep_grass", footstep_pos)
		33: #water
			AudioHandler.playSound3D("splash", footstep_pos)
			AudioHandler.playSound3D("footstep_cave", footstep_pos)
			emit_signal("footstep", global_position, "loud")
		_:
			AudioHandler.playSound3D("footstep", footstep_pos)
	if stateMachine.current_state.name == "playerSneak":
		emit_signal("footstep", global_position, "sneak")
	else:
		emit_signal("footstep", global_position, "normal")

func swordAttack():
	var medusa
	if lookRay.is_colliding():
		medusa = lookRay.get_collider()
	elif backLookRay.is_colliding():
		medusa = backLookRay.get_collider()
	else: return
	if medusa.interact() != "medusa_slain": return
	medusa.get_parent().get_parent().slain()

func swordSound():
	AudioHandler.playSound("sword_swing")
	
func sensChanged(val):
	sensitivity = remap(val, 0.0, 100.0, 0.005, 0.015)
