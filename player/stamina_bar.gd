extends ProgressBar

@export var stamina: Stamina

func _ready() -> void:
	max_value = stamina.max_stamina
	value = stamina.stamina

func _process(_delta: float) -> void:
	value = stamina.stamina
