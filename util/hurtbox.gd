class_name HurtBox
extends Area3D

signal died()
signal health_changed()
signal damaged(dmg)
signal knockbacked(force)
signal elemental_hit(element: ElementalArea.Element)

@export var resistance: Dictionary = {
	ElementalArea.Element.FIRE: 0.0,
	ElementalArea.Element.ICE: 0.0,
	ElementalArea.Element.LIGHTNING: 0.0,
	ElementalArea.Element.POISON: 0.0,
}

@export var status_manager: StatusEffectManager
@export var max_health := 10.0
@onready var health := max_health:
	set(v):
		health = clamp(v, 0, max_health)
		health_changed.emit()
		
		if is_dead():
			set_deferred("monitorable", false)
			died.emit()

func set_max_health(new_max_health: float):
	max_health = new_max_health
	health = new_max_health
	health_changed.emit()

func hit(dmg: float, knockback = Vector3.ZERO, element = ElementalArea.Element.NONE):
	if is_dead():
		return
	
	var mult = 1.0 - (resistance[element] if element in resistance else 0.0)
	var effective_dmg = dmg * mult
	health -= effective_dmg

	damaged.emit(effective_dmg)
	if element != ElementalArea.Element.NONE:
		elemental_hit.emit(element)

	if knockback:
		knockbacked.emit(knockback)

func apply_effect(effect: StatusEffect):
	if status_manager and effect:
		var eff = effect.duplicate()

		if eff.element != ElementalArea.Element.NONE:
			elemental_hit.emit(eff.element)

			var resist = resistance[eff.element] if eff.element in resistance else 0.0
			if resist >= 1.0:
				return  # Immune to this effect

			elif resist > 0.0:
				eff.duration *= (1.0 - resist)

		status_manager.apply_effect(eff)

func is_dead():
	return health <= 0
