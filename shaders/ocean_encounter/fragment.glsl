#version 300 es

precision highp float;

#ifndef RANDOM_SCALE
#ifdef RANDOM_HIGHER_RANGE
#define RANDOM_SCALE vec4(.1031, .1030, .0973, .1099)
#else
#define RANDOM_SCALE vec4(443.897, 441.423, .0973, .1099)
#endif
#endif

#define PI 3.1415926535897932384626433832795

uniform sampler2D   u_tex0;
uniform vec2        u_tex0Resolution;
uniform sampler2D   u_tex1;
uniform vec2        u_tex1Resolution;

uniform vec2 u_resolution;
uniform float u_time;

out vec4 outColor;

vec4 mod289(const in vec4 x) { return x - floor(x * (1. / 289.)) * 289.; }
vec4 permute(const in vec4 v) { return mod289(((v * 34.0) + 1.0) * v); }
vec4 taylorInvSqrt(in vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }
vec2  quintic(const in vec2 v)  { return v*v*v*(v*(v*6.0-15.0)+10.0); }

float cnoise(in vec2 P) {
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod289(Pi); // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;

    vec4 i = permute(permute(ix) + iy);

    vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
    vec4 gy = abs(gx) - 0.5 ;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;

    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);

    vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;

    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));

    vec2 fade_xy = quintic(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}

float random(in float x) {
    return fract(sin(x) * 43758.5453);
}
vec2 random2(vec2 p) {
    vec3 p3 = fract(p.xyx * RANDOM_SCALE.xyz);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.xx + p3.yz) * p3.zy);
}

float voroni(vec2 uv, float scale) {
    vec2 scaled_uv = uv * scale;

    int tile_x = int(floor(scaled_uv.x));
    int tile_y = int(floor(scaled_uv.y));
    vec2 tile_fractional = fract(scaled_uv);

    float smallest_dist = 10000000.0;
    float second_smallest_dist = 9999999.0;
    vec2 closest_point = vec2(0.0, 0.0);
    vec2 second_closest_point = vec2(0.0, 0.0);

    for (int tile_y_offset = -1; tile_y_offset <= 1; tile_y_offset++) {
        for (int tile_x_offset = -1; tile_x_offset <= 1; tile_x_offset++) {
            int loop_tile_y = tile_y + tile_y_offset;
            int loop_tile_x = tile_x + tile_x_offset;

            vec2 other_point = random2(vec2(loop_tile_x, loop_tile_y)) + vec2(tile_x_offset, tile_y_offset);
            float dist = distance(tile_fractional, other_point);

            if (dist <= smallest_dist) {
                second_smallest_dist = smallest_dist;
                smallest_dist = dist;
                second_closest_point = closest_point;
                closest_point = other_point;
            } else if (dist < second_smallest_dist) {
                second_smallest_dist = dist;
                second_closest_point = other_point;
            }
        }
    }

    vec2 midpoint = (closest_point + second_closest_point) / 2.0;
    float midline_angle = atan((second_closest_point.x - closest_point.x) / (closest_point.y - second_closest_point.y));
    float distance_to_midline = abs(cos(midline_angle) * (midpoint.y - tile_fractional.y) - sin(midline_angle) * (midpoint.x - tile_fractional.x));

    float value = 1.0 - distance_to_midline;

    value = smoothstep(0.95, 1.0, value);

    return value;
}

vec4 composite(vec4 color1, vec4 color2) {
    return vec4(color1.rgb * color1.a + color2.rgb * color2.a * (1.0 - color1.a), color1.a + color2.a * (1.0 - color1.a));
}

vec4 mask(vec4 color, float alpha) {
    return vec4(color.rgb, color.a * alpha);
}

