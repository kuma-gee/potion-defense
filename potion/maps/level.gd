class_name Level
extends MoveNext

@export var map: PackedScene

func _ready() -> void:
	super()
	next.connect(func(): Events.start_level(map))
