class_name GolemArea
extends Golem

@onready var status_area: PotionHitArea = $StatusArea
@onready var disable_timer: Timer = $DisableTimer
@onready var range_always: MeshInstance3D = $RangeAlways

func _ready() -> void:
	disable_timer.timeout.connect(func(): disable())
	disable()
	
func disable():
	status_area.is_finished = true
	range_always.hide()

func process(_delta: float) -> void:
	status_area.is_finished = false
	range_always.visible = potion != null
	disable_timer.start()
