extends State
@export var move_speed := 5.0

func update(delta):
	parent.handleMovementInput(delta, move_speed)
	parent.velocity.y -= parent.gravity * delta
	parent.move_and_slide()
	parent.syncCameras()
	if parent.has_winged_sandals and Input.is_action_pressed("jump"):
		emit_signal("transitioned", self, "playerHover")
		return
		
	if parent.is_on_floor():
		parent.handleFootstep()
		emit_signal("transitioned", self, "playerWalk")
		return
	
	
