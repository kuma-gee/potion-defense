class_name Notification
extends Label

@export var anim_in_duration := 1.0
@export var anim_out_duration := 1.0

var tw: Tween

func _ready() -> void:
	hide()

func show_text(txt: String, show_time := 1.0):
	if tw and tw.is_running(): return
	
	text = txt
	pivot_offset = size / 2
	scale = Vector2.ZERO
	show()

	tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "scale", Vector2.ONE, anim_in_duration)
	tw.tween_property(self, "scale", Vector2.ZERO, anim_out_duration).set_delay(show_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	await tw.finished
	hide()
