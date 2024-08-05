extends Control
@onready var border := $screenMargin/quoteBorder
@onready var line1 := $screenMargin/quoteBorder/quoteMargin/quoteVBox/line1
@onready var line2 := $screenMargin/quoteBorder/quoteMargin/quoteVBox/line2
@onready var line3 := $screenMargin/quoteBorder/quoteMargin/quoteVBox/line3
@onready var line4 := $screenMargin/quoteBorder/quoteMargin/quoteVBox/line4
@onready var loadingText := $screenMargin/quoteBorder/quoteMargin/loadingText
@onready var loadingAnim := $loadingAnim
@onready var game_loaded := false
@export var current_phase := "border"

signal ready_to_play 

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	border.self_modulate = Color.TRANSPARENT
	line1.modulate = Color.TRANSPARENT
	line2.modulate = Color.TRANSPARENT
	line3.modulate = Color.TRANSPARENT
	line4.modulate = Color.TRANSPARENT
	loadingAnim.play("loading")
	
func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		handleInteract()

func handleInteract():
	print("handling interact, ", current_phase)
	match current_phase:
		"border":
			current_phase = "tweeningborder"
			var text_tween = get_tree().create_tween()
			text_tween.tween_property(border, "self_modulate", Color.WHITE, 1.0)
			text_tween.tween_property(self, "current_phase", "line1", 0.0)
			AudioHandler.togglePlayer("ocean", true)
			AudioHandler.setPlayer("ocean", -60)
		"line1":
			current_phase = "tweening1"
			var text_tween = get_tree().create_tween()
			text_tween.tween_property(line1, "modulate", Color.WHITE, 1.0)
			text_tween.tween_property(self, "current_phase", "line2", 0.0)
			AudioHandler.tweenPlayer("ocean", -45)
		"line2":
			current_phase = "tweening2"
			var text_tween = get_tree().create_tween()
			text_tween.tween_property(line2, "modulate", Color.WHITE, 1.0)
			text_tween.tween_property(self, "current_phase", "line3", 0.0)
			AudioHandler.tweenPlayer("ocean", -30)
		"line3":
			current_phase = "tweening3"
			var text_tween = get_tree().create_tween()
			text_tween.tween_property(line3, "modulate", Color.WHITE, 1.0)
			text_tween.tween_property(self, "current_phase", "line4", 0.0)
			AudioHandler.tweenPlayer("ocean", -15)
		"line4":
			current_phase = "tweening4"
			var text_tween = get_tree().create_tween()
			text_tween.tween_property(line4, "modulate", Color.WHITE, 1.0)
			text_tween.tween_property(self, "current_phase", "finished", 0.1)
			AudioHandler.tweenPlayer("ocean", 0)
		"finished":
			if game_loaded: quoteFinished()
		_:
			pass
			
func gameLoaded():
	game_loaded = true
	loadingAnim.stop()
	loadingText.modulate = Color.TRANSPARENT

func quoteFinished():
	if current_phase == "finished":
		current_phase = "ending"
		var text_tween = get_tree().create_tween()
		text_tween.tween_property(border, "modulate", Color.TRANSPARENT, 2.5)
		text_tween.tween_callback(transitionFinished)

func transitionFinished():
	emit_signal("ready_to_play")
	queue_free()
