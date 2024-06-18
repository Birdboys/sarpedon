extends State

@export var move_speed := 7.5
@export var hover_dist := 0.5
@export var hover_strength := 10.0


func enter():
	parent.hoverRay.enabled = true
	
func exit():
	parent.hoverRay.enabled = false
	
func update(delta):
	parent.handleMovementInput(delta, move_speed)
	
	if parent.hoverRay.is_colliding():
		var ground_pos = parent.hoverRay.get_collision_point()
		var ground_distance = parent.hoverRay.global_position.y - ground_pos.y
		parent.velocity.y = move_toward(parent.velocity.y, 0, pow(ground_distance/hover_dist,2) * delta * hover_strength)
		parent.global_position.y = move_toward(parent.global_position.y, ground_pos.y + hover_dist + 1.0, pow(ground_distance/hover_dist,2) * delta * hover_strength)
	else:
		parent.velocity.y -= parent.gravity * delta
	parent.move_and_slide()
	
	if Input.is_action_just_released("jump"):
		emit_signal("transitioned", self, "playerAirborn")
		return
	if parent.is_on_floor():
		emit_signal("transitioned", self, "playerWalk")
		
	parent.uiCamera.global_transform = parent.camera.global_transform
