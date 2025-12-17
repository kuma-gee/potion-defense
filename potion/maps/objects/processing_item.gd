extends RayInteractable

@export var automatic := false
@export var progress: Node3D
@export var process_time: float = 3.0
@export var process := ItemResource.Process.CRUSH
@export var progress_bar: ProgressBar

@onready var item_processing = ItemResource.PROCESSES.get(process, {})
@onready var overheat_timer: Timer = $OverheatTimer
@onready var overheat_start_timer: Timer = $OverheatStartTimer
@onready var item_popup: ItemPopup = $ItemPopup
@onready var icon: Sprite3D = $Icon
@onready var sfx: RandomizedLoopSfx = $Sfx

var logger = KumaLog.new("Oven")
var working_player: FPSPlayer
var process_timer: float = 0.0:
	set(v):
		process_timer = v
		progress_bar.value = process_timer / process_time

var processing: bool = false:
	set(v):
		processing = v
		progress_bar.visible = v
		
		if not sfx.active and processing:
			sfx.start()
		elif sfx.active and not processing:
			sfx.end()
	
var item: ItemResource:
	set(v):
		item = v
		progress.visible = item != null
		item_popup.set_item(item)

func _ready() -> void:
	super()
	reset()
	hovered.connect(func(_a: FPSPlayer): icon.texture = ItemResource.PROCESS_ICONS[process] if _can_process() else null)
	overheat_start_timer.timeout.connect(func(): overheat_timer.start())
	overheat_timer.timeout.connect(func(): _on_overheated())

func _process(delta: float) -> void:
	if processing:
		var multiplier = 1.0
		if not automatic and working_player:
			multiplier = working_player.get_processing_speed()

		process_timer += delta * multiplier
		if process_timer >= process_time:
			_on_processed()
			process_timer = 0.0
			processing = false
	
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
	processing = false
	process_timer = 0.0
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
		process_timer = 0.0
		processing = true

func _can_process() -> bool:
	return item != null and item_processing.has(item.type)

func release(actor: FPSPlayer):
	if automatic: return
	if working_player != actor: return
	processing = false
	process_timer = 0.0

func action(actor: FPSPlayer):
	if automatic: return
	if not _can_process() or actor.has_item(): return

	working_player = actor
	working_player.freeze_player()
	process_timer = 0.0
	processing = true

func action_released(actor: FPSPlayer):
	if working_player != actor: return
	processing = false
	process_timer = 0.0
	
	if working_player:
		working_player.unfreeze_player()
		working_player = null
