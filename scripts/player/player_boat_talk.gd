extends State

func enter():
	parent.global_position = parent.boat.getPlayerPos()
	parent.syncCameras()
	parent.interactPrompt.text = ""
	Dialogic.timeline_ended.connect(dialogueEnded)
	
	if parent.shield_hold: parent.setShieldHold(false)
	
func update(delta):
	parent.boat.velocity = parent.boat.velocity.move_toward(Vector3.ZERO, delta * 25)
	parent.global_position = parent.boat.getPlayerPos()
	parent.syncCameras()
	
func exit():
	Dialogic.timeline_ended.disconnect(dialogueEnded)
	parent.uiCamera.global_transform = parent.camera.global_transform

func dialogueEnded():
	emit_signal("transitioned", self, "playerBoat")
