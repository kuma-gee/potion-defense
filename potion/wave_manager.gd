class_name WaveManager
extends Node

signal wave_started()
signal wave_completed()

@export var enemy_spawn_root: Node3D
@export var wave_label: Label

@export_category("Wave Settings")
@export var base_enemies_per_wave: int = 5
@export var enemies_increment_per_wave: int = 2
@export var wave_break_duration: float = 3.0
@export var spawn_interval: float = 1.0

@export_category("Enemy Resources")
@export var wave_enemy_resources: Array[PackedScene] = []
@export var lanes: Array[LaneReceiver] = []
@export var spawn_timer: Timer
@export var wave_break_timer: Timer

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

func _ready() -> void:
	wave_break_timer.timeout.connect(func(): start_wave())
	spawn_timer.timeout.connect(_on_spawn_enemy)
	
	# Connect to enemy spawn root to track enemies
	if enemy_spawn_root:
		enemy_spawn_root.child_entered_tree.connect(_on_enemy_entered_tree)

	for lane in lanes:
		lane.destroyed.connect(func(): lanes.erase(lane))

func _process(_delta: float) -> void:
	if wave_break_timer.is_stopped(): return
	wave_label.text = "%.2fs" % wave_break_timer.time_left

func _update_wave_label():
	if wave_break_timer.is_stopped():
		wave_label.text = "Wave %s - %s / %s" % [current_wave, enemies_spawned_this_wave, enemies_to_spawn]

func start_wave() -> void:
	# Calculate enemies for this wave
	enemies_to_spawn = base_enemies_per_wave + (current_wave - 1) * enemies_increment_per_wave
	enemies_spawned_this_wave = 0
	enemies_killed_this_wave = 0
	active_enemies.clear()
	is_wave_active = true
	current_wave += 1
	
	print("Starting Wave %d with %d enemies" % [current_wave, enemies_to_spawn])
	wave_started.emit(current_wave, enemies_to_spawn)
	
	# Start spawning enemies
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()

func stop_wave() -> void:
	is_wave_active = false
	spawn_timer.stop()
	
	_clear_all_enemies()
	print("Wave system stopped")

func _on_spawn_enemy() -> void:
	if not is_wave_active or enemies_spawned_this_wave >= enemies_to_spawn:
		spawn_timer.stop()
		return
	
	if not enemy_spawn_root or wave_enemy_resources.is_empty():
		push_error("WaveManager: Missing enemy spawn root or enemy resources")
		return
	
	# Pick a random enemy resource
	var enemy_resource = wave_enemy_resources.pick_random() as PackedScene
	if not enemy_resource:
		push_error("WaveManager: Invalid enemy resource")
		return
	
	# Spawn the enemy
	var enemy_instance = enemy_resource.instantiate() as Node3D
	if not enemy_instance:
		push_error("WaveManager: Failed to instantiate enemy")
		return
	
	var lane = lanes.pick_random()
	if not lane: return
	
	enemy_instance.position = lane.get_spawn_position()
	lane.enemies.append(enemy_instance)
	enemy_spawn_root.add_child(enemy_instance)
	enemies_spawned_this_wave += 1
	print("Spawned enemy %d/%d for Wave %d" % [enemies_spawned_this_wave, enemies_to_spawn, current_wave])

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
	
	print("Wave %d completed! Killed %d/%d enemies" % [current_wave, enemies_killed_this_wave, enemies_to_spawn])
	wave_completed.emit(current_wave, enemies_killed_this_wave)
	wave_break_timer.start()

func _clear_all_enemies() -> void:
	"""Remove all active enemies"""
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	active_enemies.clear()
