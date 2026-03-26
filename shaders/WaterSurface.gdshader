shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 deep_color : source_color = vec4(0.10, 0.29, 0.38, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.38, 0.61, 0.69, 1.0);
uniform vec4 foam_color : source_color = vec4(0.82, 0.89, 0.92, 1.0);
uniform float wave_scale = 0.06;
uniform float wave_speed = 0.12;
uniform float foam_strength = 0.16;
uniform float fresnel_strength = 2.4;

varying vec2 v_uv;
varying float v_wave;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise2d(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
		u.y
	);
}

void vertex() {
	vec2 wave_uv = UV * wave_scale;
	float wave_a = sin((VERTEX.x + TIME * 42.0) * 0.01);
	float wave_b = cos((VERTEX.z - TIME * 31.0) * 0.012);
	float ripple = noise2d(wave_uv + vec2(TIME * wave_speed, -TIME * wave_speed * 0.7));
	v_wave = wave_a * 0.45 + wave_b * 0.35 + ripple * 0.65;
	VERTEX.y += v_wave * 0.12;
	v_uv = UV;
}

void fragment() {
	float foam = smoothstep(0.34, 0.82, abs(v_wave)) * foam_strength;
	float fresnel = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), fresnel_strength);
	vec3 base = mix(deep_color.rgb, shallow_color.rgb, clamp(v_wave * 0.35 + 0.5, 0.0, 1.0));
	base = mix(base, foam_color.rgb, foam + fresnel * 0.22);
	ALBEDO = base;
	ROUGHNESS = mix(0.06, 0.18, foam + fresnel * 0.25);
	METALLIC = 0.02;
	SPECULAR = 0.82;
	ALPHA = 0.84;
}
