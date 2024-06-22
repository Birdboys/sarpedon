extends Node3D

@export var cup_index: int
@export var slot: int
@export var has_item := false
@onready var cupSprite := $cupSprite
var cup_tween : Tween

func handleSelectTween(is_selected):
	if cup_tween:
		cup_tween.kill()
		cup_tween = null
	if is_selected:
		cup_tween = get_tree().create_tween()
		cup_tween.tween_property(cupSprite, "offset", Vector2(0, 3), 0.25)
	else:
		cupSprite.offset = Vector2.ZERO
