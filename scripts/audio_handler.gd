extends Node
@onready var bgMusicPlayer := $bgMusicPlayer
@onready var soundQueue := $soundEffectQueue
@onready var soundQueue3D := $soundEffectQueue3D
@onready var oceanPlayer := $oceanPlayer
@onready var windPlayer := $windPlayer
@onready var players := []
@onready var players_3d := []
@onready var queue_length := 5
@onready var queue_index := 0
@onready var queue_3d_index := 0
@onready var audio_num_vars = {"ui_click":3, "footstep":5,"footstep_cave":5,"splash":3}

var ocean_tween
var music_tween
var wind_tween 

func _ready():
	populateQueues()

func _process(delta):
	pass

func populateQueues():
	for x in range(queue_length):
		var new_player = AudioStreamPlayer.new()
		var new_3d_player = AudioStreamPlayer3D.new()
		soundQueue.add_child(new_player)
		soundQueue3D.add_child(new_3d_player)
		new_player.bus = "soundEffects"
		new_3d_player.bus = "soundEffects"
		players.append(new_player)
		players_3d.append(new_3d_player)
		new_3d_player.finished.connect(reset3DPlayer.bind(x))

func playSound(audio):
	var current_player : AudioStreamPlayer = players[queue_index] 
	queue_index = wrapi(queue_index+1, 0, queue_length-1)
	if current_player.playing: current_player.stop()
	current_player.stream = getAudio(audio)
	current_player.play()
	
func playSound3D(audio, pos: Vector3):
	var current_player : AudioStreamPlayer3D = players_3d[queue_3d_index] 
	queue_3d_index = wrapi(queue_3d_index+1, 0, queue_length-1)
	if current_player.playing: current_player.stop()
	current_player.stream = getAudio(audio)
	current_player.global_position = pos
	current_player.play()
	
func getAudio(audio):
	var audio_name = audio
	if audio_name in audio_num_vars: audio_name = "%s/%s" % [audio_name, randi_range(0, audio_num_vars[audio_name]-1)]
	var sound_stream = load("Assets/sounds/%s.wav" % audio_name)
	return sound_stream
	
func setPlayer(player, val):
	match player:
		"ocean": oceanPlayer.volume_db = val
		"music": bgMusicPlayer.volume_db = val
		"wind": windPlayer.volume_db = val

func tweenPlayer(player, val, time=1.0):
	match player:
		"ocean": 
			if ocean_tween: ocean_tween.kill()
			ocean_tween = get_tree().create_tween()
			ocean_tween.tween_property(oceanPlayer, "volume_db", val, time)
		"wind": 
			if wind_tween: wind_tween.kill()
			wind_tween = get_tree().create_tween()
			wind_tween.tween_property(windPlayer, "volume_db", val, time)
		"music":
			if music_tween: music_tween.kill()
			music_tween = get_tree().create_tween()
			music_tween.tween_property(bgMusicPlayer, "volume_db", val, time)
		
func togglePlayer(player, on):
	match player:
		"ocean": oceanPlayer.playing = on
		"wind": windPlayer.playing = on
		"music": bgMusicPlayer.playing = on

func reset3DPlayer(index):
	players_3d[index].global_position = Vector3.ZERO
