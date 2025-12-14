shader_type spatial;

render_mode unshaded, cull_disabled;

uniform sampler2D fire_texture: source_color;
uniform sampler2D distortion_texture: hint_default_white;
uniform sampler2D distortion_mask_texture: source_color;
uniform sampler2D mask_texture: source_color;
uniform vec3 fire_color: source_color = vec3(1.0, 0.5, 0.0);
uniform vec2 distortion_speed = vec2(0.0, 0.1);
uniform float distortion_strength: hint_range(0.0, 1.0) = 0.1;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec2 distortion_uv = UV + TIME * distortion_speed;
	vec2 distortion = texture(distortion_texture, distortion_uv).rg * 2.0 - 1.0;

	float distortion_mask = texture(distortion_mask_texture, UV).r;
	vec2 distorted_uv = UV + distortion * distortion_strength * distortion_mask;

	float mask = texture(mask_texture, UV).r;
	ALBEDO = fire_color;
	ALPHA = texture(fire_texture, distorted_uv).r * mask;
}
