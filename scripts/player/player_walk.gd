extends State
@export var move_speed := 5.0

func enter():
	parent.camAnim.play("walk")
	if parent.has_invis_helmet and Input.is_action_pressed("use_helmet"):
		await get_tree().process_frame
		emit_signal("transitioned", self, "playerSneak")

func update(delta):
	if not movement_control: return
	if parent.has_bag and Input.is_action_just_pressed("inventory"):
		parent.camAnim.stop()
		emit_signal("transitioned", self, "playerInventory")
	
	if Input.is_action_just_pressed("jump") and parent.is_on_floor():
		print("JUMPED")
		emit_signal("transitioned", self, "playerJump")
		return
	
	if Input.is_action_just_pressed("use_helmet") and parent.has_invis_helmet:
		emit_signal("transitioned", self, "playerSneak")
		return
		
	
	parent.handleMovementInput(delta, move_speed)
	parent.move_and_slide()
	
	if not parent.is_on_floor():
		emit_signal("transitioned", self, "playerAirborn")
	
	if parent.velocity.length() > 0:
		parent.camAnim.play("walk")
	else:
		parent.camAnim.stop(true)
		
	parent.syncCameras()

func exit():
	parent.camAnim.stop()
