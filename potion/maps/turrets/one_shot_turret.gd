class_name OneShotTurret
extends PotionTurret

@export var attack_scene: PackedScene
@export var consumption := 20
@export var damage_reduction := 0.5
@export var spawn_at_target := true

@onready var attack_range: AttackRange = $AttackRange
@onready var attack_timer: Timer = $AttackTimer

func get_consumption(_delta):
	return consumption

func can_attack() -> bool:
	return attack_range.has_enemies_in_range() and attack_timer.is_stopped()

func activate():
	attack_timer.start()
	if spawn_at_target:
		_spawn_attack_at_target()
	else:
		_spawn(global_position)

func _spawn_attack_at_target() -> void:
	var enemy = attack_range.find_nearest_enemy()
	var dir = global_position.direction_to(enemy.global_position)
	var enemy_vel = enemy.velocity

	var pos = enemy.global_position - dir * 0.1 + enemy_vel * 0.1
	_spawn(pos)

func _spawn(pos: Vector3):
	var node = attack_scene.instantiate()
	if node is AttackEffect:
		node.damage_multiplier = 1.0 - damage_reduction

	node.position = pos
	get_tree().current_scene.add_child(node)
