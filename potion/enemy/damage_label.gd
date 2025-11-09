extends Node3D

@export var hurt_box: HurtBox
@export var timer: Timer
@export var label: Label3D

func _ready() -> void:
	hide()
	timer.timeout.connect(func(): hide())
	hurt_box.damaged.connect(func(dmg):
		label.text = "%s" % dmg
		timer.start()
		show()
	)
