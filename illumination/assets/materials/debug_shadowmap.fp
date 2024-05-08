varying mediump vec3 model_normal;
varying mediump vec2 texture_coord;

uniform lowp sampler2D DIFFUSE_TEXTURE;

#include "/assets/materials/includes/float_rgba_utils.glsl"

void main() {
    vec4 rgba = texture2D(DIFFUSE_TEXTURE, texture_coord.xy);
    float depth = rgba_to_float(rgba);

    gl_FragColor = vec4(depth,depth,depth,1.0);
}