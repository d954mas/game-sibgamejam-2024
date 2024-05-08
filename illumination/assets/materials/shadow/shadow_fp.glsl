#ifndef shadow_fp
#define shadow_fp

#include "/assets/materials/includes/float_rgba_utils.glsl"

uniform lowp vec4 shadow_params;//x is texture size y depth_bias
uniform lowp vec4 shadow_color;
uniform highp vec4 sun_position;//sun light position
uniform highp sampler2D SHADOW_TEXTURE;

varying highp vec4 var_texcoord0_shadow;

vec2 rand(vec2 co){
    return vec2(fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453),
    fract(sin(dot(co.yx, vec2(12.9898, 78.233))) * 43758.5453)) * 0.00047;
}
//mobile
float shadow_calculation(highp vec4 depth_data){
    highp vec2 uv = depth_data.xy;
    // vec4 rgba = texture2D(SHADOW_TEXTURE, uv + rand(uv));
    highp vec4 rgba = texture2D(SHADOW_TEXTURE, uv);
    float depth = rgba_to_float(rgba);
    //float depth = rgba.x;
    //float shadow = depth_data.z - shadow_params. > depth ? 1.0 : 0.0;
    //float shadow = step(depth,depth_data.z-shadow_params.);
    float shadow = 1.0 - step(depth_data.z-shadow_params.y, depth);

    if (uv.x<0.0 || uv.x>1.0 || uv.y<0.0 || uv.y>1.0) shadow = 0.0;

    return shadow;
}

float shadow_calculation_with_added_normal_bias_old(highp vec4 depth_data, vec3 normal, vec3 position){
    highp vec2 uv = depth_data.xy;
    highp vec4 rgba = texture2D(SHADOW_TEXTURE, uv);
    float depth = rgba_to_float(rgba);

    // Calculate the light direction
    vec3 lightDirection = normalize(sun_position.xyz - position);

    // Calculate additional normal bias based on the angle between the surface normal and the light direction
    // This bias is added to the minimum depth bias (shadow_params.y = 0.01)
    float normalBias = 0.025 * (1.0 - dot(normal, lightDirection));

    // Apply the minimum depth bias and add the calculated normal bias to the depth comparison
    float shadow = 1.0 - step(depth_data.z - (shadow_params.y + normalBias), depth);

    // Boundary check for UV coordinates
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) shadow = 0.0;

    return shadow;
}

float shadow_calculation_with_added_normal_bias(highp vec4 depth_data, vec3 normal, vec3 position){
    highp vec2 uv = depth_data.xy;
    vec3 lightDirection = normalize(sun_position.xyz - position);
    float normalBias = 0.025 * (1.0 - dot(normal, lightDirection));

    // Calculate texel size based on shadow map resolution provided by shadow_params.x
    float texel_size = 1.0 / shadow_params.x;

    float shadow = 0.0;
    int samples = 0;

    // Iterate from -0.5 to 0.5 in both x and y directions
    for(float offsetX = -0.5; offsetX <= 0.5; offsetX += 1.0) {
        for(float offsetY = -0.5; offsetY <= 0.5; offsetY += 1.0) {
            highp vec2 sampleUV = uv + vec2(offsetX, offsetY) * texel_size;
            highp vec4 sampleRGBA = texture2D(SHADOW_TEXTURE, sampleUV);
            float sampleDepth = rgba_to_float(sampleRGBA);
            // Apply the minimum depth bias and add the calculated normal bias to each sampled depth
            shadow += 1.0 - step(depth_data.z - (shadow_params.y + normalBias), sampleDepth);
            samples++;
        }
    }
    shadow /= float(samples); // Average the shadow contributions

    // Boundary check for UV coordinates
    if(uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) shadow = 0.0;

    return shadow;
}

/*
float shadow_calculation_with_added_normal_bias_soft(highp vec4 depth_data, vec3 normal, vec3 position) {
    float shadow = 0.0;
    float texel_size = 1.0 / shadow_params.x;// textureSize(tex1, 0);
    vec3 lightDirection = normalize(sun_position.xyz - position);
    float normalBias = 0.025 * (1.0 - dot(normal, lightDirection));

    for (int x = -1; x <= 1; ++x) {
        for (int y = -1; y <= 1; ++y) {
            highp vec2 uv = depth_data.st + vec2(x, y) * texel_size;
            vec4 rgba = texture2D(SHADOW_TEXTURE, uv);
            float depth = rgba_to_float(rgba);

            // Here we apply the minimum depth bias (shadow_params.y) and add the calculated normal bias
            shadow += (depth_data.z - (shadow_params.y + normalBias)) > depth ? 1.0 : 0.0;
        }
    }
    shadow /= 9.0;

    // Boundary check for UV coordinates
    highp vec2 uv = depth_data.xy;
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) shadow = 0.0;

    return shadow;
}


//soft
float shadow_calculation_soft(highp vec4 depth_data){
    float shadow = 0.0;
    float texel_size = 1.0 / shadow_params.x;//textureSize(tex1, 0);
    for (int x = -1; x <= 1; ++x)
    {
        for (int y = -1; y <= 1; ++y)
        {
            highp vec2 uv = depth_data.st + vec2(x, y) * texel_size;
            //vec4 rgba = texture2D(SHADOW_TEXTURE, uv + rand(uv));
            vec4 rgba = texture2D(SHADOW_TEXTURE, uv);
            float depth = rgba_to_float(rgba);

            shadow += depth_data.z - shadow_params.y > depth ? 1.0 : 0.0;
        }
    }
    shadow /= 9.0;

    highp vec2 uv = depth_data.xy;
    if (uv.x<0.0) shadow = 0.0;
    if (uv.x>1.0) shadow = 0.0;
    if (uv.y<0.0) shadow = 0.0;
    if (uv.y>1.0) shadow = 0.0;

    return shadow;
}*/

// SUN! DIRECT LIGHT
vec3 direct_light(vec3 light_color, vec3 light_position, vec3 position, vec3 vnormal, vec3 shadow_color){
    vec3 lightDir = normalize(light_position - position);
    float n = max(dot(vnormal, lightDir), 0.0);
    vec3 diffuse = (light_color - shadow_color) * n;
    return diffuse;
}

// SUN! DIRECT LIGHT with Phong Shading Model
vec3 direct_light_phong(vec4 light_color, vec3 light_position, vec3 position, vec3 normal, vec3 shadow_color, vec3 viewPos, float shininess, float specularStrength) {
    vec3 lightDir = normalize(light_position - position);
    vec3 viewDir = normalize(viewPos - position);
    vec3 reflectDir = reflect(-lightDir, normal);

    // Diffuse component
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = (light_color.rgb - shadow_color) * diff * light_color.w;

    // Specular component
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), shininess);
    vec3 specular = specularStrength * spec * light_color.rgb;

    return diffuse + specular;
}


#endif