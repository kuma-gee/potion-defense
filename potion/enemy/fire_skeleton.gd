class_name FireSkeleton
extends Enemy

@export var max_charges := 3
@export var burning_speed := 1.5

@onready var elemental_area: ElementalArea = $ElementalArea
@onready var fire: Node3D = $ZeldaFire
@onready var red_beam_impact: PlayParticleSystems = $RedBeamImpact
@onready var explosion_hit_box: HitBox = $ExplosionHitBox

@onready var base_explosion_damage := explosion_hit_box.damage

var fire_charges := 1:
	set(v):
		fire_charges = clamp(v, 0, max_charges)
		explosion_hit_box.damage = base_explosion_damage * (1.0 + fire_charges/10.0)
		
		var on = is_burning()
		elemental_area.element = ElementalArea.Element.FIRE if on else ElementalArea.Element.NONE
		fire.visible = on
		red_beam_impact.visible = on

func _ready() -> void:
	super()
	
	fire_charges = 1
	elemental_area.received.connect(func(elem):
		if elem == ElementalArea.Element.FIRE and fire_charges > 0:
			if not elemental_area.has_contact_with(ElementalArea.Element.ICE):
				fire_charges += 1
		elif elem == ElementalArea.Element.ICE:
			fire_charges = 0
			hurt_box.resistance[ElementalArea.Element.FIRE] = 0.0
			if animation_player.current_animation == "explode":
				move()
	)

func _play_attack():
	if fire_charges > 0:
		animation_player.play("explode")
		return
	
	super()

func _on_attack_finished(anim: String):
	if anim == "explode":
		died("death_explode")
		return
	
	super(anim)

func is_burning():
	return fire_charges > 0

func get_actual_speed(s = speed):
	return super(s if not is_burning() else burning_speed)

func move(anim = "move"):
	super(anim if not is_burning() else "run")
