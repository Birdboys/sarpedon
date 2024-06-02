extends Node3D
@export var id:= 0
func _ready():
	$interactBox.interacted.connect(interact)

func interact():
	match id:
		0: Dialogic.start("introMaiden")
		1: Dialogic.start("maidenInterject")
