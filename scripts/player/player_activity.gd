extends State

func enter():
	parent.interactPrompt.text = ""
	parent.uiCamera.current = false
	parent.activityHandler.activity_finished.connect(activityFinished)
	await parent.activityHandler.transitionCamera(parent.camera)

	
func exit():
	parent.uiCamera.current = true

func activityFinished():
	pass
