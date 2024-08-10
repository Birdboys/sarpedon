extends Node3D

@onready var player := $playerCharacter
@onready var gorgons := $gorgons
@onready var medusaLairTrigger := $medusaLairTrigger
@onready var sarpedonArea := $sarpedonArea
@onready var worldEnvironment := $worldEnvironment
@onready var deathRect := $deathRect/rect
@onready var winRect := $winRect/rect
@onready var shallowWater := $shallowWater
@onready var deepWater := $deepWater
@onready var oceanPanels := $oceanPanels
@onready var oceanAnim := $oceanAnim
@onready var boat := $boat
@onready var introBoat := $introBoat
@onready var maiden := $maiden
@onready var athena := $athena
@onready var hermes := $hermes
@onready var graeae := $graeae
@onready var medusa := $medusa
@onready var phorkys := $phorkys
@onready var sirens := $sirens
@onready var island_env := preload("res://assets/island_environment.tres")
@onready var cave_env := preload("res://assets/cave_environment.tres")
@onready var player_in_cave := false
@onready var medusa_dead := false
@onready var current_time := 0.0

@export var fogNoise : FastNoiseLite

var fog_tween

func _ready():
	AudioHandler.playSound("boat_hit")
	maiden.maiden_left.connect(activateBoat)
	medusa.medusa_slain.connect(medusaSlain)
	medusa.medusa_awake.connect(gorgons.sisterAwake)
	medusa.head_taken.connect(headTaken)
	player.player_died.connect(playerDied)
	shallowWater.body_exited.connect(player.exitingShallows)
	deepWater.body_exited.connect(player.enteringDeep)
	sarpedonArea.body_exited.connect(gameWin)
	medusaLairTrigger.body_entered.connect(playerCave.bind(true))
	medusaLairTrigger.body_exited.connect(playerCave.bind(false))
	phorkys.phorkys_summon.connect(animateWaters.bind("calm"))
	phorkys.death_area_exit.connect(animateWaters.bind("normal"))
	worldEnvironment.environment = island_env
	boat.visible = true
	deathRect.visible = false
	winRect.visible = false
	deathRect.modulate = Color.TRANSPARENT
	winRect.modulate = Color.TRANSPARENT
	player.camera.current = true
	player.startActivity(introBoat)
	PauseMenu.setTheme("black")
	
	if DataHandler.hermes_done: hermes.alreadyFinished()
	if DataHandler.athena_done: athena.alreadyFinished()
	if DataHandler.graeae_done: graeae.alreadyFinished()

	AudioHandler.togglePlayer("ocean", true)
	AudioHandler.togglePlayer("wind", true)
	
func _process(delta):
	if not player_in_cave:
		var fog_val = remap(clamp(player.global_position.y, 0, 40), 0, 40, 0.05, 0.01)
		var fog_noise = remap(fogNoise.get_noise_1d(Time.get_ticks_msec()*0.01), -1.0, 1.0, -0.01, 0.01)
		worldEnvironment.environment.fog_density = fog_val + fog_noise
	for node in get_tree().get_nodes_in_group("billboard_comp"):
		node.target_position = player.global_position
	
func _physics_process(delta):
	for node in get_tree().get_nodes_in_group("needs_player_ground"):
		if not player.is_invis: node.setTargetPos(player.getGroundPos())
	for node in get_tree().get_nodes_in_group("needs_player_eyes"):
		node.setTargetPos(player.camera.global_position)
	if Vector3(player.global_position.x, 0, player.global_position.z).length() < 150:
		AudioHandler.setPlayer("ocean", remap(clamp(Vector3(player.global_position.x, 0, player.global_position.z).length(), 0, 150), 0.0, 150.0, -60, 0))
	AudioHandler.setPlayer("wind", remap(clamp(player.global_position.y, 0, 30), 0, 30, -60, 0))

func activateBoat():
	boat.enterBox.activate()

func playerDied(death_type):
	print("PLAYER DIED", death_type)
	deathRect.visible = true
	var end_tween = get_tree().create_tween()
	end_tween.tween_property(deathRect, "modulate", Color.WHITE, 2.5)
	await end_tween.finished
	PauseMenu.setTheme("white")
	queue_free()
	Dialogic.end_timeline()
	DeathScreen.loadDeathScreen(death_type)
	
func playerCave(_body, entered):
	if fog_tween: fog_tween.kill()
	fog_tween = get_tree().create_tween()
	if entered:
		player_in_cave = entered
		fog_tween.tween_property(worldEnvironment.environment, "fog_density", 0.005, 1.0)
	else:
		fog_tween.tween_property(worldEnvironment.environment, "fog_density", 0.05, 1.0)
		await fog_tween.finished
		player_in_cave = entered
	AudioHandler.toggleReverb(entered)
	 
func gameWin(_body):
	if medusa_dead:
		deathRect.visible = true
		var end_tween = get_tree().create_tween()
		end_tween.tween_property(deathRect, "modulate", Color.WHITE, 2.5)
		await end_tween.finished
		PauseMenu.setTheme("white")
		queue_free()
		DeathScreen.loadDeathScreen("medusa_slain")
	else:
		winRect.visible = true
		DataHandler.good_ending = true
		var end_tween = get_tree().create_tween()
		end_tween.tween_property(winRect, "modulate", Color.WHITE, 2.5)
		await end_tween.finished
		queue_free()
		WinScreen.showMenu()
	Dialogic.end_timeline()

func medusaSlain():
	medusa_dead = true
	phorkys.current_phase = "ready"
	
func headTaken():
	await get_tree().create_timer(8.0).timeout
	gorgons.lament()
	
func animateWaters(type):
	print("ANIMATE WATERS")
	match type:
		"calm": oceanAnim.play("calm_ocean")
		"normal": oceanAnim.play_backwards("calm_ocean")
	
