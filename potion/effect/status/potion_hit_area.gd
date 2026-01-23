class_name PotionHitArea
extends ElementalArea

const PLAYER_LAYER = 1 << 3
const ENEMY_LAYER = 1 << 7

signal finished()

@export var lifetime: float = 0.1
@export var effects: Array[StatusEffect] = []

var lifetime_timer: Timer
var is_finished := false
var tick_timers: Dictionary = {}

func _ready() -> void:
	super()
	collision_mask = LAYER | PLAYER_LAYER | ENEMY_LAYER
	
	for effect in effects:
		tick_timers[effect] = 0.0

	if not lifetime_timer and lifetime > 0:
		lifetime_timer = Timer.new()
		lifetime_timer.wait_time = lifetime
		lifetime_timer.one_shot = true
		add_child(lifetime_timer)

	if lifetime_timer:
		lifetime_timer.timeout.connect(func():
			is_finished = true
			finished.emit()
		)

		start_lifetime()

	area_entered.connect(func(a):
		if a is HurtBox:
			for effect in effects:
				_apply_status_effect_to_target(a, effect)
	)

func _process(delta: float) -> void:
	if is_finished: return

	for effect in effects:
		if effect.tick_interval > 0:
			tick_timers[effect] += delta
			for area in get_overlapping_areas():
				_apply_status_effect_to_target(area, effect)

func _apply_status_effect_to_target(target: Node, effect: StatusEffect) -> void:
	if target == null or not target is HurtBox: return
	target.apply_effect(effect)
	tick_timers[effect] = 0.0

func start_lifetime(time = lifetime) -> void:
	if is_finished: return
	lifetime_timer.start(time)

func is_active():
	return not is_finished

func disable():
	is_finished = true
	
func enable():
	is_finished = false
