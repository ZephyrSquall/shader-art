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

uniform sampler2D   u_tex4;
uniform vec2        u_tex4Resolution;

out vec4 outColor;

#define PI 3.1415926535897932384626433832795

vec4 composite(vec4 color1, vec4 color2) {
    if (color2.a > 0.0) {
        return vec4(color1.rgb * color1.a + color2.rgb * color2.a * (1.0 - color1.a), color1.a + color2.a * (1.0 - color1.a));
    } else {
        return color1;
    }
}
vec4 mask(vec4 color, float alpha) { return vec4(color.rgb, color.a * alpha); }
float merge_masks(float alpha1, float alpha2) { return alpha1 + alpha2 * (1.0 - alpha1); }
vec3 merge_masks(vec3 alpha1, vec3 alpha2) { return alpha1 + alpha2 * (1.0 - alpha1); }
#ifndef RANDOM_SCALE
#ifdef RANDOM_HIGHER_RANGE
#define RANDOM_SCALE vec4(.1031, .1030, .0973, .1099)
#else
#define RANDOM_SCALE vec4(443.897, 441.423, .0973, .1099)
#endif
#endif

#ifndef FNC_RANDOM
#define FNC_RANDOM
float random(in float x) {
#ifdef RANDOM_SINLESS
    x = fract(x * RANDOM_SCALE.x);
    x *= x + 33.33;
    x *= x + x;
    return fract(x);
#else
    return fract(sin(x) * 43758.5453);
#endif
}
float random(in vec2 st) {
#ifdef RANDOM_SINLESS
    vec3 p3  = fract(vec3(st.xyx) * RANDOM_SCALE.xyz);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
#else
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453);
#endif
}
float random(in vec3 pos) {
#ifdef RANDOM_SINLESS
    pos  = fract(pos * RANDOM_SCALE.xyz);
    pos += dot(pos, pos.zyx + 31.32);
    return fract((pos.x + pos.y) * pos.z);
#else
    return fract(sin(dot(pos.xyz, vec3(70.9898, 78.233, 32.4355))) * 43758.5453123);
#endif
}
float random(in vec4 pos) {
#ifdef RANDOM_SINLESS
    pos = fract(pos * RANDOM_SCALE);
    pos += dot(pos, pos.wzxy + 33.33);
    return fract((pos.x + pos.y) * (pos.z + pos.w));
#else
    float dot_product = dot(pos, vec4(12.9898,78.233,45.164,94.673));
    return fract(sin(dot_product) * 43758.5453);
#endif
}
vec2 random2(float p) {
    vec3 p3 = fract(vec3(p) * RANDOM_SCALE.xyz);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.xx + p3.yz) * p3.zy);
}
vec2 random2(vec2 p) {
    vec3 p3 = fract(p.xyx * RANDOM_SCALE.xyz);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.xx + p3.yz) * p3.zy);
}
vec2 random2(vec3 p3) {
    p3 = fract(p3 * RANDOM_SCALE.xyz);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.xx + p3.yz) * p3.zy);
}
vec3 random3(float p) {
    vec3 p3 = fract(vec3(p) * RANDOM_SCALE.xyz);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.xxy + p3.yzz) * p3.zyx); 
}
vec3 random3(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * RANDOM_SCALE.xyz);
    p3 += dot(p3, p3.yxz + 19.19);
    return fract((p3.xxy + p3.yzz) * p3.zyx);
}
vec3 random3(vec3 p) {
    p = fract(p * RANDOM_SCALE.xyz);
    p += dot(p, p.yxz + 19.19);
    return fract((p.xxy + p.yzz) * p.zyx);
}
vec4 random4(float p) {
    vec4 p4 = fract(p * RANDOM_SCALE);
    p4 += dot(p4, p4.wzxy + 19.19);
    return fract((p4.xxyz + p4.yzzw) * p4.zywx);   
}
vec4 random4(vec2 p) {
    vec4 p4 = fract(p.xyxy * RANDOM_SCALE);
    p4 += dot(p4, p4.wzxy + 19.19);
    return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}
vec4 random4(vec3 p) {
    vec4 p4 = fract(p.xyzx * RANDOM_SCALE);
    p4 += dot(p4, p4.wzxy + 19.19);
    return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}
vec4 random4(vec4 p4) {
    p4 = fract(p4  * RANDOM_SCALE);
    p4 += dot(p4, p4.wzxy + 19.19);
    return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}
#endif

