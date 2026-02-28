class_name WaveManager
extends Node

const ENEMY_GROUP := Enemy.GROUP

signal game_over()
signal wave_started()
signal wave_completed()
signal all_waves_completed()

@export var obstacle_manager: ObstacleManager
@export var wave_label: Label
@export var enemy_spawn_root: Node3D

@export var spawn_timer: Timer
@export var rest_timer: Timer

@export_category("Wave")
@export var max_wave := 0
@export var start_enemy_value := 0
@export var enemy_value_increase: float = 0.0
@export var spawn_interval := 5.0
@export var paths: Array[Path3D] = []

var is_wave_active: bool = false
var is_final_wave: bool = false

var current_spawn_interval: float = 0.0
var remaining_enemy_value_budget: float = 0.0

var wave: int = 0:
	set(v):
		wave = v
		if wave_label:
			wave_label.text = "Wave %s / %s" % [wave, max_wave]

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_enemy)
	wave_completed.connect(func(): rest_timer.start())
	rest_timer.timeout.connect(next_wave)
	Events.cauldron_destroyed.connect(func(): game_over.emit())

func can_start_wave() -> bool:
	return not is_wave_active and wave < max_wave

func next_wave() -> void:
	if is_wave_active:
		return
	
	if wave > max_wave:
		push_error("WaveManager: Wave %d exceeds max_wave %d" % [wave, max_wave])
		return
	
	wave += 1
	is_wave_active = true
	is_final_wave = false

	var wave_index: int = wave - 1
	current_spawn_interval = spawn_interval
	remaining_enemy_value_budget = _get_wave_enemy_value_budget(wave_index)
	
	print("Starting Wave %d - value budget %.2f" % [wave, remaining_enemy_value_budget])
	wave_started.emit()
	if obstacle_manager:
		obstacle_manager.start()
	
	_schedule_next_spawn()

func _schedule_next_spawn() -> void:
	if not is_wave_active:
		return

	var interval: float = current_spawn_interval
	interval = max(interval, 0.5)
	spawn_timer.start(interval)
	print("Next spawn in %s" % interval)

func _on_spawn_enemy() -> void:
	if not is_wave_active:
		spawn_timer.stop()
		return

	if _spawn_enemy_from_budget():
		_schedule_next_spawn()
		return

func _spawn_enemy_from_budget() -> bool:
	if not is_wave_active:
		return false

	if remaining_enemy_value_budget <= 0.0:
		return false

	var affordable_paths: Array[Path3D] = []
	for path in paths:
		if not path is EnemyPath:
			continue
		var enemy_path: EnemyPath = path as EnemyPath
		if not enemy_path.is_active() or wave < enemy_path.start_wave:
			continue
		for enemy_res in enemy_path.enemies:
			if enemy_res == null:
				continue
			if _get_enemy_value(enemy_res) <= remaining_enemy_value_budget:
				affordable_paths.append(path)
				break

	if affordable_paths.is_empty():
		return false

	var path: Path3D = affordable_paths[randi() % affordable_paths.size()]
	var affordable_enemies: Array[EnemyResource] = []
	for enemy_res in (path as EnemyPath).enemies:
		if enemy_res == null:
			continue
		if _get_enemy_value(enemy_res) <= remaining_enemy_value_budget:
			affordable_enemies.append(enemy_res)

	if affordable_enemies.is_empty():
		return false

	var enemy_res: EnemyResource = affordable_enemies[randi() % affordable_enemies.size()]
	_spawn_enemy(enemy_res, path)
	remaining_enemy_value_budget -= _get_enemy_value(enemy_res)
	print("Spawned enemy (Wave %d) - remaining budget %.2f" % [wave, remaining_enemy_value_budget])
	return true

func _can_spawn_any_enemy() -> bool:
	if remaining_enemy_value_budget <= 0.0:
		return false

	for path in paths:
		if not path is EnemyPath:
			continue
		var enemy_path: EnemyPath = path as EnemyPath
		if not enemy_path.is_active() or wave < enemy_path.start_wave:
			continue
		for enemy_res in enemy_path.enemies:
			if enemy_res == null:
				continue
			if _get_enemy_value(enemy_res) <= remaining_enemy_value_budget:
				return true

	return false

func _spawn_enemy(enemy_res: EnemyResource, path: Path3D) -> void:
	var enemy_scene: PackedScene = enemy_res.scene
	var enemy: Node3D = enemy_scene.instantiate() as Node3D
	enemy.path = path
	enemy.souls = enemy_res.soul_amount
	enemy.position = path.curve.get_point_position(0)
	enemy.tree_exited.connect(func(): _on_enemy_removed())
	enemy_spawn_root.add_child(enemy)

	if not _can_spawn_any_enemy():
		spawn_timer.stop()
		_on_wave_completed()

func _get_wave_enemy_value_budget(wave_index: int) -> float:
	if wave_index < 0:
		return 0.0
	var base_value: float = float(start_enemy_value)
	if base_value <= 0.0:
		base_value = 1.0
	var wave_increase: float = float(wave_index) * enemy_value_increase
	return max(1.0, base_value + wave_increase)

func _get_enemy_value(enemy_res: EnemyResource) -> float:
	if enemy_res == null:
		return 0.0
	return max(enemy_res.enemy_value, 0.01)

func _on_enemy_removed() -> void:
	if not is_wave_active or not is_inside_tree() or _can_spawn_any_enemy():
		return
	
	await get_tree().create_timer(0.5).timeout
	if get_tree().get_node_count_in_group(ENEMY_GROUP) == 0:
		_on_wave_completed()

func _on_wave_completed() -> void:
	is_wave_active = false
	spawn_timer.stop()
	if obstacle_manager:
		obstacle_manager.stop()

	print("Wave %d completed!" % wave)
	if wave >= max_wave:
		all_waves_completed.emit()
	else:
		wave_completed.emit()

func clear() -> void:
	is_wave_active = false
	is_final_wave = false
	remaining_enemy_value_budget = 0.0
	wave = 0
	rest_timer.stop()
	spawn_timer.stop()
	_clear_all_enemies()

func _clear_all_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group(ENEMY_GROUP):
		if is_instance_valid(enemy):
			enemy.queue_free()
