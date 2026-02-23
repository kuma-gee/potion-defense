class_name PickupableIngredient
extends RayInteractable

@export var sound: AudioStream
@export var sound_min_pitch: float = 0.8
@export var sound_max_pitch: float = 1.0
@export var volume: float = -5.0
@export var lifetime: Timer

@export var movement_direction: Vector3 = Vector3.ZERO

var res: ItemResource

func _ready() -> void:
	super()
	if lifetime:
		lifetime.timeout.connect(func(): queue_free())

func _process(delta: float) -> void:
	if movement_direction.length() == 0.0:
		return

	global_position += movement_direction * delta

func interact(actor: FPSPlayer) -> void:
	if actor.pickup_item(res):
		AudioManager.play_sfx(sound, volume, randf_range(sound_min_pitch, sound_max_pitch))
		queue_free()
