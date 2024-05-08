uniform lowp sampler2D DIFFUSE_TEXTURE;

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

    gl_FragColor = vec4(color, texture_color.a);

}