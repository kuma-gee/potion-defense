class_name GolemMelee
extends Golem

const ENEMY_GROUP = "Enemy"

@export var move_speed: float = 1.0
@export var stop_distance: float = 0.5
@export var attack_scene: PackedScene

@onready var golem_melee_body: CharacterBody3D = $GolemMeleeBody
@onready var attack_area: EnemyAttackRange = $AttackArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_timer: Timer = $AttackTimer

var current_target: Node3D = null

func get_consumption(delta: float):
	if not attack_area.has_overlapping_bodies():
		return 0.0
	return golem.consumption * delta

func process(_delta: float) -> void:
	_move_to_target()
	
	if animation_player.current_animation == "attack" or not attack_timer.is_stopped():
		return
	
	current_target = attack_area.get_target()
	if current_target:
		_attack()

func _update_current_target() -> void:
	if current_target != null:
		if not is_instance_valid(current_target) or not _is_in_move_area(current_target):
			current_target = null

	if current_target == null:
		current_target = attack_area.get_target()

func _move_to_target() -> void:
	var velocity: Vector3 = Vector3.ZERO
	
	if current_target != null and is_instance_valid(current_target):
		var target_position: Vector3 = current_target.global_position
		target_position.y = golem_melee_body.global_position.y
		var direction: Vector3 = golem_melee_body.global_position.direction_to(target_position)
		#var distance: float = golem_melee_body.global_position.distance_to(target_position)
		#if distance > stop_distance:
			#velocity = direction * move_speed
		golem_melee_body.look_at(golem_melee_body.global_position + direction, Vector3.UP)
		#else:
			#golem_melee_body.velocity = velocity
	
	#golem_melee_body.velocity = velocity
	#golem_melee_body.move_and_slide()
	#animation_player.play("move")

func _attack():
	if not current_target: return
	animation_player.play("attack")

func spawn_attack():
	var node = attack_scene.instantiate()
	node.potion = potion
	node.target = current_target
	get_tree().current_scene.add_child(node)
	attack_timer.start(golem.attack_speed)

func _is_in_move_area(body: Node3D) -> bool:
	return body in attack_area.get_overlapping_bodies()
