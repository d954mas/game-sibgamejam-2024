uniform mediump sampler2D DIFFUSE_TEXTURE;

varying mediump vec2 var_texcoord0;
varying highp vec3 var_world_position;
varying mediump vec3 var_world_normal;
varying highp vec3 var_view_position;
varying highp vec3 var_camera_position;
uniform lowp vec4 tint;
uniform highp vec4 arrow;

const float fade_ratio = 0.75;
void main() {
    vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    float u = var_texcoord0.x * arrow.x;
    float v = var_texcoord0.y * arrow.y;
    vec4 texture_color = texture2D(DIFFUSE_TEXTURE, vec2(u,v)+vec2(arrow.z, arrow.w))* tint_pm;
    vec3 color = texture_color.rgb;


    float fade_length = fade_ratio/arrow.y;  // Fade length is a fraction of the arrow's current length
    float fade_in = smoothstep(0.0, 1.0, var_texcoord0.y/fade_length);
    float fade_out = smoothstep(0.0, 1.0, (1.0 - var_texcoord0.y)/fade_length);
    float alpha = texture_color.a * fade_in* fade_out;

    gl_FragColor = vec4(color*alpha, alpha);
}
