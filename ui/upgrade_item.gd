class_name UpgradeItem
extends TextureButton

@export var upgrade: UpgradeResource:
	set(v):
		upgrade = v
		if is_inside_tree():
			name_label.text = upgrade.name
			desc_label.text = upgrade.description
			icon_rect.texture = upgrade.icon

@export var name_label: Label
@export var desc_label: Label
@export var icon_rect: TextureRect
