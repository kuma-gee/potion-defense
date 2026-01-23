extends AttackEffect

@onready var cleanup_timer: Timer = $CleanupTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var small_hit: HitBox = $SmallHit

func _ready() -> void:
	animation_player.play("start")
	cleanup_timer.timeout.connect(func(): queue_free())
	small_hit.damage *= damage_multiplier
