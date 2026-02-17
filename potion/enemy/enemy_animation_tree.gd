class_name EnemyAnimationTree
extends AnimationTree

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
	attack_count += 1
	if attack_count >= max_attack_count:
		attack_count = 0
	
	state = "attack"
