extends Timer

@export var timer: Timer

func _ready() -> void:
	timeout.connect(func(): timer.start())
