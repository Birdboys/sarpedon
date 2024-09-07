extends Node

func _init() -> void:
	OS.set_environment("SteamAppId", str(480))
	OS.set_environment("SteamGameId", str(480))


func _ready() -> void:
	var init_reps = Steam.steamInitEx()
	print("STEAM INIT", init_reps)
	print("STEAM PERSON", Steam.getPersonaName())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
