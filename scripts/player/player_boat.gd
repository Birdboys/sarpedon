extends State

var boat_dialogue := false

func enter():
	boat_dialogue = false
	
func update(delta):
	parent.global_position = parent.boat.getPlayerPos()
	parent.syncCameras()

func physics_update(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	parent.boat.controlBoat(input_dir, delta)

func exit():
	if boat_dialogue: 
		parent.global_position = parent.boat.getPlayerPos()
		parent.syncCameras()
	else:
		parent.global_position = parent.boat.getExitPos()
		parent.boat = null
