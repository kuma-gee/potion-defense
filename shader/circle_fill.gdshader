shader_type canvas_item;

uniform float radius: hint_range(0.0, 1.0) = 0.5;
uniform float border_smoothness: hint_range(0.0, 0.5) = 0.01;
uniform float border_size: hint_range(0.0, 1.0) = 0.0;
uniform vec4 circle_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 border_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 background_color: source_color = vec4(0.0, 0.0, 0.0, 0.0);

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float circle = smoothstep(radius + border_smoothness, radius - border_smoothness, dist);
	float border_outer = smoothstep(radius + border_size + border_smoothness, radius + border_size - border_smoothness, dist);
	float border = clamp(border_outer - circle, 0.0, 1.0);
	
	vec4 final_color = mix(background_color, circle_color, circle);
	final_color = mix(final_color, border_color, border);
	COLOR = final_color;
}
