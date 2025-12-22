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
    // If both alphas are extremely low, assume both colours are fully transparent, and therefore return the first colour unmodified
    // (if this is not done, it appears a divide-by-zero occurs which makes the resulting colour become fully opaque)
    if (color1.a < 0.00000000001 && color2.a < 0.000000000001) {
        return color1;
    }
    float alpha = color1.a + color2.a * (1.0 - color1.a);
    return vec4((color1.rgb * color1.a + color2.rgb * color2.a * (1.0 - color1.a)) / alpha, alpha);
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
float cubic(const in float v) { return v*v*(3.0-2.0*v); }
vec2  cubic(const in vec2 v)  { return v*v*(3.0-2.0*v); }
vec3  cubic(const in vec3 v)  { return v*v*(3.0-2.0*v); }
vec4  cubic(const in vec4 v)  { return v*v*(3.0-2.0*v); }
float cubic(const in float v, in float slope0, in float slope1) {
    float a = slope0 + slope1 - 2.;
    float b = -2. * slope0 - slope1 + 3.;
    float c = slope0;
    float v2 = v * v;
    float v3 = v * v2;
    return a * v3 + b * v2 + c * v;
}
vec2 cubic(const in vec2 v, in float slope0, in float slope1) {
    float a = slope0 + slope1 - 2.;
    float b = -2. * slope0 - slope1 + 3.;
    float c = slope0;
    vec2 v2 = v * v;
    vec2 v3 = v * v2;
    return a * v3 + b * v2 + c * v;
}
vec3 cubic(const in vec3 v, in float slope0, in float slope1) {
    float a = slope0 + slope1 - 2.;
    float b = -2. * slope0 - slope1 + 3.;
    float c = slope0;
    vec3 v2 = v * v;
    vec3 v3 = v * v2;
    return a * v3 + b * v2 + c * v;
}
vec4 cubic(const in vec4 v, in float slope0, in float slope1) {
    float a = slope0 + slope1 - 2.;
    float b = -2. * slope0 - slope1 + 3.;
    float c = slope0;
    vec4 v2 = v * v;
    vec4 v3 = v * v2;
    return a * v3 + b * v2 + c * v;
}
vec4 grad4(float j, vec4 ip) {
    const vec4 ones = vec4(1.0, 1.0, 1.0, -1.0);
    vec4 p,s;
    p.xyz = floor( fract (vec3(j) * ip.xyz) * 7.0) * ip.z - 1.0;
    p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
    s = vec4(lessThan(p, vec4(0.0)));
    p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www;
    return p;
}
vec3 srandom3(in vec3 p) {
    p = vec3( dot(p, vec3(127.1, 311.7, 74.7)),
            dot(p, vec3(269.5, 183.3, 246.1)),
            dot(p, vec3(113.5, 271.9, 124.6)));
    return -1. + 2. * fract(sin(p) * 43758.5453123);
}
vec3 srandom3(in vec3 p, const in float tileLength) {
    p = mod(p, vec3(tileLength));
    return srandom3(p);
}
float snoise(in vec2 v) {
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    // First corner
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);

    // Other corners
    vec2 i1;
    //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
    //i1.y = 1.0 - i1.x;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    // x0 = x0 - 0.0 + 0.0 * C.xx ;
    // x1 = x0 - i1 + 1.0 * C.xx ;
    // x2 = x0 - 1.0 + 2.0 * C.xx ;
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;

    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
    + i.x + vec3(0.0, i1.x, 1.0 ));

    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;

    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt( a0*a0 + h*h );
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

    // Compute final noise value at P
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}
float snoise(in vec3 v) {
    const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
    const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

    // First corner
    vec3 i  = floor(v + dot(v, C.yyy) );
    vec3 x0 =   v - i + dot(i, C.xxx) ;

    // Other corners
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min( g.xyz, l.zxy );
    vec3 i2 = max( g.xyz, l.zxy );

    //   x0 = x0 - 0.0 + 0.0 * C.xxx;
    //   x1 = x0 - i1  + 1.0 * C.xxx;
    //   x2 = x0 - i2  + 2.0 * C.xxx;
    //   x3 = x0 - 1.0 + 3.0 * C.xxx;
    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
    vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

    // Permutations
    i = mod289(i);
    vec4 p = permute( permute( permute(
                i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
            + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
            + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    float n_ = 0.142857142857; // 1.0/7.0
    vec3  ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

    vec4 x = x_ *ns.x + ns.yyyy;
    vec4 y = y_ *ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4( x.xy, y.xy );
    vec4 b1 = vec4( x.zw, y.zw );

    //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
    //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

    vec3 p0 = vec3(a0.xy,h.x);
    vec3 p1 = vec3(a0.zw,h.y);
    vec3 p2 = vec3(a1.xy,h.z);
    vec3 p3 = vec3(a1.zw,h.w);

    //Normalise gradients
    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    // Mix final noise value
    vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),
                                dot(p2,x2), dot(p3,x3) ) );
}
float snoise(in vec4 v) {
    const vec4  C = vec4( 0.138196601125011,  // (5 - sqrt(5))/20  G4
                        0.276393202250021,  // 2 * G4
                        0.414589803375032,  // 3 * G4
                        -0.447213595499958); // -1 + 4 * G4

    // First corner
    vec4 i  = floor(v + dot(v, vec4(.309016994374947451)) ); // (sqrt(5) - 1)/4
    vec4 x0 = v -   i + dot(i, C.xxxx);

    // Other corners

    // Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
    vec4 i0;
    vec3 isX = step( x0.yzw, x0.xxx );
    vec3 isYZ = step( x0.zww, x0.yyz );
    //  i0.x = dot( isX, vec3( 1.0 ) );
    i0.x = isX.x + isX.y + isX.z;
    i0.yzw = 1.0 - isX;
    //  i0.y += dot( isYZ.xy, vec2( 1.0 ) );
    i0.y += isYZ.x + isYZ.y;
    i0.zw += 1.0 - isYZ.xy;
    i0.z += isYZ.z;
    i0.w += 1.0 - isYZ.z;

    // i0 now contains the unique values 0,1,2,3 in each channel
    vec4 i3 = clamp( i0, 0.0, 1.0 );
    vec4 i2 = clamp( i0-1.0, 0.0, 1.0 );
    vec4 i1 = clamp( i0-2.0, 0.0, 1.0 );

    //  x0 = x0 - 0.0 + 0.0 * C.xxxx
    //  x1 = x0 - i1  + 1.0 * C.xxxx
    //  x2 = x0 - i2  + 2.0 * C.xxxx
    //  x3 = x0 - i3  + 3.0 * C.xxxx
    //  x4 = x0 - 1.0 + 4.0 * C.xxxx
    vec4 x1 = x0 - i1 + C.xxxx;
    vec4 x2 = x0 - i2 + C.yyyy;
    vec4 x3 = x0 - i3 + C.zzzz;
    vec4 x4 = x0 + C.wwww;

    // Permutations
    i = mod289(i);
    float j0 = permute( permute( permute( permute(i.w) + i.z) + i.y) + i.x);
    vec4 j1 = permute( permute( permute( permute (
                i.w + vec4(i1.w, i2.w, i3.w, 1.0 ))
            + i.z + vec4(i1.z, i2.z, i3.z, 1.0 ))
            + i.y + vec4(i1.y, i2.y, i3.y, 1.0 ))
            + i.x + vec4(i1.x, i2.x, i3.x, 1.0 ));

    // Gradients: 7x7x6 points over a cube, mapped onto a 4-cross polytope
    // 7*7*6 = 294, which is close to the ring size 17*17 = 289.
    vec4 ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;

    vec4 p0 = grad4(j0,   ip);
    vec4 p1 = grad4(j1.x, ip);
    vec4 p2 = grad4(j1.y, ip);
    vec4 p3 = grad4(j1.z, ip);
    vec4 p4 = grad4(j1.w, ip);

    // Normalise gradients
    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;
    p4 *= taylorInvSqrt(dot(p4,p4));

    // Mix contributions from the five corners
    vec3 m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
    vec2 m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4)            ), 0.0);
    m0 = m0 * m0;
    m1 = m1 * m1;
    return 49.0 * ( dot(m0*m0, vec3( dot( p0, x0 ), dot( p1, x1 ), dot( p2, x2 )))
                + dot(m1*m1, vec2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;
}
vec2 snoise2( vec2 x ){
    float s  = snoise(vec2( x ));
    float s1 = snoise(vec2( x.y - 19.1, x.x + 47.2 ));
    return vec2( s , s1 );
}
vec3 snoise3( vec3 x ){
    float s  = snoise(vec3( x ));
    float s1 = snoise(vec3( x.y - 19.1 , x.z + 33.4 , x.x + 47.2 ));
    float s2 = snoise(vec3( x.z + 74.2 , x.x - 124.5 , x.y + 99.4 ));
    return vec3( s , s1 , s2 );
}
vec3 snoise3( vec4 x ){
    float s  = snoise(vec4( x ));
    float s1 = snoise(vec4( x.y - 19.1 , x.z + 33.4 , x.x + 47.2, x.w ));
    float s2 = snoise(vec4( x.z + 74.2 , x.x - 124.5 , x.y + 99.4, x.w ));
    return vec3( s , s1 , s2 );
}
float gnoise(float x) {
    float i = floor(x);  // integer
    float f = fract(x);  // fraction
    return mix(random(i), random(i + 1.0), smoothstep(0.,1.,f)); 
}
float gnoise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = cubic(f);
    return mix( a, b, u.x) +
                (c - a)* u.y * (1.0 - u.x) +
                (d - b) * u.x * u.y;
}
float gnoise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    vec3 u = quintic(f);
    return -1.0 + 2.0 * mix( mix( mix( random(i + vec3(0.0,0.0,0.0)), 
                                        random(i + vec3(1.0,0.0,0.0)), u.x),
                                mix( random(i + vec3(0.0,1.0,0.0)), 
                                        random(i + vec3(1.0,1.0,0.0)), u.x), u.y),
                            mix( mix( random(i + vec3(0.0,0.0,1.0)), 
                                        random(i + vec3(1.0,0.0,1.0)), u.x),
                                mix( random(i + vec3(0.0,1.0,1.0)), 
                                        random(i + vec3(1.0,1.0,1.0)), u.x), u.y), u.z );
}
float gnoise(vec3 p, float tileLength) {
    vec3 i = floor(p);
    vec3 f = fract(p);
            
    vec3 u = quintic(f);
        
    return mix( mix( mix( dot( srandom3(i + vec3(0.0,0.0,0.0), tileLength), f - vec3(0.0,0.0,0.0)), 
                            dot( srandom3(i + vec3(1.0,0.0,0.0), tileLength), f - vec3(1.0,0.0,0.0)), u.x),
                    mix( dot( srandom3(i + vec3(0.0,1.0,0.0), tileLength), f - vec3(0.0,1.0,0.0)), 
                            dot( srandom3(i + vec3(1.0,1.0,0.0), tileLength), f - vec3(1.0,1.0,0.0)), u.x), u.y),
                mix( mix( dot( srandom3(i + vec3(0.0,0.0,1.0), tileLength), f - vec3(0.0,0.0,1.0)), 
                            dot( srandom3(i + vec3(1.0,0.0,1.0), tileLength), f - vec3(1.0,0.0,1.0)), u.x),
                    mix( dot( srandom3(i + vec3(0.0,1.0,1.0), tileLength), f - vec3(0.0,1.0,1.0)), 
                            dot( srandom3(i + vec3(1.0,1.0,1.0), tileLength), f - vec3(1.0,1.0,1.0)), u.x), u.y), u.z );
}
vec3 gnoise3(vec3 x) {
    return vec3(gnoise(x+vec3(123.456, 0.567, 0.37)),
                gnoise(x+vec3(0.11, 47.43, 19.17)),
                gnoise(x) );
}

