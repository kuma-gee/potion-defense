class_name WaveManager
extends Node

signal wave_started(wave_number: int, enemy_count: int)
signal wave_completed(wave_number: int, enemies_killed: int)
signal enemy_spawned(enemy: Node3D, wave_number: int)
signal enemy_killed(enemy: Node3D, wave_number: int)
signal all_waves_completed()

@export var spawn_manager: SpawnManager
@export var enemy_spawn_root: Node3D

@export_category("Wave Settings")
@export var base_enemies_per_wave: int = 5
@export var enemies_increment_per_wave: int = 2
@export var wave_break_duration: float = 3.0
@export var spawn_interval: float = 1.0

@export_category("Enemy Resources")
@export var wave_enemy_resources: Array[ObstacleResource] = []

@export var wave_timer: Timer
@export var spawn_timer: Timer

var current_wave: int = 0
var enemies_to_spawn: int = 0
var enemies_spawned_this_wave: int = 0
var enemies_killed_this_wave: int = 0
var active_enemies: Array[Node3D] = []
var is_wave_active: bool = false

func _ready() -> void:
	wave_timer.timeout.connect(_on_wave_break_finished)
	spawn_timer.timeout.connect(_on_spawn_enemy)
	
	# Connect to enemy spawn root to track enemies
	if enemy_spawn_root:
		enemy_spawn_root.child_entered_tree.connect(_on_enemy_entered_tree)

func start_wave_system(starting_wave: int = 1) -> void:
	"""Start the wave system from a specific wave number"""
	current_wave = starting_wave - 1
	_start_next_wave()

func stop_wave_system() -> void:
	"""Stop all wave activity and clear enemies"""
	is_wave_active = false
	wave_timer.stop()
	spawn_timer.stop()
	
	# Clear all active enemies
	_clear_all_enemies()
	
	print("Wave system stopped")

func force_complete_current_wave() -> void:
	"""Force complete the current wave (useful for testing or special conditions)"""
	if is_wave_active:
		_clear_all_enemies()
		_on_wave_completed()

func get_current_wave_info() -> Dictionary:
	"""Get information about the current wave"""
	return {
		"wave_number": current_wave,
		"enemies_to_spawn": enemies_to_spawn,
		"enemies_spawned": enemies_spawned_this_wave,
		"enemies_killed": enemies_killed_this_wave,
		"active_enemies_count": active_enemies.size(),
		"is_active": is_wave_active
	}

func _start_next_wave() -> void:
	"""Start the next wave"""
	current_wave += 1
	
	# Calculate enemies for this wave
	enemies_to_spawn = base_enemies_per_wave + (current_wave - 1) * enemies_increment_per_wave
	enemies_spawned_this_wave = 0
	enemies_killed_this_wave = 0
	active_enemies.clear()
	is_wave_active = true
	
	print("Starting Wave %d with %d enemies" % [current_wave, enemies_to_spawn])
	wave_started.emit(current_wave, enemies_to_spawn)
	
	# Start spawning enemies
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()

func _on_spawn_enemy() -> void:
	"""Spawn a single enemy during the wave"""
	if not is_wave_active or enemies_spawned_this_wave >= enemies_to_spawn:
		spawn_timer.stop()
		return
	
	if not enemy_spawn_root or wave_enemy_resources.is_empty():
		push_error("WaveManager: Missing enemy spawn root or enemy resources")
		return
	
	# Pick a random enemy resource
	var enemy_resource = wave_enemy_resources.pick_random() as ObstacleResource
	if not enemy_resource or not enemy_resource.scene:
		push_error("WaveManager: Invalid enemy resource")
		return
	
	# Spawn the enemy
	var enemy_instance = enemy_resource.scene.instantiate() as Node3D
	if not enemy_instance:
		push_error("WaveManager: Failed to instantiate enemy")
		return
	
	# Position enemy randomly around spawn area
	var spawn_angle = randf() * TAU
	var spawn_distance = randf_range(5.0, 15.0)
	var spawn_position = Vector3(
		cos(spawn_angle) * spawn_distance,
		0,
		sin(spawn_angle) * spawn_distance
	)
	enemy_instance.global_position = spawn_position
	
	# Add enemy to scene
	enemy_spawn_root.add_child(enemy_instance)
	enemies_spawned_this_wave += 1
	
	print("Spawned enemy %d/%d for Wave %d" % [enemies_spawned_this_wave, enemies_to_spawn, current_wave])
	enemy_spawned.emit(enemy_instance, current_wave)

func _on_enemy_entered_tree(enemy: Node) -> void:
	"""Track when enemies are added to the scene"""
	if enemy is Node3D and is_wave_active:
		active_enemies.append(enemy)
		
		# Connect to enemy death/removal if possible
		if enemy.has_signal("tree_exiting"):
			enemy.tree_exiting.connect(_on_enemy_removed.bind(enemy))
		elif enemy.has_method("queue_free"):
			# Monitor for queue_free calls
			_monitor_enemy_removal(enemy)

func _monitor_enemy_removal(enemy: Node3D) -> void:
	"""Monitor an enemy for removal (since not all enemies may have death signals)"""
	while is_instance_valid(enemy) and enemy.get_parent():
		await get_tree().process_frame
	
	if is_wave_active:
		_on_enemy_removed(enemy)

func _on_enemy_removed(enemy: Node3D) -> void:
	"""Handle when an enemy is removed/killed"""
	if not is_wave_active:
		return
	
	if enemy in active_enemies:
		active_enemies.erase(enemy)
		enemies_killed_this_wave += 1
		
		print("Enemy killed: %d/%d for Wave %d" % [enemies_killed_this_wave, enemies_to_spawn, current_wave])
		enemy_killed.emit(enemy, current_wave)
		
		# Check if wave is complete
		if enemies_killed_this_wave >= enemies_to_spawn:
			_on_wave_completed()

func _on_wave_completed() -> void:
	"""Handle wave completion"""
	is_wave_active = false
	spawn_timer.stop()
	
	print("Wave %d completed! Killed %d/%d enemies" % [current_wave, enemies_killed_this_wave, enemies_to_spawn])
	wave_completed.emit(current_wave, enemies_killed_this_wave)
	
	# Check if we should continue with more waves
	if _should_continue_waves():
		print("Starting wave break for %s seconds..." % wave_break_duration)
		wave_timer.wait_time = wave_break_duration
		wave_timer.start()
	else:
		print("All waves completed!")
		all_waves_completed.emit()

func _should_continue_waves() -> bool:
	"""Determine if more waves should continue (override this for custom logic)"""
	# By default, continue indefinitely
	# You can override this to add maximum wave limits or other conditions
	return true

func _on_wave_break_finished() -> void:
	"""Handle when the break between waves is finished"""
	_start_next_wave()

func _clear_all_enemies() -> void:
	"""Remove all active enemies"""
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	active_enemies.clear()

# Public helper methods for external systems

func get_active_enemy_count() -> int:
	"""Get the number of currently active enemies"""
	return active_enemies.size()

func get_enemies_remaining_to_spawn() -> int:
	"""Get how many enemies are left to spawn in current wave"""
	return max(0, enemies_to_spawn - enemies_spawned_this_wave)

func get_enemies_remaining_to_kill() -> int:
	"""Get how many enemies are left to kill in current wave"""
	return max(0, enemies_to_spawn - enemies_killed_this_wave)

func is_wave_in_progress() -> bool:
	"""Check if a wave is currently active"""
	return is_wave_active