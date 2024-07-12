extends HBoxContainer

@onready var actionText := $actionText
@onready var remapButton := $remapButton
@onready var listening := false
@export var action_text : String
@export var action_name : String

signal capturing
signal input_captured(input)

func _ready():
	actionText.text = action_text
	remapButton.pressed.connect(remapPressed)
	setButtonText(InputMap.action_get_events(action_name)[0].as_text())

func remapPressed():
	if listening: return
	emit_signal("capturing")
	listening = true
	setButtonText("listening...")
	var input = await input_captured
	listening = false
	rebindToInput(input)
	
func rebindToInput(input):
	if input is InputEventKey:
		setButtonText(input.as_text_key_label())
	else:
		match input.button_index:
			1: setButtonText("LMB")
			2: setButtonText("RMB")
			3: setButtonText("MMB")
			4: setButtonText("MWU")
			5: setButtonText("MWD")
			 
	InputMap.action_erase_event(action_name, InputMap.action_get_events(action_name)[0])
	InputMap.action_add_event(action_name, input)

func clear():
	listening = false
	setButtonText(InputMap.action_get_events(action_name)[0].as_text())
	
func setButtonText(text):
	var clean_text = text
	if "(Physical)" in text:
		clean_text = text.replace("(Physical)", "")
	elif text == "Left Mouse Button":
		clean_text = "LMB"
	elif text == "Right Mouse Button":
		clean_text = "RMB"
	remapButton.text = clean_text.strip_edges()
		
func _input(event):
	if not listening: return
	if event is InputEventKey and event.pressed:
		emit_signal("input_captured", event)
	if event is InputEventMouseButton and event.pressed and event.button_index <= 5:
		emit_signal("input_captured", event)
