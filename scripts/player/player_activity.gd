extends State

func enter():
	parent.interactPrompt.text = ""
	#parent.uiCamera.current = false
	parent.UI.visible = false
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
	parent.activityHandler = null
	parent.uiCamera.current = true
	parent.camera.current = true
	parent.setSword(true)
	parent.setShield(true)

func activityFinished():
	parent.activityHandler.activity_finished.disconnect(activityFinished)
	await parent.activityHandler.unTransitionCamera(parent.camera)
	parent.UI.visible = true
	emit_signal("transitioned", self, "playerWalk")
