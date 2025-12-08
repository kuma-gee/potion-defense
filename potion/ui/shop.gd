class_name Shop
extends CenterContainer

@export var container: Control
@export var close_btn: Button

func _ready() -> void:
	hide()
	close_btn.pressed.connect(func(): hide())

func open(items: Array[UpgradeResource]):
	for child in container.get_children():
		child.queue_free()
	
	for item in items:
		var button = Button.new()
		button.text = "%s - Cost: %d" % [item.name, item.cost]
		button.pressed.connect(func(): Events.buy_upgrade.emit(item))
	
