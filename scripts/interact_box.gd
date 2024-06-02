extends CSGBox3D

@export var object_name : String
@export var object_prompt : String
@export var interactable := true
signal interacted
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getPrompt():
	return object_prompt

func interact():
	if interactable:
		emit_signal("interacted")
