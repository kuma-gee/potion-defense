class_name MoveNext
extends Area3D

signal next()

@export var continue_timer := 0.5
@export var mesh_instance_3d: MeshInstance3D

var started := false
var time := 0.0:
	set(v):
		time = clamp(v, 0, continue_timer)
		set_fill(time / continue_timer)

func _ready() -> void:
	time = 0.0
	collision_mask = 1 << 1
	collision_layer = 0
	visibility_changed.connect(func(): monitoring = visible)

func _process(delta: float) -> void:
	if not monitoring or started: return

	if _all_players_inside():
		time += delta

		if time >= continue_timer:
			started = true
			time = 0
			next.emit()

	elif time > 0.0:
		time -= delta

func _all_players_inside() -> bool:
	if not monitoring: return false
	return Events.get_player_count() > 0 and get_overlapping_bodies().size() >= Events.get_player_count()

func set_fill(v: float):
	var shader = mesh_instance_3d.material_override as ShaderMaterial
	shader.set_shader_parameter("fill_amount", v)
