class_name WaveManager
extends Node

signal game_over()
signal wave_started()
signal wave_completed()

@export var enemy_spawn_root: Node3D
#@export var wave_label: Label

@export_category("Wave Settings")
@export var spawn_enemy_count: int = 4
@export var spawn_interval_min: float = 2.0
@export var spawn_interval_max: float = 4.0

#@export_category("Final Wave Settings")
#@export var final_wave_from_wave: int = 3
#@export var final_wave_spawn_delay := 2.0
#@export var final_wave_enemy_count: int = 10
#@export var final_wave_spawn_interval: float = 0.5

@export_category("Enemy Resources")
@export var enemy_resources: Array[EnemyResource] = []
@export var spawn_timer: Timer
@export var wave_timer: Timer

var lane_root: Node3D
var enemies_spawned_this_wave: int = 0:
	set(v):
		enemies_spawned_this_wave = v
		_update_wave_label()

var current_wave: int = 0:
	set(v):
		current_wave = v
		_update_wave_label()

var is_wave_active: bool = false
var is_final_wave: bool = false
var waiting_for_ready: bool = true

var cauldrons := []

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_enemy)
	wave_timer.timeout.connect(_on_wave_time_expired)
	
	# Connect to enemy spawn root to track enemies
	if enemy_spawn_root:
		enemy_spawn_root.child_entered_tree.connect(_on_enemy_entered_tree)

func setup(node: Node3D):
	lane_root = node
	cauldrons = get_tree().get_nodes_in_group("cauldron")
	for c in cauldrons:
		c.died.connect(func():
			cauldrons.erase(c)
			if cauldrons.is_empty():
				game_over.emit()
		)
	#lane_root = node
	#if lane_root:
		#for lane in lane_root.get_children():
			#lane.destroyed.connect(func():
				#game_over.emit()
			#)

func _enemy_spawn_count():
	return spawn_enemy_count + floor((log(current_wave + 1) / log(10)) * 10)

func _process(_delta: float) -> void:
	if waiting_for_ready or not is_wave_active:
		return
	
	_update_wave_label()

func _update_wave_label():
	pass
	#if waiting_for_ready:
		#wave_label.text = "Ready for Wave %s" % (current_wave + 1)
	#elif is_wave_active:
		#if is_final_wave:
			#wave_label.text = "FINAL WAVE! - %s enemies remaining" % final_wave_enemy_count
		#else:
			#wave_label.text = "Wave %d - %s enemies remaining" % [current_wave, _enemy_spawn_count() - enemies_spawned_this_wave]
	#else:
		#wave_label.text = "Wave %s Complete!" % current_wave

func begin_wave(wave: int) -> void:
	waiting_for_ready = false
	current_wave = wave
	
	enemies_spawned_this_wave = 0
	is_wave_active = true
	is_final_wave = false
	
	print("Starting Wave %d with spawn count %d" % [current_wave, _enemy_spawn_count()])
	wave_started.emit()
	
	# Start spawning enemies with random intervals
	_schedule_next_spawn()

func stop_wave() -> void:
	is_wave_active = false
	spawn_timer.stop()
	wave_timer.stop()
	waiting_for_ready = true
	
	_clear_all_enemies()
	print("Wave system stopped")

func _schedule_next_spawn() -> void:
	"""Schedule the next enemy spawn with a random interval"""
	if not is_wave_active:
		return
	
	var interval = randf_range(spawn_interval_min, spawn_interval_max)
	spawn_timer.start(interval)

func _on_wave_time_expired() -> void:
	"""Called when the wave timer expires - spawn final wave"""
	if not is_wave_active:
		return
	
	spawn_timer.stop()
	#print("Wave %d time expired! Starting final wave with %d enemies" % [current_wave, final_wave_enemy_count])

	#if true or current_wave < final_wave_from_wave:
		#print("Final wave not triggered until wave %d" % final_wave_from_wave)
		#return
#
	#is_final_wave = true
	#await get_tree().create_timer(final_wave_spawn_delay).timeout
	#
	#for i in range(final_wave_enemy_count):
		#spawn_timer.start(final_wave_spawn_interval)
		#await spawn_timer.timeout
		#_spawn_single_enemy()

func _on_spawn_enemy() -> void:
	if not is_wave_active:
		spawn_timer.stop()
		return
	
	_spawn_single_enemy()
	
	# Schedule next spawn if wave is still active
	if is_wave_active and not is_final_wave:
		_schedule_next_spawn()

func _spawn_single_enemy() -> void:
	"""Spawn a single random enemy"""
	if not enemy_spawn_root or enemy_resources.is_empty():
		push_error("WaveManager: Missing enemy spawn root or enemy resources")
		return
	
	# Get available enemies for current wave
	var available_enemies: Array[EnemyResource] = []
	for enemy_res in enemy_resources:
		if enemy_res.from_wave <= current_wave and (enemy_res.until_wave == -1 or enemy_res.until_wave >= current_wave):
			available_enemies.append(enemy_res)
	
	if available_enemies.is_empty():
		push_error("WaveManager: No available enemies for wave %d" % current_wave)
		return
	
	print("Availabe enemies %s" % available_enemies.size())
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
		
		#lane.enemies.append(enemy_instance)
		enemy_spawn_root.add_child(enemy_instance)
		enemy_instance.set_target(targets.pick_random().global_position)

	enemies_spawned_this_wave += lane_spawn_count
	
	print("Spawned enemy (total: %d, Wave %d)" % [enemies_spawned_this_wave, current_wave])

func _on_enemy_entered_tree(enemy: Node) -> void:
	if enemy is Node3D and is_wave_active:
		if enemy.has_signal("tree_exited"):
			enemy.tree_exited.connect(func(): _on_enemy_removed())

func _on_enemy_removed() -> void:
	if not is_wave_active:
		return
	
	if is_inside_tree():
		await get_tree().create_timer(0.5).timeout
		
		if get_tree().get_node_count_in_group(Enemy.GROUP) == 0:
			_on_wave_completed()

func _on_wave_completed() -> void:
	is_wave_active = false
	spawn_timer.stop()
	wave_timer.stop()
	waiting_for_ready = true
	
	print("Wave %d completed!" % current_wave)
	wave_completed.emit()
	
	_update_wave_label()

func _clear_all_enemies() -> void:
	"""Remove all active enemies"""
	for enemy in get_tree().get_nodes_in_group(Enemy.GROUP):
		if is_instance_valid(enemy):
			enemy.queue_free()
