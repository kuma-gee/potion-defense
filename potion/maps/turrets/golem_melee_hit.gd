extends Node3D

@onready var play_particle_systems: PlayParticleSystems = $PlayParticleSystems
@onready var small_hit: HitBox = $SmallHit
@onready var sfx_player: SFXPlayer = $SFXPlayer

var potion: PotionResource
var target: Node3D

func _ready() -> void:
	small_hit.apply_potion(potion)

func _hit():
	play_particle_systems.play()
	small_hit.hit()
	sfx_player.play()

func _process(delta: float) -> void:
	if target:
		global_position = target.global_position
