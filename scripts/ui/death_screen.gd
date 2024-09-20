extends CanvasLayer
@onready var deathLine := $deathUI/screenMargin/quoteBorder/quoteMargin/deathLine
@onready var deathAnim := $deathAnim
@onready var tooltipText := $deathUI/screenMargin/quoteBorder/quoteMargin/tooltipText
@export var new_game_loaded := false
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	deathAnim.play("RESET")

func _process(_delta):
	if new_game_loaded and Input.is_action_just_pressed("interact"):
		startGameAgain()

func hideMenu():
	visible = false
	deathAnim.play("RESET")
	PauseMenu.toggled_on.disconnect(toggleVis)
	PauseMenu.toggled_off.disconnect(toggleVis)
	
func loadDeathScreen(type):
	PauseMenu.toggled_on.connect(toggleVis.bind(false))
	PauseMenu.toggled_off.connect(toggleVis.bind(true))
	new_game_loaded = false
	visible = true
	match type:
		"drowned":
			deathLine.text = "YOU DROWNED IN DEEP WATERS"
			SteamHandler.achievementGet("ACH_GRAVE")
		"phorkys":
			deathLine.text = "YOU SUCCUMBED TO THE ABYSS"
		"petrify":
			deathLine.text = "YOU WERE PETRIFIED BY THE GORGONS"
			SteamHandler.achievementGet("ACH_FROZEN")
		"siren":
			deathLine.text = "YOU WERE LULLED BY THE SIRENS"
			SteamHandler.achievementGet("ACH_SIREN")
		"stheno","euryale","medusa":
			deathLine.text = "YOU WERE SLAIN BY THE GORGONS"
			match type:
				"stheno": DataHandler.stheno_death = true
				"euryale": DataHandler.euryale_death = true
				"medusa": DataHandler.medusa_death = true
			DataHandler.checkUnholy()
		"medusa_slain":
			deathLine.text = "YOU SLAYED MEDUSA"
			SteamHandler.achievementGet("ACH_WRITTEN")
	deathAnim.play("load_screen")
	LoadHandler.load_finished.connect(gameLoaded)
	LoadHandler.startLoad()
	
func gameLoaded():
	new_game_loaded = true
	deathAnim.play("load_tooltip")
	LoadHandler.load_finished.disconnect(gameLoaded)

func startGameAgain():
	new_game_loaded = false
	deathAnim.play("hide_screen")
	await deathAnim.animation_finished
	var game = LoadHandler.retrieveLoad()
	get_tree().change_scene_to_packed(game)
	hideMenu()

func toggleVis(on):
	visible = on
