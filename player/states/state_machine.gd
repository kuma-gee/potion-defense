class_name StateMachine
extends Node

signal state_changed(old_state: State, new_state: State)

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	# Wait for children to be ready
	await get_tree().process_frame
	
	# Gather all state children
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transition_requested.connect(_on_transition_requested)
	
	# Start with initial state
	if initial_state:
		change_state(initial_state)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func reset_state():
	change_state(null)

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
		
	var old_state = current_state
	
	if current_state:
		current_state.exit()
	
	current_state = new_state if new_state != null else initial_state
	
	if current_state:
		current_state.enter()
	
	state_changed.emit(old_state, current_state)

func _on_transition_requested(from_state: State, to_state_name: String) -> void:
	if from_state != current_state:
		return
	
	var new_state = states.get(to_state_name.to_lower())
	if new_state:
		change_state(new_state)
	else:
		push_error("State not found: " + to_state_name)

func get_state(state_name: String) -> State:
	return states.get(state_name.to_lower())
