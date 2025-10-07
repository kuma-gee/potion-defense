class_name Stamina
extends Node

@export var max_stamina := 100.0
@export var recovery_rate := 25.0
@export var depletion_rate := 20.0
@export var recovery_start_timer: Timer

@onready var stamina := max_stamina:
	set(v):
		stamina = clamp(v, 0, max_stamina)

var is_recovering := false

func _ready():
	recovery_start_timer.timeout.connect(func(): is_recovering = true)

func _process(delta: float) -> void:
	if Input.is_action_pressed("sprint"):
		stamina -= depletion_rate * delta
		recovery_start_timer.start()
		is_recovering = false
	elif is_recovering:
		stamina += recovery_rate * delta

func has_stamina(amount: float = -1.0) -> bool:
	return stamina >= amount

func use_stamina(amount: float) -> bool:
	if has_stamina(amount):
		stamina -= amount
		recovery_start_timer.start()
		is_recovering = false
		return true

	return false
