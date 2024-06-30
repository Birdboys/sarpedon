extends State

func enter():
	parent.interactPrompt.text = ""
	parent.uiCamera.current = false
	parent.activityHandler.activity_finished.connect(activityFinished)
	await parent.activityHandler.transitionCamera(parent.camera)


func exit():
	await parent.activityHandler.unTransitionCamera(parent.camera)
	parent.activityHandler.activity_finished.disconnect(activityFinished)
	parent.activityHandler = null
	parent.uiCamera.current = true
	parent.camera.current = true

func activityFinished():
	emit_signal("transitioned", self, "playerWalk")
