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
	remapButton.text = DataHandler.translate("[%s]" % action_name.to_upper())
	
func remapPressed():
	if listening: return
	AudioHandler.playSound("ui_click")
	emit_signal("capturing")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	listening = true
	setButtonText("listening...")
	var input = await input_captured
	AudioHandler.playSound("ui_click")
	var cleaned_input_text = cleanInput(input)
	listening = false
	rebindToInput(input, cleaned_input_text)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func cleanInput(input):
	var text = ""
	if input is InputEventKey:
		text = input.as_text_key_label().replace("(Physical)", "")
	else:
		match input.button_index:
			1: text = "LMB"
			2: text = "RMB"
			3: text = "MMB"
			4: text = "MWU"
			5: text = "MWD"
			
	return text.strip_edges()
		
func rebindToInput(input, clean_text):
	InputMap.action_erase_event(action_name, InputMap.action_get_events(action_name)[0])
	InputMap.action_add_event(action_name, input)
	DataHandler.translation[action_name.to_upper()] = clean_text
	DataHandler.translationUpdated()
	remapButton.text = DataHandler.translate("[%s]" % action_name.to_upper())

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
