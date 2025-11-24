class_name Character
extends CharacterBody3D

@export var speed := 1.0
@export var hurt_box: HurtBox
@export var knockback_resistance := 5.0

var knockback: Vector3
var slow_effects := {}

func _ready() -> void:
	hurt_box.knockbacked.connect(func(x): knockback = x)

func get_actual_speed() -> float:
	var actual_speed = speed
	for factor in slow_effects.values():
		actual_speed *= factor
	return actual_speed
	
func get_movement_direction() -> Vector3:
	return Vector3.ZERO

func apply_knockback(delta: float) -> bool:
	var has_knockback = knockback.length() > 0.01
	if has_knockback:
		velocity = get_knockback_force(knockback)
		knockback = knockback.lerp(Vector3.ZERO, delta * knockback_resistance)
		move_and_slide()

	return has_knockback

func get_knockback_force(knock: Vector3) -> Vector3:
	return knock

func damage(amount: int) -> void:
	hurt_box.hit(amount)

func slow(type: String, factor: float) -> void:
	if factor >= 1.0:
		slow_effects.erase(type)
	else:
		slow_effects[type] = factor
