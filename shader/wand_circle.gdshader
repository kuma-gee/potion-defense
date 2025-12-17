shader_type spatial;

render_mode unshaded;

uniform vec4 move_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 circle_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform sampler2D circle_texture: source_color;
uniform sampler2D gradient_texture: source_color;
uniform float start: hint_range(-1.0, 1.0, 0.01) = 0.8;
uniform float end: hint_range(-1.0, 1.0, 0.01) = -0.4;

float remap(float value, float from_min, float from_max, float to_min, float to_max) {
	return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min);
}

void fragment() {
	ALBEDO = circle_color.rgb;
	float offset = remap(move_color.r, 0.0, 1.0, start, end);
	vec2 uv = UV + vec2(0, offset);
	ALPHA *= texture(circle_texture, uv).r * texture(gradient_texture, UV).r;
}
