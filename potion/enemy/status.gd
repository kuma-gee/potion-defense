extends Node3D

@export var status_manager: StatusEffectManager
@export var container: Control

func _ready() -> void:
	status_manager.status_effect_applied.connect(func(_eff): _update())
	status_manager.status_effect_removed.connect(func(_eff): _update())
	
func _update():
	for child in container.get_children():
		child.queue_free()

	for effect in status_manager.active_effects:
		var label = Label.new()
		label.text = effect.get_effect_type()
		container.add_child(label)
