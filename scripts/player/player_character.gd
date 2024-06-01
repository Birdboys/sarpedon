extends CharacterBody3D


@export var walk_speed := 5.0
@export var jump_strength := 4.5
@export var sensitivity := .01
@export var gravity := 10.0

@onready var stateMachine := $stateMachine
@onready var camera := $neck/playerCam
@onready var hoverRay := $hoverRay

func _ready():
	stateMachine.initialize(self) 

