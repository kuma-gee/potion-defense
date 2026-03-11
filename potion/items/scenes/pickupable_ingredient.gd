class_name PickupableIngredient
extends RayInteractable

@export var lifetime: Timer
@export var input_icon: InputIcon
@export var movement_direction: Vector3 = Vector3.ZERO
@export  var process_action: ProcessAction

@onready var sfx_player: SFXPlayer = $SFXPlayer

var res: ItemResource
var last_interact: FPSPlayer

func _ready() -> void:
	super()
	if lifetime:
		lifetime.timeout.connect(func(): queue_free())
	
	if input_icon:
		input_icon.connect_interactable(self)
	if process_action:
		process_action.finished.connect(func(_s): _pick_up())
		
func _pick_up():
	if last_interact and last_interact.pickup_item(res):
		sfx_player.play()
		queue_free()

func _process(delta: float) -> void:
	if not is_moving():
		return

	global_position += movement_direction * delta

func is_moving():
	return movement_direction.length() > 0.01

func interact(actor: FPSPlayer) -> void:
	if actor.has_item(): return
	last_interact = actor
	
	if process_action and not is_moving():
		process_action.action_pressed(actor)
	else:
		_pick_up()
