class_name Chest
extends RayInteractable

@export var static_collision: CollisionShape3D
@export var item: ItemResource:
	set(v):
		item = v
		visible = item != null
		static_collision.disabled = not visible
		current_capacity = item.max_capacity if item else 0
		timer.stop()

		if is_inside_tree():
			label.text = item.name if item else ""

var timer: Timer = Timer.new()
var current_capacity := 0

func _ready() -> void:
	super()

	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(func():
		if current_capacity < (item.max_capacity if item else 0):
			current_capacity += 1
	)

	hovered.connect(func(_a): label.text = ("%s (%s/%s)" % [item.name, current_capacity, item.max_capacity]) if item else "")
	interacted.connect(func(actor: Node):
		if actor is FPSPlayer:
			_give_item(actor as FPSPlayer)
	)

func _give_item(player: FPSPlayer) -> void:
	if not item or (current_capacity <= 0 and item.max_capacity > 0):
		return
	
	if player.has_item():
		print("Player already has an item")
		return
	
	player.pickup_item(item)
	print("Gave item from chest: %s" % item.name)
	current_capacity -= 1
	timer.start(item.restore_time)
