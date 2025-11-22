extends RayInteractable

@export var item_processing: Dictionary[ItemResource.Type, ItemResource.Type] = {}
@export var automatic := false
@export var progress: Node3D

@onready var process_timer: Timer = $ProcessTimer
@onready var overheat_timer: Timer = $OverheatTimer
@onready var overheat_start_timer: Timer = $OverheatStartTimer
@onready var item_popup: ItemPopup = $ItemPopup

var working_player: FPSPlayer
var item: ItemResource:
	set(v):
		item = v
		progress.visible = item != null
		item_popup.set_type(item.type if item else -1)

func _ready() -> void:
	super()
	item = null
	process_timer.timeout.connect(func(): _on_processed())
	overheat_start_timer.timeout.connect(func(): overheat_timer.start())
	overheat_timer.timeout.connect(func(): _on_overheated())
	
func _on_processed():
	var new_item = item_processing.get(item.type)
	item = ItemResource.get_resource(new_item)
	if automatic:
		overheat_start_timer.start()

func _on_overheated():
	item = null

func interact(actor: FPSPlayer):
	if item != null:
		if not actor.has_item():
			if not automatic and item_processing.has(item.type):
				working_player = actor
				process_timer.start()
			else:
				actor.pickup_item(item)
				item = null
		return
	
	if not actor.has_item(): return
	
	var i = actor.release_item()
	if not item_processing.has(i.type): return
	
	item = i
	if automatic:
		process_timer.start()

func release(actor: FPSPlayer):
	if automatic: return
	if working_player != actor: return
	process_timer.stop()
