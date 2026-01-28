shader_type spatial;
render_mode unshaded, blend_mix, depth_prepass_alpha, cull_disabled, specular_disabled;

uniform sampler2D sprite_texture : source_color, filter_nearest;
uniform bool enable_billboard = true;
uniform bool enable_outline = true;

uniform vec4 line_color : source_color = vec4(0.0,0.0,0.0,1.0);
uniform float glowSize: hint_range(0.0, 300) = 15.0;
uniform int glowDensity: hint_range(0, 30) = 1;
uniform int glowRadialCoverage: hint_range(0, 32) = 8;
uniform float glowAngle: hint_range(0.0, 6.28) = 1.57;
uniform float glowSharpness: hint_range(0.0, 5.0) = 1.0;
uniform float alphaThreshold: hint_range(0.0, 1.0) =  0.2;

void vertex() {
    if (enable_billboard) {
        vec3 world_origin = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
        float scale_x = length(MODEL_MATRIX[0].xyz);
        float scale_y = length(MODEL_MATRIX[1].xyz);
        vec3 cam_right = normalize(INV_VIEW_MATRIX[0].xyz);
        vec3 cam_up    = normalize(INV_VIEW_MATRIX[1].xyz);
        vec2 local = VERTEX.xy;
        vec3 world_billboard = world_origin
            + cam_right * local.x * scale_x
            + cam_up    * local.y * scale_y;
        POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(world_billboard, 1.0);
    } else {
        POSITION = PROJECTION_MATRIX * VIEW_MATRIX * (MODEL_MATRIX * vec4(VERTEX, 1.0));
    }
}

void fragment() {
    vec4 col = texture(sprite_texture, UV);

    ALBEDO = col.rgb;
    ALPHA = col.a;

    if (enable_outline) {
        vec2 pixel_size = 1.0 / vec2(textureSize(sprite_texture, 0));
        float alph = 0.0;
        for (int i = 0; i < glowRadialCoverage; i++) {
            for (int j = 0; j < glowDensity; j++) {
                float radians360 = 6.28;
                float angle = (radians360 / float(glowRadialCoverage)) * float(i+1) + glowAngle;
                float dist = glowSize * float(j + 1) / float(glowDensity);
                vec2 pixel_coor = vec2(sin(angle), cos(angle));
                vec4 tex = texture(sprite_texture, UV + pixel_coor * pixel_size * dist);

                float distFrom = float(glowDensity - j) / float(glowDensity);
                float sharpness = mix(0.0, 1.0, pow(distFrom, glowSharpness));
                alph += (tex.a * line_color.a) * sharpness;
            }
        }

        if (ALPHA < alphaThreshold) {
            ALBEDO = line_color.rgb;
            ALPHA = alph;
        }
    }
}