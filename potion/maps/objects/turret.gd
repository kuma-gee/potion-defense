class_name Turret
extends RayInteractable

const GROUP = "GOLEM"
const POTION_TURRETS = {
	ItemResource.Type.POTION_FIRE_BOMB: preload("uid://baxxwp86stwe6"),
	ItemResource.Type.POTION_BLIZZARD: preload("uid://c3jwn2bp7a8hm"),
	ItemResource.Type.POTION_POISON_CLOUD: preload("uid://cxya3lrhur7jg"),
}

@export var progress_bar: ProgressBar
@export var max_fuel := 100.0
@export var potion_fuel_amount := 50.0
@export var fuel_consumption_rate := 1.0

@export var price_container: Control

@onready var turret_body: Node3D = $TurretBody

var golem_type = null:
	set(v):
		golem_type = v
		progress_bar.visible = v != null
		turret_body.visible = v != null
		
var current_fuel := 0.0:
	set(v):
		current_fuel = v
		progress_bar.value = v

var potion_type = null:
	set(v):
		if potion_turret and potion_type != v:
			potion_turret.queue_free()
			potion_turret = null
		
		potion_type = v
		
		if potion_turret == null and potion_type in POTION_TURRETS:
			var node = POTION_TURRETS[potion_type].instantiate()
			potion_turret = node
			add_child(node)
			node.global_position  = global_position
		
		var color = CauldronItem.POTION_COLORS.get(potion_type, Color.WHITE) if _has_potion() else Color.WHITE
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = color
		progress_bar.add_theme_stylebox_override("fill", style_box)

var out_of_fuel := false:
	set(v):
		if v == out_of_fuel:
			return

		out_of_fuel = v
		turret_body.position.y = -0.3 if v else 0.0

var potion_turret: PotionTurret

func _ready() -> void:
	super()
	add_to_group(GROUP)
	
	golem_type = null
	current_fuel = 0.0
	out_of_fuel = true
	progress_bar.max_value = max_fuel
	_on_unhovered(null)
	
	hovered.connect(_on_hovered)
	unhovered.connect(_on_unhovered)
	interacted.connect(_on_interacted)

func _on_hovered(_actor):
	if has_golems():
		price_container.show()

func _on_unhovered(_actor):
	price_container.hide()

func has_golems():
	return Events.get_golem_counts().values().reduce(func(a, b): return a + b, 0) > 0

func _process(delta: float) -> void:
	if not golem_type or not potion_turret:
		return
	
	var consumption = potion_turret.get_consumption(delta)
	out_of_fuel = consumption > current_fuel

	if current_fuel <= 0.0 or not potion_turret.can_attack():
		return
	
	if not out_of_fuel:
		current_fuel = max(0.0, current_fuel - consumption)
		potion_turret.activate()
	else:
		potion_turret.deactivate()

func _on_interacted(actor: FPSPlayer) -> void:
	if has_golems():
		_try_unlock()
	elif golem_type != null:
		_try_add_potion(actor)

func _try_unlock() -> void:
	golem_type = Events.get_golem_counts().keys()[0]
	progress_bar.show()

func _try_add_potion(actor: FPSPlayer) -> void:
	if not actor.has_method("is_holding_potion") or not actor.has_method("release_item"):
		return
	
	if not actor.is_holding_potion():
		return
	
	if _has_potion() and actor.held_item_type.type != potion_type:
		print("Turret already has a different potion type!")
		return
	
	current_fuel = min(max_fuel, current_fuel + potion_fuel_amount)
	
	var item = actor.release_item()
	potion_type = item.type
	print("Added potion to turret. Fuel: %d/%d" % [current_fuel, max_fuel])

func _has_potion():
	return current_fuel > 0 and potion_type != null
