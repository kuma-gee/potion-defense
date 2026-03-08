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

	reset()
	hovered.connect(func(_a: FPSPlayer):
		disabled.visible = not _can_process() and item != null
		process_action.hovered(_a)
	)
	unhovered.connect(func(_a: FPSPlayer):
		process_action.unhovered(_a)
	)
	icon.change_texture(ItemResource.PROCESS_ICONS[process])

func _process(delta: float) -> void:
	process_action.update(delta)
	
func _on_processed():
	if not item:
		logger.warn("Processed empty item")
		return
	
	var new_item = item_processing.get(item.type)
	if new_item:
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
		if not actor.has_item() and process_action.player == null:
			actor.pickup_item(item)
			reset()
		return
	
	if not actor.has_item(): return
	
	if allow_only_valid and not _can_process(actor.held_item_type):
		return
	
	item = actor.release_item()
	# if process_action.automatic and _can_process():
	# 	_start_processing(null)

func _can_process(i = item) -> bool:
	return i != null and item_processing.has(i.type)

func action(actor: FPSPlayer):
	if not _can_process() or actor.has_item(): return
	if process_action:
		process_action.action_pressed(actor)

func action_released(actor: FPSPlayer):
	if process_action:
		process_action.action_released(actor)

# func cancel_action(_actor: FPSPlayer) -> void:
# 	if process_action and process_action.player != null:
# 		process_action.cancel()
# 	else:
# 		reset_player()

func reset_item():
	item = null
	reset_player()

func reset_player():
	return
