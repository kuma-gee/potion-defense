class_name GolemArea
extends Golem

@onready var status_area: PotionHitArea = $StatusArea
@onready var disable_timer: Timer = $DisableTimer

func _ready() -> void:
	disable_timer.timeout.connect(func(): status_area.is_finished = true)

func get_consumption(delta: float):
	return golem.consumption * delta

func process(_delta: float) -> void:
	status_area.is_finished = false
	disable_timer.start()
