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

@export var heal_multiplier := 1.0
@export var damage_multiplier := 1.0
@export var anti_heal := false
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
	if is_dead(): return
	if is_invincible() and dmg > 0:
		return
	
	if shield and dmg > 0:
		dmg = shield.shield_damage(dmg)
		if dmg <= 0.0:
			return
	
	var mult = 1.0 - get_resistance(element)
	var effective_dmg = dmg * mult * damage_multiplier
	
	if dmg > 0:
		health -= effective_dmg
		damaged.emit(effective_dmg)
		if effective_dmg > 0 and knockback:
			knockback.y = 0
			knockbacked.emit(knockback * mult)
	elif dmg < 0:
		if anti_heal and element == ElementalArea.Element.HOLY:
			var x = abs(effective_dmg)
			health -= x
			damaged.emit(x)
		else:
			health -= effective_dmg * heal_multiplier # Healing

	if element != ElementalArea.Element.NONE:
		elemental_hit.emit(element)

func apply_effect(effect: StatusEffect):
	if status_manager and effect:
		var eff = effect.duplicate()

		if eff.element != ElementalArea.Element.NONE:
			elemental_hit.emit(eff.element)

			var resist = get_resistance(eff.element)
			if resist >= 1.0:
				return  # Immune to this effect

			elif resist > 0.0:
				eff.duration *= (1.0 - resist)

		status_manager.apply_effect(eff)

func get_resistance(elem: ElementalArea.Element):
	return resistance[elem] if elem in resistance else 0.0

func is_dead():
	return health <= 0

func is_invincible():
	return invincibility_timer and not invincibility_timer.is_stopped()
