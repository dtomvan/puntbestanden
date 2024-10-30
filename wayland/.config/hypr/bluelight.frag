// blue light filter shader
// ~~values from https://reshade.me/forum/shader-discussion/3673-blue-light-filter-similar-to-f-lux~~
// values from -> the color F3A888

precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {

    vec4 pixColor = texture2D(tex, v_texcoord);

    // red
    // pixColor[1] *= 1;
    pixColor[1] *= 0.953;

    // green
    // pixColor[1] *= 0.855;
    pixColor[1] *= 0.659;

    // blue
    // pixColor[2] *= 0.725;
    pixColor[2] *= 0.533;

    gl_FragColor = pixColor;
}
