#version 300 es

precision highp float;

uniform vec2        u_resolution;
uniform float       u_time;

uniform sampler2D   u_tex0;
uniform vec2        u_tex0Resolution;

uniform sampler2D   u_tex1;
uniform vec2        u_tex1Resolution;

uniform sampler2D   u_tex2;
uniform vec2        u_tex2Resolution;

uniform sampler2D   u_tex3;
uniform vec2        u_tex3Resolution;

out vec4 outColor;

#define PI 3.1415926535897932384626433832795

vec4 composite(vec4 color1, vec4 color2) {
    return vec4(color1.rgb * color1.a + color2.rgb * color2.a * (1.0 - color1.a), color1.a + color2.a * (1.0 - color1.a));
}
vec4 mask(vec4 color, float alpha) {
    return vec4(color.rgb, color.a * alpha);
}
float random(in float x) {
    return fract(sin(x) * 43758.5453);
}

vec3 mod289(const in vec3 x) { return x - floor(x * (1. / 289.)) * 289.; }
vec4 mod289(const in vec4 x) { return x - floor(x * (1. / 289.)) * 289.; }
vec4 permute(const in vec4 v) { return mod289(((v * 34.0) + 1.0) * v); }
vec4 taylorInvSqrt(in vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }
vec3  quintic(const in vec3 v)  { return v*v*v*(v*(v*6.0-15.0)+10.0); }

float pnoise(in vec3 P, in vec3 rep) {
    vec3 Pi0 = mod(floor(P), rep); // Integer part, modulo period
    vec3 Pi1 = mod(Pi0 + vec3(1.0), rep); // Integer part + 1, mod period
    Pi0 = mod289(Pi0);
    Pi1 = mod289(Pi1);
    vec3 Pf0 = fract(P); // Fractional part for interpolation
    vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
    vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    vec4 iy = vec4(Pi0.yy, Pi1.yy);
    vec4 iz0 = Pi0.zzzz;
    vec4 iz1 = Pi1.zzzz;

    vec4 ixy = permute(permute(ix) + iy);
    vec4 ixy0 = permute(ixy + iz0);
    vec4 ixy1 = permute(ixy + iz1);

    vec4 gx0 = ixy0 * (1.0 / 7.0);
    vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
    gx0 = fract(gx0);
    vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
    vec4 sz0 = step(gz0, vec4(0.0));
    gx0 -= sz0 * (step(0.0, gx0) - 0.5);
    gy0 -= sz0 * (step(0.0, gy0) - 0.5);

    vec4 gx1 = ixy1 * (1.0 / 7.0);
    vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
    gx1 = fract(gx1);
    vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
    vec4 sz1 = step(gz1, vec4(0.0));
    gx1 -= sz1 * (step(0.0, gx1) - 0.5);
    gy1 -= sz1 * (step(0.0, gy1) - 0.5);

    vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
    vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
    vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
    vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
    vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
    vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
    vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
    vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

    vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;
    vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;

    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
    float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
    float n111 = dot(g111, Pf1);

    vec3 fade_xyz = quintic(Pf0);
    vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
    vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
    return 2.2 * n_xyz;
}
float cnoise(in vec3 P) {
    vec3 Pi0 = floor(P); // Integer part for indexing
    vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
    Pi0 = mod289(Pi0);
    Pi1 = mod289(Pi1);
    vec3 Pf0 = fract(P); // Fractional part for interpolation
    vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
    vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    vec4 iy = vec4(Pi0.yy, Pi1.yy);
    vec4 iz0 = Pi0.zzzz;
    vec4 iz1 = Pi1.zzzz;

    vec4 ixy = permute(permute(ix) + iy);
    vec4 ixy0 = permute(ixy + iz0);
    vec4 ixy1 = permute(ixy + iz1);

    vec4 gx0 = ixy0 * (1.0 / 7.0);
    vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
    gx0 = fract(gx0);
    vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
    vec4 sz0 = step(gz0, vec4(0.0));
    gx0 -= sz0 * (step(0.0, gx0) - 0.5);
    gy0 -= sz0 * (step(0.0, gy0) - 0.5);

    vec4 gx1 = ixy1 * (1.0 / 7.0);
    vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
    gx1 = fract(gx1);
    vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
    vec4 sz1 = step(gz1, vec4(0.0));
    gx1 -= sz1 * (step(0.0, gx1) - 0.5);
    gy1 -= sz1 * (step(0.0, gy1) - 0.5);

    vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
    vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
    vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
    vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
    vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
    vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
    vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
    vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

    vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;
    vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;

    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
    float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
    float n111 = dot(g111, Pf1);

    vec3 fade_xyz = quintic(Pf0);
    vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
    vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
    return 2.2 * n_xyz;
}

vec4 moon_spot(vec2 position, float size, vec2 moon_uv, vec4 prev_color, float angle) {
    position.y += 0.01;

    position = vec2(
        position.y * sin(angle) + position.x * cos(angle),
        position.y * cos(angle) - position.x * sin(angle)
    );

    vec4 color = prev_color;
    
    if (distance(moon_uv, position) < size) {
        color = composite(vec4(0.89, 0.89, 0.89, 1.0), color);
    }

    return color;
}

