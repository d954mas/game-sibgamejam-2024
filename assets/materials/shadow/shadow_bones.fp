uniform lowp sampler2D DIFFUSE_TEXTURE;


varying mediump vec2 var_texcoord0;

varying highp vec3 var_world_position;
varying mediump vec3 var_world_normal;
varying highp vec3 var_camera_position;
varying highp vec3 var_view_position;

#include "/illumination/assets/materials/shadow/shadow_fp.glsl"
#include "/illumination/assets/materials/light_uniforms.glsl"

//for animation
uniform highp sampler2D tex_anim;







void main() {
    //do not remove or shader remove textures
    vec4 texture_color = texture2D(DIFFUSE_TEXTURE, var_texcoord0) + texture2D(SHADOW_TEXTURE, var_texcoord0_shadow.xy) +
    + texture2D(DATA_TEXTURE, var_texcoord0_shadow.xy)+texture2D(tex_anim, vec2(0.0))+vec4(1.0);


    gl_FragColor = float_to_rgba(gl_FragCoord.z) * (min(1.0, texture_color.r));
}
