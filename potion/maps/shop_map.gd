class_name ShopMap
extends Node3D

@onready var purchased: AudioStreamPlayer = $Purchased
@onready var move_shop: MoveNext = $MoveShop
@onready var equipment: UpgradesList = $Equipment
@onready var shop_items: UpgradesList = $ShopItems
@onready var player_join: PlayerJoin = $PlayerJoin

func _ready() -> void:
	get_tree().paused = false
	Events.upgrade_unlocked.connect(func(): purchased.play())
	move_shop.next.connect(func(): SceneManager.change_to_map_select())
	
	shop_items.show_upgrades(Events.unlocked_shop_items.filter(func(s): return not Events.has_upgrade(s)))
	equipment.show_upgrades(Events.unlocked_upgrades)

	for player_id in Events.players:
		player_join.setup_player(player_id)
