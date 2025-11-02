class_name StatusEffect
extends Resource

signal finished()

@export var duration: float = 5.0
@export var tick_interval: float = 1.0

var time_remaining: float = 0.0
var tick_timer: float = 0.0
var target: Node = null

func _init(p_duration: float = 5.0, p_tick_interval: float = 1.0) -> void:
	duration = p_duration
	tick_interval = p_tick_interval
	time_remaining = duration

func apply(p_target: Node) -> void:
	target = p_target
	time_remaining = duration
	tick_timer = 0.0
	on_apply()

func update(delta: float) -> bool:
	if not target or not is_instance_valid(target):
		return false
	
	time_remaining -= delta
	tick_timer += delta
	
	if tick_timer >= tick_interval:
		tick_timer -= tick_interval
		on_tick()
	
	on_update(delta)
	
	if time_remaining <= 0:
		on_remove()
		finished.emit()
		return false
	
	return true

func remove() -> void:
	on_remove()
	finished.emit()

# Override these in subclasses
func on_apply() -> void:
	pass

func on_tick() -> void:
	pass

func on_update(_delta: float) -> void:
	pass

func on_remove() -> void:
	pass

func get_effect_type() -> String:
	return "base"

func can_stack_with(other: StatusEffect) -> bool:
	return get_effect_type() == other.get_effect_type()
