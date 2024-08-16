extends Node3D
@onready var goin := false
@onready var is_ready := false
@onready var islandScene
@onready var sussy_keycodes := [KEY_TAB, KEY_ALT, KEY_ESCAPE, KEY_P]

@onready var anim := $mainAnim
@onready var tooltipAnim := $tooltipAnim
@onready var sarpedonTitle := $sarpedonTitle
@onready var ui := $Camera3D/screenMargin
@onready var transitionRect := $Camera3D/transitionRect
@onready var medusaMesh := $medusaMesh
@onready var loadingScreen := preload("res://scenes/ui/loading_screen.tscn")

var loading_screen
var island_scene 
# Called when the node enters the scene tree for the first time.
func _ready():
	transitionRect.modulate = Color.TRANSPARENT
	loading_screen = loadingScreen.instantiate()
	PauseMenu.setTheme("black")
	anim.play("idle")
	PauseMenu.toggled_on.connect(hideUI.bind(true))
	PauseMenu.toggled_off.connect(hideUI.bind(false))
	get_tree().create_timer(3.0).timeout.connect(readyToPlay)
	AudioHandler.setPlayer("wind", -60.0)
	AudioHandler.setPlayer("music", -60.0)
	AudioHandler.togglePlayer("wind", true)
	AudioHandler.togglePlayer("music", true)
	AudioHandler.tweenPlayer("wind", 0, 3.0)
	AudioHandler.tweenPlayer("music", 0, 3.0)
	if DataHandler.good_ending:
		DataHandler.resetGame()
		medusaMesh.visible = true
	else:
		medusaMesh.visible = false

func mainPressed():
	if goin: return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	AudioHandler.playSound("ui_click")
	AudioHandler.tweenPlayer("wind", -60, 2.5)
	AudioHandler.tweenPlayer("music", -60, 2.5)
	goin = true
	var transition_tween = get_tree().create_tween()
	transition_tween.tween_property(transitionRect, "modulate", Color.WHITE, 2.5)
	await transition_tween.finished
	visible = false
	get_tree().root.add_child(loading_screen)
	loading_screen.ready_to_play.connect(startTheGame)
	AudioHandler.togglePlayer("wind", false)
	LoadHandler.load_finished.connect(loading_screen.gameLoaded)
	LoadHandler.startLoad()
	PauseMenu.setTheme("white")

func startTheGame():
	island_scene = ResourceLoader.load_threaded_get("res://assets/temp/test_island.tscn")
	LoadHandler.load_finished.disconnect(loading_screen.gameLoaded)
	get_tree().change_scene_to_packed(island_scene)

func _input(event):
	if is_ready and event is InputEventKey and event.keycode not in sussy_keycodes:
		mainPressed()
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func hideUI(on: bool):
	sarpedonTitle.visible = not on
	ui.visible = not on

func readyToPlay():
	tooltipAnim.play("show")
	is_ready = true
