extends State

func enter():
	parent.interactPrompt.text = ""
	#parent.uiCamera.current = false
	parent.activityHandler.activity_finished.connect(activityFinished)
	parent.setSword(false)
	parent.setShield(false)
	parent.velocity = Vector3.ZERO
	await parent.activityHandler.transitionCamera(parent.camera)

func update(delta):
	if not parent.is_on_floor():
		parent.velocity.y -= parent.gravity * delta
		parent.move_and_slide()
		
func exit():
	await parent.activityHandler.unTransitionCamera(parent.camera)
	parent.activityHandler.activity_finished.disconnect(activityFinished)
	parent.activityHandler = null
	parent.uiCamera.current = true
	parent.camera.current = true
	parent.setSword(true)
	parent.setShield(true)

func activityFinished():
	emit_signal("transitioned", self, "playerWalk")
