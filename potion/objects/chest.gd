class_name Chest
extends RayInteractable

@export var decal: Decal
@export var item_view: CauldronItem
@export var timer_label: Label3D
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
			item_view.type = item.type if item else -1
			if item_view.item:
				decal.texture_albedo = item_view.item.texture

var timer: Timer = Timer.new()
var current_capacity := 0

func _ready() -> void:
	super()
	timer_label.hide()

	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(func():
		var max_cap = get_max_capacity()
		if current_capacity < max_cap:
			current_capacity += 1
			if current_capacity < max_cap:
				timer.start(item.restore_time)
	)

	hovered.connect(func(_a): label.text = ("%s (%s/%s)" % [item.name, current_capacity, item.max_capacity]) if item else "")
	interacted.connect(func(actor: Node):
		if actor is FPSPlayer:
			_give_item(actor as FPSPlayer)
	)

func get_max_capacity():
	return item.max_capacity if item else 0

func _process(_delta: float) -> void:
	if label.visible and not timer.is_stopped() and item:
		timer_label.visible = true
		var time_left = timer.time_left
		timer_label.text = "Restock: %.1fs" % time_left
	else:
		timer_label.visible = false

func _give_item(player: FPSPlayer) -> void:
	if not item or (current_capacity <= 0 and item.max_capacity > 0):
		return
	
	if player.has_item():
		print("Player already has an item")
		return
	
	player.pickup_item(item)
	print("Gave item from chest: %s" % item.name)
	current_capacity -= 1

	if timer.is_stopped():
		timer.start(item.restore_time)
