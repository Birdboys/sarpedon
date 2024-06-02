extends State

func enter():
	parent.velocity.x = 0
	parent.velocity.z = 0
	
func update(delta):
	await Dialogic.timeline_ended
	emit_signal("transitioned", self, "playerWalk")
