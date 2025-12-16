#version 300 es

precision highp float;

uniform vec2 u_resolution;
uniform float u_time;

out vec4 outColor;

void main() {
    vec2 image_uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 uv = image_uv * 2.0 - 1.0;

    vec4 color = vec4(uv.x, uv.y, sin(u_time), 1.0);
    outColor = color;
}