extends Node

var steam_running := false

func _init() -> void:
	OS.set_environment("SteamAppId", str(3164390))
	OS.set_environment("SteamGameId", str(3164390))

func _ready() -> void:
	initializeSteam()
	
func initializeSteam():
	var init_reps = Steam.steamInitEx()
	print(init_reps)
	if init_reps['status'] > 0:
		steam_running = false
	else:
		steam_running = true

func achievementGet(achievement):
	if not steam_running: return
	Steam.setAchievement(achievement)
	Steam.storeStats()
	