#ifndef FBM_OCTAVES
#define FBM_OCTAVES 4
#endif

#ifndef FBM_NOISE_FNC
#define FBM_NOISE_FNC(UV) snoise3(UV)
#endif

#ifndef FBM_NOISE2_FNC
#define FBM_NOISE2_FNC(UV) FBM_NOISE_FNC(UV)
#endif

#ifndef FBM_NOISE3_FNC
#define FBM_NOISE3_FNC(UV) FBM_NOISE_FNC(UV)
#endif

#ifndef FBM_NOISE_TILABLE_FNC
#define FBM_NOISE_TILABLE_FNC(UV, TILE) gnoise(UV, TILE)
#endif

#ifndef FBM_NOISE3_TILABLE_FNC
#define FBM_NOISE3_TILABLE_FNC(UV, TILE) FBM_NOISE_TILABLE_FNC(UV, TILE)
#endif

#ifndef FBM_NOISE_TYPE
#define FBM_NOISE_TYPE vec3
#endif

#ifndef FBM_VALUE_INITIAL
#define FBM_VALUE_INITIAL 0.0
#endif

#ifndef FBM_SCALE_SCALAR
#define FBM_SCALE_SCALAR 2.0
#endif

#ifndef FBM_AMPLITUDE_INITIAL
#define FBM_AMPLITUDE_INITIAL 0.5
#endif

