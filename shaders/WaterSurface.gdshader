shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 deep_color : source_color = vec4(0.10, 0.29, 0.38, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.38, 0.61, 0.69, 1.0);
uniform vec4 foam_color : source_color = vec4(0.82, 0.89, 0.92, 1.0);
uniform vec4 shoreline_color : source_color = vec4(0.59, 0.69, 0.67, 1.0);
uniform float wave_scale = 0.06;
uniform float wave_speed = 0.12;
uniform float foam_strength = 0.16;
uniform float fresnel_strength = 3.6;
uniform float shoreline_foam = 0.22;
uniform float normal_strength = 0.4;
uniform float channel_mode = 0.0;
uniform float flow_speed_scale = 0.24;
uniform float water_opacity = 0.78;
uniform float absorption_strength = 1.18;
uniform float reflection_strength = 0.92;
uniform float micro_ripple_strength = 0.18;
uniform float micro_ripple_scale = 1.85;
uniform float wave_height = 0.11;
uniform float silt_tint_strength = 0.16;

varying vec2 v_uv;
varying float v_wave;
varying float v_ripple;

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
	vec2 micro_uv = UV * micro_ripple_scale;
	float lake_wave_a = sin((VERTEX.x + TIME * 18.0) * 0.008);
	float lake_wave_b = cos((VERTEX.z - TIME * 13.0) * 0.009);
	float lake_cross = sin((VERTEX.x * 0.005 + VERTEX.z * 0.004) + TIME * 0.17);
	float stream_wave_a = sin((UV.x * 82.0) - TIME * (22.0 + flow_speed_scale * 28.0));
	float stream_wave_b = cos((UV.y * 24.0) + TIME * 11.0);
	float ripple = noise2d(wave_uv + vec2(TIME * wave_speed * mix(0.7, 2.2, channel_mode), -TIME * wave_speed * 0.45));
	float micro_ripple = noise2d(micro_uv + vec2(TIME * 0.09, -TIME * 0.07)) * 2.0 - 1.0;
	float lake_wave = lake_wave_a * 0.38 + lake_wave_b * 0.24 + lake_cross * 0.22 + ripple * 0.55;
	float channel_wave = stream_wave_a * 0.34 + stream_wave_b * 0.12 + ripple * 0.42;
	v_wave = mix(lake_wave, channel_wave, channel_mode);
	v_ripple = micro_ripple;
	VERTEX.y += v_wave * wave_height * mix(1.0, 0.55, channel_mode);
	VERTEX.y += v_ripple * micro_ripple_strength * mix(0.06, 0.03, channel_mode);
	v_uv = UV;
}

void fragment() {
	float center_mask = 1.0 - smoothstep(0.45, 0.98, length(v_uv * 2.0 - 1.0));
	float foam = smoothstep(0.48, 0.92, abs(v_wave) + abs(v_ripple) * 0.24) * foam_strength;
	float fresnel = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), fresnel_strength);
	float lake_edge = smoothstep(0.52, 0.98, length(v_uv * 2.0 - 1.0));
	float channel_edge = 1.0 - smoothstep(0.08, 0.28, min(v_uv.y, 1.0 - v_uv.y));
	float shore_edge = mix(lake_edge, channel_edge, channel_mode);
	float depth_mix = clamp(0.25 + center_mask * absorption_strength + v_wave * 0.10 + channel_mode * (0.45 - abs(v_uv.y - 0.5)) * 0.22, 0.0, 1.0);
	vec3 base = mix(shallow_color.rgb, deep_color.rgb, depth_mix);
	base = mix(base, shoreline_color.rgb, shore_edge * (silt_tint_strength + channel_mode * 0.05));
	base = mix(base, foam_color.rgb, foam + shore_edge * shoreline_foam * mix(0.65, 1.0, channel_mode));
	base = mix(base, vec3(0.84, 0.89, 0.92), clamp(fresnel * reflection_strength + center_mask * 0.08, 0.0, 1.0) * 0.16);
	vec3 wave_normal = normalize(vec3(-dFdx(v_wave + v_ripple * micro_ripple_strength) * mix(2.9, 1.8, channel_mode), 1.0, -dFdy(v_wave + v_ripple * micro_ripple_strength) * mix(2.9, 1.8, channel_mode)));
	NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), wave_normal * 0.5 + 0.5, normal_strength);
	NORMAL_MAP_DEPTH = normal_strength;
	ALBEDO = base;
	ROUGHNESS = clamp(mix(0.04, 0.18, shore_edge * 0.55 + foam * 0.75 + channel_mode * 0.08) + (1.0 - center_mask) * 0.05, 0.03, 0.28);
	METALLIC = 0.0;
	SPECULAR = clamp(0.68 + fresnel * 0.18, 0.0, 1.0);
	ALPHA = clamp(water_opacity + fresnel * 0.08 - shore_edge * 0.06, 0.65, 0.94);
}
