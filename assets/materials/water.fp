uniform highp sampler2D DIFFUSE_TEXTURE;

varying highp vec2 var_texcoord0;
varying highp vec3 var_world_position;
varying mediump vec3 var_world_normal;
varying highp vec3 var_camera_position;
varying highp vec3 var_view_position;

#include "/illumination/assets/materials/shadow/shadow_fp.glsl"
#include "/illumination/assets/materials/light_uniforms.glsl"

uniform highp vec4 time;

// Enhanced Random function using highp precision for dithering
float randDither(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9918, 78.233))) * 43758.5453123);
}

// Simple hash function
float hash(float n) {
    return fract(sin(n) * 1e4);
}

// Random function for star position
float randStars(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    highp vec2 uvPos = var_texcoord0;
    uvPos *= 1.1; // No tiling
    //uvPos.x += time.x * 0.025; // Adding motion along the y-axis
    //uvPos.y += time.x * 0.025; // Adding motion along the y-axis
   // uvPos.z += time.x * 0.025; // Adding motion along the y-axis

    vec4 textureColor = texture2D(DIFFUSE_TEXTURE, uvPos);

    // Calculate a gradient factor based on the y-coordinate
    float gradient = (var_world_position.y + 25.0) / 50.0;
    gradient = clamp(gradient, 0.0, 1.0);
    gradient = smoothstep(0.0, 1.0, gradient);
    // Apply dithering to gradient
    float dither = randDither(uvPos + time.x);
    gradient = mix(gradient, gradient + 0.1 * (dither - 0.5), 0.5);  // Adjust 0.05 for less/more dithering

    vec3 mixedColor = mix(textureColor.rgb, textureColor.rgb*0.2, gradient);

    gl_FragColor = vec4(mixedColor.rgb, 1.0);
}
