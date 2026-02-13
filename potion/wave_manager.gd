class_name WaveManager
extends Node

const ENEMY_GROUP := Enemy.GROUP

signal game_over()
signal wave_started()
signal wave_completed()
signal all_waves_completed()

@export var wave_label: Label
@export var wave_resources: Array[WaveResource] = []
@export var enemy_spawn_root: Node3D

@export var spawn_timer: Timer
@export var rest_timer: Timer

var is_wave_active: bool = false
var is_final_wave: bool = false

var paths: Array[Path3D]

var spawn_plan: Array[Dictionary] = []
var current_spawn_index: int = 0
var current_spawn_interval: float = 0.0

var max_wave: int = 0
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

func setup(map: Map) -> void:
	clear()
	
	wave_resources = map.wave_resources
	paths = map.paths
	
	if wave_resources.is_empty():
		push_error("WaveManager: No wave resources found in map")
		return
	
	max_wave = wave_resources.size()
	wave = 0

func can_start_wave() -> bool:
	return not is_wave_active and wave < max_wave

func next_wave() -> void:
	if is_wave_active:
		return
	
	if wave > max_wave:
		push_error("WaveManager: Wave %d exceeds max_wave %d" % [wave, max_wave])
		return
	
	wave += 1
	current_spawn_index = 0
	is_wave_active = true
	is_final_wave = false
	
	var wave_index: int = _get_wave_index(wave)
	if wave_index < 0:
		is_wave_active = false
		return
	
	current_spawn_interval = _get_spawn_interval(wave_index)
	spawn_plan = _plan_wave_spawns(wave_index)
	
	print("Starting Wave %d - %d spawns planned" % [wave, spawn_plan.size()])
	wave_started.emit()
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
	
	if current_spawn_index >= spawn_plan.size():
		spawn_timer.stop()
		return
	
	_spawn_planned_enemy()
	_schedule_next_spawn()

func _plan_wave_spawns(wave_index: int) -> Array[Dictionary]:
	var plan: Array[Dictionary] = []
	var available_enemies: Array[EnemyResource] = _get_wave_enemies(wave_index)
	var enemy_count: int = _get_wave_enemy_count(wave_index)
	
	if available_enemies.is_empty():
		push_error("WaveManager: No enemies configured for wave %d" % wave)
		return plan
	
	if enemy_count <= 0:
		push_error("WaveManager: Invalid enemy count for wave %d" % wave)
		return plan
	
	if paths.is_empty():
		push_error("WaveManager: No lanes available for spawning")
		return plan
	
	for i in range(enemy_count):
		var enemy_res: EnemyResource = available_enemies[randi() % available_enemies.size()]
		var path: Path3D = paths[randi() % paths.size()]
		plan.append({
			"enemy_resource": enemy_res,
			"path": path,
		})
	
	print("Planned %d spawns for wave %d" % [plan.size(), wave])
	return plan

func _spawn_planned_enemy() -> void:
	if current_spawn_index >= spawn_plan.size():
		return
	
	var spawn_data: Dictionary = spawn_plan[current_spawn_index]
	var enemy_res: EnemyResource = spawn_data["enemy_resource"] as EnemyResource
	var path: Path3D = spawn_data["path"] as Path3D
	
	var enemy_scene: PackedScene = enemy_res.scene
	var enemy: Node3D = enemy_scene.instantiate() as Node3D
	enemy.path = path
	enemy.souls = enemy_res.soul_amount
	enemy.position = path.curve.get_point_position(0)
	enemy.tree_exited.connect(func(): _on_enemy_removed())
	enemy_spawn_root.add_child(enemy)
	
	current_spawn_index += 1
	print("Spawned enemy %d/%d (Wave %d)" % [current_spawn_index, spawn_plan.size(), wave])

func _get_wave_index(wave_index: int) -> int:
	if wave_resources.is_empty():
		push_error("WaveManager: No wave data in map")
		return -1
	
	var index: int = wave_index - 1
	if index < 0 or index >= wave_resources.size():
		push_error("WaveManager: Invalid wave index %d" % wave_index)
		return -1
	
	return index

func _get_wave_enemy_count(wave_index: int) -> int:
	if wave_index < 0 or wave_index >= wave_resources.size():
		return 0
	return wave_resources[wave_index].enemy_count

func _get_wave_enemies(wave_index: int) -> Array[EnemyResource]:
	if wave_index < 0 or wave_index >= wave_resources.size():
		return [] as Array[EnemyResource]
	return wave_resources[wave_index].enemies

func _get_spawn_interval(wave_index: int) -> float:
	if wave_index < 0 or wave_index >= wave_resources.size():
		return 0.0
	var resource: WaveResource = wave_resources[wave_index]
	return resource.base_spawn_interval

func _on_enemy_removed() -> void:
	if not is_wave_active or not is_inside_tree() or current_spawn_index < spawn_plan.size():
		return
	
	await get_tree().create_timer(0.5).timeout
	if get_tree().get_node_count_in_group(ENEMY_GROUP) == 0:
		_on_wave_completed()

func _on_wave_completed() -> void:
	is_wave_active = false
	spawn_timer.stop()

	print("Wave %d completed!" % wave)
	if wave >= max_wave:
		all_waves_completed.emit()
	else:
		wave_completed.emit()

func clear() -> void:
	is_wave_active = false
	is_final_wave = false
	spawn_plan.clear()
	current_spawn_index = 0
	wave = 0
	rest_timer.stop()
	spawn_timer.stop()
	_clear_all_enemies()

func _clear_all_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group(ENEMY_GROUP):
		if is_instance_valid(enemy):
			enemy.queue_free()
