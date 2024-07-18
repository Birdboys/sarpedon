extends Node3D

@onready var player := $playerCharacter
@onready var environment := $WorldEnvironment

# Called when the node enters the scene tree for the first time.
func _ready():
	player.camera.current = true
	pass # Replace with function body.

func _process(delta):
	var fog_val = remap(clamp(player.global_position.y, 0, 40), 0, 40, 0.05, 0.01)
	environment.environment.fog_density = fog_val #+ fog_offset
	for node in get_tree().get_nodes_in_group("billboard_comp"):
		node.target_position = player.global_position
