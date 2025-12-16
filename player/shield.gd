class_name Shield
extends Node3D

signal broken()

@export var shield_fill: Control
@export var shield_amount := 20.0
@export var restore_amount := 0.5

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var restore_delay: Timer = $RestoreDelay
@onready var current_shield := shield_amount:
	set(v):
		current_shield = clamp(v, 0, shield_amount)
		set_fill(current_shield / shield_amount)

var tw: Tween

var destroyed := false
var restore := false
var is_active := false:
	set(v):
		is_active = v
		restore = false
		
		if is_active:
			restore_delay.stop()
		elif not destroyed:
			restore_delay.start()

func _ready() -> void:
	current_shield = shield_amount
	restore_delay.timeout.connect(func(): restore = true)
	visibility_changed.connect(func(): shield_fill.visible = visible)

func _process(delta: float) -> void:
	if not destroyed and restore and current_shield < shield_amount:
		current_shield += restore_amount * delta

func restore_shield():
	destroyed = false
	current_shield = shield_amount

func set_fill(v: float):
	var mat = shield_fill.material as ShaderMaterial
	mat.set_shader_parameter("fill", v)

func shield_damage(dmg: float) -> float:
	if not is_active: return dmg
	
	current_shield -= dmg
	if current_shield <= 0.0:
		broken.emit()
		destroyed = true
		return abs(current_shield)
	
	return 0.0

func deactivate_shield() -> void:
	if not is_active or destroyed: return
	is_active = false

	if tw and tw.is_running():
		tw.kill()

	tw = create_tween().set_parallel()
	tw.tween_method(set_shield_opacity, _get_shader_value("opacity"), 0.0, 0.3)
	tw.tween_method(set_shield_fade, _get_shader_value("fade_value"), 0.0, 0.3)

func activate_shield() -> void:
	if destroyed: return
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
