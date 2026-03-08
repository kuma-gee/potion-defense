class_name ProcessAction
extends Node

signal finished(success: bool)
signal cancelled()

@export var automatic := false

var player: FPSPlayer
var hovered_players: Array = []

func update(_delta: float) -> void:
	pass

func on_item_changed(_item: ItemResource) -> void:
	pass

func action_pressed(actor: FPSPlayer) -> void:
	if player == null:
		player = actor
	_on_action_pressed()

func action_released(actor: FPSPlayer) -> void:
	if actor == player:
		player = null
		_on_action_released()

func _on_action_pressed() -> void:
	pass

func _on_action_released() -> void:
	pass

func cancel() -> void:
	cancelled.emit()

func complete() -> void:
	finished.emit(true)

func fail() -> void:
	finished.emit(false)

func hovered(actor: FPSPlayer) -> void:
	if not hovered_players.has(actor):
		hovered_players.append(actor)
	_on_hover_change(hovered_players.size())

func unhovered(actor: FPSPlayer) -> void:
	hovered_players.erase(actor)
	_on_hover_change(hovered_players.size())

func _on_hover_change(player_count: int) -> void:
	pass
