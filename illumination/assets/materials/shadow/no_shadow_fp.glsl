#ifndef no_shadow_fp
#define no_shadow_fp

#include "/assets/materials/includes/float_rgba_utils.glsl"

uniform lowp vec4 shadow_params; //x is texture size y depth_bias
uniform lowp vec4 shadow_color;
uniform highp vec4 sun_position; //sun light position
uniform highp sampler2D SHADOW_TEXTURE;

varying highp vec4 var_texcoord0_shadow;

float shadow_calculation_mobile(vec4 depth_data){
    return 0.0;
}

float shadow_calculation(vec4 depth_data){
    return 0.0;
}

float shadow_calculation_with_added_normal_bias(highp vec4 depth_data, vec3 normal, vec3 position){
   return 0.0;
}


// SUN! DIRECT LIGHT
vec3 direct_light(vec3 light_color, vec3 light_position, vec3 position, vec3 vnormal, vec3 shadow_color){
    vec3 dist = light_position;
    vec3 direction = normalize(dist);
    float n = max(dot(vnormal, direction), 0.0);
    vec3 diffuse = (light_color - shadow_color) * n;
    return diffuse;
}

#endif