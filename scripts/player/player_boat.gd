extends State

var boat_dialogue := false
var boat_death := false

func enter():
	boat_dialogue = false
	boat_death = false
	
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
	elif boat_death:
		parent.global_position = parent.boat.getPlayerPos()
		parent.syncCameras()
		parent.boat.velocity = Vector3.ZERO
	else:
		parent.global_position = parent.boat.getExitPos()
		parent.boat.velocity = Vector3.ZERO
		parent.boat = null
		
