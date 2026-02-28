extends Node3D

@export var freeze_time := 3.0
@export var small_hit: HitBox

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cleanup_timer: Timer = $CleanupTimer
@onready var freeze_area: Area3D = $FreezeArea

var potion: PotionResource

func _ready() -> void:
	small_hit.apply_potion(potion, 1.0)
	animation_player.play("start")
	cleanup_timer.timeout.connect(func(): queue_free())

func _freeze():
	for body in freeze_area.get_overlapping_bodies():
		if body is Character:
			small_hit.hit()
			body.freeze(freeze_time)
