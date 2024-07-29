extends State

func enter():
	parent.collision_layer = 0
	parent.collision_mask = 0
	parent.velocity.x = 0
	parent.velocity.z = 0
	parent.interactPrompt.text = ""
	parent.emit_signal("player_died", parent.death_type)

func update(delta):
	if not parent.is_on_floor():
		parent.velocity.y -= parent.gravity * delta
		parent.move_and_slide()
		
func exit():
	parent.uiCamera.global_transform = parent.camera.global_transform
	
