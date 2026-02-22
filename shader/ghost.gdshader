shader_type spatial;
render_mode unshaded;

uniform lowp float globalfade : hint_range(0, 1) = 0.5;
uniform sampler2D texture: source_color, filter_linear, repeat_disable;

void fragment () {
	float sinvresnel = dot(normalize(NORMAL), normalize(VIEW))*(1.0-globalfade);
	ALPHA = sinvresnel;
	ALBEDO = texture(texture, UV).rgb;
}