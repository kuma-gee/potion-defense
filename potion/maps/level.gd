class_name Level
extends Area3D

@export var map: PackedScene
@export var continue_timer := 3.0

var time := 0.0:
	set(v):
		time = clamp(v, 0, continue_timer)

func _ready() -> void:
	visibility_changed.connect(func(): monitoring = visible)

func _process(delta: float) -> void:
	if not map: return
	
	if _all_players_inside():
		time += delta

		if time >= continue_timer:
			Events.start_level(map)
	elif time > 0.0:
		time -= delta

func _all_players_inside() -> bool:
	if not monitoring: return false
	return Events.get_player_count() > 0 and get_overlapping_bodies().size() >= Events.get_player_count()
