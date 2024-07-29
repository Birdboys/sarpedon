extends Node

@onready var hermes_done := false
@onready var athena_done := false
@onready var graeae_done := false
@onready var translation := {
	"FORWARD": "W",
	"BACK": "S",
	"LEFT": "A",
	"RIGHT": "D",
	"JUMP": "SPACE",
	"INTERACT": "E",
	"INVENTORY": "TAB",
	"EQUIP_SWORD": "R",
	"EQUIP_SHIELD": "Q",
	"USE_SWORD": "LMB",
	"USE_SHIELD": "RMB",
	"USE_HELMET": "CTRL"
}
	
signal translation_updated

func _ready():
	print()
	

func translate(text: String):
	if not text.contains("["): return text
	var text_array = text.split(" ")
	for x in range(len(text_array)):
		if text_array[x].strip_edges().match("[*]"):
			var key = text_array[x].strip_edges().trim_prefix("[").trim_suffix("]")
			var stripped_text
			if key in translation: 
				stripped_text = "[%s]" % translation[text_array[x].strip_edges().trim_prefix("[").trim_suffix("]")]
			else:
				stripped_text = "[%s]" % key
			if text_array[x].begins_with("\n"): stripped_text = "\n"+stripped_text
			text_array[x] = stripped_text
		
	return " ".join(text_array)

func translationUpdated():
	emit_signal("translation_updated")
