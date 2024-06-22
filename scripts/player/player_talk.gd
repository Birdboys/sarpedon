extends State

func enter():
	parent.velocity.x = 0
	parent.velocity.z = 0
	parent.interactPrompt.text = ""
	
func update(delta):
	await Dialogic.timeline_ended
	parent.uiCamera.global_transform = parent.camera.global_transform
	emit_signal("transitioned", self, "playerWalk")
