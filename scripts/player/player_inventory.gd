extends State

func enter():
	parent.inventoryHandler.openInventory()
	parent.velocity.x = 0
	parent.velocity.z = 0
	parent.interactPrompt.text = ""

func update(delta):
	if Input.is_action_just_pressed("inventory"):
		emit_signal("transitioned", self, "playerWalk")
	if Input.is_action_just_pressed("left"):
		parent.inventoryHandler.nextItem(false)
	if Input.is_action_just_pressed("right"):
		parent.inventoryHandler.nextItem(true)
		
func exit():
	parent.inventoryHandler.closeInventory()
