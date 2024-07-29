extends CanvasLayer

@onready var mainMenu := $pauseUI/pauseMargin/pauseBorder/panelMargin/VBoxContainer/menuPanel/mainMenu
@onready var controlsMenu := $pauseUI/pauseMargin/pauseBorder/panelMargin/VBoxContainer/menuPanel/controlsMenu
@onready var settingsMenu := $pauseUI/pauseMargin/pauseBorder/panelMargin/VBoxContainer/menuPanel/settingsMenu
@onready var creditsMenu := $pauseUI/pauseMargin/pauseBorder/panelMargin/VBoxContainer/menuPanel/creditsMenu
@onready var whiteBorder := $pauseUI/pauseMargin/pauseBorder/panelMargin/VBoxContainer/topRow/whiteBorder
@onready var topRowPanel := $pauseUI/pauseMargin/pauseBorder/panelMargin/VBoxContainer/topRow
@onready var borderPanel := $pauseUI/pauseMargin/pauseBorder
@onready var pauseBG := $pauseUI/pauseBg
@onready var current_menu := "closed"
var was_mouse_captured := false

signal toggled_on
signal toggled_off

func _ready():
	setTheme("white")
	hideMenu()
	mainMenu.button.connect(handleMainButtons)

func showMenu():
	was_mouse_captured = Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Dialogic.toggleVisibility(false)
	current_menu = "main"
	visible = true
	get_tree().paused = true
	mainMenu.open()
	controlsMenu.close()
	settingsMenu.close()
	emit_signal("toggled_on")
	
func hideMenu():
	if was_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Dialogic.toggleVisibility(true)
	current_menu = "closed"
	visible = false
	get_tree().paused = false
	emit_signal("toggled_off")
	
func setTheme(menu_theme):
	match menu_theme:
		"white":
			pauseBG.theme_type_variation = "pauseBgW"
			borderPanel.theme_type_variation = "topBotPanelW"
			whiteBorder.visible = true
		"black":
			pauseBG.theme_type_variation = "pauseBg"
			borderPanel.theme_type_variation = "topBotPanel"
			whiteBorder.visible = false
			
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
		"credits":
			mainMenu.close()
			creditsMenu.open()
			current_menu = "credits"
		"resume":
			hideMenu()
		_: pass

func handleEscape():
	match current_menu:
		"main":
			hideMenu()
		"controls":
			controlsMenu.close()
			mainMenu.open()
			current_menu = "main"
			AudioHandler.playSound("ui_click")
		"settings":
			settingsMenu.close()
			mainMenu.open()
			current_menu = "main"
			AudioHandler.playSound("ui_click")
		"credits":
			creditsMenu.close()
			mainMenu.open()
			current_menu = "main"
			AudioHandler.playSound("ui_click")
		"closed":
			showMenu()
	
func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		handleEscape()
