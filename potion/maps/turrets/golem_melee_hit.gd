extends Node3D

@onready var play_particle_systems: PlayParticleSystems = $PlayParticleSystems
@onready var small_hit: HitBox = $SmallHit

var potion: PotionResource

func _ready() -> void:
	small_hit.apply_potion(potion)
	play_particle_systems.play()
	
	await get_tree().create_timer(0.1).timeout
	small_hit.hit()