void main()
{
    vec2 uv = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;

    vec2 sun_position = vec2(0.65, 0.75);

    vec4 color;

    if (uv.y < 0.3) {
        // Apply perspective
        vec2 perspective_uv = uv;
        perspective_uv.y = 2.0 / ((uv.y + 0.05) - 0.55);
        perspective_uv.x *= perspective_uv.y * 0.7;

        // Move waves slowly
        perspective_uv.x += u_time * 0.1;
        perspective_uv.y += u_time * 0.1;

        // Apply distortion
        perspective_uv.x += sin((perspective_uv.y + u_time * 0.1) * 15.0) * 0.025;
        perspective_uv.y += cos((perspective_uv.x + u_time * 0.1) * 15.0) * 0.025;

        float voroni = voroni(perspective_uv, 2.0);
        voroni *= smoothstep(0.35, -0.1, uv.y);

        color = vec4(voroni, voroni, 1.0, 1.0);

        vec2 reflection_uv = vec2(uv.x - sun_position.x, uv.y);
        reflection_uv.y = 2.0 / ((reflection_uv.y + 0.05) - 0.55);
        reflection_uv.x *= reflection_uv.y * 0.7;

        float reflection_mask = smoothstep(-1.2, -0.3, reflection_uv.x) - smoothstep(0.3, 1.2, reflection_uv.x);

        #define REF_SCALE 0.3

        float noise = REF_SCALE * sin(reflection_uv.y * 10.0 + cos(u_time)) + REF_SCALE * cos(reflection_uv.y * 10.0 + sin(u_time * 0.9))
        + REF_SCALE * sin(reflection_uv.x * 20.0 + cos(u_time * 1.1)) + REF_SCALE * cos(reflection_uv.x * 20.0 + sin(u_time))
        + (0.5 * cos(reflection_uv.y * 30.0) + 1.0)
        + REF_SCALE * sin((reflection_uv.x + reflection_uv.y) * 20.0)
        - REF_SCALE * cos(16.0 * reflection_uv.y - 32.0 * (reflection_uv.x + cos(u_time * 0.2)))
        - REF_SCALE * sin(reflection_uv.y * 2.0 + reflection_uv.x * 3.0 + u_time);
        - REF_SCALE * sin(reflection_uv.y * 4.0 + reflection_uv.x - 3.0 + u_time + 5.0);
        vec4 reflection_color = vec4(vec3(noise), clamp(noise, 0.0, 1.0));
        reflection_color = mask(reflection_color, reflection_mask);
        color = composite(reflection_color, color);
    } else {
        vec4 sky_color = mix(vec4(0.8, 0.89, 0.98, 1.0), vec4(0.4, 0.7, 0.9, 1.0), (uv.y / 0.7) - 0.3 / 0.7);
        float sun_brightness = smoothstep(1.0, 0.6, 5.0 * distance(uv, sun_position));
        vec4 sun_color = vec4(1.0, 1.0, 0.9, sun_brightness);
        color = composite(sun_color, sky_color);
    }

    vec2 image_uv = gl_FragCoord.xy / u_resolution.xy * 1.06;
    image_uv.x += 0.1;
    vec4 image_color = texture(u_tex0, image_uv);
    if (image_uv.x > 1.0 || image_uv.y > 1.0) {
        image_color = vec4(0);
    }
    color = composite (image_color, color);

    float ray_brightness = smoothstep(0.7, 1.0, sin(u_time * 2.0 + atan(uv.y - sun_position.y, uv.x - sun_position.x) * 6.0));
    vec4 ray_color = vec4(1.0, 1.0, 0.9, ray_brightness);
    float ray_mask = smoothstep(1.0, 0.0, distance(uv, sun_position));
    ray_color = mask(ray_color, ray_mask);
    color = composite (ray_color, color);

    vec2 watermark_uv = gl_FragCoord.xy / u_resolution.xy * 9.0;
    watermark_uv.x = watermark_uv.x * 0.37;
    vec4 watermark_color = texture(u_tex1, watermark_uv);
    if (watermark_uv.x > 1.0 || watermark_uv.y > 1.0) {
        watermark_color = vec4(0);
    }
    watermark_color = mask(watermark_color, 0.15);
    color = composite (watermark_color, color);

    outColor = color;
}
