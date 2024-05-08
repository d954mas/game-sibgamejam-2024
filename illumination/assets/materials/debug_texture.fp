varying mediump vec3 model_normal;
varying mediump vec2 texture_coord;

uniform lowp sampler2D DIFFUSE_TEXTURE;

void main() {
    vec4 color = texture2D(DIFFUSE_TEXTURE, texture_coord.xy);
    gl_FragColor = vec4(color.rgb,1.0);
}