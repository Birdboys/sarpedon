extends Node3D
@onready var boatFinder := $boatFinder
@onready var boatFinderCol := $boatFinder/finderShape
@onready var boatPuller := $boatPuller
@onready var boatPullerCol := $boatPuller/finderShape
@onready var player_in_sing_range := false
@onready var player_in_pull_range := false
@onready var interact_radius := 75.0
var boat

# Called when the node enters the scene tree for the first time.
func _ready():
	boatFinderCol.shape.radius = interact_radius
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_boat_finder_body_entered(body):
	print(body.name)
	if body.name == "playerCharacter":
		player_in_sing_range = true
		boat = body.boat

func _on_boat_finder_body_exited(body):
	print(body.name, "dooba")
	if body.name == "playerCharacter":
		player_in_sing_range = false
		boat = null
