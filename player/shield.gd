class_name Shield
extends Node3D

signal broken()

@export var shield_amount := 30.0
@onready var repair_timer: Timer = $RepairTimer
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@onready var current_shield := shield_amount

var tw: Tween

var is_active := false:
	set(v):
		is_active = v
		if is_active:
			repair_timer.stop()
		else:
			repair_timer.start()

func _ready() -> void:
	repair_timer.timeout.connect(func(): current_shield = shield_amount)

func shield_damage(dmg: float) -> float:
	if not is_active: return dmg
	
	current_shield -= dmg
	if current_shield <= 0.0:
		broken.emit()
		return abs(current_shield)
	
	return 0.0

func deactivate_shield() -> void:
	if not is_active: return
	is_active = false

	if tw and tw.is_running():
		tw.kill()

	tw = create_tween().set_parallel()
	tw.tween_method(set_shield_opacity, _get_shader_value("opacity"), 0.0, 0.3)
	tw.tween_method(set_shield_fade, _get_shader_value("fade_value"), 0.0, 0.3)

func activate_shield() -> void:
	is_active = true

	if tw and tw.is_running():
		tw.kill()

	tw = create_tween().set_parallel()
	tw.tween_method(set_shield_opacity, 0.0, 1.0, 0.3)
	tw.tween_method(set_shield_fade, 0.0, 1.0, 0.3)

func set_shield_opacity(value: float) -> void:
	_set_shader_value("opacity", value)

func set_shield_fade(value: float) -> void:
	_set_shader_value("fade_value", value)

func _set_shader_value(field: String, value) -> void:
	var material = mesh_instance_3d.material_override as ShaderMaterial
	material.set_shader_parameter(field, value)

func _get_shader_value(field: String) -> float:
	var material = mesh_instance_3d.material_override as ShaderMaterial
	return material.get_shader_parameter(field)
