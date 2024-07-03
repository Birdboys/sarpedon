extends Node3D
@onready var trigger1 := $trigger1
@onready var trigger2 := $trigger2
@onready var current_phase := "idle"
# Called when the node enters the scene tree for the first time.
func _ready():
	trigger1.interacted.connect(introDialogue)
	trigger2.interacted.connect(startWeave)
func _process(delta):
	pass

func introDialogue():
	Dialogic.start("athenaIntro")
	trigger1.deactivate()
	trigger2.activate()

func startWeave():
	trigger2.deactivate()
	#Dialogic.start("athenaWeaveExplanation")
