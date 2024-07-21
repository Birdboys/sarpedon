extends Node3D

@onready var player := $playerCharacter
@onready var gorgons := $gorgons
@onready var worldEnvironment := $worldEnvironment
@onready var islandTrigger := $enterIslandTrigger
@onready var caveTrigger := $enterCaveTrigger
@onready var environAnim := $environAnim
@onready var island_env := preload("res://assets/island_environment.tres")
@onready var cave_env := preload("res://assets/cave_environment.tres")
@onready var player_in_cave := false
# Called when the node enters the scene tree for the first time.
func _ready():
	islandTrigger.body_entered.connect(playerExitCave)
	caveTrigger.body_entered.connect(playerEnterCave)

	worldEnvironment.environment = island_env
	player.camera.current = true

func _process(delta):
	if not player_in_cave:
		var fog_val = remap(clamp(player.global_position.y, 0, 40), 0, 40, 0.05, 0.01)
		worldEnvironment.environment.fog_density = fog_val #+ fog_offset
	for node in get_tree().get_nodes_in_group("billboard_comp"):
		node.target_position = player.global_position

func _physics_process(delta):
	pass
	#gorgons.setGorgonTargetPos(player.global_position)
	
func playerEnterCave(_body):
	if worldEnvironment.environment.fog_density != 0:
		player_in_cave = true
		environAnim.play("island_to_cave")
	
func playerExitCave(_body):
	if worldEnvironment.environment.fog_density == 0:
		environAnim.play("island_to_cave", -1, -1)
		await environAnim.animation_finished
		player_in_cave = false
