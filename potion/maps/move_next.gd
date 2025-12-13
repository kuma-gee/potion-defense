class_name MoveNext
extends Area3D

signal next()

@export var continue_timer := 3.0
@onready var csg_box_3d: CSGBox3D = $CSGBox3D

var time := 0.0:
	set(v):
		time = clamp(v, 0, continue_timer)

func _ready() -> void:
	csg_box_3d.hide()
	collision_mask = 1 << 1
	collision_layer = 0
	visibility_changed.connect(func(): monitoring = visible)

func _process(delta: float) -> void:
	if not monitoring: return

	if _all_players_inside():
		time += delta

		if time >= continue_timer:
			time = 0
			next.emit()

	elif time > 0.0:
		time -= delta

func _all_players_inside() -> bool:
	if not monitoring: return false
	return Events.get_player_count() > 0 and get_overlapping_bodies().size() >= Events.get_player_count()
