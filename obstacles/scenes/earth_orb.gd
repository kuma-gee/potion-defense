extends CharacterBody3D

@export var speed := 10
@export var descend_distance := 5
@export var hit_particles: PackedScene
@export var gravity := 1.0
@export var meteorite: Node3D

@onready var hit_box: HitBox = $HitBox
@onready var player = get_tree().get_first_node_in_group("player") as Player
@onready var move_delay: Timer = $MoveDelay

func _physics_process(delta: float) -> void:
	if not move_delay.is_stopped(): return
	
	var dir = meteorite.global_position.direction_to(player.global_position)
	meteorite.look_at(player.global_position, Vector3.UP)
	velocity = dir * speed
	#velocity.z = dir.z * speed

	#var distance = global_position.distance_to(player.global_position)
	#if distance <= descend_distance:
	#velocity.y = gravity * delta

	if move_and_slide():
		velocity = Vector3.ZERO
		
		var collision = get_last_slide_collision()
		var pos = collision.get_position()
		hit_box.hit()
		_spawn_hit_particles(pos)

func _spawn_hit_particles(pos: Vector3) -> void:
	if not hit_particles:
		return
	
	var particles = hit_particles.instantiate() as Node3D
	particles.position = pos
	get_tree().current_scene.add_child(particles)
	
	await get_tree().physics_frame
	queue_free()
