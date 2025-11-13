class_name PlayerAnim
extends AnimationTree

func update_move(dir: Vector3):
	set("parameters/Move/blend_amount", dir.length())

func died():
	set("parameters/Death/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	set("parameters/State/transition_request", "dead")
