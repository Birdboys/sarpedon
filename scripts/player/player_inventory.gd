extends State
@export var move_speed := 5.0

func enter():
	parent.inventoryHandler.openInventory()
	#	await get_tree().create_timer(0.5).timeout
	
func update(delta):
	if Input.is_action_just_pressed("inventory"):
		emit_signal("transitioned", self, "playerWalk")

func exit():
	parent.inventoryHandler.closeInventory()
