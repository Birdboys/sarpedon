extends Control
@onready var loadingScreen := preload("res://scenes/ui/loading_screen.tscn")
@onready var goin := false
@onready var islandScene
@onready var loadTimer := $loadTimer

var loading_screen
var island_scene 

func _ready():
	$VBoxContainer/Button.pressed.connect(mainPressed)
	loadTimer.timeout.connect(checkLoad)
	loading_screen = loadingScreen.instantiate()

func mainPressed():
	if goin: return
	goin = true
	visible = false
	get_tree().root.add_child(loading_screen)
	print("LOADING SCREEN ADDED TO SCENE, ", Time.get_ticks_msec())
	loading_screen.ready_to_play.connect(startTheGame)
	ResourceLoader.load_threaded_request("res://assets/temp/test_island.tscn")
	checkLoad()
	
func startTheGame():
	island_scene = ResourceLoader.load_threaded_get("res://assets/temp/test_island.tscn")
	get_tree().change_scene_to_packed(island_scene)
	#queue_free()

func checkLoad():
	var res = ResourceLoader.load_threaded_get_status("res://assets/temp/test_island.tscn")
	if res == ResourceLoader.THREAD_LOAD_LOADED:
		loading_screen.gameLoaded()
	else:
		loadTimer.start(0.1)
