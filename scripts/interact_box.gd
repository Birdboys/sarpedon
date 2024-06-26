extends CSGBox3D

@export var object_name : String
@export_multiline var object_prompt : String
@export var interact_ret : String
@export var interactable := true
@export var on_start := true

signal interacted
# Called when the node enters the scene tree for the first time.
func _ready():
	if on_start:
		activate()
	else:
		deactivate()

func getPrompt():
	return object_prompt

func interact():
	if interactable:
		emit_signal("interacted")
		return interact_ret

func activate():
	interactable = true
	use_collision = true
	
func deactivate():
	interactable = false
	use_collision = false
