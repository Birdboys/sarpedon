extends Node3D
@onready var player := $playerCharacter

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for node in get_tree().get_nodes_in_group("billboard_comp"):
		node.target_position = player.global_position
	pass
