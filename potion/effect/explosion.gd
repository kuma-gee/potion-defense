extends Node3D

@export var small_explosion_anim: AnimationPlayer
@export var small_hitbox: HitBox

# @export var large_explosion_anim: AnimationPlayer
# @export var large_hitbox: HitBox

# @export var elemental: ElementalArea

func _ready() -> void:
	# if elemental.has_contact_with(ElementalArea.Element.POISON):
	# 	_large_explosion()
	# else:
	_small_explosion()

func _small_explosion() -> void:
	small_explosion_anim.play("start")
	await get_tree().create_timer(0.1).timeout
	small_hitbox.hit()

# func _large_explosion() -> void:
# 	large_explosion_anim.play("Init")
# 	large_hitbox.hit()
