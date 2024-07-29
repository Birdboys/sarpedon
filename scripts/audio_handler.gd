extends Node
@onready var bgMusicPlayer := $bgMusicPlayer
@onready var soundQueue := $soundEffectQueue
@onready var soundQueue3D := $soundEffectQueue3D
@onready var players := []
@onready var players_3d := []
@onready var queue_length := 5
@onready var queue_index := 0
@onready var queue_3d_index := 0
@onready var audio_num_vars = {"ui_click":3}
# Called when the node enters the scene tree for the first time.
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
		
func playSound(audio):
	var current_player : AudioStreamPlayer = players[queue_index] 
	queue_index = clamp(queue_index+1, 0, queue_length-1)
	if current_player.playing: current_player.stop()
	current_player.stream = getAudio(audio)
	current_player.play()
	print("PLAYING AUDIO ", audio)
	
func playSound3D(audio, pos: Vector3):
	var current_player : AudioStreamPlayer = players[queue_3d_index] 
	queue_3d_index = clamp(queue_3d_index+1, 0, queue_length-1)
	if current_player.playing: current_player.stop()
	current_player.stream = getAudio(audio)
	current_player.global_position = pos
	current_player.play()
	
func getAudio(audio):
	var audio_name = audio
	if audio_name in audio_num_vars: audio_name = "%s/%s" % [audio_name, randi_range(0, audio_num_vars[audio_name]-1)]
	var sound_stream = load("Assets/sounds/%s.wav" % audio_name)
	return sound_stream
	
func reset3DPlayer(index):
	players_3d[index].global_position = Vector3.ZERO
