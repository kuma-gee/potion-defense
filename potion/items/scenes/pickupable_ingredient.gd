class_name PickupableIngredient
extends RayInteractable

@export var sound: AudioStream
@export var sound_min_pitch := 0.8
@export var sound_max_pitch := 1.0
@export var volume := -5.0

var res: ItemResource

func interact(actor: FPSPlayer):
	if actor.pickup_item(res):
		AudioManager.play_sfx(sound, volume, randf_range(sound_min_pitch, sound_max_pitch))
		queue_free()
