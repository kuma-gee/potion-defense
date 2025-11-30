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

var lane_root: Node3D
var enemies_spawned_this_wave: int = 0

var is_wave_active: bool = false
var is_final_wave: bool = false

var cauldrons := []

var wave = 0:
	set(v):
		wave = v
		if wave_resource:
			wave_label.text = "Wave %s / %s" % [wave, wave_resource.max_wave]

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_enemy)
	wave_completed.connect(func(): rest_timer.start())
	rest_timer.timeout.connect(next_wave)

func setup(map: Map):
	clear()
	
	lane_root = map.lanes
	wave_resource = map.wave_resource
	
	if wave_resource == null:
		push_error("WaveManager: No wave_resource found in map")
		return

	cauldrons = map.cauldrons.duplicate()
	for c in cauldrons:
		c.died.connect(func():
			cauldrons.erase(c)
			if cauldrons.is_empty():
				game_over.emit()
		)
	
	next_wave()

func _enemy_spawn_count():
	# dynamically adjust based on players
	return min(wave_resource.min_enemy_count + floor((log(max(wave, 1)) / log(10)) * 10), wave_resource.max_enemy_count)

func next_wave() -> void:
	if is_wave_active:
		return
	
	if wave > wave_resource.max_wave:
		push_error("WaveManager: Wave %d exceeds max_wave %d" % [wave, wave_resource.max_wave])
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
	
	var interval = randf_range(wave_resource.spawn_interval_min, wave_resource.spawn_interval_max)
	spawn_timer.start(interval)

func _on_spawn_enemy() -> void:
	if not is_wave_active:
		spawn_timer.stop()
		return
	
	_spawn_single_enemy()
	_schedule_next_spawn()

func _spawn_single_enemy() -> void:
	if not enemy_spawn_root or wave_resource.enemy_resources.is_empty():
		push_error("WaveManager: Missing enemy spawn root or enemy resources")
		return
	
	var available_enemies = wave_resource.enemy_resources.duplicate()
	var valid_lanes =  lane_root.get_children()
	if valid_lanes.is_empty():
		push_error("WaveManager: No lanes available for spawning")
		return
	
	var left_to_spawn = _enemy_spawn_count() - enemies_spawned_this_wave
	if left_to_spawn <= 0:
		return

	var targets = cauldrons.filter(func(c): return is_instance_valid(c) and not c.destroyed)
	var lane_spawn_count = randi_range(1, min(valid_lanes.size(), left_to_spawn, 1))
	valid_lanes.shuffle()
	for i in range(lane_spawn_count):
		var lane = valid_lanes[i]
		var enemy_res = available_enemies.pick_random()
		var enemy_resource = enemy_res.scene
		var enemy_instance = enemy_resource.instantiate() as Node3D
		enemy_instance.position = lane.global_position
		enemy_instance.resource = enemy_res
		enemy_instance.tree_exited.connect(func(): _on_enemy_removed())
		
		enemy_spawn_root.add_child(enemy_instance)

		var closest_target = null
		var closest_distance = INF
		for t in targets:
			var dist = enemy_instance.global_position.distance_to(t.global_position)
			if dist < closest_distance:
				closest_distance = dist
				closest_target = t
		
		if closest_target:
			enemy_instance.set_target(closest_target.global_position)

	enemies_spawned_this_wave += lane_spawn_count
	print("Spawned enemy (total: %d, Wave %d)" % [enemies_spawned_this_wave, wave])

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
	if wave >= wave_resource.max_wave:
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
