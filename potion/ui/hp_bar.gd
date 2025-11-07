class_name HpBar
extends ProgressBar

@export var hurt_box: HurtBox

func _ready() -> void:
	max_value = hurt_box.max_health
	_update_health()
	hide()
	hurt_box.health_changed.connect(_update_health)

func _update_health():
	value = hurt_box.health
	visible = not hurt_box.max_health == hurt_box.health
