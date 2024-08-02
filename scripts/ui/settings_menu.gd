extends Control
@onready var sensSlider := $ScrollContainer/settingsVbox/sensitivitySlider/MarginContainer2/VBoxContainer/MarginContainer/sensSlider
@onready var audioSlider := $ScrollContainer/settingsVbox/audioSlider/MarginContainer2/VBoxContainer/MarginContainer/audio
@onready var musicSlider := $ScrollContainer/settingsVbox/musicSlider/MarginContainer2/VBoxContainer/MarginContainer/music

signal sens_changed(new_sens)

func _ready():
	sensSlider.value_changed.connect(sensUpdated)
	audioSlider.value_changed.connect(audioUpdated)
	musicSlider.value_changed.connect(musicUpdated)

func open():
	visible = true
	loadSettings()
	
func close():
	visible = false

func loadSettings():
	sensSlider.set_value_no_signal(DataHandler.settings['sensitivity'])
	audioSlider.set_value_no_signal(DataHandler.settings['audio_volume'])
	musicSlider.set_value_no_signal(DataHandler.settings['music_volume'])

func sensUpdated(val):
	DataHandler.settings['sensitivity'] = val
	emit_signal("sens_changed", val)

func audioUpdated(val):
	DataHandler.settings['audio_volume'] = val
	AudioServer.set_bus_volume_db(1, remap(val, 0.0, 100.0, -60.0, 0.0))

func musicUpdated(val):
	DataHandler.settings['music_volume'] = val
