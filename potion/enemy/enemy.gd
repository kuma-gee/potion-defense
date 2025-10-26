class_name Enemy
extends CharacterBody3D

@export var speed := 3.0
@export var attack_anims: Array[String] = []
@export var hit_box: HitBox
@export var animation_player: AnimationPlayer

# Animation Tree doesnt work?
var is_attacking := false
var attack_num := 0:
	set(v):
		attack_num = v % attack_anims.size()

func _ready() -> void:
	animation_player.animation_finished.connect(func(_a):
		hit_box.hit()
		is_attacking = false
	)

func _physics_process(_delta: float) -> void:
	if hit_box.has_overlapping_areas():
		if not is_attacking:
			animation_player.play(attack_anims[attack_num])
			attack_num += 1
			is_attacking = true
		return
	
	var dir = -global_basis.z.normalized()
	velocity = dir * speed
	move_and_slide()
	animation_player.play("Running_A")
