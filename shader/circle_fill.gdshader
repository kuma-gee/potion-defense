shader_type canvas_item;

uniform float radius: hint_range(0.0, 1.0) = 0.5;
uniform float border_smoothness: hint_range(0.0, 0.5) = 0.01;
uniform vec4 circle_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 background_color: source_color = vec4(0.0, 0.0, 0.0, 0.0);

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float circle = smoothstep(radius + border_smoothness, radius - border_smoothness, dist);
	
	vec4 final_color = mix(background_color, circle_color, circle);
	COLOR = final_color;
}
