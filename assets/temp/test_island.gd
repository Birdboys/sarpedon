extends Node3D

@onready var player := $playerCharacter
@onready var gorgons := $gorgons
@onready var worldEnvironment := $worldEnvironment
@onready var islandTrigger := $enterIslandTrigger
@onready var caveTrigger := $enterCaveTrigger
@onready var environAnim := $environAnim
@onready var oceanPanels := $oceanPanels
@onready var boat := $boat
@onready var introBoat := $introBoat
@onready var maiden := $maiden
@onready var island_env := preload("res://assets/island_environment.tres")
@onready var cave_env := preload("res://assets/cave_environment.tres")
@onready var player_in_cave := false
@onready var current_time := 0.0


var bobber_pos
var ocean_shader
var ocean_noise
# Called when the node enters the scene tree for the first time.
func _ready():
	islandTrigger.body_entered.connect(playerExitCave)
	caveTrigger.body_entered.connect(playerEnterCave)
	maiden.maiden_left.connect(activateBoat)
	worldEnvironment.environment = island_env
	player.camera.current = true
	player.startActivity(introBoat)
	
func _process(delta):
	if not player_in_cave:
		var fog_val = remap(clamp(player.global_position.y, 0, 40), 0, 40, 0.05, 0.01)
		worldEnvironment.environment.fog_density = fog_val #+ fog_offset
	for node in get_tree().get_nodes_in_group("billboard_comp"):
		node.target_position = player.global_position
	
func _physics_process(delta):
	for node in get_tree().get_nodes_in_group("needs_player"):
		node.target_pos = player.global_position
	return
	#$testNav/NavigationAgent3D.target_position = player.global_position
	#if $testNav/NavigationAgent3D.is_target_reachable():
	#	var current_agent_position: Vector3 = $testNav.global_position
	#	var next_path_position: Vector3 = $testNav/NavigationAgent3D.get_next_path_position()

	#	$testNav.velocity = current_agent_position.direction_to(next_path_position) * 10.0
	#	$testNav.move_and_slide()
	#	$testNav/canGet.visible = true
	#	$testNav/cantGet.visible = false
	#else:
	#	$testNav/canGet.visible = false
	#	$testNav/cantGet.visible = true
	pass
	
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

