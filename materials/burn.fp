#define speed 1
#define PI 3.1415926

varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_sampler;
uniform lowp vec4 tint;
uniform lowp vec4 time;

float random(vec2 st) {
	return fract(sin(dot(st,vec2(94.23,48.127))+14.23)*1124.23);
}

float noise(vec2 st) {
	vec2 ip=floor(st);
	vec2 fp=fract(st);
	float a=random(ip);
	float b=random(ip + vec2(1., 0.));
	float c=random(ip + vec2(0., 1.));
	float d=random(ip + vec2(1., 1.));
	vec2 u=smoothstep(0.,1.,fp);
	return mix(mix(a,b,u.x),mix(c,d,u.x),u.y);
}

float fractalNoise(vec2 uv) {
	uv*=30.;
	float amp=.6,n=0.;
	for (int i=0;i<6;i++) {
		n+=noise(uv)*amp;
		uv*=2.;
		amp*=.5;
	}
	return n;
}

float displace(vec2 uv, float iTime) {
	uv = mix(uv, vec2(fractalNoise(uv)),.08);
	float d = -.1 + mod(iTime * .1, 1.5);
	vec2 d1=vec2(.5,.5)+noise(uv*3.)-.5;
	return smoothstep(d,d+.08,distance(uv,d1));
}

vec3 burn(vec4 col, vec2 uv, float iTime) {
	float a = displace(uv, iTime);
	vec3 b = (1. -a) * vec3(1., .14, .016) * a * 100.;
	vec3 res = vec3(0);
	if (col.a > 0) {
		res = col.rgb * a + b;
	}
	return res;
}

void main()
{
	float time = time.x * speed;
	vec2 res = vec2(2, 2);
	vec2 uv = var_texcoord0.xy * res.xy - 0.5;
	
	// Pre-multiply alpha since all runtime textures already are
	gl_FragColor = vec4(burn(texture2D(texture_sampler, var_texcoord0.xy), uv * vec2(res.x / res.y, 1.), time), 1.);
}
