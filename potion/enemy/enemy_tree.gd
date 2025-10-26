extends AnimationTree

const ATTACK_SHOT = "parameters/Attack/request"

@export var attack_count := 3

var attack_num := 0:
	set(v):
		attack_num = v % attack_count

func attack():
	set(ATTACK_SHOT, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	attack_num += 1
