extends Area3D

func _ready() -> void:
	body_entered.connect(func(b):
		if b is Character:
			b.drop_death()
	)
