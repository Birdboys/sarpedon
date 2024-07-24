extends CanvasLayer
@onready var deathLine := $deathUI/screenMargin/quoteBorder/quoteMargin/deathLine
@onready var deathAnim := $deathAnim
@onready var tooltipText := $deathUI/screenMargin/quoteBorder/quoteMargin/tooltipText
@export var new_game_loaded := false
# Called when the node enters the scene tree for the first time.
func _ready():
	hideMenu()

func _process(delta):
	if new_game_loaded and Input.is_action_just_pressed("interact"):
		startGameAgain()

func hideMenu():
	visible = false
	deathAnim.play("RESET")
	
func loadDeathScreen(type):
	new_game_loaded = false
	visible = true
	match type:
		"drowned":
			deathLine.text = "YOU SUCCUMBED TO DEEP WATERS"
		"phorkys":
			pass
		"petrify":
			deathLine.text = "YOU WERE PETRIFIED BY THE GORGONS"
	deathAnim.play("load_screen")
	LoadHandler.load_finished.connect(gameLoaded)
	LoadHandler.startLoad()
	
func gameLoaded():
	new_game_loaded = true
	deathAnim.play("load_tooltip")

func startGameAgain():
	new_game_loaded = false
	var game = LoadHandler.retrieveLoad()
	get_tree().change_scene_to_packed(game)
	hideMenu()
