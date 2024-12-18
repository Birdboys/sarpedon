extends State

func enter():
	parent.inventoryHandler.openInventory()
	parent.velocity.x = 0
	parent.velocity.z = 0
	parent.interactPrompt.text = ""
	parent.camAnim.stop()
	parent.compass.visible = false
	AudioHandler.playSound("inventory_open")

func update(_delta):
	parent.camAnim.stop()
	if Input.is_action_just_pressed("inventory"):
		emit_signal("transitioned", self, "playerWalk")
	if Input.is_action_just_pressed("left"):
		parent.inventoryHandler.nextItem(false)
	if Input.is_action_just_pressed("right"):
		parent.inventoryHandler.nextItem(true)
			
func exit():
	parent.inventoryHandler.closeInventory()
	parent.compass.visible = true
	AudioHandler.playSound("inventory_close")
