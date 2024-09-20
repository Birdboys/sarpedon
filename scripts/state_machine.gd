extends Node
class_name StateMachine

@export var initial_state : State
var current_state : State
var states : Dictionary = {}
var prev_state : String

func initialize(parent):
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_state_transition)
			child.parent = parent

	if initial_state:
		initial_state.enter()
		current_state = initial_state
		
func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func on_state_transition(state, new_state_name):
	print("TRANSITION FROM %s to %s" % [state.name, new_state_name])
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	if current_state:
		current_state.exit()
	
	new_state.enter()
	prev_state = current_state.name
	current_state = new_state
	
