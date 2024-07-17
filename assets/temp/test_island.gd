extends Node3D

@onready var player := $playerCharacter
@onready var environment := $WorldEnvironment
@onready var fog_noise := FastNoiseLite.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(player.global_position.y)
	var fog_val = remap(clamp(player.global_position.y, 0, 40), 0, 50, 0.05, 0.01)
#	var fog_offset = fog_noise.noise.get_noise_1d(Time * 0.01) * 0.005
	environment.environment.fog_density = fog_val #+ fog_offset
	pass
