class_name ShopMap
extends Node3D

@onready var purchased: AudioStreamPlayer = $Purchased
@onready var move_shop: MoveNext = $MoveShop
@onready var equipment: UpgradesList = $Equipment
@onready var shop_items: UpgradesList = $ShopItems
@onready var golem_upgrades: UpgradesList = $GolemUpgrades
@onready var player_join: PlayerJoin = $PlayerJoin

var selected_golem: GolemResource = null

func _ready() -> void:
	get_tree().paused = false
	Events.upgrade_unlocked.connect(func():
		purchased.play()
		equipment.show_upgrades(Events.golem_counts.keys())
	)
	move_shop.next.connect(func(): SceneManager.change_to_map_select())
	
	shop_items.show_upgrades(Events.unlocked_shop_items)
	shop_items.upgrade_selected.connect(func(upgrade, node):
		if Events.buy_upgrade(upgrade):
			node.queue_free()
	)

	equipment.show_upgrades(Events.golem_counts.keys())
	equipment.upgrade_selected.connect(func(upgrade, node):
		if upgrade is GolemResource:
			var golem = upgrade as GolemResource
			selected_golem = golem
			golem_upgrades.global_position = node.global_position + Vector3.BACK * 2
			golem_upgrades.show_upgrades(golem.upgrades)
			for c in golem_upgrades.get_children():
				c.golem = selected_golem
	)

	golem_upgrades.upgrade_selected.connect(func(upgrade, _node):
		if selected_golem:
			Events.buy_golem_upgrade(selected_golem, upgrade)
	)

	for player_id in Events.players:
		player_join.setup_player(player_id)
