extends Node3D

@onready var trigger1 := $trigger1
@onready var trigger2 := $trigger2
@onready var current_phase := "idle"

var player
signal activity_finished

func _ready():
	Dialogic.signal_event.connect(handleDialogue)
	trigger1.interacted.connect(introDialogue)

func handleDialogue(type):
	pass

func introDialogue():
	current_phase = "intro"
	Dialogic.start("hermesIntro")
	trigger1.deactivate()
	trigger2.activate()
