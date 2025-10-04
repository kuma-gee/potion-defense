shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, unshaded;

group_uniforms render;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D albedo_texture;

uniform float opacity : hint_range(0.0, 2.0) = 0.35;
uniform vec4 ghost_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float flicker_speed : hint_range(0.0, 5.0) = 0.0;
uniform float phase_frequency : hint_range(0.0, 1.0) = 0.0;

uniform float fresnel_strength : hint_range(0.0, 1.5) = 0.8;
uniform vec3 fresnel_color : source_color = vec3(1.0, 1.0, 1.0);

uniform float wave_amplitude: hint_range(0.0, 0.01) = 0.006;
uniform float wave_frequency: hint_range(0.0, 20.0) = 19.397;
uniform float wave_speed: hint_range(0.0, 10.0) = 3.618;
uniform float chroma_amount: hint_range(0.0, 10.0) = 1.0;

void fragment() {
	vec2 wave_offset = vec2(
		sin(SCREEN_UV.y * wave_frequency + TIME * wave_speed),
		sin(SCREEN_UV.x * wave_frequency + TIME * wave_speed)
	) * wave_amplitude;

	vec2 distorted_uv = SCREEN_UV + wave_offset;

	vec2 red_uv   = distorted_uv + wave_offset * chroma_amount;
	vec2 blue_uv  = distorted_uv - wave_offset * chroma_amount;
	vec2 green_uv = distorted_uv;

	float r = texture(screen_texture, red_uv).r;
	float g = texture(screen_texture, green_uv).g;
	float b = texture(screen_texture, blue_uv).b;
	vec3 screen_color = vec3(r, g, b);

	float flicker = sin(TIME * flicker_speed) * 0.5 + 0.5;
	float phase = sin(TIME * phase_frequency * 6.2831) * 0.5 + 0.5;

	float fresnel_factor = pow(1.0 - dot(NORMAL, VIEW), 2.0) * fresnel_strength;
	vec3 fresnel = fresnel_color * fresnel_factor;

	vec4 base_texture = texture(albedo_texture, UV);
	vec3 base_color = base_texture.rgb * ghost_color.rgb;


	vec4 final_color = vec4(base_color, ghost_color.a);
	final_color.rgb = mix(final_color.rgb, screen_color, 0.6);
	final_color.rgb += fresnel;

	float final_alpha = ghost_color.a * opacity * flicker * phase;
	final_color.a = clamp(final_alpha, 0.0, 1.0);

	EMISSION = final_color.rgb;
	ALBEDO = final_color.rgb;
	ALPHA = final_color.a;
}
