uniform lowp sampler2D DIFFUSE_TEXTURE;


varying mediump vec2 var_texcoord0;
varying highp vec3 var_world_position;
varying mediump vec3 var_world_normal;
varying highp vec3 var_camera_position;
varying highp vec3 var_view_position;

#include "/illumination/assets/materials/shadow/shadow_fp.glsl"
#include "/illumination/assets/materials/light_uniforms.glsl"
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
    vec3 lights_color = vec3(0);

    vec3 surface_normal = var_world_normal;
    vec3 view_direction = normalize(var_camera_position - var_world_position);

    // Ambient
    vec3 ambient = ambient_color.rgb * ambient_color.w;


    highp float xStride = screen_size.x/clusters_data.x;
    highp float yStride = screen_size.y/clusters_data.y;
    highp float zStride = (lights_camera_data.y-lights_camera_data.x)/clusters_data.z;


    int clusterX_index = int(floor(gl_FragCoord.x/ xStride));
    int clusterY_index = int(floor(gl_FragCoord.y/ yStride));
    int clusterZ_index = int(floor(-var_view_position.z) / zStride);



    int clusterID = clusterX_index +
    clusterY_index * int(clusters_data.x) +
    clusterZ_index * int(clusters_data.x) * int(clusters_data.y);

    highp int cluster_tex_idx = int(lights_data.x)*LIGHT_DATA_PIXELS + clusterID * (1+int(clusters_data.w));
    int num_lights = int(round(rgba_to_float(getData(cluster_tex_idx))*(clusters_data.w+1.0)));

    for (int i = 0; i < num_lights; ++i) {
        highp int light_tex_idx = cluster_tex_idx +1 + i;
        int lightIdx = int(round(rgba_to_float(getData(light_tex_idx))*(lights_data.x+1.0)));
        // lightIdx = i;
        // if (num_lights!= int(lights_data.x)){
        //   gl_FragColor = vec4(1.0,0.0,0.0, 1.0);
        //     return;
        //  }
        //if (lightIdx != i){
        //    break;
        // }
        //if (lightIdx>460){
        //  gl_FragColor = vec4(1,0,0,1);
        //return;
        //}

        highp int lightIndex = lightIdx * LIGHT_DATA_PIXELS;
        float x = DecodeRGBAToFloatPosition(getData(lightIndex));
        float y = DecodeRGBAToFloatPosition(getData(lightIndex+1));
        float z = DecodeRGBAToFloatPosition(getData(lightIndex+2));
        vec4 spotDirectionData = getData(lightIndex+3);
        vec4 lightColorData = getData(lightIndex+4);
        vec4 lightData = getData(lightIndex+5);


        vec3 lightPosition = vec3(x, y, z);
        float lightRadius = round(lightData.x*LIGHT_RADIUS_MAX)+spotDirectionData.w;//fractional and integer part in different pixels
        float lightSmoothness = lightData.y;
        float lightSpecular = lightData.z;
        float lightCutoff = lightData.w;


        float lightDistance = length(lightPosition - var_world_position);
        if (lightDistance > lightRadius) {
            // Skip this light source because of distance
            continue;
        }

        vec3 lightColor = lightColorData.rgb* lightColorData.a;
        vec3 lightDirection = normalize(lightPosition - var_world_position);
        vec3 lightIlluminanceColor = point_light2(lightColor.rgb, lightSmoothness, lightPosition, var_world_position, var_world_normal
        , lightSpecular, view_direction);



        /*if (lightCutoff < 1.0) {
            vec3 spotDirection = spotDirectionData.xyz* 2.0 - vec3(1.0);
            float spot_theta = dot(lightDirection, normalize(spotDirection));

            float spot_cutoff = lightCutoff * 2.0 - 1.0;

            if (spot_theta <= spot_cutoff) {
                continue;
            }

            if (lightSmoothness > 0.0) {
                float spot_cutoff_inner = (spot_cutoff + 1.0) * (1.0 - lightSmoothness) - 1.0;
                float spot_epsilon = spot_cutoff_inner - spot_cutoff;
                float spot_intensity = clamp((spot_cutoff - spot_theta) / spot_epsilon, 0.0, 1.0);

                lightIlluminanceColor = lightIlluminanceColor * spot_intensity;;
            }
        }*/

        lights_color = lights_color + lightIlluminanceColor;

        //
    }


    //REGION SHADOW -----------------
    // shadow map
    vec4 depth_proj = var_texcoord0_shadow / var_texcoord0_shadow.w;
    float shadow =  0.00001 * shadow_calculation(depth_proj.xyzw);
    vec3 shadow_color = shadow_color.xyz*shadow_color.w * shadow;

    vec3 resultColor = color.rgb * ambient; //Start with modulated ambient color

    // In your main function or wherever you calculate lighting
    vec3 viewPos = var_camera_position; // Assuming this is your view/camera position
    float shininess = 5.0; // Example shininess value
    float specularStrength = 0.7; // Example specular strength

    // Update your sunlight calculation to include the Phong specular component
    resultColor += color.rgb * max(direct_light(sunlight_color.rgb, sun_position.xyz, var_world_position.xyz, var_world_normal, shadow_color)*sunlight_color.w, 0.0);
    // resultColor += color.rgb * max(direct_light(sunlight_color.rgb, sun_position.xyz, var_world_position.xyz, var_world_normal, shadow_color)*sunlight_color.w, 0.0);
    //diff_light = (min(diff_light, 1.0));
    resultColor += vec3(lights_color.xyz);
    // gl_FragColor = vec4(diff_light.rgb, 1.0);


    gl_FragColor = vec4(resultColor, texture_color.a);

    //float colorz = floor(-var_view_position.z-camNear)/clusters_data.z;
    //gl_FragColor = vec4(float(clusterX_index)/clusters_data.x,float(clusterY_index)/clusters_data.y,float(clusterZ_index)/clusters_data.z, texture_color.a);
    //gl_FragColor = vec4(float(clusterZ_index)/clusters_data.z,float(clusterZ_index)/clusters_data.z,float(clusterZ_index)/clusters_data.z, texture_color.a);
    //gl_FragColor = vec4(clusterZ_index/10.0,color.g,color.b, texture_color.a);
}
