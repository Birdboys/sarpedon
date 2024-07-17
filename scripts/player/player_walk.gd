extends State
@export var move_speed := 5.0

func enter():
	if parent.has_invis_helmet and Input.is_action_pressed("sneak"):
		await get_tree().process_frame
		emit_signal("transitioned", self, "playerSneak")

func update(delta):
	if parent.has_bag and Input.is_action_just_pressed("inventory"):
		emit_signal("transitioned", self, "playerInventory")
	
	parent.handleMovementInput(delta, move_speed)
	
	if Input.is_action_just_pressed("jump") and parent.is_on_floor():
		print("JUMPED")
		emit_signal("transitioned", self, "playerJump")
		return
	
	if Input.is_action_just_pressed("sneak") and parent.has_invis_helmet:
		emit_signal("transitioned", self, "playerSneak")
		return
	parent.move_and_slide()
	
	if not parent.is_on_floor():
		emit_signal("transitioned", self, "playerAirborn")
		
	parent.syncCameras()
