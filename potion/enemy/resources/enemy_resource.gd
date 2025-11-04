class_name EnemyResource
extends Resource

@export var scene: PackedScene
@export var from_wave: int = 1
@export var until_wave: int = -1
@export var health: int = 100
@export var speed: float = 1.0
@export var damage: int = 10
@export var name: String = "Enemy"
@export var projectile: ProjectileResource