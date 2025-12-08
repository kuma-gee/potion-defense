class_name NewRecipe
extends TextureRect

@export var item: CauldronItem
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hide()

func open(i: ItemResource) -> void:
	item.item = i
	animation_player.play("open")
