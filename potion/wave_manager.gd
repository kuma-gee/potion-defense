class_name WaveManager
extends Node

signal game_over()
signal wave_started()
signal wave_completed()

@export var enemy_spawn_root: Node3D
@export var wave_label: Label

@export_category("Wave Settings")
@export var base_enemies_per_wave: int = 5
@export var enemies_increment_per_wave: int = 2
@export var base_groups_per_wave: int = 3
@export var groups_increment_per_wave: int = 1
@export var max_groups_per_wave: int = 8
@export var group_spawn_interval_min: float = 5.0
@export var group_spawn_interval_max: float = 15.0
@export var spawn_interval_within_group: float = 0.5
@export var final_wave_group_delay: float = 3.0

@export_category("Enemy Resources")
@export var enemy_resources: Array[EnemyResource] = []
@export var lanes: Array[LaneReceiver] = []
@export var spawn_timer: Timer
@export var group_timer: Timer

var enemies_to_spawn: int = 0
var enemies_spawned_this_wave: int = 0:
	set(v):
		enemies_spawned_this_wave = v
		_update_wave_label()

var enemies_killed_this_wave: int = 0
var current_wave: int = 0:
	set(v):
		current_wave = v
		_update_wave_label()

var active_enemies: Array[Node3D] = []
var is_wave_active: bool = false
var is_spawning_group: bool = false
var groups_to_spawn: int = 0
var groups_spawned: int = 0
var enemies_in_current_group: int = 0
var enemies_spawned_in_group: int = 0
var is_final_group: bool = false
var waiting_for_ready: bool = true

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_enemy)
	group_timer.timeout.connect(_on_spawn_group)
	
	# Connect to enemy spawn root to track enemies
	if enemy_spawn_root:
		enemy_spawn_root.child_entered_tree.connect(_on_enemy_entered_tree)

	for lane in lanes:
		lane.destroyed.connect(func():
			lanes.erase(lane)
			if lanes.is_empty():
				game_over.emit()
		)

func _process(_delta: float) -> void:
	if waiting_for_ready:
		return
	
	_update_wave_label()

func _update_wave_label():
	if waiting_for_ready:
		wave_label.text = "Ready for Wave %s" % (current_wave + 1)
	elif is_wave_active:
		var group_text = "Group %s/%s" % [groups_spawned, groups_to_spawn]
		if is_final_group:
			group_text = "Final Wave!"
		wave_label.text = "Wave %s - %s - %s/%s enemies" % [current_wave, group_text, enemies_spawned_this_wave, enemies_to_spawn]
	else:
		wave_label.text = "Wave %s Complete!" % current_wave

func begin_wave(wave: int) -> void:
	waiting_for_ready = false
	current_wave = wave
	
	# Calculate groups and enemies for this wave
	groups_to_spawn = min(base_groups_per_wave + (current_wave - 1) * groups_increment_per_wave, max_groups_per_wave)
	enemies_to_spawn = base_enemies_per_wave + (current_wave - 1) * enemies_increment_per_wave
	
	enemies_spawned_this_wave = 0
	enemies_killed_this_wave = 0
	groups_spawned = 0
	active_enemies.clear()
	is_wave_active = true
	is_final_group = false
	
	print("Starting Wave %d with %d enemies in %d groups" % [current_wave, enemies_to_spawn, groups_to_spawn])
	wave_started.emit()
	
	# Start spawning first group immediately
	_spawn_next_group()

func stop_wave() -> void:
	is_wave_active = false
	spawn_timer.stop()
	group_timer.stop()
	is_spawning_group = false
	waiting_for_ready = true
	
	_clear_all_enemies()
	print("Wave system stopped")
	
func _spawn_next_group() -> void:
	if groups_spawned >= groups_to_spawn:
		return
	
	groups_spawned += 1
	is_final_group = (groups_spawned == groups_to_spawn)
	
	# Calculate enemies for this group
	var remaining_enemies = enemies_to_spawn - enemies_spawned_this_wave
	var remaining_groups = groups_to_spawn - groups_spawned + 1
	enemies_in_current_group = max(1, int(float(remaining_enemies) / float(remaining_groups)))
	enemies_spawned_in_group = 0
	
	print("Spawning group %d/%d with ~%d enemies (Wave %d)" % [groups_spawned, groups_to_spawn, enemies_in_current_group, current_wave])
	
	# Start spawning enemies in this group
	is_spawning_group = true
	spawn_timer.wait_time = spawn_interval_within_group
	spawn_timer.start()

