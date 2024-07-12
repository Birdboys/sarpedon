extends Node3D
@onready var boatFinder := $boatFinder
@onready var boatFinderCol := $boatFinder/finderShape
@onready var boatPuller := $boatPuller
@onready var boatPullerCol := $boatPuller/pullerShape
@onready var singTimer := $singTimer
@onready var player_in_sing_range := false
@onready var player_in_pull_range := false
@export var sing_radius := 75.0
@export var pull_radius := 55.0
@onready var num_sing_texts := 6
#@onready var min_boat_pull_force := 3
@onready var max_boat_pull_force := 7
var boat

# Called when the node enters the scene tree for the first time.
func _ready():
	boatFinderCol.shape.radius = sing_radius
	boatPullerCol.shape.radius = pull_radius
	
	boatFinder.body_entered.connect(boatFinderEntered)
	boatFinder.body_exited.connect(boatFinderExited)
	boatPuller.body_entered.connect(boatPullerEntered)
	boatPuller.body_exited.connect(boatPullerExited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if player_in_pull_range and boat:
		var distance_scale = getBoatDistance()/pull_radius
		distance_scale = pow(1.0 - distance_scale, 2)
		boat.velocity += getPullDirection() * distance_scale * max_boat_pull_force * delta
		#print("PULLING BOAT, ", pull_force.length(), ", ", pull_force, ", ", boat.position)
		
func boatFinderEntered(body):
	print(body.name)
	if body.name == "playerCharacter":
		print("BOAT ENTERED")
		player_in_sing_range = true
		boat = body.boat
		singTimer.start(randf_range(5, 15))
	
func boatFinderExited(body):
	print(body.name)
	if body.name == "playerCharacter":
		print("BOAT ENTERED")
		player_in_sing_range = false
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
