class_name StatusEffectManager
extends Node

signal status_effect_applied(effect: StatusEffect)
signal status_effect_removed(effect: StatusEffect)

var active_effects: Array[StatusEffect] = []

func _physics_process(delta: float) -> void:
	var effects_to_remove: Array[int] = []
	
	for i in range(active_effects.size()):
		var effect = active_effects[i]
		if not effect.update(delta):
			effects_to_remove.append(i)
	
	# Remove finished effects (iterate backwards to avoid index issues)
	for i in range(effects_to_remove.size() - 1, -1, -1):
		var idx = effects_to_remove[i]
		var effect = active_effects[idx]
		active_effects.remove_at(idx)
		status_effect_removed.emit(effect)

func apply_effect(effect: StatusEffect) -> void:
	var target = get_parent()
	if not target:
		push_warning("StatusEffectManager has no parent to apply effects to")
		return
	
	# Check if we should stack or refresh
	var existing_effect = _find_stackable_effect(effect)
	if existing_effect:
		existing_effect.time_remaining = effect.duration
		return
	
	var eff = effect
	eff.apply(target)
	active_effects.append(eff)
	status_effect_applied.emit(eff)

func remove_effect(effect: StatusEffect) -> void:
	var idx = active_effects.find(effect)
	if idx >= 0:
		effect.remove()
		active_effects.remove_at(idx)
		status_effect_removed.emit(effect)

func remove_effects_by_type(effect_type: String) -> void:
	var effects_to_remove: Array[StatusEffect] = []
	
	for effect in active_effects:
		if effect.get_effect_type() == effect_type:
			effects_to_remove.append(effect)
	
	for effect in effects_to_remove:
		remove_effect(effect)

func has_effect_type(effect_type: String) -> bool:
	for effect in active_effects:
		if effect.get_effect_type() == effect_type:
			return true
	return false

func clear_all_effects() -> void:
	for effect in active_effects:
		effect.remove()
		status_effect_removed.emit(effect)
	active_effects.clear()

func _find_stackable_effect(new_effect: StatusEffect) -> StatusEffect:
	for effect in active_effects:
		if new_effect.can_stack_with(effect):
			return effect
	return null
