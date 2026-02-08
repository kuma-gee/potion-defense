class_name GolemRangeThrow
extends CharacterBody3D

signal reached_target(target: Node3D)

@export var speed: float = 8.0
@export var arc_height: float = 2.5

@onready var cleanup_timer: Timer = $CleanupTimer
@onready var play_particle_systems: PlayParticleSystems = $PlayParticleSystems
@onready var hit_box: HitBox = $HitBox

var target: Node3D = null
var _start_position: Vector3 = Vector3.ZERO
var _target_position: Vector3 = Vector3.ZERO
var _elapsed: float = 0.0
var _is_active: bool = false
var _total_distance: float = 0.0

var potion: PotionResource

func _ready() -> void:
	hit_box.apply_potion(potion)
	cleanup_timer.timeout.connect(func(): queue_free())
	_start_position = global_position

func set_target(new_target: Node3D) -> void:
	target = new_target
	if not is_instance_valid(target):
		_is_active = false
		return
	set_target_position(target.global_position)

func set_target_position(target_position: Vector3) -> void:
	_start_position = global_position
	_target_position = target_position
	_total_distance = _start_position.distance_to(_target_position)
	_elapsed = 0.0
	_is_active = true

func _physics_process(delta: float) -> void:
	if not _is_active:
		return
	if speed <= 0.0:
		velocity = Vector3.ZERO
		move_and_slide()
		_arrive()
		return
	_elapsed += delta
	
	var duration: float = maxf(_total_distance / speed, 0.0001)
	var t: float = clampf(_elapsed / duration, 0.0, 1.0)
	var flat_position: Vector3 = _start_position.lerp(_target_position, t)
	var height: float = sin(t * PI) * arc_height
	var desired_position: Vector3 = flat_position + Vector3.UP * height
	velocity = (desired_position - global_position) / maxf(delta, 0.0001)
	move_and_slide()
	if t >= 1.0:
		_arrive()

func _arrive() -> void:
	_is_active = false
	velocity = Vector3.ZERO
	move_and_slide()
	global_position = _target_position
	reached_target.emit(target)
	
	hit_box.hit()
	play_particle_systems.play()
	cleanup_timer.start()
