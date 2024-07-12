extends Control
@onready var playButton := $mainMenuButtons/playButton
@onready var settingsButton := $mainMenuButtons/settingsButton
@onready var controlsButton := $mainMenuButtons/controlsButton
@onready var creditsButton := $mainMenuButtons/creditsButton
@onready var quitButton := $mainMenuButtons/quitButton

signal button(id)

func _ready():
	#playButton.pressed.connect()
	controlsButton.pressed.connect(controls)
	settingsButton.pressed.connect(settings)
	quitButton.pressed.connect(quit)

func open():
	visible = true

func close():
	visible = false
	
func play():
	pass

func settings():
	emit_signal("button", "settings")
	
func credits():
	pass
	
func controls():
	emit_signal("button", "controls")
	
func quit():
	get_tree().quit()
