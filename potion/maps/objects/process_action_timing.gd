class_name ProcessActionTiming
extends ProcessAction

@export var cursor_bar: ColorRect
@export var full_bar: ColorRect
@export var hit_bar: ColorRect
@export var hit_sound: AudioStreamPlayer

@export var start_rotation := -180
@export var end_rotation := 0

@export var required_hits: int = 3
@export var max_misses: int = 3

@export var min_speed := 1.0
@export var max_speed := 2.0
@export var min_line_width := 0.01
@export var max_line_width := 0.05

var cursor_speed := 0.0
var hits: int = 0
var misses: int = 0
var direction: float = 1.0

var line_tolerance: float = 0.05:
	set(v):
		line_tolerance = v
		var mat = hit_bar.material as ShaderMaterial
		mat.set_shader_parameter("fill", line_tolerance) # don't make x2 here because the fill value is only 0.5

var hit_position: float = 1.0:
	set(v):
		hit_position = v
		hit_bar.rotation_degrees = remap(v, 0, 1, start_rotation, end_rotation)

var cursor: float = 0.0:
	set(v):
		cursor = v
		cursor_bar.rotation_degrees = remap(v, 0, 1, start_rotation, end_rotation)

func _ready() -> void:
	hide_visuals()

func on_item_changed(_item: ItemResource):
	hits = 0
	misses = 0
	cursor = 0.0
	direction = 1.0
	hide_visuals()

func _reset_state() -> void:
	_new_hit_position()

func hide_visuals():
	hit_bar.hide()
	cursor_bar.hide()

func _new_hit_position():
	hit_position = randf_range(0 + line_tolerance, 1)
	
	var part_size = (max_line_width - min_line_width) / float(required_hits - 1)
	line_tolerance = max_line_width - part_size * hits
	cursor_speed = remap(line_tolerance, max_line_width, min_line_width, min_speed, max_speed)
	hit_bar.show()
	cursor_bar.show()

func _on_cancelled() -> void:
	hide_visuals()

func _on_update(delta: float) -> void:
	cursor += direction * cursor_speed * delta
	if cursor >= 1.0:
		cursor = 1.0
		direction = -1.0
	elif cursor <= 0.0:
		cursor = 0.0
		direction = 1.0

func _on_action_pressed() -> void:
	var s = hit_position - line_tolerance * 2.0
	var end = hit_position
	
	if cursor >= s and cursor <= end:
		hit_sound.start()

		hits += 1
		if hits >= required_hits:
			complete()
		else:
			_new_hit_position()
		return

	_new_hit_position()
