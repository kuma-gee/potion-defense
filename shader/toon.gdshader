// https://www.youtube.com/watch?v=WR_SP4LmOlw
// - Custom Lighting
// - Outer Shadow #TODO
// - Anisotropic Hair
// - Face Shadow # TODO
// - Metallic # TODO
shader_type spatial;
render_mode depth_draw_opaque, cull_disabled;

uniform float light_smooth = 0.2;
uniform vec3 shadow_color: source_color;
uniform vec3 base_color: source_color = vec3(0.7);
uniform vec3 terminal_shadow_color: source_color;
uniform sampler2D main_texture;
uniform sampler2D normal_texture: hint_normal;
uniform float alpha_scissor_threshold: hint_range(0.0, 1.0, 0.01) = 0.5;

// group_uniforms hair;
// uniform sampler2D hair_mask_texture;
// uniform float aniso_hair_fresnel_pow = 0.1;
// uniform float aniso_hair_fresnel_intensity = 0.1;
// uniform float hair_shine_size = 0.1;
// uniform float hair_shine_smooth = 0.1;
// uniform float hair_shine_strength = 0.05;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 albedo_tex = texture(main_texture, UV);
	ALBEDO = albedo_tex.rgb;
	//ALPHA = albedo_tex.a;
	//ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	
	// Let Godot handle normal map transformation
	//NORMAL_MAP = texture(normal_texture, UV).rgb;
}

void light() {
	// vec3 normal_from_texture = texture(normal_texture, UV).rgb;
	// vec3 normal = vec3(normal_from_texture.x * NORMAL.x, normal_from_texture.y * NORMAL.y, normal_from_texture.z);
	// normal = NORMAL - normal_from_texture;

	float lDot = dot(NORMAL, LIGHT);
	float lSmooth = smoothstep(0, light_smooth, lDot);
	vec3 iLerp = mix(shadow_color, base_color, lSmooth);

	DIFFUSE_LIGHT += ALBEDO * ATTENUATION * LIGHT_COLOR * iLerp; // LIGHT_COLOR, makes it too bright

	// TODO
	//float lDot_b = dot(normal, LIGHT);
	//float lSmooth_b = smoothstep(0, light_smooth, lDot_b);
	//vec3 iLerp_b = mix(terminal_shadow_color, ALBEDO * iLerp, lSmooth_b);

	//  float aniso_hair_fresnel_pow = 1.0;
	//  float aniso_hair_fresnel_intensity = 1.0;
	//  vec3 H = normalize(LIGHT + VIEW);
	//  float NdotH = dot(NORMAL, H);
	//  float anisoHairFresnel = pow(1.0 - NdotH, aniso_hair_fresnel_pow) * aniso_hair_fresnel_intensity;
	//  float anisoHair = anisoHairFresnel * texture(hair_mask_texture, UV).r * lDot;

	//  float specular_amount = max(pow(NdotH, aniso_hair_fresnel_pow), 0.0f) * aniso_hair_fresnel_intensity
	//  					    * texture(hair_mask_texture, UV).r
	//  						* lSmooth;
	//  specular_amount = smoothstep(hair_shine_size, hair_shine_size + hair_shine_smooth, specular_amount);
	//  SPECULAR_LIGHT += hair_shine_strength * specular_amount * LIGHT_COLOR;
}
