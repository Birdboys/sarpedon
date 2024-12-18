extends Node

@onready var hermes_done := false
@onready var athena_done := false
@onready var graeae_done := false
@onready var good_ending := false
@onready var medusa_death := false
@onready var stheno_death := false
@onready var euryale_death := false
@onready var player_statue_transforms : Array[Transform3D] = []
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

@onready var settings := {
	"sensitivity" : 50.0,
	"audio_volume": 100.0,
	"music_volume": 100.0
}

@onready var screenshot_id := 0
signal translation_updated

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

func checkUnholy():
	if medusa_death and euryale_death and stheno_death: SteamHandler.achievementGet("ACH_UNHOLY")

func resetGame():
	hermes_done = false
	athena_done = false
	graeae_done = false
	good_ending = false
