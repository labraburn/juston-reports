precision highp float;

uniform vec2    u_resolution;
uniform float   u_time;
uniform vec3    u_tint_color;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(void)
{
    float time = u_time;
    vec2 uv = (gl_FragCoord.xy / u_resolution.xx - 0.5) * 8.0;
    vec2 uv0 = uv;

    float i0 = 1.0;
    float i1 = 1.0;
    float i2 = 1.0;
    float i4 = 0.0;

    for(int s = 0; s < 7; s++)
    {
        vec2 r;
        r = vec2(cos(uv.y * i0 - i4 + time / i1), sin(uv.x * i0 - i4 + time / i1)) / i2;
        r += vec2(-r.y, r.x) * 0.3;
        uv.xy += r;

        i0 *= 1.93;
        i1 *= 1.15;
        i2 *= 1.7;
        i4 += 0.05 + 0.1 * time * i1;
    }

    float r = sin(uv.x - time) * 0.5 + 0.5;
    float b = sin(uv.y + time) * 0.5 + 0.5;
    float g = sin((uv.x + uv.y + sin(time * 0.5)) * 0.5) * 0.5 +0.5;

    vec3 rgb = vec3(r, g, b);
    vec3 hsv = rgb2hsv(rgb);
    
    hsv.y = max(hsv.y, 0.8);
    hsv.z = max(hsv.z, 0.4);
    
    gl_FragColor = vec4(hsv2rgb(hsv) * u_tint_color, 1.0);
}

