varying mediump vec2 var_texcoord0; // The UV coordinate passed from the vertex shader
varying lowp vec4 var_color; // The color passed from the vertex shader

uniform lowp sampler2D texture_sampler; // The texture sampler

// Function to draw a circle with a smooth edge
// uv - UV coordinate, pos - circle center position, radius - circle radius, feather - edge softness
float circle(vec2 uv, vec2 pos, float radius, float feather) {
    vec2 uvDist = uv - pos;
    return 1.0 - smoothstep(radius - feather, radius + feather, length(uvDist));
}

void main() {
    // Color for the circle, replace with your desired color
    vec3 circleColor = var_color.rgb; // Example: orange color

    // Adjust these parameters as needed
    vec2 circlePos = vec2(0.5, 0.5); // Circle position in UV coordinates
    float circleRadius = 0.5; // Circle radius
    float circleFeather = 0.0075; // Edge softness

    // Drawing the circle
    float alpha = circle(var_texcoord0, circlePos, circleRadius, circleFeather);

    // Setting the color with smoothed edges
    gl_FragColor = vec4(circleColor * alpha, alpha);
}
