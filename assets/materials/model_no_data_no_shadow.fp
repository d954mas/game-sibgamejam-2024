uniform lowp sampler2D DIFFUSE_TEXTURE;


//#include "/illumination/assets/materials/shadow/no_shadow_fp.glsl"
uniform lowp vec4 shadow_color;
uniform highp vec4 sun_position; //sun light position
// SUN! DIRECT LIGHT
vec3 direct_light(vec3 light_color, vec3 light_position, vec3 position, vec3 vnormal, vec3 shadow_color){
    vec3 dist = light_position;
    vec3 direction = normalize(dist);
    float n = max(dot(vnormal, direction), 0.0);
    vec3 diffuse = (light_color - shadow_color) * n;
    return diffuse;
}


uniform lowp vec4 ambient_color;
uniform lowp vec4 sunlight_color;
uniform lowp vec4 fog_color;
uniform highp vec4 fog;


varying mediump vec2 var_texcoord0;
varying highp vec3 var_world_position;
varying mediump vec3 var_world_normal;
varying highp vec3 var_view_position;
varying highp vec3 var_camera_position;
uniform lowp vec4 tint;

void main() {
    vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    vec4 texture_color = texture2D(DIFFUSE_TEXTURE, var_texcoord0)* tint_pm;
    vec3 color = texture_color.rgb;
    // Defold Editor
    // if (sun_position.xyz == vec3(0)) {
    //gl_FragColor = vec4(color.rgb * vec3(0.8), 1.0);
    //  return;
    // }

    //COLOR
    vec3 illuminance_color = vec3(0);
    vec3 specular_color = vec3(0);

    vec3 surface_normal = var_world_normal;
    vec3 view_direction = normalize(var_camera_position - var_world_position);

    // Ambient
    vec3 ambient = ambient_color.rgb * ambient_color.w;
    illuminance_color = illuminance_color + ambient;


    //REGION SHADOW -----------------
    // shadow map
    float shadow = 1.0;
    vec3 shadow_color = shadow_color.xyz*shadow_color.w*(sunlight_color.w) * shadow;

    vec3 diff_light = vec3(0);
    diff_light += max(direct_light(sunlight_color.rgb, sun_position.xyz, var_world_position.xyz, var_world_normal, shadow_color)*sunlight_color.w, 0.0);
    diff_light += vec3(illuminance_color.xyz);

    color.rgb = color.rgb * (min(diff_light, 1.0));

    // Fog
    float dist = abs(var_view_position.z);
    float fog_max = fog.y;
    float fog_min = fog.x;
    float fog_factor = clamp((fog_max - dist) / (fog_max - fog_min) + fog_color.a, 0.0, 1.0);
    color = mix(fog_color.rgb, color, fog_factor);


    gl_FragColor = vec4(color, texture_color.a);

    //float colorz = floor(-var_view_position.z-camNear)/clusters_data.z;
    //gl_FragColor = vec4(float(clusterX_index)/clusters_data.x,float(clusterY_index)/clusters_data.y,float(clusterZ_index)/clusters_data.z, texture_color.a);
    //gl_FragColor = vec4(float(clusterZ_index)/clusters_data.z,float(clusterZ_index)/clusters_data.z,float(clusterZ_index)/clusters_data.z, texture_color.a);
    //gl_FragColor = vec4(clusterZ_index/10.0,color.g,color.b, texture_color.a);
}