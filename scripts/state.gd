extends Node
class_name State

signal transitioned
var parent
@export var camera_control := true
@export var movement_control := true
@export var interact_control := true

func enter():
	pass

func exit():
	pass

func update(_delta):
	pass

func physics_update(_delta):
	pass
