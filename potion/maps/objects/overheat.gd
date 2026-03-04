class_name Overheat
extends Timer

signal overheated

@onready var timer: Timer = $Timer

func _ready() -> void:
	timeout.connect(func(): timer.start())
	timer.timeout.connect(func(): _on_overheated())

func _on_overheated():
	overheated.emit()
	
func reset():
	stop()
	timer.stop()