void main (void) {
    vec2 image_uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 uv = image_uv * 2.0 - 1.0;

    float time = mod(u_time * 1.0, 15.0) - 7.5;
    float angle = 0.12 * (time - 0.9 * tanh(time));
    float eclipse_time = smoothstep(0.2, 0.0, abs(angle));

    vec2 sun_position = vec2(0.0, 0.83);
    float sun_radius = 0.11;
    float max_ray_length = 0.05 + eclipse_time * 0.05;
    vec2 sun_uv = uv - sun_position;

    vec4 normal_sky_color = mix(vec4(0.72, 0.9, 0.95, 1.0), vec4(0.1, 0.44, 0.85, 1.0), image_uv.y);
    vec4 eclipse_sky_color = mix(vec4(1.0, 0.5, 0.0, 1.0), vec4(0.02, 0.01, 0.0, 1.0), min(1.0, distance(uv, sun_position) * 3.0));

    vec4 color = mix(normal_sky_color, eclipse_sky_color, eclipse_time);

    vec4 sun_color = mix(vec4(1.0, 1.0, 0.9, 1.0), vec4(0.97, 0.56, 0.05, 1.0), eclipse_time);

    if (distance(uv, sun_position) < sun_radius) {
        color = sun_color;
    } else {
        vec2 sun_edge = normalize(sun_uv) * sun_radius;
        float ray_length = (cnoise(vec3(sun_edge + sun_position, u_time * 0.001) * 500.0) * 0.5 + 0.4) * max_ray_length;

        if (length(sun_uv) < ray_length + sun_radius) {
            color = sun_color;
        }
    }

    vec2 moon_uv = uv;
    moon_uv /= sun_position.y;
    float moon_orbit_scale = 2.0;
    moon_uv /= moon_orbit_scale;
    moon_uv.y -= 1.0 / moon_orbit_scale - 1.0;

    // Angle 0 is (0, 1), rotate clockwise around origin by angle.
    vec2 moon_position = vec2(
        sin(angle),
        cos(angle)
    );

    vec4 moon_color = vec4(0.0);
    if (distance(moon_uv, moon_position) < sun_radius / (sun_position.y * moon_orbit_scale)) {
        vec4 base_moon_color = vec4(1.0);
        base_moon_color = composite(moon_spot(vec2(0.005, 1.005), 0.01, moon_uv, base_moon_color, angle), base_moon_color);
        base_moon_color = composite(moon_spot(vec2(0.0, 1.03), 0.01, moon_uv, base_moon_color, angle), base_moon_color);
        base_moon_color = composite(moon_spot(vec2(-0.03, 1.025), 0.01, moon_uv, base_moon_color, angle), base_moon_color);
        base_moon_color = composite(moon_spot(vec2(-0.025, 0.99), 0.015, moon_uv, base_moon_color, angle), base_moon_color);
        base_moon_color = composite(moon_spot(vec2(0.03, 1.02), 0.01, moon_uv, base_moon_color, angle), base_moon_color);
        base_moon_color = composite(moon_spot(vec2(0.0, 0.97), 0.01, moon_uv, base_moon_color, angle), base_moon_color);
        base_moon_color = composite(moon_spot(vec2(-0.04, 0.96), 0.01, moon_uv, base_moon_color, angle), base_moon_color);
        base_moon_color = composite(moon_spot(vec2(-0.055, 0.98), 0.01, moon_uv, base_moon_color, angle), base_moon_color);
        base_moon_color = composite(moon_spot(vec2(-0.05, 1.005), 0.01, moon_uv, base_moon_color, angle), base_moon_color);

        moon_color = mix(base_moon_color, vec4(0.0, 0.0, 0.0, 1.0), eclipse_time);
    }
    color = composite(moon_color, color);

    image_uv.y /= 0.9;
    
    if (image_uv.x > 0.0 && image_uv.x < 1.0 && image_uv.y < 1.0) {
        vec4 darken_color = texture(u_tex0, image_uv);
        vec4 static_color = texture(u_tex1, image_uv);
        vec4 glow_color = texture(u_tex2, image_uv);

        darken_color.rgb *= 1.0 - eclipse_time * 0.8;
        glow_color = mask(glow_color, eclipse_time);

        color = composite(darken_color, color);
        color = composite(static_color, color);
        color = composite(glow_color, color);
    }

    vec2 watermark_uv = gl_FragCoord.xy / u_resolution.xy * 8.0;
    watermark_uv.x = watermark_uv.x * 0.37;
    vec4 watermark_color = texture(u_tex3, watermark_uv);
    if (watermark_uv.x > 1.0 || watermark_uv.y > 1.0) {
        watermark_color = vec4(0);
    }
    watermark_color = mask(vec4(1.0,1.0,1.0,1.0), watermark_color.a * 0.06);
    color = composite (watermark_color, color);

    outColor = color;
}
