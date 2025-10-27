shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled;

uniform vec4 circle_color : source_color = vec4(1.0, 1.0, 0.0, 0.8);
uniform float radius : hint_range(0.0, 1.0) = 0.4;
uniform float border_smoothness : hint_range(0.0, 0.5) = 0.05;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	
	float circle = 1.0 - smoothstep(radius - border_smoothness, radius + border_smoothness, dist);
	
	ALBEDO = circle_color.rgb;
	ALPHA = circle * circle_color.a;
}
