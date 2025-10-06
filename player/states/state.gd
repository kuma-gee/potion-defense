class_name State
extends Node

signal transition_requested(from_state: State, to_state_name: String)

@onready var state_machine: StateMachine = get_parent()

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func request_transition(to_state_name: String) -> void:
	transition_requested.emit(self, to_state_name)
