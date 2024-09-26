extends CharacterBody3D

@onready var shoreFinder := $shoreFinder
@onready var boatMesh := $boatMesh
@onready var takeSupplyBox := $takeSupplyBox
@onready var enterBox := $enterBox
@onready var exitBox := $exitBox
@onready var creakTimer := $creakTimer
@onready var boat_angular_velocity := 0.0
@onready var intro_phase := "idle"
@export var boat_force := 5
@export var boat_torque := 5
@export var max_boat_velocity := 10.0
@export var max_boat_angular_velocity := 0.5
@export var boat_friction := 0.4
var in_boat := false

signal activity_finished

func _ready():
	takeSupplyBox.interacted.connect(playerTakeSupplies)
	enterBox.interacted.connect(playerEnter)
	exitBox.interacted.connect(playerExit)
	creakTimer.timeout.connect(playCreakSound)
	
func _process(delta):
	rotate(Vector3.UP, boat_angular_velocity * delta)
	if not is_on_floor(): velocity.y -= 10.0 * delta
	move_and_slide()

func _physics_process(delta):
	if in_boat and len(shoreFinder.get_overlapping_bodies()) > 0:
		exitBox.interactable = true
	else:
		exitBox.interactable = false
	if velocity.length() >= max_boat_velocity: 
		velocity = velocity.normalized() * max_boat_velocity
	velocity = velocity.move_toward(Vector3.ZERO, delta * boat_friction * boat_force)
	boat_angular_velocity = move_toward(boat_angular_velocity, 0, delta * boat_friction * boat_torque)
	
func controlBoat(inputs, delta):
	if inputs.y:
		velocity += inputs.y * -transform.basis.z * boat_force * delta
	if inputs.x:
		boat_angular_velocity = boat_angular_velocity + (-inputs.x * boat_torque * delta)
		boat_angular_velocity = clampf(boat_angular_velocity, -max_boat_angular_velocity, max_boat_angular_velocity)

func getPlayerPos():
	return $playerPosition.global_position
	
func getExitPos():
	return $exitPosition.global_position
	
func playerEnter():
	in_boat = true
	enterBox.deactivate()
	exitBox.activate()
	set_collision_layer_value(1, false)
	boatMesh.mesh.surface_get_material(0).no_depth_test = true
	creakTimer.start(randf_range(2.0,5.0))
	
func playerExit():
	in_boat = false
	enterBox.activate()
	exitBox.deactivate()
	set_collision_layer_value(1, true)
	velocity = Vector3.ZERO
	boat_angular_velocity = 0
	boatMesh.mesh.surface_get_material(0).no_depth_test = false
	creakTimer.stop()

func playerTakeSupplies():
	takeSupplyBox.deactivate()

func playCreakSound():
	if velocity.length() > 1.5: 
		AudioHandler.playSound("boat_creak")
	creakTimer.start(randf_range(3.0,6.0))
