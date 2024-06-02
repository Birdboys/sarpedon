extends State
@export var move_speed := 5.0

func update(delta):
	parent.handleMovementInput(delta, move_speed)
	
	if Input.is_action_just_pressed("jump"):
		print("JUMPED")
		emit_signal("transitioned", self, "playerJump")
		return
	parent.move_and_slide()
	
	if not parent.is_on_floor():
		emit_signal("transitioned", self, "playerAirborn")
	