#ifndef FBM_AMPLITUDE_SCALAR
#define FBM_AMPLITUDE_SCALAR 0.5
#endif

#ifndef FNC_FBM
#define FNC_FBM
FBM_NOISE_TYPE fbm(in vec2 st) {
    // Initial values
    FBM_NOISE_TYPE value = FBM_NOISE_TYPE(FBM_VALUE_INITIAL);
    float amplitude = FBM_AMPLITUDE_INITIAL;

    // Loop of octaves
    for (int i = 0; i < FBM_OCTAVES; i++) {
        value += amplitude * FBM_NOISE2_FNC(vec3(st, u_time));
        st *= FBM_SCALE_SCALAR;
        amplitude *= FBM_AMPLITUDE_SCALAR;
    }
    return value;
}
FBM_NOISE_TYPE fbm(in vec3 pos) {
    // Initial values
    FBM_NOISE_TYPE value = FBM_NOISE_TYPE(FBM_VALUE_INITIAL);
    float amplitude = FBM_AMPLITUDE_INITIAL;

    // Loop of octaves
    for (int i = 0; i < FBM_OCTAVES; i++) {
        value += amplitude * FBM_NOISE3_FNC(pos);
        pos *= FBM_SCALE_SCALAR;
        amplitude *= FBM_AMPLITUDE_SCALAR;
    }
    return value;
}
FBM_NOISE_TYPE fbm(vec3 p, float tileLength) {
    const float persistence = 0.5;
    const float lacunarity = 2.0;

    float amplitude = 0.5;
    FBM_NOISE_TYPE total = FBM_NOISE_TYPE(0.0);
    float normalization = 0.0;

    for (int i = 0; i < FBM_OCTAVES; ++i) {
        float noiseValue = FBM_NOISE3_TILABLE_FNC(p, tileLength * lacunarity * 0.5) * 0.5 + 0.5;
        total += noiseValue * amplitude;
        normalization += amplitude;
        amplitude *= persistence;
        p = p * lacunarity;
    }

    return total / normalization;
}
#endif

