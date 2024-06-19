extends RigidBody3D

@onready var shoreFinder := $shoreFinder
@onready var enterBox := $enterBox
@onready var exitBox := $exitBox
@export var boat_force := 1000.0
@export var boat_torque := 100.0
@export var max_boat_velocity := 15.0
@export var max_boat_angular_velocity := 0.5
var in_boat := false

func _ready():
	enterBox.interacted.connect(playerEnter)
	exitBox.interacted.connect(playerExit)

func _integrate_forces(state):
	if state.linear_velocity.length() >= max_boat_velocity: 
		state.linear_velocity = state.linear_velocity.normalized() * max_boat_velocity
	if state.angular_velocity.length() >= max_boat_angular_velocity: 
		state.angular_velocity = state.angular_velocity.normalized() * max_boat_angular_velocity
	if len(shoreFinder.get_overlapping_bodies()) > 0: 
		state.linear_velocity = state.linear_velocity * 0.75

func controlBoat(inputs, delta):
	#apply_central_force(-transform.basis.z * boat_force)
	if inputs.y:
		apply_central_force(inputs.y * -transform.basis.z * boat_force * delta)
	if inputs.x:
		apply_torque(-inputs.x * Vector3.UP * boat_torque * delta)

func getPlayerPos():
	return $playerPosition.global_position
	
func getExitPos():
	return $exitPosition.global_position
	
func playerEnter():
	freeze = false
	in_boat = true
	enterBox.deactivate()
	exitBox.activate()
	
func playerExit():
	freeze = true
	in_boat = false
	enterBox.activate()
	exitBox.deactivate()
