shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform bool use_texture_layers = false;
uniform vec4 meadow_color : source_color = vec4(0.33, 0.41, 0.24, 1.0);
uniform vec4 dry_grass_color : source_color = vec4(0.58, 0.52, 0.33, 1.0);
uniform vec4 soil_color : source_color = vec4(0.39, 0.30, 0.22, 1.0);
uniform vec4 sand_color : source_color = vec4(0.72, 0.66, 0.53, 1.0);
uniform vec4 wet_color : source_color = vec4(0.25, 0.29, 0.23, 1.0);
uniform vec4 rock_color : source_color = vec4(0.42, 0.40, 0.37, 1.0);
uniform sampler2D grass_albedo : source_color, repeat_enable;
uniform sampler2D grass_roughness : repeat_enable;
uniform sampler2D grass_normal : hint_normal, repeat_enable;
uniform sampler2D soil_albedo : source_color, repeat_enable;
uniform sampler2D soil_roughness : repeat_enable;
uniform sampler2D soil_normal : hint_normal, repeat_enable;
uniform sampler2D mud_albedo : source_color, repeat_enable;
uniform sampler2D mud_roughness : repeat_enable;
uniform sampler2D mud_normal : hint_normal, repeat_enable;
uniform sampler2D rock_albedo : source_color, repeat_enable;
uniform sampler2D rock_roughness : repeat_enable;
uniform sampler2D rock_normal : hint_normal, repeat_enable;
uniform float grass_uv_scale = 0.095;
uniform float soil_uv_scale = 0.085;
uniform float mud_uv_scale = 0.11;
uniform float rock_uv_scale = 0.075;
uniform float normal_strength = 0.55;
uniform float rain_wetness = 0.0;
uniform float snow_cover = 0.0;
uniform float macro_albedo_strength = 1.0;
uniform float terrain_scale = 0.000045;
uniform float ridge_scale = 0.00011;
uniform float detail_scale = 0.00022;
uniform float micro_scale = 0.0017;
uniform float height_scale = 2.6;
uniform float ridge_strength = 1.05;
uniform float valley_wetness = 0.35;

varying float v_height;
varying float v_slope;
varying float v_macro_noise;
varying vec2 v_world_xz;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise2d(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
		u.y
	);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 5; i++) {
		value += noise2d(p) * amplitude;
		p *= 2.03;
		amplitude *= 0.5;
	}
	return value;
}

float ridge_noise(vec2 p) {
	float n = fbm(p);
	return 1.0 - abs(n * 2.0 - 1.0);
}

float terrain_height(vec2 p) {
	float broad = fbm(p * terrain_scale);
	float ridges = ridge_noise(p * ridge_scale);
	float detail = fbm(p * detail_scale);
	return (broad * 0.62 + ridges * 0.28 + detail * 0.10 - 0.44) * height_scale + ridges * ridge_strength;
}

vec3 decode_normal(vec3 encoded) {
	return normalize(encoded * 2.0 - 1.0);
}

vec3 sample_detail_albedo(sampler2D tex, vec2 uv, float mix_strength) {
	vec2 uv_b = vec2(uv.x * 0.67 - uv.y * 0.31, uv.x * 0.31 + uv.y * 0.67);
	return mix(texture(tex, uv).rgb, texture(tex, uv_b).rgb, mix_strength);
}

float sample_detail_roughness(sampler2D tex, vec2 uv, float mix_strength) {
	vec2 uv_b = vec2(uv.x * 0.67 - uv.y * 0.31, uv.x * 0.31 + uv.y * 0.67);
	return mix(texture(tex, uv).r, texture(tex, uv_b).r, mix_strength);
}

vec3 sample_detail_normal(sampler2D tex, vec2 uv, float mix_strength) {
	vec2 uv_b = vec2(uv.x * 0.67 - uv.y * 0.31, uv.x * 0.31 + uv.y * 0.67);
	return normalize(mix(decode_normal(texture(tex, uv).rgb), decode_normal(texture(tex, uv_b).rgb), mix_strength));
}

void vertex() {
	vec2 p = VERTEX.xz;
	v_height = VERTEX.y;
	v_slope = clamp(1.0 - NORMAL.y, 0.0, 1.0);
	v_macro_noise = fbm(p * detail_scale * 0.42);
	v_world_xz = p;
}