const float CLOUD_SCROLL_SPEED = 0.6;
vec2 get_cloud_uv(vec2 uv) {
    // Apply perspective to clouds
    vec2 cloud_uv = uv;
    cloud_uv.y = 6.0 / (uv.y + 0.4);
    cloud_uv.x *= cloud_uv.y * 0.8;

    if (uv.y > -0.4) {
        cloud_uv.x += CLOUD_SCROLL_SPEED * u_time;
    } else {
        cloud_uv.x -= CLOUD_SCROLL_SPEED * u_time;
    }

    return cloud_uv;
}

vec2 unget_cloud_uv(vec2 cloud_uv) {
    vec2 uv = cloud_uv;
    cloud_uv.x -= CLOUD_SCROLL_SPEED * u_time;

    cloud_uv.x /= cloud_uv.y * 0.8;
    uv.y = (6.0 / cloud_uv.y) - 0.4;
    uv.x = cloud_uv.x;

    return uv;
}

vec4 lightning_shine(vec2 cloud_uv, vec2 lightning_root, float brightness) {
    float distance_measure = 1.0 - distance(cloud_uv, lightning_root);
    float shine_distance = smoothstep(1.0 - brightness * 0.5, 1.0, distance_measure);

    vec4 color = vec4(1.0, 1.0, 1.0, shine_distance);

    return color;
}

