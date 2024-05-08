#include "/assets/materials/includes/float_rgba_utils.glsl"

void main() {
    gl_FragColor = float_to_rgba(gl_FragCoord.z);
}
