shader_type canvas_item;

uniform float radius: hint_range(0.0, 1.0) = 0.5;
uniform float border_smoothness: hint_range(0.0, 0.5) = 0.01;
uniform vec4 circle_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 background_color: source_color = vec4(0.0, 0.0, 0.0, 0.0);

void fragment() {
	// Get UV coordinates centered at (0.5, 0.5)
	vec2 uv = UV - vec2(0.5);
	
	// Calculate distance from center
	float dist = length(uv);
	
	// Create smooth circle using smoothstep
	// smoothstep creates a smooth transition between two values
	float circle = smoothstep(radius + border_smoothness, radius - border_smoothness, dist);
	
	// Mix between background and circle color based on circle mask
	vec4 final_color = mix(background_color, circle_color, circle);
	
	COLOR = final_color;
}
