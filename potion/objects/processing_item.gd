extends RayInteractable

@export var item_processing: Dictionary[ItemResource.Type, ItemResource.Type] = {}
@export var automatic := false
@export var progress: Node3D

@onready var process_timer: Timer = $ProcessTimer
@onready var overheat_timer: Timer = $OverheatTimer
@onready var overheat_start_timer: Timer = $OverheatStartTimer
@onready var item_popup: ItemPopup = $ItemPopup

var logger = KumaLog.new("Oven")
var working_player: FPSPlayer
var item: ItemResource:
	set(v):
		item = v
		progress.visible = item != null
		item_popup.set_item(item)

func _ready() -> void:
	super()
	item = null
	process_timer.timeout.connect(func(): _on_processed())
	overheat_start_timer.timeout.connect(func(): overheat_timer.start())
	overheat_timer.timeout.connect(func(): _on_overheated())
	
func _on_processed():
	if not item:
		logger.warn("Processed empty item")
		return
	
	var new_item = item_processing.get(item.type)
	item = ItemResource.get_resource(new_item)
	action_released(working_player)
	
	if automatic:
		overheat_start_timer.start()

func _on_overheated():
	if not item:
		logger.warn("Overheated on empty item")
	if not automatic:
		logger.warn("Overheated on non automatic station")
	
	reset()
	
func reset():
	item = null
	process_timer.stop()
	overheat_start_timer.stop()

func interact(actor: FPSPlayer):
	if item != null:
		if not actor.has_item():
			actor.pickup_item(item)
			reset()
		return
	
	if not actor.has_item(): return
	
	item = actor.release_item()
	if automatic and _can_process():
		process_timer.start()

func _can_process() -> bool:
	return item != null and item_processing.has(item.type)

func release(actor: FPSPlayer):
	if automatic: return
	if working_player != actor: return
	process_timer.stop()

func action(actor: FPSPlayer):
	if automatic: return
	if not _can_process() or actor.has_item(): return

	working_player = actor
	working_player.freeze_player()
	process_timer.start()

func action_released(actor: FPSPlayer):
	if working_player != actor: return
	process_timer.stop()
	
	if working_player:
		working_player.unfreeze_player()
		working_player = null
