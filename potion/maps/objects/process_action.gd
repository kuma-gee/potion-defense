class_name ProcessAction
extends Node

signal started(player)
signal finished(success: bool)
signal cancelled()

@export var automatic := false

var station: ProcessingItem
var player: FPSPlayer
var running: bool = false

func setup(processing_item: ProcessingItem) -> void:
	station = processing_item

func start(actor: FPSPlayer) -> void:
	player = actor
	running = true
	_reset_state()
	started.emit(player)

func update(delta: float) -> void:
	if not running:
		return
	_on_update(delta)

func on_item_changed(_item: ItemResource):
	pass

func action_pressed() -> void:
	if not running:
		return
	_on_action_pressed()

func action_released() -> void:
	if not running:
		return
	_on_action_released()

func cancel() -> void:
	if not running:
		return
	running = false
	_on_cancelled()
	cancelled.emit()

func complete() -> void:
	if not running:
		return
	running = false
	_on_completed()
	finished.emit(true)

func fail() -> void:
	if not running:
		return
	running = false
	_on_failed()
	finished.emit(false)

func _reset_state() -> void:
	pass

func _on_update(_delta: float) -> void:
	pass

func _on_action_pressed() -> void:
	pass

func _on_action_released() -> void:
	pass

func _on_cancelled() -> void:
	pass

func _on_completed() -> void:
	pass

func _on_failed() -> void:
	pass
