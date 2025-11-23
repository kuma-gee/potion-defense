extends RayInteractable

@export var resource: ItemResource
#@export var trees: Array[Node3D] = []
@onready var process_timer: Timer = $ProcessTimer

var player: FPSPlayer

func _ready() -> void:
	super()
	process_timer.timeout.connect(func():
		if player:
			player.pickup_item(resource)
			release(player)
	)
	
	#var tree = trees.pick_random()
	#for t in trees:
		#t.visible = t == tree
	
func interact(actor: FPSPlayer):
	if player: return
	
	player = actor
	player.freeze_player()
	process_timer.start()

func release(actor: FPSPlayer):
	if player != actor: return
	player.unfreeze_player()
	player = null
	process_timer.stop()
