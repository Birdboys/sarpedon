extends CanvasLayer

@onready var winAnim := $winAnim
@onready var mainMenu := preload("res://scenes/ui/main_menu.tscn")
@export var current_phase := "idle"
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	current_phase = "idle"

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		if current_phase == "quote_done":
			AudioHandler.playSound("ui_click")
			current_phase = "thanking"
			winAnim.play("load_thanks")
		elif current_phase == "thanks_done":
			AudioHandler.playSound("ui_click")
			get_tree().change_scene_to_packed(mainMenu)
			DataHandler.resetGame()
			hideMenu()
		
func showMenu():
	PauseMenu.toggled_on.connect(toggleVis.bind(false))
	PauseMenu.toggled_off.connect(toggleVis.bind(true))
	visible = true
	winAnim.play("load_screen")
	
func hideMenu():
	PauseMenu.toggled_on.disconnect(toggleVis)
	PauseMenu.toggled_off.disconnect(toggleVis)
	visible = false
	current_phase = "idle"

func toggleVis(on):
	visible = on

#func 
