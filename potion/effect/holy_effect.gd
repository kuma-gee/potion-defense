extends Node3D

@export var hit_box: HitBox
@onready var play_particle_systems: PlayParticleSystems = $PlayParticleSystems

var potion: PotionResource

func _ready() -> void:
	hit_box.apply_potion(potion)
	play_particle_systems.play()
	play_particle_systems.tree_exiting.connect(func(): queue_free())
