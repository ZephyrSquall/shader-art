#version 300 es

precision highp float;

uniform vec2 u_resolution;
uniform float u_time;
uniform sampler2D u_image0;
uniform sampler2D u_image1;

out vec4 outColor;

vec4 composite(vec4 color1, vec4 color2) {
    if (color1.a < 0.00000000001 && color2.a < 0.000000000001) {
        return color1;
    }
    float alpha = color1.a + color2.a * (1.0 - color1.a);
    return vec4((color1.rgb * color1.a + color2.rgb * color2.a * (1.0 - color1.a)) / alpha, alpha);
}

void main() {
    vec2 image_uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 uv = image_uv * 2.0 - 1.0;
    image_uv.y = 1.0 - image_uv.y;

    vec4 color = composite(texture(u_image0, image_uv * 4.0) + vec4(0.5, 0.5, 0.5, 0.0), vec4(uv.x, uv.y, sin(u_time), 1.0));
    color = composite(texture(u_image1, image_uv) + vec4(0.5, 0.5, 0.5, 0.0), color);
    outColor = color;
}