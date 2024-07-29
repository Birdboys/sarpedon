extends State
@export var sneak_speed := 3.0
@onready var cam_tween = get_tree().create_tween().set_parallel(true)

func enter():
	parent.camAnim.play("sneak")
	if cam_tween is Tween:
		cam_tween.kill()
	cam_tween = get_tree().create_tween().set_parallel(true)
	cam_tween.tween_property(parent.camera, "v_offset", parent.camera.v_offset - 0.05, 0.5)
	parent.postProcessAnim.play("start_sneak")
	
func update(delta):
	if Input.is_action_just_pressed("inventory"):
		emit_signal("transitioned", self, "playerInventory")
	
	if Input.is_action_just_released("use_helmet"):
		emit_signal("transitioned", self, "playerWalk")
		
	parent.handleMovementInput(delta, sneak_speed)
	
	if Input.is_action_just_pressed("jump") and parent.is_on_floor():
		emit_signal("transitioned", self, "playerJump")
		return
	parent.move_and_slide()
	
	if not parent.is_on_floor():
		emit_signal("transitioned", self, "playerAirborn")
	
	if parent.velocity.length() > 0:
		parent.camAnim.play("sneak")
	else:
		parent.camAnim.stop(true)
		
	parent.syncCameras()

func exit():
	cam_tween.kill()
	cam_tween = get_tree().create_tween().set_parallel(true)
	cam_tween.tween_property(parent.camera, "v_offset", parent.camera.v_offset + 0.05, 0.5)
	parent.postProcessAnim.play_backwards("start_sneak")
	parent.camAnim.stop()
