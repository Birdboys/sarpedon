extends Node3D

@onready var iconBase := $discusCam/discusUI/margin/iconAnchor/iconBase
@onready var iconTarget := $discusCam/discusUI/margin/iconAnchor/iconTarget
@onready var iconIndicator := $discusCam/discusUI/margin/iconAnchor/iconIndicator
@onready var discusCam := $discusCam
@onready var discusUI := $discusCam/discusUI
@onready var tutText := $discusCam/discusUI/margin/tutorialText
@onready var discus := preload("res://scenes/discus.tscn")
@onready var rot_speed_1 := 5.0
@onready var rot_speed_2 := 7.0
@onready var rot_speed_3 := 10.0
@onready var throw_rot_val := 0.0
@onready var throw_height_val := 0.0
@onready var throw_strength_val := 0.0
@onready var current_state := "idle"
var current_discus = null

const MAX_DISCUS_STRENGTH := 30.0
const MAX_DISCUS_TORQUE := 15.0
signal discus_landed

func _ready():
	discusUI.visible = false
	iconTarget.rotation = 0
	iconIndicator.rotation = 0

func _process(delta):
	#print(current_state)
	match current_state:
		"spinning1": iconIndicator.rotation = wrapf(iconIndicator.rotation + rot_speed_1 * delta, 0, 2*PI)
		"spinning2": iconIndicator.rotation = wrapf(iconIndicator.rotation + rot_speed_2 * delta, 0, 2*PI)
		"spinning3": iconIndicator.rotation = wrapf(iconIndicator.rotation + rot_speed_3 * delta, 0, 2*PI)
		"throwing": if current_discus: discusCam.look_at(current_discus.global_position)
		_: pass
	if "spinning" in current_state and Input.is_action_just_pressed("interact"):
		handleInteract()
	
func resetIcons():
	iconTarget.rotation = 0
	iconIndicator.rotation = 0

func throwDiscus(force):
	tutText.visible = false
	var new_discus := discus.instantiate()
	add_child(new_discus)
	new_discus.global_position = discusCam.global_position - Vector3.UP * 0.25
	new_discus.apply_central_impulse(force)
	new_discus.apply_torque_impulse(Vector3.LEFT * force.length())
	new_discus.landed.connect(discusLanded)
	new_discus.thrown()
	current_discus = new_discus
	current_state = "throwing" 
	
func discusLanded():
	current_state = "idle"
	current_discus = null
	discusUI.visible = false
	var cam_tween = get_tree().create_tween()
	cam_tween.tween_property(discusCam, "rotation", Vector3.ZERO, 1.0)
	await cam_tween.finished
	emit_signal("discus_landed")
	
func startThrow():
	throw_rot_val = 0.0
	throw_height_val = 0.0
	throw_strength_val = 0.0
	discusUI.visible = true
	tutText.visible = true
	resetIcons()
	getRandomRot()
	current_state = "spinning1"

func startAutoThrow():
	current_state = "auto_throw"
	throw_rot_val = 0.0
	throw_height_val = 0.0
	throw_strength_val = 0.0
	discusUI.visible = true
	tutText.visible = false
	resetIcons()
	getRandomRot()
	var auto_tween = get_tree().create_tween()
	auto_tween.tween_property(iconIndicator, "rotation", deg_to_rad(360), (PI)/rot_speed_1)
	auto_tween.tween_property(iconIndicator, "rotation", 0, 0)
	auto_tween.tween_property(iconIndicator, "rotation", deg_to_rad(360), (2*PI)/rot_speed_1)
	auto_tween.tween_property(iconIndicator, "rotation", 0, 0)
	auto_tween.tween_callback(handleInteract)
	auto_tween.tween_property(iconIndicator, "rotation", deg_to_rad(360), (2*PI)/rot_speed_2)
	auto_tween.tween_property(iconIndicator, "rotation", 0, 0)
	auto_tween.tween_callback(handleInteract)
	auto_tween.tween_property(iconIndicator, "rotation", deg_to_rad(360), (2*PI)/rot_speed_3)
	auto_tween.tween_property(tutText, "visible", false, 0)
	auto_tween.tween_callback(handleInteract)
	auto_tween.tween_callback(throwHermesDiscus)


func getThrowForce():
	#var throw_force = (-discusCam.global_basis.z).rotated(discusCam.global_basis.y)
	#throw_force = throw_force.rotated(discusCam.global_basis.x, deg_to_rad(45))
	#throw_force = throw_force.normalized() * MAX_DISCUS_STRENGTH
	var throw_force = (-discusCam.global_basis.z).rotated(discusCam.global_basis.y, throw_rot_val)
	throw_force = throw_force.rotated(discusCam.global_basis.x, throw_height_val)
	throw_force = throw_force.normalized() * throw_strength_val
	
	return throw_force

func throwHermesDiscus():
	var throw_force = (-discusCam.global_basis.z).rotated(discusCam.global_basis.x, deg_to_rad(45))
	throw_force = throw_force.normalized() * MAX_DISCUS_STRENGTH * 5
	throwDiscus(throw_force)
	AudioHandler.playSound("hermes_throw")
	
func getRandomRot():
	#iconTarget.rotation = deg_to_rad(randi_range(-90, 90))
	iconIndicator.rotation = wrapf(iconTarget.rotation + deg_to_rad(180), 0, 2*PI)

func handleInteract():
	AudioHandler.playSound("ui_click")
	var icon_tween = get_tree().create_tween()
	icon_tween.tween_property(iconIndicator, "modulate", Color(0.2, 0.2, 0.2), 0.0)
	icon_tween.tween_interval(0.1)
	icon_tween.tween_property(iconIndicator, "modulate", Color(1, 1, 1), 0.15)
	var target_diff = angle_difference(iconTarget.rotation,iconIndicator.rotation)/PI
	match current_state:
		"spinning1": 
			current_state = "spinning2"
			throw_strength_val = remap(abs(target_diff), 1, 0, 0, MAX_DISCUS_STRENGTH)
		"spinning2":
			current_state = "spinning3"
			throw_height_val = remap(target_diff, -1, 1, deg_to_rad(0), deg_to_rad(90))
		"spinning3":
			throw_rot_val = remap(target_diff, 1, -1, deg_to_rad(-45), deg_to_rad(45))
			var throw_force = getThrowForce()
			throwDiscus(throw_force)
			AudioHandler.playSound("throw")
		_:
			pass
