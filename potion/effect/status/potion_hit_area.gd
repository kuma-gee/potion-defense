class_name PotionHitArea
extends Area3D

signal finished()

@export var lifetime: float = 0.1
@export var effect: StatusEffect
@export var tick_interval: float = 0.0
@export var lifetime_timer: Timer

var is_finished := false
var tick_timer: float = 0.0

func _ready() -> void:
	area_entered.connect(func(a): _apply_status_effect_to_target(a))

	if not lifetime_timer:
		lifetime_timer = Timer.new()
		lifetime_timer.wait_time = lifetime
		lifetime_timer.one_shot = true
		add_child(lifetime_timer)

	lifetime_timer.timeout.connect(func():
		is_finished = true
		finished.emit()
	)

	start_lifetime()

func _process(delta: float) -> void:
	if tick_interval > 0 and not is_finished:
		tick_timer += delta
		if tick_timer >= tick_interval:
			tick_timer -= tick_interval

			for area in get_overlapping_areas():
				_apply_status_effect_to_target(area)

func _apply_status_effect_to_target(target: HurtBox) -> void:
	if not target or not target.status_manager or not effect:
		return

	target.status_manager.apply_effect(effect)

func start_lifetime(time = lifetime) -> void:
	if is_finished: return
	lifetime_timer.start(time)
