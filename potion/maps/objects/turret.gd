class_name Turret
extends RayInteractable

const GROUP = "GOLEM"

@export var progress_bar: ProgressBar
@export var max_fuel := 100.0
@export var potion_fuel_amount := 50.0

@export var price_container: Control

var golem_res: GolemResource = null:
	set(v):
		golem_res = v
		progress_bar.visible = v != null
		
var current_fuel := 0.0:
	set(v):
		current_fuel = v
		progress_bar.value = v

var potion_res: PotionResource = null:
	set(v):
		potion_res = v
		if potion_res:
			golem.set_potion_type(potion_res)
		
		var color: Color = Color.WHITE if not potion_res else potion_res.color
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = color
		progress_bar.add_theme_stylebox_override("fill", style_box)

var out_of_fuel := false:
	set(v):
		if v == out_of_fuel:
			return

		out_of_fuel = v

var golem: Golem

func _ready() -> void:
	super()
	add_to_group(GROUP)
	
	golem_res = null
	current_fuel = 0.0
	out_of_fuel = true
	progress_bar.max_value = max_fuel
	visible = has_golems()
	_on_unhovered(null)
	
	hovered.connect(_on_hovered)
	unhovered.connect(_on_unhovered)
	interacted.connect(_on_interacted)

func _on_hovered(_actor):
	if has_golems() and golem == null:
		price_container.show()
	elif golem:
		golem.on_hover()
		
func _on_unhovered(_actor):
	price_container.hide()
	if golem:
		golem.on_unhover()

func get_golem_range():
	return golem.get_node_or_null("Range") if golem else null

func has_golems():
	return Events.has_available_golems()

func _process(delta: float) -> void:
	if not golem_res:
		return
	
	var consumption = golem.get_consumption(delta)
	out_of_fuel = consumption > current_fuel

	current_fuel = max(0.0, current_fuel - consumption)
	if current_fuel <= 0.0 or not is_instance_valid(golem):
		return
	
	golem.process(delta)

func _on_interacted(actor: FPSPlayer) -> void:
	if has_golems():
		_try_unlock()
	elif golem_res != null:
		_try_add_potion(actor)

func _try_unlock() -> void:
	# TODO: golem type select
	golem_res = Events.get_available_golem_counts().keys()[0]
	progress_bar.show()

	var node = golem_res.scene.instantiate()
	golem = node
	node.golem = golem_res
	add_child(node)
	node.global_position  = global_position

func _try_add_potion(actor: FPSPlayer) -> void:
	if not actor.has_method("is_holding_potion") or not actor.has_method("release_item"):
		return
	
	if not actor.is_holding_potion():
		return
	
	if _has_potion() and actor.held_item_type.type != potion_res.type:
		print("Turret already has a different potion type!")
		return
	
	current_fuel = min(max_fuel, current_fuel + potion_fuel_amount)
	
	var item = actor.release_item()
	potion_res = item
	print("Added potion to turret. Fuel: %d/%d" % [current_fuel, max_fuel])

func _has_potion():
	return current_fuel > 0 and potion_res != null
