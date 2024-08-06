extends Node3D
@onready var goin := false
@onready var islandScene
@onready var sussy_keycodes := [KEY_TAB, KEY_ALT, KEY_ESCAPE]

@onready var anim := $mainAnim
@onready var sarpedonTitle := $sarpedonTitle
@onready var ui := $Camera3D/screenMargin
@onready var loadingScreen := preload("res://scenes/ui/loading_screen.tscn")

var loading_screen
var island_scene 
# Called when the node enters the scene tree for the first time.
func _ready():
	loading_screen = await loadingScreen.instantiate()
	PauseMenu.setTheme("black")
	anim.play("idle")
	PauseMenu.toggled_on.connect(hideUI.bind(true))
	PauseMenu.toggled_off.connect(hideUI.bind(false))
	hideUI(false)

func mainPressed():
	if goin: return
	AudioHandler.playSound("ui_click")
	goin = true
	visible = false
	get_tree().root.add_child(loading_screen)
	loading_screen.ready_to_play.connect(startTheGame)
	LoadHandler.load_finished.connect(loading_screen.gameLoaded)
	LoadHandler.startLoad()
	PauseMenu.setTheme("white")

func startTheGame():
	island_scene = ResourceLoader.load_threaded_get("res://assets/temp/test_island.tscn")
	LoadHandler.load_finished.disconnect(loading_screen.gameLoaded)
	get_tree().change_scene_to_packed(island_scene)

func _input(event):
	if event is InputEventKey and event.keycode not in sussy_keycodes:
		mainPressed()
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func hideUI(on: bool):
	sarpedonTitle.visible = not on
	ui.visible = not on
