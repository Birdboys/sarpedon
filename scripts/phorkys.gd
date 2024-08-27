extends Node3D

@onready var phorkysMesh := $phorkysMesh
@onready var deathArea := $phorkysMesh/deathArea
@onready var deathCol := $phorkysMesh/deathArea/CollisionShape3D
@onready var deathTimer := $deathTimer
@onready var current_phase := "idle"
@onready var summon_tween 
@onready var death_
@export var spawnArea : Area3D

var player

signal phorkys_summon
signal death_area_exit

func _ready():
	spawnArea.body_exited.connect(playerExited)
	Dialogic.signal_event.connect(handleDialogue)
	phorkysMesh.visible = false
	
func playerExited(body):
	if body.name != "playerCharacter": return
	match current_phase:
		"ready": firstSummon(body)

func handleDialogue(type):
	match type:
		"phorkysLeave":
			current_phase = "after_summon"
			var ocean_pos = phorkysMesh.global_position - Vector3.UP * 4
			if summon_tween: summon_tween.kill()
			summon_tween = get_tree().create_tween()
			summon_tween.tween_property(phorkysMesh, "global_position", ocean_pos, 4.0)
			activateDeathArea()
			
func firstSummon(body):
	player = body
	if not body.boat: return
	current_phase = "first_summon"
	Dialogic.start("phorkysIntro")
	emit_signal("phorkys_summon")
	var ocean_pos
	ocean_pos = body.boat.global_position + body.boat.global_basis.z * body.boat.velocity.length()/2.0 - Vector3.UP * 4
	var surface_pos = ocean_pos + Vector3.UP * 5
	phorkysMesh.visible = true
	phorkysMesh.global_position = ocean_pos
	if summon_tween is Tween: summon_tween.kill()
	summon_tween = get_tree().create_tween()
	summon_tween.tween_property(phorkysMesh, "global_position", surface_pos, 4.0)
	AudioHandler.tweenPlayer("ocean", -45.0, 20)
	
func activateDeathArea():
	deathCol.disabled = false
	deathArea.body_exited.connect(playerExitDeathArea)
	deathTimer.timeout.connect(playerDrowned)
	deathTimer.start(15)
	
func playerExitDeathArea(_player):
	emit_signal("death_area_exit")
	deathTimer.stop()
	AudioHandler.tweenPlayer("ocean", 0, 1.0)

func playerDrowned():
	AudioHandler.tweenPlayer("ocean", 0 , 1.0)
	player.deathByPhorkys()
	player = null
	pass
