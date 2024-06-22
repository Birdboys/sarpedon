extends Node3D

@onready var pos0 := $pos0
@onready var pos1 := $pos1
@onready var pos2 := $pos2

@onready var cup0 := $cup0
@onready var cup1 := $cup1
@onready var cup2 := $cup2

@onready var secret := $secret
@onready var moveTimer := $moveTimer

@onready var slot0
@onready var slot1 
@onready var slot2

@onready var secret_slot = 0

@onready var choosing := false
@onready var choice_id := 1

@export var avg_wait_time := 1.0
@export var wait_time_interval := 0.25

signal choice_made(correct: bool)

func _ready():
	setUpCups()

func _process(delta):
	if choosing:
		if Input.is_action_just_pressed("left"):
			choice_id = wrap(choice_id+1, 0, 3)
			toggleCups(choice_id)
		if Input.is_action_just_pressed("right"):
			choice_id = wrap(choice_id-1, 0, 3)
			toggleCups(choice_id)
		if Input.is_action_just_pressed("dialogic_default_action"):
			print("YOU CHOSE CUP ", choice_id)
			toggleCups(-1)
			emit_signal("choice_made", getCupBySlot(choice_id).has_item)
			print("PICKED THE CORRECT CUP ", getCupBySlot(choice_id).has_item)
			choosing = false
			

func setUpCups():
	cup0.slot = 0
	cup1.slot = 1
	cup2.slot = 2
	
	cup0.position = pos0.position
	cup1.position = pos1.position
	cup2.position = pos2.position
	
	slot0 = cup0
	slot1 = cup1
	slot2 = cup2
	
	cup0.has_item = true
	cup1.has_item = false
	cup2.has_item = false
	secret_slot = 0

func swapTwoCups(cupSlotA, cupSlotB):
	var cupA = getCupBySlot(cupSlotA)
	var cupB = getCupBySlot(cupSlotB)
	var tempCupSlot = cupA.slot
	
	putCupInSlot(cupA, cupB.slot)
	putCupInSlot(cupB, tempCupSlot)

func swapRandomCups():
	var cupA = randi_range(0,2)
	var cupB = randi_range(0,2)
	while cupB == cupA:
		cupB = randi_range(0,2)
	swapTwoCups(cupA, cupB)
	
func rotateCups(dir: bool):
	var cups = [getCupBySlot(0),getCupBySlot(1),getCupBySlot(2)]
	var rotation_mod = 1 if dir else -1
	for x in range(0,3):
		putCupInSlot(cups[x], wrap(x+rotation_mod, 0, 3))
	
func putCupInSlot(cup, slot):
	cup.slot = slot
	match slot:
		0: slot0 = cup
		1: slot1 = cup
		2: slot2 = cup
	
	if cup.has_item:
		secret_slot = slot
		
	var end_pos = getPosFromSlot(slot)
	var new_tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK)
	new_tween.tween_property(cup, "position", getHalfwayMovePos(cup.position, end_pos), 0.5).set_ease(Tween.EASE_IN)
	new_tween.tween_property(cup, "position", end_pos, 0.5).set_ease(Tween.EASE_OUT)

func getCupBySlot(slot):
	match slot:
		0: return slot0
		1: return slot1
		2: return slot2

func getPosFromSlot(slot):
	match slot:
		0: return pos0.position
		1: return pos1.position
		2: return pos2.position

func getHalfwayMovePos(posA, posB):
	var dir := Vector3(posB.x-posA.x, 0, posB.z-posA.z)/2.0 
	var offset := dir.rotated(Vector3.UP, PI/2.0).normalized() * randf_range(0.1,.2)
	return posA + dir + offset

func _on_move_timere_timeout():
	return
	swapRandomCups()
	#moveTimer.start(randf_range(avg_wait_time-wait_time_interval,avg_wait_time+wait_time_interval))

func startChoice():
	choosing = true
	choice_id = 1
	toggleCups(choice_id)
	
func toggleCups(cup_id):
	for x in range(0,3):
		var new_cup = getCupBySlot(x)
		new_cup.handleSelectTween(x==cup_id)

func toggleSecretCup(on: bool):
	var secret_cup = getCupBySlot(secret_slot)
	var cup_tween = get_tree().create_tween()
	if on:
		secret.position = getPosFromSlot(secret_slot)
		secret.position.z += 0.01
		secret.visible = true
		cup_tween.tween_property(secret_cup.cupSprite, "offset", Vector2(0,30), 1.0)
	else:
		cup_tween.tween_property(secret_cup.cupSprite, "offset", Vector2(0,0), 1.0)
		cup_tween.tween_property(secret, "visible", false, 0.1)