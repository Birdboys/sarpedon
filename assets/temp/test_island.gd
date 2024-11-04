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
@onready var playerStatue := preload("res://assets/temp/statue.tscn")
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
	boat.visible = true
	introBoat.visible = true
	deathRect.visible = false
	winRect.visible = false
	deathRect.modulate = Color.TRANSPARENT
	winRect.modulate = Color.TRANSPARENT
	player.camera.current = true
	player.startActivity(introBoat)
	PauseMenu.setTheme("black")
	AudioHandler.togglePlayer("ocean", true)
	AudioHandler.togglePlayer("wind", true)
	AudioHandler.resetEffects()
	handleRepeat()
	
func _process(_delta):
	if not player_in_cave:
		var fog_val = remap(clamp(player.global_position.y, 0, 40), 0, 40, 0.05, 0.03)
		var fog_noise = remap(fogNoise.get_noise_1d(Time.get_ticks_msec()*0.01), -1.0, 1.0, -0.01, 0.01)
		worldEnvironment.environment.fog_density = fog_val + fog_noise
	for node in get_tree().get_nodes_in_group("billboard_comp"):
		node.target_position = player.global_position
	
	RenderingServer.global_shader_parameter_set("current_time", Time.get_ticks_msec()/1000.0)
	
func _physics_process(_delta):
	for node in get_tree().get_nodes_in_group("needs_player_eyes"):
		node.setTargetPos(player.getEyePos())
	for node in get_tree().get_nodes_in_group("needs_player_ground"):
		node.setTargetPos(player.getGroundPos())
	for node in get_tree().get_nodes_in_group("needs_player_left"):
		node.setTargetPos(player.getGroundPos("left"))
	for node in get_tree().get_nodes_in_group("needs_player_right"):
		node.setTargetPos(player.getGroundPos("right"))

	if Vector3(player.global_position.x, 0, player.global_position.z).length() < 150:
		AudioHandler.setPlayer("ocean", remap(clamp(Vector3(player.global_position.x, 0, player.global_position.z).length(), 0, 150), 0.0, 150.0, -60, 0))
	AudioHandler.setPlayer("wind", remap(clamp(player.global_position.y, 0, 30), 0, 30, -60, 0))

func activateBoat():
	boat.enterBox.activate()

func playerDied(death_type):
	print("PLAYER DIED", death_type)
	AudioHandler.tweenPlayer("chase", -60)
	AudioHandler.tweenPlayer("music", -60)
	deathRect.visible = true
	var end_tween = get_tree().create_tween()
	end_tween.tween_property(deathRect, "modulate", Color.WHITE, 2.5)
	await end_tween.finished
	PauseMenu.setTheme("white")
	AudioHandler.togglePlayer("chase", false)
	AudioHandler.togglePlayer("music", false)
	queue_free()
	Dialogic.end_timeline()
	DeathScreen.loadDeathScreen(death_type)
	if death_type in ["stheno", "euryale", "medusa", "petrify"]:
		var player_pos = player.global_position.y
		var ground_pos = player.groundPoint.global_position.y
		var diff = player_pos - ground_pos
		var statue_transform = player.global_transform
		DataHandler.player_statue_transforms.append(statue_transform)
	
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
	AudioHandler.tweenPlayer("chase", -60)
	AudioHandler.tweenPlayer("music", -60)
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
	AudioHandler.togglePlayer("chase", false)
	AudioHandler.togglePlayer("music", false)
	Dialogic.end_timeline()

func medusaSlain():
	medusa_dead = true
	phorkys.current_phase = "ready"
	
func headTaken():
	await get_tree().create_timer(8.0).timeout
	gorgons.lament()
	AudioHandler.togglePlayer("chase", true)
	AudioHandler.setPlayer("chase", 0.0)
	AudioHandler.seekPlayer("chase", 0.0)
	
func animateWaters(type):
	print("ANIMATE WATERS")
	match type:
		"calm": oceanAnim.play("calm_ocean")
		"normal": oceanAnim.play_backwards("calm_ocean")

func loadPlayerStatues(transforms):
	for s in transforms:
		var new_statue = playerStatue.instantiate()
		new_statue.starting_anim = "ARMCOVER"
		add_child(new_statue)
		new_statue.global_transform = s
		new_statue.rotation.y += PI

func handleRepeat():
	await get_tree().physics_frame
	await get_tree().physics_frame
	if DataHandler.hermes_done: hermes.alreadyFinished()
	if DataHandler.athena_done: athena.alreadyFinished()
	if DataHandler.graeae_done: graeae.alreadyFinished()
	if not DataHandler.player_statue_transforms.is_empty(): loadPlayerStatues(DataHandler.player_statue_transforms)
