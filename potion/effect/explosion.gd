extends AttackEffect

@onready var cleanup_timer: Timer = $CleanupTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var small_hit: HitBox = $SmallHit

var potion: PotionResource

func _ready() -> void:
	small_hit.apply_potion(potion, damage_multiplier)
	animation_player.play("start")
	cleanup_timer.timeout.connect(func(): queue_free())
