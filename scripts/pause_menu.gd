extends CanvasLayer

@onready var mainMenu := $pauseUI/pauseMargin/pauseBorder/panelMargin/VBoxContainer/menuPanel/mainMenu
@onready var controlsMenu := $pauseUI/pauseMargin/pauseBorder/panelMargin/VBoxContainer/menuPanel/controlsMenu
@onready var settingsMenu := $pauseUI/pauseMargin/pauseBorder/panelMargin/VBoxContainer/menuPanel/settingsMenu
@onready var current_menu := "closed"

func _ready():
	hideMenu()
	mainMenu.button.connect(handleMainButtons)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func showMenu():
	Dialogic.toggleVisibility(false)
	current_menu = "main"
	visible = true
	get_tree().paused = true
	mainMenu.open()
	controlsMenu.close()
	settingsMenu.close()
	
func hideMenu():
	Dialogic.toggleVisibility(true)
	print("HIDING")
	current_menu = "closed"
	visible = false
	get_tree().paused = false
	
func handleMainButtons(button):
	match button:
		"controls": 
			mainMenu.close()
			controlsMenu.open()
			current_menu = "controls"
		"settings":
			mainMenu.close()
			settingsMenu.open()
			current_menu = "settings"
		_: pass

func handleEscape():
	match current_menu:
		"main":
			hideMenu()
		"controls":
			controlsMenu.close()
			mainMenu.open()
			current_menu = "main"
		"settings":
			settingsMenu.close()
			mainMenu.open()
			current_menu = "main"
		"closed":
			showMenu()
			
func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		handleEscape()
