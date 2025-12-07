class_name WandAbility
extends RefCounted

var player: FPSPlayer
var wand: WandResource
var is_active: bool = false
var time_remaining: float = 0.0

func _init(p_player: FPSPlayer, p_wand: WandResource) -> void:
	player = p_player
	wand = p_wand

func activate() -> void:
	is_active = true
	time_remaining = wand.duration
	_on_activate()

func deactivate() -> void:
	is_active = false
	time_remaining = 0.0
	_on_deactivate()

func process(delta: float) -> void:
	if is_active:
		time_remaining -= delta
		_on_process(delta)
		
		if time_remaining <= 0.0:
			deactivate()

func _on_activate() -> void:
	pass

func _on_deactivate() -> void:
	pass

func _on_process(_delta: float) -> void:
	pass
