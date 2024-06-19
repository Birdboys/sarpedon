extends State

func enter():
	parent.uiCamera.current = false
	parent.activityHandler.activity_finished.connect(activityFinished)
	await parent.activityHandler.transitionCamera(parent.camera)

func update(delta):
	print(parent.uiCamera.current)
	
	#emit_signal("transitioned", self, "playerWalk")
	
func exit():
	parent.uiCamera.current = true

func activityFinished():
	pass
