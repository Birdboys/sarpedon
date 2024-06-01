extends Node
class_name State

signal transitioned
var parent

func enter():
	pass

func exit():
	pass

func update(_delta):
	pass

func physics_update(_delta):
	pass
	
func unhandled_input(event):
	handleCamera(event)

func handleCamera(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			parent.rotate_y(-event.relative.x * parent.sensitivity)
			parent.camera.rotate_x(-event.relative.y * parent.sensitivity)
			parent.camera.rotation.x = clamp(parent.camera.rotation.x, deg_to_rad(-60), deg_to_rad(85))

func handleMovementInput(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (parent.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		parent.velocity.x = direction.x * parent.walk_speed
		parent.velocity.z = direction.z * parent.walk_speed
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, parent.walk_speed*10.0*delta)
		parent.velocity.z = move_toward(parent.velocity.z, 0, parent.walk_speed*10.0*delta)