// Taken from https://gist.github.com/sugi-cho/6a01cae436acddd72bdf
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
// Taken from https://gist.github.com/sugi-cho/6a01cae436acddd72bdf
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
float mod289(const in float x) { return x - floor(x * (1. / 289.)) * 289.; }
vec2 mod289(const in vec2 x) { return x - floor(x * (1. / 289.)) * 289.; }
vec3 mod289(const in vec3 x) { return x - floor(x * (1. / 289.)) * 289.; }
vec4 mod289(const in vec4 x) { return x - floor(x * (1. / 289.)) * 289.; }
float permute(const in float v) { return mod289(((v * 34.0) + 1.0) * v); }
vec2 permute(const in vec2 v) { return mod289(((v * 34.0) + 1.0) * v); }
vec3 permute(const in vec3 v) { return mod289(((v * 34.0) + 1.0) * v); }
vec4 permute(const in vec4 v) { return mod289(((v * 34.0) + 1.0) * v); }
float taylorInvSqrt(in float r) { return 1.79284291400159 - 0.85373472095314 * r; }
vec2 taylorInvSqrt(in vec2 r) { return 1.79284291400159 - 0.85373472095314 * r; }
vec3 taylorInvSqrt(in vec3 r) { return 1.79284291400159 - 0.85373472095314 * r; }
vec4 taylorInvSqrt(in vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }
vec3 quintic(const in vec3 v)  { return v*v*v*(v*(v*6.0-15.0)+10.0); }

float msign(in float x) { return (x<0.0)?-1.0:1.0; }
float cos_acos_3( float x ) { x=sqrt(0.5+0.5*x); return x*(x*(x*(x*-0.008972+0.039071)-0.107074)+0.576975)+0.5; } // https://www.shadertoy.com/view/WltSD7
float sdEllipse( vec2 p, in vec2 ab )
{
  //if( ab.x==ab.y ) return length(p)-ab.x;

	p = abs( p ); 
    if( p.x>p.y ){ p=p.yx; ab=ab.yx; }
	
	float l = ab.y*ab.y - ab.x*ab.x;
    float m = ab.x*p.x/l; float m2 = m*m;
	float n = ab.y*p.y/l; float n2 = n*n;
    float c = (m2+n2-1.0)/3.0; float c2 = c*c; float c3 = c*c2;
    float d = c3 + m2*n2;
    float q = d  + m2*n2;
    float g = m  + m *n2;

    float co;

    if( d<0.0 )
    {
        float h = acos(q/c3)/3.0;
        float s = cos(h); s += 2.0;
        float t = sin(h); t *= sqrt(3.0);
        float rx = sqrt( m2-c*(s+t) );
        float ry = sqrt( m2-c*(s-t) );
        co = ry + sign(l)*rx + abs(g)/(rx*ry);
    }
    else                                    // d>0
    {                                       // q>0
        float h = 2.0*m*n*sqrt(d);          // h>0
        float s = pow(q+h, 1.0/3.0 );       // s>0
        float t = c2/s;                     // t>0
        float rx = -(s+t) - c*4.0 + 2.0*m2;
        float ry =  (s-t)*sqrt(3.0);
        float rm = sqrt( rx*rx + ry*ry );
        co = ry/sqrt(rm-rx) + 2.0*g/rm;
    }
    co = (co-m)/2.0;

    float si = sqrt( max(1.0-co*co,0.0) );
 
    vec2 r = ab * vec2(co,si);
	
    return length(r-p) * msign(p.y-r.y);
}

vec4 bubble(vec2 uv, vec2 offset, vec2 scale, float rotation, float time_offset, int object_id) {
    // Translate
    uv = uv - offset;

    // Scale
    uv.x /= scale.x;
    uv.y /= scale.y;

    float angle = atan(uv.y, uv.x);
    float radius = distance(uv, vec2(0.0, 0.0));
    vec3 color_hsv = vec3(sin((radius*radius + sin(angle * 2.0 + time_offset)) * 1.0 - u_time * 0.1), 1.0 - radius * radius, 1.0);
    float border_mask = (smoothstep(0.5, 0.99, pow(radius, 1.5)) * 0.95 + 0.05) - smoothstep(0.99, 1.0, radius);

    vec4 color = vec4(hsv2rgb(color_hsv), border_mask);

    float angle_offset = 1.0;
    float radius_offset = 0.75;

    float shine = smoothstep(0.1, 0.0, sdEllipse(vec2(radius - radius_offset, angle - angle_offset), vec2(0.1, 0.5)));
    
    vec4 ellipse_color = vec4(vec3(1.0), shine);

    color = composite(ellipse_color, color);

    if (object_id != 0 && radius < 1.0) {
        // Rotate (only rotate character as bubble lighting is independent of rotation)
        uv = vec2(uv.x * cos(rotation) + uv.y * sin(rotation), -uv.x * sin(rotation) + uv.y * cos(rotation));
        vec4 object_color = vec4(1.0, 1.0, 1.0, 0.0);
        if (object_id == 1) {object_color = texture(u_tex1, (uv + 1.0) / 2.0);}
        else if (object_id == 2) {object_color = texture(u_tex2, (uv + 1.0) / 2.0);}
        else if (object_id == 3) {object_color = texture(u_tex3, (uv + 1.0) / 2.0);}
        color = clamp(color, 0.0, 1.0);
        color = composite(color, object_color);
    }

    return color;
}

