extends Control
@onready var remapArea := $controlsVbox/remapScroll/remapVbox
@onready var controlRemapper := preload("res://scenes/ui/control_remapper.tscn")
@onready var actions := {"forward": "Forward", "back": "Back", "left": "Left", "right": "Right", "jump": "Jump", "interact": "Interact", "inventory": "Inventory", "equip_sword": "Equip Sword", "equip_shield": "Equip Shield", "use_sword": "Use Sword", "use_shield": "Use Shield", "use_helmet": "Use Helmet"}
# Called when the node enters the scene tree for the first time.

func _ready():
	pass # Replace with function body.
	
func open():
	visible = true
	for action in actions:
		var new_remap := controlRemapper.instantiate()
		new_remap.action_text = actions[action]
		new_remap.action_name = action
		remapArea.add_child(new_remap)
		new_remap.capturing.connect(oneCapturing)

func close():
	visible = false
	for child in remapArea.get_children():
		child.queue_free()
		
func oneCapturing(name):
	for child in remapArea.get_children():
		if child.action_name != name:
			child.clear()