vec4 lightning_line(vec2 uv, vec2 lightning_line_start, float initial_width, float final_width, float length, float angle, float brightness, out vec4 circle_color) {
    vec4 color = vec4(0.0);

    uv -= lightning_line_start;
    uv = vec2(uv.x * cos(angle) + uv.y * sin(angle), -uv.x * sin(angle) + uv.y * cos(angle));
    uv += lightning_line_start;

    float line_equation = 0.0;
    if (uv.x > lightning_line_start.x) {
        line_equation = (uv.y - (lightning_line_start.y - (length / (initial_width - final_width)) * (lightning_line_start.x + initial_width))) / (length / (initial_width - final_width));
    } else {
        line_equation = (uv.y - (lightning_line_start.y - (length / (final_width - initial_width)) * (lightning_line_start.x - initial_width))) / (length / (final_width - initial_width));
    }

    float brightness_distance = 0.0;
    if (uv.x > lightning_line_start.x) {
        brightness_distance = (- uv.x + line_equation) / (-lightning_line_start.x + line_equation);
    } else {
        brightness_distance = (uv.x - line_equation) / (lightning_line_start.x - line_equation);
    }

    if (uv.y < lightning_line_start.y && lightning_line_start.y - length < uv.y) {
        brightness_distance = smoothstep(1.0 - brightness, 1.0, brightness_distance);

        color = vec4(vec3(1.0), brightness_distance);
    }

    circle_color = vec4(vec3(1.0), smoothstep(1.0 - brightness, 1.0, ((-1.0 / initial_width) * distance(uv, lightning_line_start) + 1.0)));

    return color;
}

vec4 lightning_bolt(vec2 uv, vec2 lightning_root_bolt, float seed, float scale, float brightness) {
    vec4 color = vec4(0.0);
    vec4 total_circle_color = vec4(0.0);

    uv -= lightning_root_bolt;
    uv /= scale;
    uv += lightning_root_bolt;

    float width = 0.2;

    float seed_offset = seed + 0.5;
    int i_max = 6;
    float width_reduction = width / float(i_max);

    for (int i = 0; i < i_max; i++) {
        if (i != 0) {
            int branches = int(random(seed_offset) * 4.0);
            seed_offset += 0.001;
            for (int branch = 0; branch < branches; branch++) {
                float initial_width = width / 2.0;
                float final_width = 0.0;
                float length = random(seed_offset) + 2.0;
                seed_offset += 0.001;
                float angle = random(seed_offset) * 3.0 - 1.5;
                seed_offset += 0.001;

                vec4 circle_color = vec4(0.0);
                color = composite(lightning_line(uv, lightning_root_bolt, initial_width, final_width, length, angle, brightness, circle_color), color);
                total_circle_color = composite(circle_color, total_circle_color);
            }
        }

        float initial_width = width;
        width -= width_reduction;
        float final_width = width;

        float length = random(seed_offset) + 2.0;
        seed_offset += 0.001;
        float angle = random(seed_offset) * 2.5 - 1.25;
        seed_offset += 0.001;

        vec4 circle_color = vec4(0.0);
        color = composite(lightning_line(uv, lightning_root_bolt, initial_width, final_width, length, angle, brightness, circle_color), color);
        total_circle_color = composite(circle_color, total_circle_color);
        lightning_root_bolt += vec2(
            length * sin(angle),
            -length * cos(angle)
        );
    }

    color = composite(color, total_circle_color);

    return color;
}

float round_down(float num, float multiple) {
    float remainder = mod(num, multiple);
    return num - remainder;
}

const float LIGHTNING_RESET_TIME = 4.0;

