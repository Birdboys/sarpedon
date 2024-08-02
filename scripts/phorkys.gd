extends Node3D

@onready var phorkysMesh := $phorkysMesh
@onready var current_phase := "idle"
@onready var summon_tween := get_tree().create_tween()
@export var spawnArea : Area3D

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
			if summon_tween is Tween: summon_tween.kill()
			summon_tween = get_tree().create_tween()
			summon_tween.tween_property(phorkysMesh, "global_position", ocean_pos, 4.0)
			
func firstSummon(body):
	if not body.boat: return
	current_phase = "first_summon"
	Dialogic.start("phorkysIntro")
	var ocean_pos
	#if body.boat:
	ocean_pos = body.boat.global_position + body.boat.global_basis.z * 5 - Vector3.UP * 3
	#else:
		#ocean_pos = body.global_position - body.global_basis.z * 4 - Vector3.UP * 3
	var surface_pos = ocean_pos + Vector3.UP * 4
	phorkysMesh.visible = true
	phorkysMesh.global_position = ocean_pos
	if summon_tween is Tween: summon_tween.kill()
	summon_tween = get_tree().create_tween()
	summon_tween.tween_property(phorkysMesh, "global_position", surface_pos, 4.0)
