varying mediump vec2 var_texcoord0;
varying lowp vec4 var_color;

uniform lowp sampler2D texture_sampler;
uniform lowp sampler2D rt_target;

void main()
{
    lowp vec4 tex0 = texture2D(texture_sampler, var_texcoord0.xy);
    lowp vec4 tex1 = texture2D(rt_target, var_texcoord0.xy);
    //not worked texture_sampler will be discard
    //rt_target now is texture 0. Shoud be texture 1
    //gl_FragColor = tex1;

    //use texture_sampler so texture index not changed.
    gl_FragColor = tex0 * 0.0001 + tex1;
}
