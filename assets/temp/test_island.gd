extends Node3D

@onready var player := $playerCharacter
@onready var worldEnvironment := $worldEnvironment
@onready var islandTrigger := $enterIslandTrigger
@onready var caveTrigger := $enterCaveTrigger
@onready var environAnim := $environAnim
@onready var island_env := preload("res://assets/island_environment.tres")
@onready var cave_env := preload("res://assets/cave_environment.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	islandTrigger.body_entered.connect(playerExitCave)
	caveTrigger.body_entered.connect(playerEnterCave)
	
	worldEnvironment.environment = island_env
	player.camera.current = true

func _process(delta):
	var fog_val = remap(clamp(player.global_position.y, 0, 40), 0, 40, 0.05, 0.01)
	worldEnvironment.environment.fog_density = fog_val #+ fog_offset
	for node in get_tree().get_nodes_in_group("billboard_comp"):
		node.target_position = player.global_position

func playerEnterCave(_body):
	if worldEnvironment.environment != cave_env:
		environAnim.play("island_to_cave")
	
func playerExitCave(_body):
	if worldEnvironment.environment != island_env:
		environAnim.play("island_to_cave", -1, -1)
