varying mediump vec2 var_texcoord0;
varying lowp vec4 var_color;

uniform lowp sampler2D texture_sampler;

void main()
{
    lowp vec4 tex = texture2D(texture_sampler, var_texcoord0.xy);
    // Calculate the luminance of the texture color
    float luminance = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    // Create a grayscale color by setting the RGB components to the luminance
    lowp vec4 grayscaleColor = vec4(luminance, luminance, luminance, tex.a);
    // Apply the original color's alpha (if needed) and multiply by var_color
    gl_FragColor = grayscaleColor * var_color;
}
