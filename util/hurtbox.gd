class_name HurtBox
extends Area3D

signal died()
signal health_changed()
signal damaged(dmg)
signal knockbacked(force)
signal elemental_hit(element: ElementalArea.Element)

@export var resistance: Dictionary[ElementalArea.Element, float] = {
	ElementalArea.Element.FIRE: 0.0,
	ElementalArea.Element.ICE: 0.0,
	ElementalArea.Element.LIGHTNING: 0.0,
	ElementalArea.Element.POISON: 0.0,
}

@export var invincibility_timer: Timer
@export var shield: Shield
@export var status_manager: StatusEffectManager
@export var max_health := 10.0
@onready var health := max_health:
	set(v):
		health = clamp(v, 0, max_health)
		health_changed.emit()
		
		if is_dead():
			set_deferred("monitorable", false)
			died.emit()

func _ready() -> void:
	if invincibility_timer: # On revive we create a new instance
		invincibility_timer.start()

func set_max_health(new_max_health: float):
	max_health = new_max_health
	health = new_max_health
	health_changed.emit()

func hit(dmg: float, knockback = Vector3.ZERO, element = ElementalArea.Element.NONE):
	if is_dead() or is_invincible():
		return
	
	if shield:
		dmg = shield.shield_damage(dmg)
		if dmg <= 0.0:
			return
	
	var mult = 1.0 - (resistance[element] if element in resistance else 0.0)
	var effective_dmg = dmg * mult
	health -= effective_dmg

	damaged.emit(effective_dmg)
	if element != ElementalArea.Element.NONE:
		elemental_hit.emit(element)

	if effective_dmg > 0 and knockback:
		knockback.y = 0
		knockbacked.emit(knockback * mult)

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

func is_invincible():
	return invincibility_timer and not invincibility_timer.is_stopped()
