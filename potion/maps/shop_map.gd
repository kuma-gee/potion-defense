class_name ShopMap
extends Map

signal next_level()

@onready var shop_open: RayInteractable = $ShopArea/ShopOpen
@onready var move_next: MoveNext = $ShopArea/MoveNext
@onready var shop_list: UpgradesList = $ShopArea/ShopOpen/EquipmentsSelect

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var prepare_move_next: MoveNext = $PrepareArea/MoveNext
@onready var equipment: UpgradesList = $PrepareArea/Inventory/Equipment
@onready var inventory: RayInteractable = $PrepareArea/Inventory
@onready var purchased: AudioStreamPlayer = $Purchased

var entrance
var shop_items: Array[UpgradeResource] = []

func _ready() -> void:
	#if Events.is_first_level():
		#shop_open.interacted.connect(func(_a):
			#shop_list.show_upgrades(shop_items)
			#move_next.show()
		#)

	Events.upgrade_unlocked.connect(func(): purchased.play())
	inventory.interacted.connect(func(_a):
		equipment.show_upgrades(Events.unlocked_upgrades)
		#prepare_move_next.show()
	)

	move_next.next.connect(func(): _move_to_equipments())
	prepare_move_next.next.connect(func(): next_level.emit())

func setup(map: Map):
	animation_player.play("RESET")
	shop_items.append_array(map.upgrades)
	shop_items = shop_items.filter(func(s): return not Events.has_upgrade(s))

	if is_instance_valid(entrance):
		entrance.queue_free()
		entrance = null

	if map.entrance_scene:
		entrance = map.entrance_scene.instantiate()
		add_child(entrance)

	#if Events.is_first_level():
		##prepare_move_next.hide()
		#move_next.hide()
	#else:
	shop_list.show_upgrades(shop_items)

func _move_to_equipments() -> void:
	animation_player.play("next")
