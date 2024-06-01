extends State

func enter():
	parent.velocity.y = parent.jump_strength
	
func update(delta):
	handleMovementInput(delta)
	parent.velocity.y -= parent.gravity * delta
	parent.move_and_slide()
	
	if parent.is_on_floor():
		emit_signal("transitioned", self, "playerWalk")
	if parent.velocity.y < 0:
		emit_signal("transitioned", self, "playerAirborn")
