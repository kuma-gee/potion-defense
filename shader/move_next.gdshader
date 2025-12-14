shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, unshaded;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform vec2 uv_offset = vec2(0.0, 0.0);
uniform vec2 uv_scale = vec2(1.0, 1.0);

uniform float center_distance: hint_range(0.0, 10.0) = 5.0;
uniform float fill_amount: hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 base_uv = (UV + uv_offset) * uv_scale;
	vec2 center = vec2(0.5, 0.5);
	vec2 dist_vec = abs(base_uv - center);
	float dist = max(dist_vec.x, dist_vec.y);
	float alpha_falloff = step(center_distance, dist);
	
	float fill_edge = mix(0.0, center_distance, fill_amount);
	float right_edge = center.x + center_distance;
	float left_edge = right_edge - (center_distance * 2.0 * fill_amount);
	float horizontal_fill = step(left_edge, base_uv.x) * step(base_uv.x, right_edge);
	float inside_rect = step(dist, center_distance);
	float fill = horizontal_fill * inside_rect;
	
	ALPHA = albedo.a * max(alpha_falloff, fill);

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb;
}
