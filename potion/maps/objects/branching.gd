class_name Branching
extends Obstacle

@export var branch_first: Array[Node3D]
@export var branch_second: Array[Node3D]

@onready var branches := [branch_second, branch_first]
var active_branch := 0

func activate():
	super()
	
	active_branch = (active_branch + 1) % branches.size()
	for i in range(branches.size()):
		_toggle_all(branches[i], i == active_branch)
	
	await get_tree().create_timer(0.1).timeout
	finished.emit()
	
func _toggle_all(nodes, show_node):
	for x in nodes:
		x.visible = show_node
		for child in x.get_children():
			var static_body = child as StaticBody3D
			if static_body:
				static_body.set_collision_layer_value(1, show_node)