vec4 generateLightning(vec2 uv, vec4 cloud_color, float initial_seed, out float brightness) {
    float adjusted_time = mod(u_time + initial_seed, LIGHTNING_RESET_TIME);
    float index = round_down(u_time + initial_seed, LIGHTNING_RESET_TIME);
    float seed = initial_seed + index;

    float initial_strike_time = random(seed) * 3.0;

    brightness = 2.0 * (smoothstep(0.0, 0.1, adjusted_time - initial_strike_time) - smoothstep(0.1, 0.8, adjusted_time - initial_strike_time));
    brightness += 1.3 * (smoothstep(0.0, 0.1, adjusted_time - initial_strike_time) - smoothstep(0.1, 0.4, adjusted_time - initial_strike_time));

    vec2 cloud_uv = get_cloud_uv(uv);

    // lightning_root_screen: Where it initially appears in the screen's uv space before time shifting
    // lightning_root_cloud: Where it appears in the cloud's uv space after time shifting
    // lightning_root_bolt: Where it appears in the screen's uv space after time shifting
    vec2 lightning_root_screen = vec2(
        random(seed + 0.01) * 2.2 - 1.1,
        pow(random(seed + 0.02), 3.0) * 1.2 - 0.2
    );
    vec2 lightning_root_cloud = get_cloud_uv(lightning_root_screen);
    lightning_root_cloud.x -= CLOUD_SCROLL_SPEED * adjusted_time;
    vec2 lightning_root_bolt = unget_cloud_uv(lightning_root_cloud);

    // Scale the lightning bolt based on its distance (by taking it's y position in cloud space and
    // measuring how far a unit move along the x axis is when converted back to uv space)
    float scale = unget_cloud_uv(vec2(1.0 + CLOUD_SCROLL_SPEED * u_time, lightning_root_cloud.y)).x * 0.5;

    vec4 lightning_shine = lightning_shine(cloud_uv, lightning_root_cloud, brightness);
    vec4 lightning_bolt = lightning_bolt(uv, lightning_root_bolt, seed, scale, brightness);

    vec3 cloud_hsv = rgb2hsv(cloud_color.rgb);
    vec3 lightning_shine_hsv = rgb2hsv(lightning_shine.rgb);
    cloud_hsv.z /= (1.0 - lightning_shine.a * 0.6);

    cloud_color.rgb = hsv2rgb(cloud_hsv);

    cloud_color = composite(lightning_bolt, cloud_color);

    brightness *= scale;

    return cloud_color;
}

const float MOUNTAIN_SCROLL_SPEED = 0.1;
const float ARSON_SCROLL_SPEED = 0.142;
const float ARSON_ANIMATION_RATE = 1.5;