func _on_spawn_group() -> void:
	if is_wave_active and groups_spawned < groups_to_spawn:
		_spawn_next_group()

func _on_spawn_enemy() -> void:
	if not is_wave_active or not is_spawning_group:
		spawn_timer.stop()
		return
	
	if enemies_spawned_this_wave >= enemies_to_spawn:
		spawn_timer.stop()
		is_spawning_group = false
		return
	
	if not enemy_spawn_root or enemy_resources.is_empty():
		push_error("WaveManager: Missing enemy spawn root or enemy resources")
		return
	
	# Get available enemies for current wave
	var available_enemies: Array[EnemyResource] = []
	for enemy_res in enemy_resources:
		# Check if enemy is available in this wave
		if enemy_res.from_wave <= current_wave and (enemy_res.until_wave == -1 or enemy_res.until_wave >= current_wave):
			available_enemies.append(enemy_res)
	
	if available_enemies.is_empty():
		push_error("WaveManager: No available enemies for wave %d" % current_wave)
		return
	
	# Pick a random available enemy
	var enemy_res = available_enemies.pick_random()
	var enemy_resource = enemy_res.scene
	if not enemy_resource:
		push_error("WaveManager: Invalid enemy scene in resource")
		return
	
	# Spawn the enemy
	var enemy_instance = enemy_resource.instantiate() as Node3D
	if not enemy_instance:
		push_error("WaveManager: Failed to instantiate enemy")
		return
	
	var lane = lanes.pick_random()
	if not lane: return
	
	enemy_instance.position = lane.get_spawn_position()
	enemy_instance.resource = enemy_res

	lane.enemies.append(enemy_instance)
	enemy_spawn_root.add_child(enemy_instance)
	enemies_spawned_this_wave += 1
	enemies_spawned_in_group += 1
	
	print("Spawned enemy %d/%d (Group %d/%d, Wave %d)" % [enemies_spawned_this_wave, enemies_to_spawn, groups_spawned, groups_to_spawn, current_wave])
	
	# Check if current group is complete
	if enemies_spawned_in_group >= enemies_in_current_group or enemies_spawned_this_wave >= enemies_to_spawn:
		spawn_timer.stop()
		is_spawning_group = false
		
		# Schedule next group if not the last one
		if groups_spawned < groups_to_spawn and enemies_spawned_this_wave < enemies_to_spawn:
			var delay = final_wave_group_delay if is_final_group else randf_range(group_spawn_interval_min, group_spawn_interval_max)
			group_timer.wait_time = delay
			group_timer.start()
			print("Next group in %.1fs" % delay)

func _on_enemy_entered_tree(enemy: Node) -> void:
	if enemy is Node3D and is_wave_active:
		active_enemies.append(enemy)
		
		# Connect to enemy death/removal if possible
		if enemy.has_signal("tree_exiting"):
			enemy.tree_exiting.connect(_on_enemy_removed.bind(enemy))
		elif enemy.has_method("queue_free"):
			# Monitor for queue_free calls
			_monitor_enemy_removal(enemy)

func _monitor_enemy_removal(enemy: Node3D) -> void:
	while is_instance_valid(enemy) and enemy.get_parent():
		await get_tree().process_frame
	
	if is_wave_active:
		_on_enemy_removed(enemy)

func _on_enemy_removed(enemy: Node3D) -> void:
	if not is_wave_active:
		return
	
	if enemy in active_enemies:
		active_enemies.erase(enemy)
		enemies_killed_this_wave += 1
		print("Enemy killed: %d/%d for Wave %d" % [enemies_killed_this_wave, enemies_to_spawn, current_wave])
		
		# Check if wave is complete
		if enemies_killed_this_wave >= enemies_to_spawn:
			_on_wave_completed()

func _on_wave_completed() -> void:
	is_wave_active = false
	spawn_timer.stop()
	group_timer.stop()
	is_spawning_group = false
	waiting_for_ready = true
	
	print("Wave %d completed! Killed %d/%d enemies" % [current_wave, enemies_killed_this_wave, enemies_to_spawn])
	wave_completed.emit()
	
	_update_wave_label()

func _clear_all_enemies() -> void:
	"""Remove all active enemies"""
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	active_enemies.clear()
