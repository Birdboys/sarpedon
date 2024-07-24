extends Node3D

@onready var player := $playerCharacter
@onready var gorgons := $gorgons
@onready var worldEnvironment := $worldEnvironment
@onready var deathRect := $deathRect
@onready var islandTrigger := $enterIslandTrigger
@onready var caveTrigger := $enterCaveTrigger
@onready var shallowWater := $shallowWater
@onready var deepWater := $deepWater
@onready var environAnim := $environAnim
@onready var oceanPanels := $oceanPanels
@onready var boat := $boat
@onready var introBoat := $introBoat
@onready var maiden := $maiden
@onready var athena := $athena
@onready var hermes := $hermes
@onready var graeae := $graeae
@onready var island_env := preload("res://assets/island_environment.tres")
@onready var cave_env := preload("res://assets/cave_environment.tres")
@onready var player_in_cave := false
@onready var current_time := 0.0

func _ready():
	islandTrigger.body_entered.connect(playerExitCave)
	caveTrigger.body_entered.connect(playerEnterCave)
	maiden.maiden_left.connect(activateBoat)
	player.player_died.connect(playerDied)
	shallowWater.body_exited.connect(player.exitingShallows)#(playerExitShallow)
	deepWater.body_exited.connect(player.enteringDeep)
	worldEnvironment.environment = island_env
	player.camera.current = true
	#player.startActivity(introBoat)
	
	
	if DataHandler.hermes_done: hermes.alreadyFinished()
	if DataHandler.athena_done: athena.alreadyFinished()
	if DataHandler.graeae_done: graeae.alreadyFinished()

func _process(delta):
	if not player_in_cave:
		var fog_val = remap(clamp(player.global_position.y, 0, 40), 0, 40, 0.05, 0.01)
		worldEnvironment.environment.fog_density = fog_val #+ fog_offset
	for node in get_tree().get_nodes_in_group("billboard_comp"):
		node.target_position = player.global_position
	
func _physics_process(delta):
	for node in get_tree().get_nodes_in_group("needs_player_ground"):
		node.setTargetPos(player.getGroundPos())
	for node in get_tree().get_nodes_in_group("needs_player_eyes"):
		node.setTargetPos(player.camera.global_position)
	
func playerEnterCave(_body):
	if worldEnvironment.environment.fog_density != 0:
		player_in_cave = true
		environAnim.play("island_to_cave")
	
func playerExitCave(_body):
	if worldEnvironment.environment.fog_density == 0:
		environAnim.play("island_to_cave", -1, -1)
		await environAnim.animation_finished
		player_in_cave = false

func activateBoat():
	boat.enterBox.activate()

func playerDied(death_type):
	var end_tween = get_tree().create_tween()
	end_tween.tween_property(deathRect, "color", Color.BLACK, 2.5)
	await end_tween.finished
	queue_free()
	DeathScreen.loadDeathScreen(death_type)
	

func playerExitShallow():
	player.exitingShallows()
