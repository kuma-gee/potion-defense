extends Node3D

@export var explosion_vfx: PackedScene

@onready var puff_clouds_2: GPUParticles3D = $VFX_Puff_styleB/puff_clouds2
@onready var vfx_puff_style_b: Node3D = $VFX_Puff_styleB

@onready var poison: PotionHitArea = $Poison
@onready var elemental_area: ElementalArea = $ElementalArea
@onready var large_hit: HitBox = $LargeHit
@onready var cleanup: Timer = $Cleanup

func _ready() -> void:
	#if elemental_area.has_contact_with(ElementalArea.Element.FIRE):
		#_explode()
	#else:
	poison.finished.connect(func():
		puff_clouds_2.emitting = false
		await get_tree().create_timer(puff_clouds_2.lifetime).timeout
		queue_free()
	)

	elemental_area.received.connect(func(element):
		if element == ElementalArea.Element.FIRE:
			_explode()
	)

	cleanup.timeout.connect(func(): queue_free())

func _explode():
	var node = explosion_vfx.instantiate()
	node.position = global_position
	get_parent().add_child(node)
	
	large_hit.hit()
	poison.queue_free()
	puff_clouds_2.hide()
	puff_clouds_2.emitting = false
	cleanup.start()
