extends Node3D

@onready var player := $playerCharacter
@onready var gorgons := $gorgons
@onready var medusaLairTrigger := $medusaLairTrigger
@onready var sarpedonArea := $sarpedonArea
@onready var worldEnvironment := $worldEnvironment
@onready var deathRect := $deathRect
@onready var winRect := $winRect
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
@onready var medusa := $medusa
@onready var island_env := preload("res://assets/island_environment.tres")
@onready var cave_env := preload("res://assets/cave_environment.tres")
@onready var player_in_cave := false
@onready var medusa_dead := false
@onready var current_time := 0.0

func _ready():
	maiden.maiden_left.connect(activateBoat)
	medusa.medusa_slain.connect(medusaSlain)
	player.player_died.connect(playerDied)
	shallowWater.body_exited.connect(player.exitingShallows)
	deepWater.body_exited.connect(player.enteringDeep)
	sarpedonArea.body_exited.connect(gameWin)
	medusaLairTrigger.body_entered.connect(playerCave.bind(true))
	medusaLairTrigger.body_exited.connect(playerCave.bind(false))
	worldEnvironment.environment = island_env
	player.camera.current = true
	player.startActivity(introBoat)
	PauseMenu.setTheme("black")
	
	
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
		if not player.is_invis: node.setTargetPos(player.getGroundPos())
	for node in get_tree().get_nodes_in_group("needs_player_eyes"):
		node.setTargetPos(player.camera.global_position)

func activateBoat():
	boat.enterBox.activate()

func playerDied(death_type):
	var end_tween = get_tree().create_tween()
	end_tween.tween_property(deathRect, "color", Color.BLACK, 2.5)
	await end_tween.finished
	PauseMenu.setTheme("white")
	queue_free()
	DeathScreen.loadDeathScreen(death_type)
	
func playerCave(_body, entered):
	print("PLAYER ENTER CAVE, ", entered)

func gameWin(_body):
	if medusa_dead:
		var end_tween = get_tree().create_tween()
		end_tween.tween_property(deathRect, "color", Color.BLACK, 2.5)
		await end_tween.finished
		PauseMenu.setTheme("white")
		queue_free()
		DeathScreen.loadDeathScreen("medusa_slain")
	else:
		var end_tween = get_tree().create_tween()
		end_tween.tween_property(winRect, "modulate", Color.WHITE, 2.5)
		await end_tween.finished
		queue_free()
		WinScreen.showMenu()

func medusaSlain():
	medusa_dead = true
	await get_tree().create_timer(1.0).timeout
	gorgons.lament()

