class_name EnemyAnimationTree
extends AnimationTree

const ATTACK = "parameters/Attack/request"
const SPAWN = "parameters/Spawn/request"

@export var max_attack_count: int = 3

var attack_count := 0
var state = ""
var extra_state = ""

func knockback():
	state = "knockback"

func died():
	state = "dead"

func move():
	attack_count = 0
	state = "move"

func attack():
	state = "attack"
	attack_count += 1
	if attack_count >= max_attack_count:
		attack_count = 0
	
	set(ATTACK, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func spawn():
	state = "spawn"
	set(SPAWN, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
