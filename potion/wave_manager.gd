class_name WaveManager
extends Node

signal game_over()
signal wave_started()
signal wave_completed()
signal all_waves_completed()

@export var wave_label: Label
@export var wave_resource: Array[WaveResource]
@export var enemy_spawn_root: Node3D

@export var spawn_timer: Timer
@export var rest_timer: Timer

var enemies_spawned_this_wave: int = 0

var is_wave_active: bool = false
var is_final_wave: bool = false

var paths: Array[Path3D]

var max_wave := 0
var wave = 0:
	set(v):
		wave = v
		if wave_resource:
			wave_label.text = "Wave %s / %s" % [wave, max_wave]

func current_wave_resource() -> WaveResource:
	for wr in wave_resource:
		if wave <= wr.until_wave:
			return wr
	return null

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_enemy)
	wave_completed.connect(func(): rest_timer.start())
	rest_timer.timeout.connect(next_wave)
	Events.cauldron_destroyed.connect(func(): game_over.emit())

func setup(map: Map):
	clear()
	
	wave_resource = map.wave_resource
	paths = map.paths
	# wave_resource.sort_custom(func(a, b): return a.until_wave - b.until_wave)
	
	if wave_resource == null or wave_resource.is_empty():
		push_error("WaveManager: No wave_resource found in map")
		return
	
	max_wave = wave_resource[-1].until_wave

func _enemy_spawn_count():
	# dynamically adjust based on players
	# return min(current_wave_resource.min_enemy_count + floor((log(max(wave, 1)) / log(10)) * 10), current_wave_resource.max_enemy_count)
	# TODO
	return current_wave_resource().min_enemy_count

func can_start_wave():
	return not is_wave_active and wave < max_wave

func next_wave() -> void:
	if is_wave_active or not wave_resource or wave_resource.is_empty():
		return
	
	if wave > max_wave:
		push_error("WaveManager: Wave %d exceeds max_wave %d" % [wave, max_wave])
		return
	
	wave += 1
	enemies_spawned_this_wave = 0
	is_wave_active = true
	is_final_wave = false
	
	print("Starting Wave %d with spawn count %d" % [wave, _enemy_spawn_count()])
	wave_started.emit()
	_schedule_next_spawn()

func _schedule_next_spawn() -> void:
	"""Schedule the next enemy spawn with a random interval"""
	if not is_wave_active or not wave_resource:
		return

	var res = current_wave_resource()
	var interval = randf_range(res.spawn_interval_min, res.spawn_interval_max)
	spawn_timer.start(interval)

func _on_spawn_enemy() -> void:
	if not is_wave_active:
		spawn_timer.stop()
		return
	
	_spawn_single_enemy()
	_schedule_next_spawn()

func _spawn_single_enemy() -> void:
	var available_enemies = current_wave_resource().enemies.duplicate()
	if paths.is_empty():
		push_error("WaveManager: No lanes available for spawning")
		return
	
	var left_to_spawn = _enemy_spawn_count() - enemies_spawned_this_wave
	if left_to_spawn <= 0:
		return

	var valid_lanes = paths.duplicate()
	var lane_spawn_count = randi_range(1, min(valid_lanes.size(), left_to_spawn, 1))
	valid_lanes.shuffle()

	for i in range(lane_spawn_count):
		var path = valid_lanes[i] as Path3D
		var enemy_res = _pick_weighted_enemy(available_enemies)
		var enemy = enemy_res.instantiate() as Node3D
		enemy.path = path
		enemy.position = path.curve.get_point_position(0)
		enemy.tree_exited.connect(func(): _on_enemy_removed())
		enemy_spawn_root.add_child(enemy)

	enemies_spawned_this_wave += lane_spawn_count
	print("Spawned enemy (total: %d, Wave %d)" % [enemies_spawned_this_wave, wave])

func _pick_weighted_enemy(enemies: Array[EnemyResource]) -> PackedScene:
	if enemies.is_empty():
		push_error("WaveManager: No enemies available to pick from")
		return null
	
	var total_weight := 0
	for enemy in enemies:
		total_weight += enemy.weight
	
	var random_value := randi_range(1, total_weight)
	var cumulative_weight := 0
	
	for enemy in enemies:
		cumulative_weight += enemy.weight
		if random_value <= cumulative_weight:
			return enemy.scene
	
	return enemies[0].scene

func _on_enemy_removed() -> void:
	if not is_wave_active or not is_inside_tree():
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
	enemies_spawned_this_wave = 0
	wave = 0
	rest_timer.stop()
	spawn_timer.stop()
	_clear_all_enemies()

func _clear_all_enemies() -> void:
	"""Remove all active enemies"""
	for enemy in get_tree().get_nodes_in_group(Enemy.GROUP):
		if is_instance_valid(enemy):
			enemy.queue_free()
