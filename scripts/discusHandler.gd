extends Node3D

@onready var iconBase := $discusCam/discusUI/margin/iconAnchor/iconBase
@onready var iconTarget := $discusCam/discusUI/margin/iconAnchor/iconTarget
@onready var iconIndicator := $discusCam/discusUI/margin/iconAnchor/iconIndicator
@onready var discusCam := $discusCam
@onready var discusUI := $discusCam/discusUI
@onready var discus := preload("res://scenes/discus.tscn")
@onready var rot_speed_1 := 3.0
@onready var rot_speed_2 := 5.0
@onready var rot_speed_3 := 8.0
@onready var throw_rot_val := 0.0
@onready var throw_height_val := 0.0
@onready var throw_strength_val := 0.0

const MAX_DISCUS_STRENGTH := 15.0
signal discus_thrown
@onready var current_state := "idle"
func _ready():
	discusUI.visible = false
	iconTarget.rotation = 0
	iconIndicator.rotation = 0

func _process(delta):
	match current_state:
		"spinning1": iconIndicator.rotation = wrapf(iconIndicator.rotation + rot_speed_1 * delta, 0, 2*PI)
		"spinning2": iconIndicator.rotation = wrapf(iconIndicator.rotation + rot_speed_1 * delta, 0, 2*PI)
		"spinning3": iconIndicator.rotation = wrapf(iconIndicator.rotation + rot_speed_1 * delta, 0, 2*PI)
		_: pass
	if "spinning" in current_state and Input.is_action_just_pressed("interact"):
		handleInteract()
	if Input.is_action_just_pressed("jump"):
		discusUI.visible= false
		get_parent().emit_signal("activity_finished")
	#print(iconIndicator.rotation)
func resetIcons():
	iconTarget.rotation = 0
	iconIndicator.rotation = 0

func throwDiscus(force):
	var new_discus := discus.instantiate()
	add_child(new_discus)
	new_discus.global_position = discusCam.global_position
	new_discus.apply_central_impulse(force)
	print(force)

func startThrow():
	throw_rot_val = 0.0
	throw_height_val = 0.0
	throw_strength_val = 0.0
	discusUI.visible = true
	resetIcons()
	getRandomRot()
	current_state = "spinning1"
	
func getThrowForce():
	#var throw_force = (-discusCam.global_basis.z).rotated(discusCam.global_basis.y, throw_rot_val)
	#throw_force = throw_force.rotated(discusCam.global_basis.x, throw_height_val)
	#throw_force = throw_force.normalized() * throw_strength_val
	
	var throw_force = (-discusCam.global_basis.z)
	throw_force = throw_force.rotated(discusCam.global_basis.x, deg_to_rad(45))
	throw_force = throw_force.normalized() * MAX_DISCUS_STRENGTH
	return throw_force
	
func getRandomRot():
	pass
	#iconTarget.rotation = deg_to_rad(randi_range(-90, 90))

func handleInteract():
	var target_diff = angle_difference(iconTarget.rotation,iconIndicator.rotation)/PI
	match current_state:
		"spinning1": 
			current_state = "spinning2"
			throw_rot_val = remap(target_diff, -1, 1, deg_to_rad(-45), deg_to_rad(45))
		"spinning2":
			current_state = "spinning3"
			throw_height_val = remap(target_diff, -1, 1, deg_to_rad(0), deg_to_rad(90))
		"spinning3":
			current_state = "throwing"
			throw_strength_val = remap(abs(target_diff), 1, 0, 0, MAX_DISCUS_STRENGTH)
			var throw_force = getThrowForce()
			throwDiscus(throw_force)
			startThrow()
			#emit_signal("discus_thrown")
			
