extends Control
@onready var loadingScreen := preload("res://scenes/ui/loading_screen.tscn")
@onready var goin := false
@onready var islandScene
@onready var sussy_keycodes := [KEY_TAB, KEY_ALT, KEY_ESCAPE]

var loading_screen
var island_scene 

func _ready():
	#$VBoxContainer/Button.pressed.connect(mainPressed)
	loading_screen = loadingScreen.instantiate()

func mainPressed():
	if goin: return
	goin = true
	visible = false
	get_tree().root.add_child(loading_screen)
	loading_screen.ready_to_play.connect(startTheGame)
	LoadHandler.load_finished.connect(loading_screen.gameLoaded)
	LoadHandler.startLoad()
	
func startTheGame():
	island_scene = ResourceLoader.load_threaded_get("res://assets/temp/test_island.tscn")
	LoadHandler.load_finished.disconnect(loading_screen.gameLoaded)
	get_tree().change_scene_to_packed(island_scene)

func _unhandled_key_input(event):
	if event.keycode not in sussy_keycodes:
		mainPressed()
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
