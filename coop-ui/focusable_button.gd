class_name FocusableButton
extends BaseButton

signal player_focus_entered(player_id: String)
signal player_focus_exited(player_id: String)
signal player_activated(player_id: String)
signal player_canceled(player_id: String)

const FOCUS_GROUP := "focusable_control"

static var _focus_by_player: Dictionary[String, FocusableButton] = {}

@export var initial_focus := false
var _players_with_focus: Array[String] = []

func _ready() -> void:
	add_to_group(FOCUS_GROUP)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _exit_tree() -> void:
	_clear_all_player_focus()

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_drop_focus_if_invalid()

func _unhandled_input(event: InputEvent) -> void:
	var player_id: String = _get_player_id_from_event(event)
	if player_id.is_empty():
		return
	if not has_focus_for_player(player_id):
		if _focus_by_player.has(player_id) and _focus_by_player[player_id] != null:
			return
		
		if initial_focus:
			grab_focus_for_player(player_id)
		return

	if _handle_player_event(event, player_id):
		get_viewport().set_input_as_handled()

func grab_focus_for_player(player_id: String) -> void:
	if player_id.is_empty():
		return
	if not _can_receive_focus():
		return
	var current: FocusableButton = _focus_by_player.get(player_id, null)
	if current == self:
		return
	if current is FocusableButton:
		(current as FocusableButton)._remove_player_focus(player_id)
	_focus_by_player[player_id] = self
	if not _players_with_focus.has(player_id):
		_players_with_focus.append(player_id)
	player_focus_entered.emit(player_id)

func release_focus_for_player(player_id: String) -> void:
	_remove_player_focus(player_id)

func has_focus_for_player(player_id: String) -> bool:
	return _focus_by_player.get(player_id, null) == self

func get_focused_players() -> Array[String]:
	return _players_with_focus.duplicate()

static func get_focus_for_player(player_id: String) -> FocusableButton:
	var control: FocusableButton = _focus_by_player.get(player_id, null)
	if control is FocusableButton:
		return control as FocusableButton
	return null

static func clear_focus_for_player(player_id: String) -> void:
	var control: FocusableButton = _focus_by_player.get(player_id, null)
	if control is FocusableButton:
		(control as FocusableButton).release_focus_for_player(player_id)
	else:
		_focus_by_player.erase(player_id)

func _handle_player_event(event: InputEvent, player_id: String) -> bool:
	if event.is_action_pressed("ui_up"):
		return _move_focus(player_id, Vector2.UP)
	if event.is_action_pressed("ui_down"):
		return _move_focus(player_id, Vector2.DOWN)
	if event.is_action_pressed("ui_left"):
		return _move_focus(player_id, Vector2.LEFT)
	if event.is_action_pressed("ui_right"):
		return _move_focus(player_id, Vector2.RIGHT)
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact") or event.is_action_pressed("action"):
		return _activate(player_id)
	if event.is_action_pressed("ui_cancel"):
		player_canceled.emit(player_id)
		return true
	return false

func _activate(player_id: String) -> bool:
	if not _can_receive_focus():
		return false
	player_activated.emit(player_id)
	if disabled:
		return true
	if toggle_mode:
		button_pressed = not button_pressed
		toggled.emit(button_pressed)
	pressed.emit()
	return true

func _move_focus(player_id: String, direction: Vector2) -> bool:
	var next: FocusableButton = _find_focusable_in_direction(direction)
	if not next:
		return false
	if next == self:
		return false
	next.grab_focus_for_player(player_id)
	return true

func _find_focusable_in_direction(direction: Vector2) -> FocusableButton:
	var neighbor: Control = _get_neighbor_control(direction)
	if neighbor:
		return _find_focusable_from(neighbor, direction)
	return _find_focusable_from(self , direction)

func _get_neighbor_control(direction: Vector2) -> Control:
	var path: NodePath
	if direction == Vector2.LEFT:
		path = focus_neighbor_left
	elif direction == Vector2.RIGHT:
		path = focus_neighbor_right
	elif direction == Vector2.UP:
		path = focus_neighbor_top
	else:
		path = focus_neighbor_bottom
	if path.is_empty():
		return null
	var node: Node = get_node_or_null(path)
	if node is Control:
		return node as Control
	return null

func _find_focusable_from(start: Control, direction: Vector2) -> FocusableButton:
	var current: Control = start
	var guard: int = 0
	while current and guard < 128:
		current = _step_focus_candidate(current, direction)
		if current is FocusableButton:
			var focusable: FocusableButton = current as FocusableButton
			if focusable._can_receive_focus():
				return focusable
		guard += 1
	return null

func _step_focus_candidate(node: Control, direction: Vector2) -> Control:
	var side = SIDE_BOTTOM
	if direction == Vector2.UP:
		side = SIDE_TOP
	elif direction == Vector2.LEFT:
		side = SIDE_LEFT
	elif direction == Vector2.RIGHT:
		side = SIDE_RIGHT
	return node.find_valid_focus_neighbor(side)

func _can_receive_focus() -> bool:
	if not is_visible_in_tree():
		return false
	if focus_mode == Control.FOCUS_NONE:
		return false
	if disabled:
		return false
	return true

func _drop_focus_if_invalid() -> void:
	if _players_with_focus.is_empty():
		return
	if _can_receive_focus():
		return
	_clear_all_player_focus()

func _clear_all_player_focus() -> void:
	if _players_with_focus.is_empty():
		return
	var players: Array[String] = _players_with_focus.duplicate()
	for player_id: String in players:
		release_focus_for_player(player_id)

func _remove_player_focus(player_id: String) -> void:
	if not _players_with_focus.has(player_id):
		return
	_players_with_focus.erase(player_id)
	if _focus_by_player.get(player_id, null) == self:
		_focus_by_player.erase(player_id)
	player_focus_exited.emit(player_id)

func _get_player_id_from_event(event: InputEvent) -> String:
	return PlayerInput.create_id(event)

func _get_mouse_player_id() -> String:
	var mouse_event: InputEventMouseMotion = InputEventMouseMotion.new()
	mouse_event.device = 0
	return PlayerInput.create_id(mouse_event)

func _on_mouse_entered() -> void:
	var player_id: String = _get_mouse_player_id()
	grab_focus_for_player(player_id)

func _on_mouse_exited() -> void:
	var player_id: String = _get_mouse_player_id()
	#if has_focus_for_player(player_id):
		#release_focus_for_player(player_id)
