shader_type canvas_item;

uniform bool enabled = false;
uniform vec3 color: source_color = vec3(1.0);

void fragment() {
	if (COLOR.r > 0.9 && COLOR.b < 0.2 && enabled) {
		COLOR.rgb = color;
	}
}
