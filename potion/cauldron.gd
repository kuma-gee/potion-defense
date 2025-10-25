class_name Cauldron
extends RayInteractable

var items = []

@export var mix_item_per_item := 0.5
@export var potion_amount := 4

var required_time := 0.0
var time := 0.0
var mixing := 0:
	set(v):
		mixing = max(v, 0)
		if mixing == 0:
			time = 0.0

func _ready() -> void:
	super()
	hovered.connect(func(a: FPSPlayer):
		label.text = ""
		if a.has_item():
			label.text = "Fill" if ItemResource.is_empty_potion(a.item) else "Put in"
		elif not items.is_empty():
			label.text = "Mix"
	)
	interacted.connect(func(a: FPSPlayer):
		if mixing > 0:
			return

		if a and a.has_item():
			if a.item == ItemResource.Type.POTION_EMPTY:
				if not items.is_empty() and _is_only_potions():
					a.take_item()
					a.hold_item(items.pop_back())
				return
			elif ItemResource.is_potion(a.item):
				items.append(a.take_item())
				a.hold_item(ItemResource.Type.POTION_EMPTY)
			else:
				items.append(a.take_item())
			
			print("Cauldron items: %s" % [items])
		elif mixing <= 0:
			mixing += 1
	)
	released.connect(func(_a: FPSPlayer): mixing -= 1)

func _is_only_potions():
	for i in items:
		if not ItemResource.is_potion(i):
			return false
	return true

func _process(delta: float) -> void:
	if mixing > 0:
		print("Mixing: %s" % time)
		time += delta
		required_time = mix_item_per_item * items.size()
		if time >= required_time:
			mixing = 0
			_mix_items()

func _mix_items():
	var new_item = ItemResource.find_recipe(items)
	items.clear()

	if new_item:
		for i in potion_amount:
			items.append(new_item)
		
		label.text = ""
		print("Mixed: %s" % [items])
		return
	
	# TODO: explode
