varying lowp vec2 var_texcoord0;
varying lowp vec4 var_face_color;
varying lowp vec4 var_outline_color;
varying lowp vec4 var_shadow_color;
varying lowp vec4 var_sdf_params;
varying lowp vec4 var_layer_mask;

uniform mediump sampler2D texture_sampler;

void main()
{
    lowp float distance = texture2D(texture_sampler, var_texcoord0).x;

    lowp float sdf_edge = var_sdf_params.x;
    lowp float sdf_outline = var_sdf_params.y;
    lowp float sdf_smoothing = var_sdf_params.z/300.0;

    lowp float alpha = smoothstep(sdf_edge - sdf_smoothing, sdf_edge + sdf_smoothing, distance);
    lowp float outline_alpha = smoothstep(sdf_outline - sdf_smoothing, sdf_outline + sdf_smoothing, distance);
    lowp vec4 color = mix(var_outline_color, var_face_color, alpha);

    gl_FragColor = color * outline_alpha;
}
