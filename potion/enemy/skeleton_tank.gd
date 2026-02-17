class_name SkeletonTank
extends Enemy

@export var armor: Array[Node3D] = []
@onready var elemental_area: ElementalArea = $ElementalArea

var has_armor := true:
	set(v):
		has_armor = v
		for a in armor:
			a.visible = has_armor

func _ready() -> void:
	super()
	elemental_area.received.connect(func(elem):
		if elem == ElementalArea.Element.POISON:
			has_armor = false
			hurt_box.resistance = {}
	)
