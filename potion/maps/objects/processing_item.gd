class_name ProcessingItem
extends RayInteractable

@export var process_action: ProcessAction
@export var progress: Node3D
@export var process := ItemResource.Process.CRUSH
@export var allow_only_valid := false

@onready var item_processing = ItemResource.PROCESSES.get(process, {})
@onready var item_popup: ItemPopup = $ItemPopup
@onready var icon: SpriteTextureOutlined = $Icon
@onready var disabled: Sprite3D = $Icon/Disabled

var logger = KumaLog.new("Oven")
var working_player: FPSPlayer

var processing: bool = false
var item: ItemResource:
	set(v):
		item = v
		progress.visible = item != null
		item_popup.set_item(item)
		process_action.on_item_changed(item)

func _ready() -> void:
	super()
	process_action.finished.connect(_on_process_action_finished)
	process_action.cancelled.connect(reset_player)
	process_action.setup(self)

	reset()
	hovered.connect(func(_a: FPSPlayer): disabled.visible = not _can_process() and item != null)
	icon.change_texture(ItemResource.PROCESS_ICONS[process])

func _process(delta: float) -> void:
	if not processing or process_action == null:
		return

	process_action.update(delta)
	
func _on_processed():
	if not item:
		logger.warn("Processed empty item")
		return
	
	var new_item = item_processing.get(item.type)
	item = ItemResource.get_resource(new_item)
	reset_player()

func _on_process_action_finished(success: bool) -> void:
	if success:
		_on_processed()
		return
	
	reset()

func reset():
	item = null
	reset_player()

func interact(actor: FPSPlayer):
	if item != null:
		if not actor.has_item() and not process_action.running:
			actor.pickup_item(item)
			reset()
		return
	
	if not actor.has_item(): return
	
	if allow_only_valid and not _can_process(actor.held_item_type):
		return
	
	item = actor.release_item()
	if process_action.automatic and _can_process():
		_start_processing(null)

func _can_process(i = item) -> bool:
	return i != null and item_processing.has(i.type)

func release(actor: FPSPlayer):
	cancel_action(actor)

func action(actor: FPSPlayer):
	if not _can_process() or actor.has_item(): return
	if working_player and working_player != actor: return

	if not processing:
		working_player = actor
		working_player.begin_action_lock(self)
		_start_processing(actor)

	if process_action:
		process_action.action_pressed()

func action_released(actor: FPSPlayer):
	if working_player != actor: return
	if process_action:
		process_action.action_released()

func cancel_action(actor: FPSPlayer) -> void:
	if working_player != actor:
		return
	if process_action and process_action.running:
		process_action.cancel()
	else:
		reset_player()

func _start_processing(actor: FPSPlayer) -> void:
	processing = true
	if process_action:
		process_action.start(actor)

func reset_item():
	item = null
	reset_player()

func reset_player():
	processing = false
	if working_player:
		working_player.end_action_lock(self)
		working_player = null
