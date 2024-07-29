extends Control
@onready var resumeButton := $mainMenuButtons/resumeButton
@onready var settingsButton := $mainMenuButtons/settingsButton
@onready var controlsButton := $mainMenuButtons/controlsButton
@onready var creditsButton := $mainMenuButtons/creditsButton
@onready var quitButton := $mainMenuButtons/quitButton

signal button(id)

func _ready():
	resumeButton.pressed.connect(resume)
	controlsButton.pressed.connect(controls)
	settingsButton.pressed.connect(settings)
	creditsButton.pressed.connect(credits)
	quitButton.pressed.connect(quit)

func open():
	visible = true

func close():
	visible = false
	
func resume():
	AudioHandler.playSound("ui_click")
	emit_signal("button", "resume")

func settings():
	AudioHandler.playSound("ui_click")
	emit_signal("button", "settings")
	
func credits():
	AudioHandler.playSound("ui_click")
	emit_signal("button", "credits")
	
func controls():
	AudioHandler.playSound("ui_click")
	emit_signal("button", "controls")
	
func quit():
	get_tree().quit()
