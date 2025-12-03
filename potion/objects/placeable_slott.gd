extends RayInteractable

@onready var item_popup: ItemPopup = $ItemPopup

var item: ItemResource:
	set(v):
		item = v
		item_popup.set_item(item)

func _ready() -> void:
	super()
	
	item = null
	#Events.game_started.connect(func():
		## no idea why this is required, pls tell me if u do
		#await get_tree().create_timer(0.2).timeout
		#
		#if has_overlapping_areas():
			#monitorable = false
			#hide()
	#)
	

func has_item():
	return item != null
	
func interact(actor: FPSPlayer):
	if has_overlapping_areas(): return
	
	if item != null:
		if not actor.has_item():
			actor.pickup_item(item)
			item = null
			
		return
	
	if not actor.has_item(): return
	
	item = actor.release_item()
