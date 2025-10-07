shader_type canvas_item;

uniform float radius: hint_range(0.0, 1.0) = 0.5;
uniform float smoothness: hint_range(0.0, 1.0) = 0.1;

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    COLOR.a = 1. - smoothstep(radius, radius + smoothness, dist);
}
