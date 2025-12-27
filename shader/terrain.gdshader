shader_type spatial;

group_uniforms Grass;
uniform vec4 base_color: source_color = vec4(0.2, 0.6, 0.2, 1.0);
uniform sampler2D noise_texture: source_color, filter_linear_mipmap, repeat_enable;
uniform vec2 noise_scale = vec2(1.0, 1.0);
uniform float noise_strength: hint_range(0.0, 1.0) = 0.3;

group_uniforms Terrain;
uniform vec4 secondary_color: source_color = vec4(0.4, 0.3, 0.2, 1.0);
uniform sampler2D secondary_texture: source_color, filter_linear_mipmap, repeat_enable;
uniform vec2 secondary_scale = vec2(1.0, 1.0);
uniform float secondary_noise_strength: hint_range(0.0, 1.0) = 0.3;
uniform sampler2D blend_mask: hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec2 mask_scale = vec2(1.0, 1.0);
uniform vec2 mask_offset = vec2(0.0, 0.0);

group_uniforms Lighting;
uniform float light_smooth = 0.1;
uniform vec3 light_color: source_color = vec3(1.0);
uniform vec3 shadow_color: source_color;

uniform float roughness: hint_range(0.0, 1.0) = 0.8;

void fragment() {
	vec2 noise_uv = UV * noise_scale;
	vec4 noise = texture(noise_texture, noise_uv);
	
	vec3 color = base_color.rgb;
	color = mix(color, color * noise.rgb, noise_strength);
	
	// Secondary layer
	vec2 secondary_uv = UV * secondary_scale;
	vec4 secondary_noise = texture(secondary_texture, secondary_uv);
	vec3 secondary = secondary_color.rgb;
	secondary = mix(secondary, secondary * secondary_noise.rgb, secondary_noise_strength);
	
	// Blend mask
	vec2 mask_uv = UV * mask_scale + mask_offset;
	float mask = texture(blend_mask, mask_uv).r;
	
	color = mix(color, secondary, mask);
	
	ALBEDO = color;
	ROUGHNESS = roughness;
}

//void light() {
    //// Lambertian diffuse lighting
    //float NdotL = dot(NORMAL, LIGHT);
    //DIFFUSE_LIGHT += ALBEDO * ATTENUATION * LIGHT_COLOR * max(0.0, NdotL);
    //
    //// Specular lighting (Cook-Torrance BRDF for specular_schlick_ggx)
    //vec3 H = normalize(VIEW + LIGHT);
    //float NdotH = max(dot(NORMAL, H), 0.0);
    //float NdotV = max(dot(NORMAL, VIEW), 0.0);
    //float HdotV = max(dot(H, VIEW), 0.0);
    //
    //// Fresnel (Schlick approximation)
    //vec3 F0 = mix(vec3(0.04), ALBEDO, METALLIC);
    //vec3 F = F0 + (1.0 - F0) * pow(1.0 - HdotV, 5.0);
    //
    //// Distribution (GGX/Trowbridge-Reitz)
    //float alpha = ROUGHNESS * ROUGHNESS;
    //float alpha2 = alpha * alpha;
    //float denom = (NdotH * NdotH * (alpha2 - 1.0) + 1.0);
    //float D = alpha2 / (PI * denom * denom);
    //
    //// Geometry (Smith's method with GGX)
    //float k = alpha / 2.0;
    //float G1V = NdotV / (NdotV * (1.0 - k) + k);
    //float G1L = NdotL / (NdotL * (1.0 - k) + k);
    //float G = G1V * G1L;
    //
    //// Cook-Torrance specular
    //vec3 specular = (F * D * G) / max(4.0 * NdotV * NdotL, 0.001);
    //
    //SPECULAR_LIGHT += specular * ATTENUATION * LIGHT_COLOR * max(0.0, NdotL);
//}

//void light() {
	//float lDot = dot(NORMAL, LIGHT);
	//float lSmooth = smoothstep(0, light_smooth, lDot);
	//vec3 iLerp = mix(shadow_color, light_color, lSmooth);
//
	//DIFFUSE_LIGHT += ATTENUATION * ALBEDO * LIGHT_COLOR * iLerp;
//
	//// Specular lighting (Cook-Torrance BRDF for specular_schlick_ggx)
    //vec3 H = normalize(VIEW + LIGHT);
    //float NdotH = max(dot(NORMAL, H), 0.0);
    //float NdotV = max(dot(NORMAL, VIEW), 0.0);
    //float HdotV = max(dot(H, VIEW), 0.0);
    //
    //// Fresnel (Schlick approximation)
    //vec3 F0 = mix(vec3(0.04), ALBEDO, METALLIC);
    //vec3 F = F0 + (1.0 - F0) * pow(1.0 - HdotV, 5.0);
    //
    //// Distribution (GGX/Trowbridge-Reitz)
    //float alpha = ROUGHNESS * ROUGHNESS;
    //float alpha2 = alpha * alpha;
    //float denom = (NdotH * NdotH * (alpha2 - 1.0) + 1.0);
    //float D = alpha2 / (PI * denom * denom);
    //
    //// Geometry (Smith's method with GGX)
    //float k = alpha / 2.0;
    //float G1V = NdotV / (NdotV * (1.0 - k) + k);
    //float G1L = lDot / (lDot * (1.0 - k) + k);
    //float G = G1V * G1L;
    //
    //// Cook-Torrance specular
    //vec3 specular = (F * D * G) / max(4.0 * NdotV * lDot, 0.001);
    //
    //SPECULAR_LIGHT += specular * ATTENUATION * LIGHT_COLOR * max(0.0, lDot);
//}