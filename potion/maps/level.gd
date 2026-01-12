class_name Level
extends MoveNext

func _ready() -> void:
	super()
	next.connect(func(): Events.next_level())
