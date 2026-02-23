shader_type spatial;
render_mode unshaded;

uniform lowp float globalfade : hint_range(0, 1) = 0.5;
uniform sampler2D texture: source_color, filter_linear, repeat_disable;
uniform sampler2D mask_texture: source_color, filter_linear, repeat_disable;
uniform vec3 color: source_color = vec3(1.0);

void fragment () {
	float sinvresnel = dot(normalize(NORMAL), normalize(VIEW))*(1.0-globalfade);
	float mask_fade = texture(mask_texture, UV).r;
	ALPHA = sinvresnel * mask_fade;
	ALBEDO = texture(texture, UV).rgb * color;
}
