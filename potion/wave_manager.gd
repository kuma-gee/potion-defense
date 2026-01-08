class_name WaveManager
extends Node

signal game_over()
signal wave_started()
signal wave_completed()
signal all_waves_completed()

@export var wave_label: Label
@export var wave_resource: WaveResource
@export var enemy_spawn_root: Node3D

@export var spawn_timer: Timer
@export var rest_timer: Timer

var is_wave_active: bool = false
var is_final_wave: bool = false

var paths: Array[Path3D]

var spawn_plan: Array[Dictionary] = []
var current_spawn_index: int = 0
var difficulty := 1.0

var max_wave := 0
var wave = 0:
	set(v):
		wave = v
		if wave_resource:
			wave_label.text = "Wave %s / %s" % [wave, max_wave]

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_enemy)
	wave_completed.connect(func(): rest_timer.start())
	rest_timer.timeout.connect(next_wave)
	Events.cauldron_destroyed.connect(func(): game_over.emit())

func setup(map: Map):
	clear()
	
	wave_resource = map.wave_resource
	paths = map.paths
	
	if wave_resource == null:
		push_error("WaveManager: No wave_resource found in map")
		return
	
	max_wave = wave_resource.max_waves
	difficulty = wave_resource.initial_difficulty
	wave = 0

func _calculate_wave_budget() -> float:
	return wave_resource.base_enemy_value * difficulty

func can_start_wave():
	return not is_wave_active and wave < max_wave

func next_wave() -> void:
	if is_wave_active or not wave_resource:
		return
	
	if wave > max_wave:
		push_error("WaveManager: Wave %d exceeds max_wave %d" % [wave, max_wave])
		return
	
	wave += 1
	current_spawn_index = 0
	is_wave_active = true
	is_final_wave = false
	
	difficulty = wave_resource.initial_difficulty * (1.0 + (wave - 1) * 0.3)
	
	var wave_budget = _calculate_wave_budget()
	spawn_plan = _plan_wave_spawns(wave_budget)
	
	print("Starting Wave %d with budget %.1f (difficulty: %.2f) - %d spawns planned" % [wave, wave_budget, difficulty, spawn_plan.size()])
	wave_started.emit()
	_schedule_next_spawn()

func _schedule_next_spawn() -> void:
	if not is_wave_active or not wave_resource:
		return

	var difficulty_speed_multiplier = 1.0 / (1.0 + (difficulty - 1.0) * 0.1)
	var interval = wave_resource.base_spawn_interval * difficulty_speed_multiplier
	interval = max(interval, 0.5)
	spawn_timer.start(interval)
	print("Next spawn in %s" % interval)

func _on_spawn_enemy() -> void:
	if not is_wave_active:
		spawn_timer.stop()
		return
	
	if current_spawn_index >= spawn_plan.size():
		spawn_timer.stop()
		return
	
	_spawn_planned_enemy()
	_schedule_next_spawn()

func _plan_wave_spawns(wave_budget: float) -> Array[Dictionary]:
	var plan: Array[Dictionary] = []
	var used_budget: float = 0.0
	var available_enemies = wave_resource.enemies.duplicate()
	
	if paths.is_empty():
		push_error("WaveManager: No lanes available for spawning")
		return plan
	
	while used_budget < wave_budget:
		var remaining_budget = wave_budget - used_budget
		var affordable_enemies = _get_affordable_enemies(available_enemies, remaining_budget)
		
		if affordable_enemies.is_empty():
			break
		
		var enemy_res = _pick_weighted_enemy(affordable_enemies, remaining_budget, wave_budget)
		var path = paths[randi() % paths.size()]
		
		plan.append({
			"enemy_resource": enemy_res,
			"path": path,
		})
		
		used_budget += enemy_res.enemy_value
	
	print("Planned %d spawns for wave %d (budget: %.1f/%.1f)" % [plan.size(), wave, used_budget, wave_budget])
	return plan

func _spawn_planned_enemy() -> void:
	if current_spawn_index >= spawn_plan.size():
		return
	
	var spawn_data = spawn_plan[current_spawn_index]
	var enemy_res = spawn_data["enemy_resource"] as EnemyResource
	var path = spawn_data["path"] as Path3D
	
	var enemy_scene = enemy_res.scene
	var enemy = enemy_scene.instantiate() as Node3D
	enemy.path = path
	enemy.position = path.curve.get_point_position(0)
	enemy.tree_exited.connect(func(): _on_enemy_removed())
	enemy_spawn_root.add_child(enemy)
	
	current_spawn_index += 1
	print("Spawned enemy %d/%d with value %d (Wave %d)" % [current_spawn_index, spawn_plan.size(), enemy_res.enemy_value, wave])

func _get_affordable_enemies(enemies: Array[EnemyResource], budget: float) -> Array[EnemyResource]:
	var affordable: Array[EnemyResource] = []
	for enemy in enemies:
		if enemy.enemy_value <= budget:
			affordable.append(enemy)
	return affordable

func _pick_weighted_enemy(enemies: Array[EnemyResource], remaining_budget: float, wave_budget: float) -> EnemyResource:
	if enemies.is_empty():
		push_error("WaveManager: No enemies available to pick from")
		return null
	
	var budget_ratio = remaining_budget / wave_budget
	var weighted_enemies: Array[EnemyResource] = []
	
	for enemy in enemies:
		var base_weight: float
		if budget_ratio > 0.5:
			base_weight = 1.0 / max(enemy.enemy_value, 1.0)
		else:
			base_weight = float(enemy.enemy_value)
		
		var weight_count = max(1, int(base_weight * 10))
		for i in range(weight_count):
			weighted_enemies.append(enemy)
	
	if weighted_enemies.is_empty():
		return enemies[0]
	
	return weighted_enemies[randi() % weighted_enemies.size()]

func _on_enemy_removed() -> void:
	if not is_wave_active or not is_inside_tree() or current_spawn_index < spawn_plan.size():
		return
	
	await get_tree().create_timer(0.5).timeout
	if get_tree().get_node_count_in_group(Enemy.GROUP) == 0:
		_on_wave_completed()

func _on_wave_completed() -> void:
	is_wave_active = false
	spawn_timer.stop()

	print("Wave %d completed!" % wave)
	if wave >= max_wave:
		all_waves_completed.emit()
	else:
		wave_completed.emit()

func clear():
	is_wave_active = false
	is_final_wave = false
	spawn_plan.clear()
	current_spawn_index = 0
	wave = 0
	rest_timer.stop()
	spawn_timer.stop()
	_clear_all_enemies()

func _clear_all_enemies() -> void:
	"""Remove all active enemies"""
	for enemy in get_tree().get_nodes_in_group(Enemy.GROUP):
		if is_instance_valid(enemy):
			enemy.queue_free()