void fragment() {
	float elevation = smoothstep(-height_scale * 0.42, height_scale * 0.82, v_height);
	float grass_mask = smoothstep(0.12, 0.78, elevation) * (1.0 - smoothstep(0.18, 0.55, v_slope));
	float dry_mask = smoothstep(0.30, 0.92, elevation + v_macro_noise * 0.18);
	float sand_mask = smoothstep(0.0, 0.22, 1.0 - elevation) * (1.0 - smoothstep(0.08, 0.28, v_slope));
	float rock_mask = smoothstep(0.16, 0.52, v_slope) * (0.55 + 0.45 * smoothstep(0.28, 0.92, elevation));
	float wet_mask = smoothstep(0.0, 0.34, 1.0 - elevation) * (1.0 - rock_mask) * valley_wetness;
	wet_mask = clamp(wet_mask + rain_wetness * (0.30 + (1.0 - v_slope) * 0.55), 0.0, 1.0);

	vec3 albedo = mix(soil_color.rgb, meadow_color.rgb, grass_mask);
	albedo = mix(albedo, dry_grass_color.rgb, dry_mask * (0.45 + 0.35 * grass_mask));
	albedo = mix(albedo, sand_color.rgb, sand_mask * 0.82);
	albedo = mix(albedo, wet_color.rgb, wet_mask);
	albedo = mix(albedo, rock_color.rgb, rock_mask);

	float roughness = mix(0.98, 0.78, rock_mask);
	roughness = mix(roughness, 0.72, wet_mask * 0.65);

	if (use_texture_layers) {
		float mud_mask = clamp(wet_mask * 1.45, 0.0, 1.0);
		float soil_mask = clamp(1.0 - max(max(grass_mask, mud_mask), rock_mask), 0.0, 1.0);
		soil_mask = max(soil_mask, sand_mask * 0.75);
		float weight_sum = max(0.001, grass_mask + soil_mask + mud_mask + rock_mask);
		float grass_w = grass_mask / weight_sum;
		float soil_w = soil_mask / weight_sum;
		float mud_w = mud_mask / weight_sum;
		float rock_w = rock_mask / weight_sum;

		vec2 grass_uv = v_world_xz * grass_uv_scale;
		vec2 soil_uv = v_world_xz * soil_uv_scale;
		vec2 mud_uv = v_world_xz * mud_uv_scale;
		vec2 rock_uv = v_world_xz * rock_uv_scale;

		vec3 grass_tex = sample_detail_albedo(grass_albedo, grass_uv, 0.34);
		vec3 soil_tex = sample_detail_albedo(soil_albedo, soil_uv, 0.31);
		vec3 mud_tex = sample_detail_albedo(mud_albedo, mud_uv, 0.28);
		vec3 rock_tex = sample_detail_albedo(rock_albedo, rock_uv, 0.22);

		float grass_r = sample_detail_roughness(grass_roughness, grass_uv, 0.34);
		float soil_r = sample_detail_roughness(soil_roughness, soil_uv, 0.31);
		float mud_r = sample_detail_roughness(mud_roughness, mud_uv, 0.28);
		float rock_r = sample_detail_roughness(rock_roughness, rock_uv, 0.22);

		vec3 grass_n = sample_detail_normal(grass_normal, grass_uv, 0.34);
		vec3 soil_n = sample_detail_normal(soil_normal, soil_uv, 0.31);
		vec3 mud_n = sample_detail_normal(mud_normal, mud_uv, 0.28);
		vec3 rock_n = sample_detail_normal(rock_normal, rock_uv, 0.22);

		albedo =
			grass_tex * grass_w +
			soil_tex * soil_w +
			mud_tex * mud_w +
			rock_tex * rock_w;
		albedo = mix(albedo, sand_color.rgb, sand_mask * 0.26);
		albedo = mix(albedo, dry_grass_color.rgb, dry_mask * 0.18);
		albedo = mix(albedo, wet_color.rgb, wet_mask * 0.12);

		roughness =
			grass_r * grass_w +
			soil_r * soil_w +
			mud_r * mud_w +
			rock_r * rock_w;
		roughness = clamp(roughness, 0.18, 1.0);

		vec3 blended_normal = normalize(
			grass_n * grass_w +
			soil_n * soil_w +
			mud_n * mud_w +
			rock_n * rock_w
		);
		NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), blended_normal * 0.5 + 0.5, normal_strength);
		NORMAL_MAP_DEPTH = normal_strength;
	}

	float micro = fbm(v_world_xz * micro_scale + vec2(v_macro_noise * 4.0, v_height * 0.06));
	albedo *= mix(0.80, 1.16, micro) * macro_albedo_strength;
	float snow_mask = snow_cover * (1.0 - smoothstep(0.18, 0.52, v_slope)) * smoothstep(-0.25, 0.55, elevation + micro * 0.12);
	albedo = mix(albedo, vec3(0.90, 0.92, 0.94), snow_mask);
	roughness = mix(roughness, 0.66, snow_mask);
	roughness = mix(roughness, max(0.18, roughness * 0.72), rain_wetness * 0.65);

	ALBEDO = albedo;
	ROUGHNESS = roughness;
	SPECULAR = mix(0.03, 0.18, wet_mask + rain_wetness * 0.55 + rock_mask * 0.35);
	AO = mix(0.82, 1.0, micro) * mix(0.9, 1.0, elevation);
}
