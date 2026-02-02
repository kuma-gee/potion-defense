extends MarginContainer

@export var souls_label: Label
@export var show_if_available := true

func _ready() -> void:
	_update_souls()
	Events.souls_changed.connect(func(): _update_souls())
	visible = not show_if_available or Events.total_souls > 0

func _update_souls():
	souls_label.text = "%s" % Events.total_souls
