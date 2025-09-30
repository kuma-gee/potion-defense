extends Node3D

const UPGRADE_LEVELS = {
	1: []
}

@export var player: Player
@export var survival_timer: Timer
@export var platform: StartPlatform
@export var spawn_manager: SpawnManager

@export_category("UI")
@export var level_label: Label
@export var upgrade_select: Control
@export var upgrade_select_container: Control
@export var gameover_screen: GameoverScreen

var level := 0:
	set(v):
		level = v
		level_label.text = "Level %d" % v

func _ready() -> void:
	get_tree().paused = false
	level = 0

	upgrade_select_container.hide()
	survival_timer.timeout.connect(_on_round_ended)
	platform.pressed.connect(start_round)
	player.died.connect(_on_player_died)
	
	for child in upgrade_select.get_children():
		if not child is UpgradeItem: continue
		
		child.pressed.connect(func():
			if not child.upgrade: return
			UpgradeManager.add_player_upgrade(child.upgrade.name)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			upgrade_select_container.hide()
			print("Selected Upgrade %s" % child.upgrade.name)
		)

func _on_player_died():
	survival_timer.stop()
	spawn_manager.stop()
	gameover_screen.show_gameover()
	print("Player died")


func _on_round_ended():
	platform.reset()
	spawn_manager.stop()

	var available_upgrades = UpgradeManager.get_upgrades_for_level(level)
	for child in upgrade_select.get_children():
		if not child is UpgradeItem: continue
		if available_upgrades.is_empty():
			child.hide()
			continue

		var upgrade = available_upgrades.pick_random()
		child.upgrade = UpgradeManager.get_upgrade_resource(upgrade)
		available_upgrades.erase(upgrade)

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	upgrade_select_container.show()
	print("Round ended")

func start_round():
	level += 1
	survival_timer.start()
	spawn_manager.start()
	print("Round %s started" % level)
