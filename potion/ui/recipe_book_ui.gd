class_name RecipeBookUI
extends FocusDialog

@export var recipe_page: TextureRect
@export var next_page_btn: BaseButton
@export var prev_page_btn: BaseButton
@export var page_label: Label
@export var recipes: Array[Texture2D] = []

var current_page := 0:
	set(v):
		current_page = clamp(v, 0, max(recipes.size() - 1, 0))
		recipe_page.texture = recipes[current_page]
		page_label.text = "Page %d/%d" % [current_page + 1, recipes.size()]

func _ready() -> void:
	super()
	next_page_btn.pressed.connect(func(): current_page += 1)
	prev_page_btn.pressed.connect(func(): current_page -= 1)
	current_page = 0

func _gui_input(event: InputEvent) -> void:
	super(event)

	if event.is_action_pressed("ui_left") or event.is_action_pressed("move_left"):
		current_page -= 1
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("move_right"):
		current_page += 1