float round_down(float num, float multiple) {
    float remainder = mod(num, multiple);
    return num - remainder;
}

const float BUBBLE_RESET_TIME = 20.0;

vec4 generateBubble(vec2 uv, float initial_seed, int object_id) {
    float adjusted_time = mod(u_time + initial_seed, BUBBLE_RESET_TIME);
    float index = round_down(u_time + initial_seed, BUBBLE_RESET_TIME);
    float seed = initial_seed + index;

    float rising_speed = 0.2 + random(seed) * 0.05;
    float wobbling_speed = 1.5 + random(seed + 0.1) * 0.2;
    float initial_wobble = random(seed + 0.2) * 2.0 * PI;

    float x_pos = random(seed + 0.3) * 2.4 - 1.2 + sin(adjusted_time * wobbling_speed + initial_wobble) * 0.1;
    float y_pos = adjusted_time * rising_speed - 2.0 - random(seed + 0.4);
    vec2 origin = vec2(x_pos, y_pos);

    float scale = random(seed + 0.5) * 0.1 + 0.05;
    float angle = random(seed + 0.6) * 2.0 * PI + sin(adjusted_time) * 0.5;
    float time_offset = random( + 0.7) * 2.0 * PI;

    return bubble(uv, origin, vec2(scale), angle, time_offset, object_id);
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

void main (void) {
    vec2 image_uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 uv = image_uv * 2.0 - 1.0;
    float aspect_ratio = u_resolution.x / u_resolution.y;
    uv.x *= aspect_ratio;

    vec4 color = mix(vec4(0.01, 0.2, 0.4, 1.0), vec4(0.03, 0.8, 0.9, 1.0), image_uv.y * image_uv.y);

    // Apply perspective
    vec2 perspective_uv = uv;
    perspective_uv.y = 3.0 / ((uv.y + 0.05) - 0.2);
    perspective_uv.x *= perspective_uv.y * 1.1;

    // Move waves slowly
    perspective_uv.x += u_time * 0.13;
    perspective_uv.y -= u_time * 0.1;

    // Apply distortion
    perspective_uv += vec2(sin((perspective_uv.y + u_time * 0.1) * 15.0) * 0.035, cos((perspective_uv.x + u_time * 0.11) * 15.0) * 0.035);

    float voroni = voroni(perspective_uv, 2.0);
    voroni *= smoothstep(0.4, 0.8, uv.y);

    vec4 voroni_color = vec4(1.0, 1.0, 1.0, voroni);

    color = composite(voroni_color, color);

    color = composite(generateBubble(uv, 0.0, 2), color);
    color = composite(generateBubble(uv, 1.0, 0), color);
    color = composite(generateBubble(uv, 2.0, 0), color);
    color = composite(generateBubble(uv, 3.0, 0), color);
    color = composite(generateBubble(uv, 4.0, 0), color);
    color = composite(generateBubble(uv, 5.0, 0), color);
    color = composite(generateBubble(uv, 6.0, 0), color);
    color = composite(generateBubble(uv, 7.0, 0), color);
    color = composite(generateBubble(uv, 8.0, 3), color);
    color = composite(generateBubble(uv, 9.0, 0), color);
    color = composite(generateBubble(uv, 10.0, 0), color);
    color = composite(generateBubble(uv, 11.0, 0), color);
    color = composite(generateBubble(uv, 12.0, 0), color);
    color = composite(generateBubble(uv, 13.0, 0), color);
    color = composite(generateBubble(uv, 14.0, 0), color);
    color = composite(generateBubble(uv, 15.0, 0), color);
    color = composite(generateBubble(uv, 16.0, 0), color);
    color = composite(generateBubble(uv, 17.0, 0), color);
    color = composite(generateBubble(uv, 18.0, 0), color);
    color = composite(generateBubble(uv, 19.0, 0), color);

    if (image_uv.x > 0.0 && image_uv.x < 1.0 && image_uv.y < 1.0) {
        vec4 tama_color = texture(u_tex0, image_uv);
        color = composite(tama_color, color);
    }

    color = composite(bubble(uv, vec2(0.42, -0.64) + vec2(sin(u_time * 0.5), sin(u_time)) * 0.03, vec2(0.37), sin(u_time) * 0.2, 0.0, 1), color);

    vec2 watermark_uv = gl_FragCoord.xy / u_resolution.xy * 8.0;
    watermark_uv.x = watermark_uv.x * 0.37;
    vec4 watermark_color = texture(u_tex4, watermark_uv);
    if (watermark_uv.x > 1.0 || watermark_uv.y > 1.0) {
        watermark_color = vec4(0);
    }
    watermark_color = mask(vec4(1.0,1.0,1.0,1.0), watermark_color.a * 0.08);
    color = composite (watermark_color, color);

    outColor = color;
}