void main (void) {
    vec2 image_uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 uv = image_uv * 2.0 - 1.0;
    float aspect_ratio = u_resolution.x / u_resolution.y;
    uv.x *= aspect_ratio;

    vec2 cloud_uv = get_cloud_uv(uv);

    vec4 color = vec4(0.17, 0.11, 0.09, 1.0);

    float height = -0.4 + gnoise(uv.x * 10.0 + u_time * MOUNTAIN_SCROLL_SPEED) * 0.1;
    if (uv.y > height) {
        vec3 cloud_hsv = fbm(vec3(cloud_uv, u_time * 0.2)) * 0.5 + 0.5;
        cloud_hsv.x = 0.0;
        cloud_hsv.y *= 0.1;
        cloud_hsv.z *= 0.4;
        vec4 cloud_color = vec4(hsv2rgb(cloud_hsv), 1.0);
        color = composite(cloud_color, color);
    } else {
        vec4 mountain_color = vec4(0.2, 0.13, 0.11, smoothstep(-0.42, height, uv.y) * 0.8);
        if (uv.y > -0.42) {
            float new_y = (50.0 * height + 1.0) * uv.y + 21.0 * height;
            cloud_uv.y = get_cloud_uv(vec2(uv.x, new_y)).y;
        }

        vec3 land_texture_hsv = fbm(vec3(cloud_uv * 0.9, 0.0)) * 0.5 + 0.5;
        land_texture_hsv.x = land_texture_hsv.x * 0.5;
        land_texture_hsv.y *= 0.8;
        land_texture_hsv.z = land_texture_hsv.z * 0.4 + 0.0;
        vec4 land_texture_color = vec4(hsv2rgb(land_texture_hsv), 1.0);
        color = composite(land_texture_color, color);

        vec4 land_color1 = vec4(0.0);
        vec4 land_color2 = vec4(0.0);
        land_color1.rga = fbm(vec3(cloud_uv * 0.01, 0.0)) * 0.5 + 0.5;
        land_color1.r *= 0.9;
        land_color1.a *= 0.5;
        land_color1.rgb *= 0.25;
        land_color2.gba = fbm(vec3(cloud_uv * 0.011, 0.0)) * 0.5 + 0.5;
        land_color2.b *= 0.7;
        land_color2.a *= 0.5;
        land_color2.rgb *= 0.25;
        vec4 land_color = land_color1 + land_color2;
        land_color = mix(land_color, vec4(0.17, 0.11, 0.09, 0.8), clamp(uv.y / 0.1 + 5.0, 0.0, 1.0));

        color = composite(land_color, color);
    }

    // Add lightning
    const float BRIGHTNESS_MULTIPLIER = 0.15;
    float total_brightness = 0.0;
    float brightness = 0.0;
    color = composite(generateLightning(uv, color, 0.0, brightness), color);
    total_brightness += brightness * BRIGHTNESS_MULTIPLIER;
    color = composite(generateLightning(uv, color, 1.0, brightness), color);
    total_brightness += brightness * BRIGHTNESS_MULTIPLIER;
    color = composite(generateLightning(uv, color, 2.0, brightness), color);
    total_brightness += brightness * BRIGHTNESS_MULTIPLIER;
    color = composite(generateLightning(uv, color, 3.0, brightness), color);
    total_brightness += brightness * BRIGHTNESS_MULTIPLIER;

    color = composite(generateLightning(uv, color, 0.5, brightness), color);
    total_brightness += brightness * BRIGHTNESS_MULTIPLIER;
    color = composite(generateLightning(uv, color, 1.5, brightness), color);
    total_brightness += brightness * BRIGHTNESS_MULTIPLIER;
    color = composite(generateLightning(uv, color, 2.5, brightness), color);
    total_brightness += brightness * BRIGHTNESS_MULTIPLIER;
    color = composite(generateLightning(uv, color, 3.5, brightness), color);
    total_brightness += brightness * BRIGHTNESS_MULTIPLIER;

    color = composite(vec4(1.0, 1.0, 1.0, total_brightness), color);

    vec2 arson_uv = image_uv * 1.0;
    arson_uv.x = (arson_uv.x * 1.0) - 0.12;
    arson_uv.y = (arson_uv.y * 2.0) - 0.65;
    arson_uv.x += ARSON_SCROLL_SPEED * u_time;
    arson_uv.x -= ARSON_SCROLL_SPEED * round_down(u_time, ARSON_ANIMATION_RATE);
    if (arson_uv.x > 0.0 && arson_uv.x < 1.0 && arson_uv.y > 0.0 && arson_uv.y < 1.0) {
        vec4 arson_color = vec4(0.0);
        float arson_selector = mod(u_time * 1.0, ARSON_ANIMATION_RATE);
        if (arson_selector < ARSON_ANIMATION_RATE / 4.0) {
            arson_color = texture(u_tex0, arson_uv);
        } else if (arson_selector < ARSON_ANIMATION_RATE / 2.0) {
            arson_color = texture(u_tex1, arson_uv);
        } else if (arson_selector < ARSON_ANIMATION_RATE * 3.0 / 4.0) {
            arson_color = texture(u_tex2, arson_uv);
        } else {
            arson_color = texture(u_tex3, arson_uv);
        }

        vec3 arson_hsv = rgb2hsv(arson_color.rgb);
        arson_hsv.z *= (0.75 - total_brightness * 3.0);
        arson_color.rgb = hsv2rgb(arson_hsv);

        color = composite(arson_color, color);
    }

    vec2 watermark_uv = gl_FragCoord.xy / u_resolution.xy * 8.0;
    watermark_uv.x = watermark_uv.x * 0.57;
    vec4 watermark_color = texture(u_tex4, watermark_uv);
    if (watermark_uv.x > 1.0 || watermark_uv.y > 1.0) {
        watermark_color = vec4(0);
    }
    watermark_color = mask(vec4(1.0,1.0,1.0,1.0), watermark_color.a * 0.08);
    color = composite (watermark_color, color);

    outColor = color;
}
