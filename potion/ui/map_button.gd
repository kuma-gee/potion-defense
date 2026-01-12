extends TextureButton

@export var name_label: Label

var res: MapResource
var is_disabled := false:
	set(v):
		is_disabled = v
		disabled = v
		modulate = Color.DIM_GRAY if disabled else Color.WHITE

func _ready() -> void:
	name_label.text = "%s" % res.name
