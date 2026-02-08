class_name GolemRange
extends Golem

@export var projectile_count := 3
@export var spawn_pos: Node3D
@export var attack_scene: PackedScene
@export var spread_radius: float = 0.8
@export var spread_radius_jitter: float = 0.3
@export var spread_angle_jitter: float = 0.5

@onready var enemy_attack_range: EnemyAttackRange = $EnemyAttackRange
@onready var attack_timer: Timer = $AttackTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_target: Node3D

func get_consumption(delta: float):
	if not current_target and attack_timer.is_stopped(): return 0.0
	return golem.consumption * delta

func process(_delta: float) -> void:
	if animation_player.current_animation == "attack" or not attack_timer.is_stopped():
		return
	
	current_target = enemy_attack_range.get_target()
	if current_target:
		animation_player.play("attack")

func _throw_attack():
	if golem == null or golem.scene == null:
		return
	
	if not is_instance_valid(current_target):
		return

	var count: int = max(1, projectile_count)
	var base_angle: float = randf() * TAU
	var angle_step: float = TAU / float(count)
	var center: Vector3 = current_target.global_position
	for i: int in range(count):
		var angle_jitter: float = randf_range(-spread_angle_jitter, spread_angle_jitter)
		var angle: float = base_angle + angle_step * float(i) + angle_jitter
		var radius_jitter: float = randf_range(-spread_radius_jitter, spread_radius_jitter)
		var radius: float = maxf(0.0, spread_radius + radius_jitter)
		var offset: Vector3 = Vector3(cos(angle), 0.0, sin(angle)) * radius
		var projectile: GolemRangeThrow = attack_scene.instantiate() as GolemRangeThrow
		projectile.potion = potion
		projectile.position = spawn_pos.global_position
		get_tree().current_scene.add_child(projectile)
		projectile.set_target_position(center + offset)
	
	attack_timer.start(golem.attack_speed)
