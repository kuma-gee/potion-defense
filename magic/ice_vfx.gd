extends Area3D

var active := false:
	set(v):
		active = v
		
		for b in get_overlapping_bodies():
			if b.has_method("freeze_body"):
				b.freeze_body()

func _ready() -> void:
	body_entered.connect(func(b):
		if active and b.has_method("freeze_body"):
			b.freeze_body()
	)

func activate() -> void:
	active = true

func deactivate():
	active = false
