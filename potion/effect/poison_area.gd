extends AttackEffect

@export var explosion_vfx: PackedScene

@onready var puff_clouds_2: GPUParticles3D = $VFX_Puff_styleB/puff_clouds2
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var poison: PotionHitArea = $Poison
@onready var cleanup: Timer = $Cleanup
@onready var large_hit: HitBox = $LargeHit

func _ready() -> void:
	poison.lifetime *= damage_multiplier
	large_hit.damage *= damage_multiplier

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
	get_tree().current_scene.add_child(node)
	animation_player.play("explode")
	cleanup.start()
