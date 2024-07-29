extends Node3D
@onready var singTimer := $singTimer
@onready var attackTimer := $attackTimer
@onready var sirens := [$siren1, $siren2, $siren3]
@onready var player_in_sing_range := false
@onready var player_in_pull_range := false
@onready var player_attacked := false
@onready var num_sing_texts := 22
@onready var attack_timeout := 10.0
@onready var capsize_distance := 15.0

@onready var max_boat_pull_force := 7
@export var boatFinder : Area3D
@export var boatPuller : Area3D
@export var boatAttacker : Area3D
@export var sing_radius : float
@export var pull_radius : float
@export var attack_radius := 50

var boat
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	boatFinder.body_entered.connect(boatFinderEntered)
	boatFinder.body_exited.connect(boatFinderExited)
	boatPuller.body_entered.connect(boatPullerEntered)
	boatPuller.body_exited.connect(boatPullerExited)
	boatAttacker.body_entered.connect(boatAttackerEntered)
	boatAttacker.body_exited.connect(boatAttackerExited)
	attackTimer.timeout.connect(attackPlayer)
	
func _process(delta):
	pass
	
func _physics_process(delta):
	if player_in_pull_range and boat:
		var distance_scale = getBoatDistance()/pull_radius
		distance_scale = pow(1.0 - distance_scale, 2)
		boat.velocity += getPullDirection() * distance_scale * max_boat_pull_force * delta
		if getBoatDistance() < capsize_distance:
			attackPlayer()
			
func boatFinderEntered(body):
	if body.name == "playerCharacter":
		print("BOAT ENTERED")
		player_in_sing_range = true
		player = body
		boat = body.boat
		singTimer.start(randf_range(5, 15))
	
func boatFinderExited(body):
	if body.name == "playerCharacter":
		print("BOAT ENTERED")
		player_in_sing_range = false
		player = null
		boat = null
		singTimer.stop()

func boatPullerEntered(body):
	if body.name == "playerCharacter":
		player_in_pull_range = true

func boatPullerExited(body):
	if body.name == "playerCharacter":
		player_in_pull_range = false

func _on_sing_timer_timeout():
	if not boat: return
	var song_time = remap(getBoatDistance(), 0, sing_radius, 0, 10)
	var new_song = randi_range(0, num_sing_texts)
	while new_song == Dialogic.VAR.siren_lul:
		new_song = randi_range(0, num_sing_texts)
	Dialogic.VAR.siren_lul = new_song
	Dialogic.start("sirenLures")
	singTimer.start(randf_range(song_time, song_time+3))

func getBoatDistance():
	if boat:
		return (boat.global_position - global_position).length()
	else:
		return null
		
func getPullDirection():
	if boat:
		return (global_position-boat.global_position).normalized()
	else:
		return null

func boatAttackerEntered(body):
	if body.name == "playerCharacter":
		attackTimer.start(attack_timeout)
	
func boatAttackerExited(body):
	if body.name == "playerCharacter":
		attackTimer.stop()
	
func attackPlayer():
	attackTimer.stop()
	if player_attacked: return
	player_attacked = true
	var siren_tween = get_tree().create_tween().set_parallel().set_ease(Tween.EASE_IN)
	for siren in sirens:
		siren_tween.tween_property(siren, "global_position", player.camera.global_position, 1.5)
	player.sirenAttack()
