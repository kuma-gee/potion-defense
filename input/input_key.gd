# Maps inputs to images from https://thoseawesomeguys.com/prompts/
class_name InputKey
extends Node

const ASSETS_FOLDER = "res://assets/Inputs/"
const JOYPAD_KEYS = {
	PlayerInput.Device.PLAYSTATION: preload("res://input/joypad/ps5_keys.tres"),
	PlayerInput.Device.XBOX: preload("res://input/joypad/xbox_keys.tres"),
	PlayerInput.Device.STEAM_DECK: preload("res://input/joypad/deck_keys.tres"),
}

const BLANK_KEY = preload("res://assets/Inputs/Keyboard & Mouse/Blanks/Blank_Black_Normal.png")
const KEY_MAPS = {
	"Left": "Arrow_Left",
	"Right": "Arrow_Right",
	"Up": "Arrow_Up",
	"Down": "Arrow_Down",
	# TODO: probably will be more
}

@export_enum("Light", "Dark") var theme := "Dark" # For keyboard/mouse
@export var exclude_mouse := false
@export var action := ""

var _logger = KumaLog.new("InputKey")

func get_texture(input: PlayerInput) -> Texture2D:
	var ev = get_event_for_action(input)
	if ev:
		var type = InputType.to_type(ev)
		var dev = input.get_device()
		
		if dev == PlayerInput.Device.KEYBOARD:
			var text = InputType.to_text(type)
			var folder = ASSETS_FOLDER + "Keyboard & Mouse"
			var file = "%s/%s/%s_Key_%s.png" % [folder, theme, text, theme]
			if ResourceLoader.exists(file):
				return load(file)
			else:
				_logger.warn("Failed to find input file: %s" % file)
		elif dev in JOYPAD_KEYS:
			var keys: JoypadKeys = JOYPAD_KEYS[dev]
			return keys.get_texture(type)
		else:
			_logger.warn("Unknown device type %s for input %s" % [dev, type])
	
	return BLANK_KEY

func get_event_for_action(input: PlayerInput):
	var events = InputMap.action_get_events(action)
	for ev in events:
		if exclude_mouse and (ev is InputEventMouseMotion or ev is InputEventMouseButton): continue
		
		if input.is_player_event(ev):
			return ev
	
	return null
