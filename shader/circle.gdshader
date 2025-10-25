shader_type canvas_item;

uniform vec4 color: source_color = vec4(1.0);

uniform float circle_size:hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float inner_circle_size:hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float circle_smooth:hint_range(0.0, 1.0, 0.01) = 0.0;

uniform float fill: hint_range(0.0, 1.0, 0.01) = 1.0;

void fragment() {
	vec2 uv = UV - vec2(0.5, 0.5);
	float dist = length(uv);
	float circle = 1. - smoothstep(circle_size, circle_size + circle_smooth, dist);
	float inner_circle = smoothstep(inner_circle_size, inner_circle_size + circle_smooth, dist);

	float angle = atan(uv.x, uv.y); // -PI to PI
	float fill_value = step(PI - (TAU * fill), angle);

	vec4 circle_color = color * inner_circle * fill_value;
	circle_color.a *= circle;
	COLOR = circle_color;
}
