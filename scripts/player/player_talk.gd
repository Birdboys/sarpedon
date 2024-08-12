extends State

func enter():
	parent.velocity.x = 0
	parent.velocity.z = 0
	parent.interactPrompt.text = ""
	Dialogic.timeline_ended.connect(dialogueEnded)
	
	if parent.shield_hold: parent.setShieldHold(false)

func update(delta):
	if not parent.is_on_floor():
		parent.velocity.y -= parent.gravity * delta
		parent.move_and_slide()
		
func exit():
	Dialogic.timeline_ended.disconnect(dialogueEnded)
	parent.uiCamera.global_transform = parent.camera.global_transform
	
func dialogueEnded():
	emit_signal("transitioned", self, "playerWalk")
	pass
