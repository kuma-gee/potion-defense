extends Node3D

@export var explosion_vfx: PackedScene

@onready var puff_clouds_2: GPUParticles3D = $VFX_Puff_styleB/puff_clouds2
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var poison: PotionHitArea = $Poison
@onready var cleanup: Timer = $Cleanup

func _ready() -> void:
	poison.finished.connect(func():
		puff_clouds_2.emitting = false
		await get_tree().create_timer(puff_clouds_2.lifetime).timeout
		queue_free()
	)
	poison.received.connect(func(element):
		if element == ElementalArea.Element.FIRE:
			_explode()
	)

	cleanup.timeout.connect(func(): queue_free())
	animation_player.play("start")

func _explode():
	var node = explosion_vfx.instantiate()
	node.position = global_position
	get_parent().add_child(node)
	animation_player.play("explode")
	cleanup.start()
