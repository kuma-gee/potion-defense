@tool
extends FocusableButton

@export var label: Label
@export var text := "":
	set(v):
		text = v
		label.text = v
		
@export var normal_theme := ""
@export var focus_theme := ""
		
@onready var panel_container: PanelContainer = $PanelContainer

func _ready() -> void:
	super()
	panel_container.theme_type_variation = normal_theme
	player_focus_entered.connect(func(_id):
		panel_container.theme_type_variation = focus_theme
	)
	player_focus_exited.connect(func(_id):
		if _players_with_focus.is_empty():
			panel_container.theme_type_variation = normal_theme
	)
