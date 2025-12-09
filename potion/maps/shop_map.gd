class_name ShopMap
extends Map

signal next_level()

@export var shop_ui: Shop

@onready var shop_open: RayInteractable = $ShopArea/ShopOpen
@onready var move_next: MoveNext = $ShopArea/MoveNext

@onready var equipments: EquipmentsSelect = $PrepareArea/Equipments
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var prepare_move_next: MoveNext = $PrepareArea/MoveNext

var shop_items: Array[UpgradeResource] = []

func _ready() -> void:
	shop_open.interacted.connect(func(_a): shop_ui.open(shop_items))
	move_next.next.connect(func(): _move_to_equipments())
	prepare_move_next.next.connect(func(): next_level.emit())

func setup(shop: Array[UpgradeResource]):
	shop_items = shop

func _move_to_equipments() -> void:
	animation_player.play("next")

func setup_prepare_area():
	equipments.show_upgrades(Events.unlocked_upgrades)
