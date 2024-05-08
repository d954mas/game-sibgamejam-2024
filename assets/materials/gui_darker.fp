varying mediump vec2 var_texcoord0;
varying lowp vec4 var_color;

uniform lowp sampler2D texture_sampler;
// Uniform to control how much to darken the colors
float darken_factor = 0.3;

void main()
{
    lowp vec4 tex = texture2D(texture_sampler, var_texcoord0.xy);
    // Apply the darken factor to each color channel to make them darker
    lowp vec4 darkerColor = vec4(tex.rgb * darken_factor, tex.a);

    // Apply the original color's alpha (if needed) and multiply by var_color
    gl_FragColor = darkerColor * var_color;
}
