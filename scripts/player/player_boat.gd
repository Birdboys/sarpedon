extends State

func update(delta):
	parent.global_position = parent.boat.getPlayerPos()
	parent.uiCamera.global_transform = parent.camera.global_transform

func physics_update(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	parent.boat.controlBoat(input_dir, delta)

func exit():
	parent.global_position = parent.boat.getExitPos()
	parent.boat = null
