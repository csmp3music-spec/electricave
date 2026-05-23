shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform bool use_texture_layers = false;
uniform vec4 meadow_color : source_color = vec4(0.33, 0.41, 0.24, 1.0);
uniform vec4 dry_grass_color : source_color = vec4(0.58, 0.52, 0.33, 1.0);
uniform vec4 soil_color : source_color = vec4(0.39, 0.30, 0.22, 1.0);
uniform vec4 sand_color : source_color = vec4(0.72, 0.66, 0.53, 1.0);
uniform vec4 wet_color : source_color = vec4(0.25, 0.29, 0.23, 1.0);
uniform vec4 rock_color : source_color = vec4(0.42, 0.40, 0.37, 1.0);
uniform vec4 floodplain_color : source_color = vec4(0.33, 0.37, 0.25, 1.0);
uniform vec4 silt_color : source_color = vec4(0.57, 0.53, 0.42, 1.0);
uniform vec4 upland_color : source_color = vec4(0.44, 0.45, 0.40, 1.0);
uniform sampler2D grass_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D grass_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D grass_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D soil_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D soil_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D soil_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D mud_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D mud_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D mud_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rock_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rock_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rock_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float grass_uv_scale = 0.095;
uniform float soil_uv_scale = 0.085;
uniform float mud_uv_scale = 0.11;
uniform float rock_uv_scale = 0.075;
uniform float rock_triplanar_sharpness = 7.5;
uniform float rock_triplanar_blend_start = 0.18;
uniform float rock_triplanar_blend_end = 0.48;
uniform float normal_strength = 0.55;
uniform float detail_normal_strength = 0.18;
uniform float leaf_litter_strength = 0.22;
uniform float shoreline_grit_strength = 0.20;
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
uniform float terrain_low_hint = -2.5;
uniform float terrain_high_hint = 18.0;
uniform float wet_clearcoat_strength = 0.78;

varying float v_height;
varying float v_slope;
varying float v_macro_noise;
varying vec2 v_world_xz;
varying vec4 v_context;

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

vec3 triplanar_weights(vec3 normal, float sharpness) {
	vec3 weights = pow(abs(normalize(normal)), vec3(sharpness));
	return weights / max(0.0001, weights.x + weights.y + weights.z);
}

vec3 sample_triplanar_albedo(sampler2D tex, vec3 pos, vec3 weights, float scale, float mix_strength) {
	vec3 sample_x = sample_detail_albedo(tex, pos.yz * scale, mix_strength);
	vec3 sample_y = sample_detail_albedo(tex, pos.xz * scale, mix_strength);
	vec3 sample_z = sample_detail_albedo(tex, pos.xy * scale, mix_strength);
	return sample_x * weights.x + sample_y * weights.y + sample_z * weights.z;
}

float sample_triplanar_roughness(sampler2D tex, vec3 pos, vec3 weights, float scale, float mix_strength) {
	float sample_x = sample_detail_roughness(tex, pos.yz * scale, mix_strength);
	float sample_y = sample_detail_roughness(tex, pos.xz * scale, mix_strength);
	float sample_z = sample_detail_roughness(tex, pos.xy * scale, mix_strength);
	return sample_x * weights.x + sample_y * weights.y + sample_z * weights.z;
}

vec3 sample_triplanar_normal(sampler2D tex, vec3 pos, vec3 weights, float scale, float mix_strength) {
	vec3 sample_x = sample_detail_normal(tex, pos.yz * scale, mix_strength);
	vec3 sample_y = sample_detail_normal(tex, pos.xz * scale, mix_strength);
	vec3 sample_z = sample_detail_normal(tex, pos.xy * scale, mix_strength);
	return normalize(sample_x * weights.x + sample_y * weights.y + sample_z * weights.z);
}

void vertex() {
	vec2 p = VERTEX.xz;
	v_height = VERTEX.y;
	v_slope = clamp(1.0 - NORMAL.y, 0.0, 1.0);
	v_macro_noise = fbm(p * detail_scale * 0.42);
	v_world_xz = p;
	v_context = COLOR;
}

void fragment() {
	float dataset_elevation = clamp(v_context.r, 0.0, 1.0);
	float shoreline_mask = clamp(v_context.g, 0.0, 1.0);
	float floodplain_mask = clamp(v_context.b, 0.0, 1.0);
	float coast_mask = clamp(v_context.a, 0.0, 1.0);
	float raw_elevation = clamp((v_height - terrain_low_hint) / max(0.001, terrain_high_hint - terrain_low_hint), 0.0, 1.0);
	float elevation = mix(smoothstep(-height_scale * 0.42, height_scale * 0.82, v_height), raw_elevation, 0.55);
	elevation = mix(elevation, dataset_elevation, 0.65);
	float grass_mask = smoothstep(0.12, 0.78, elevation) * (1.0 - smoothstep(0.18, 0.55, v_slope));
	float dry_mask = smoothstep(0.30, 0.92, elevation + v_macro_noise * 0.18);
	float sand_mask = smoothstep(0.0, 0.22, 1.0 - elevation) * (1.0 - smoothstep(0.08, 0.28, v_slope));
	sand_mask = max(sand_mask, coast_mask * (0.30 + shoreline_mask * 0.70));
	float rock_mask = smoothstep(0.16, 0.52, v_slope) * (0.55 + 0.45 * smoothstep(0.28, 0.92, elevation));
	rock_mask = max(rock_mask, smoothstep(0.72, 1.0, elevation) * 0.22);
	float wet_mask = smoothstep(0.0, 0.34, 1.0 - elevation) * (1.0 - rock_mask) * valley_wetness;
	wet_mask = max(wet_mask, shoreline_mask * (0.28 + coast_mask * 0.14) + floodplain_mask * 0.20);
	wet_mask = clamp(wet_mask + rain_wetness * (0.30 + (1.0 - v_slope) * 0.55), 0.0, 1.0);

	vec3 albedo = mix(soil_color.rgb, meadow_color.rgb, grass_mask);
	albedo = mix(albedo, dry_grass_color.rgb, dry_mask * (0.45 + 0.35 * grass_mask));
	albedo = mix(albedo, sand_color.rgb, sand_mask * 0.82);
	albedo = mix(albedo, wet_color.rgb, wet_mask);
	albedo = mix(albedo, rock_color.rgb, rock_mask);
	albedo = mix(albedo, floodplain_color.rgb, floodplain_mask * (1.0 - rock_mask) * 0.42);
	albedo = mix(albedo, silt_color.rgb, shoreline_mask * 0.34 + coast_mask * 0.22);
	albedo = mix(albedo, upland_color.rgb, smoothstep(0.76, 1.0, elevation) * rock_mask * 0.24);

	float roughness = mix(0.98, 0.78, rock_mask);
	roughness = mix(roughness, 0.72, wet_mask * 0.65);

	if (use_texture_layers) {
		float mud_mask = clamp(max(wet_mask * 1.45, shoreline_mask * 0.75 + floodplain_mask * 0.35), 0.0, 1.0);
		float soil_mask = clamp(1.0 - max(max(grass_mask, mud_mask), rock_mask), 0.0, 1.0);
		soil_mask = max(soil_mask, sand_mask * 0.75 + floodplain_mask * 0.18);
		float weight_sum = max(0.001, grass_mask + soil_mask + mud_mask + rock_mask);
		float grass_w = grass_mask / weight_sum;
		float soil_w = soil_mask / weight_sum;
		float mud_w = mud_mask / weight_sum;
		float rock_w = rock_mask / weight_sum;

		vec2 grass_uv = v_world_xz * grass_uv_scale;
		vec2 soil_uv = v_world_xz * soil_uv_scale;
		vec2 mud_uv = v_world_xz * mud_uv_scale;
		vec2 rock_uv = v_world_xz * rock_uv_scale;
		vec3 world_pos = vec3(v_world_xz.x, v_height, v_world_xz.y);
		vec3 rock_weights = triplanar_weights(NORMAL, rock_triplanar_sharpness);
		float rock_triplanar_mix = smoothstep(rock_triplanar_blend_start, rock_triplanar_blend_end, v_slope);

		vec3 grass_tex = sample_detail_albedo(grass_albedo, grass_uv, 0.34);
		vec3 soil_tex = sample_detail_albedo(soil_albedo, soil_uv, 0.31);
		vec3 mud_tex = sample_detail_albedo(mud_albedo, mud_uv, 0.28);
		vec3 rock_tex = mix(
			sample_detail_albedo(rock_albedo, rock_uv, 0.22),
			sample_triplanar_albedo(rock_albedo, world_pos, rock_weights, rock_uv_scale, 0.22),
			rock_triplanar_mix
		);

		float grass_r = sample_detail_roughness(grass_roughness, grass_uv, 0.34);
		float soil_r = sample_detail_roughness(soil_roughness, soil_uv, 0.31);
		float mud_r = sample_detail_roughness(mud_roughness, mud_uv, 0.28);
		float rock_r = mix(
			sample_detail_roughness(rock_roughness, rock_uv, 0.22),
			sample_triplanar_roughness(rock_roughness, world_pos, rock_weights, rock_uv_scale, 0.22),
			rock_triplanar_mix
		);

		vec3 grass_n = sample_detail_normal(grass_normal, grass_uv, 0.34);
		vec3 soil_n = sample_detail_normal(soil_normal, soil_uv, 0.31);
		vec3 mud_n = sample_detail_normal(mud_normal, mud_uv, 0.28);
		vec3 rock_n = mix(
			sample_detail_normal(rock_normal, rock_uv, 0.22),
			sample_triplanar_normal(rock_normal, world_pos, rock_weights, rock_uv_scale, 0.22),
			rock_triplanar_mix
		);

		albedo =
			grass_tex * grass_w +
			soil_tex * soil_w +
			mud_tex * mud_w +
			rock_tex * rock_w;
		albedo = mix(albedo, sand_color.rgb, sand_mask * 0.26);
		albedo = mix(albedo, dry_grass_color.rgb, dry_mask * 0.18);
		albedo = mix(albedo, wet_color.rgb, wet_mask * 0.12);
		albedo = mix(albedo, floodplain_color.rgb, floodplain_mask * 0.18);
		albedo = mix(albedo, silt_color.rgb, shoreline_mask * 0.16 + coast_mask * 0.14);
		albedo = mix(albedo, upland_color.rgb, smoothstep(0.76, 1.0, elevation) * rock_mask * 0.12);

		roughness =
			grass_r * grass_w +
			soil_r * soil_w +
			mud_r * mud_w +
			rock_r * rock_w;
		roughness = clamp(roughness, 0.18, 1.0);
		roughness = mix(roughness, max(0.22, roughness * 0.76), shoreline_mask * 0.30 + floodplain_mask * 0.16);

		float litter_noise = fbm(v_world_xz * 0.00115 + vec2(23.7, 9.2));
		float grit_noise = ridge_noise(v_world_xz * 0.0026 + vec2(3.1, 41.0));
		float litter_mask = clamp((soil_w + mud_w * 0.35) * (1.0 - shoreline_mask) * (1.0 - rock_mask), 0.0, 1.0);
		float grit_mask = clamp((shoreline_mask + coast_mask * 0.7 + rock_mask * 0.35) * shoreline_grit_strength, 0.0, 1.0);
		albedo = mix(albedo, albedo * mix(0.74, 1.08, litter_noise), litter_mask * leaf_litter_strength);
		albedo = mix(albedo, mix(vec3(0.48, 0.46, 0.39), vec3(0.74, 0.71, 0.62), grit_noise), grit_mask);
		roughness = clamp(roughness + litter_mask * leaf_litter_strength * 0.06 + grit_mask * 0.12, 0.18, 1.0);

		vec3 blended_normal = normalize(
			grass_n * grass_w +
			soil_n * soil_w +
			mud_n * mud_w +
			rock_n * rock_w
		);
		vec3 detail_normal = normalize(vec3(
			(fbm(v_world_xz * 0.0031 + vec2(13.0, 2.0)) - 0.5) * 2.0,
			(fbm(v_world_xz * 0.0031 + vec2(5.0, 17.0)) - 0.5) * 2.0,
			1.0
		));
		blended_normal = normalize(mix(blended_normal, detail_normal, detail_normal_strength * (1.0 - snow_cover)));
		NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), blended_normal * 0.5 + 0.5, normal_strength);
		NORMAL_MAP_DEPTH = normal_strength;
	}

	float micro = fbm(v_world_xz * micro_scale + vec2(v_macro_noise * 4.0, v_height * 0.06));
	albedo *= mix(0.80, 1.16, micro) * macro_albedo_strength;
	float snow_mask = snow_cover * (1.0 - smoothstep(0.18, 0.52, v_slope)) * smoothstep(-0.25, 0.55, elevation + micro * 0.12);
	albedo = mix(albedo, vec3(0.90, 0.92, 0.94), snow_mask);
	roughness = mix(roughness, 0.66, snow_mask);
	roughness = mix(roughness, max(0.18, roughness * 0.72), rain_wetness * 0.65);
	float wet_clearcoat = clamp((wet_mask * 0.72 + rain_wetness * 0.64) * (1.0 - snow_mask) * (1.0 - smoothstep(0.22, 0.82, v_slope)), 0.0, 1.0);

	ALBEDO = albedo;
	ROUGHNESS = roughness;
	SPECULAR = mix(0.03, 0.18, wet_mask + rain_wetness * 0.55 + rock_mask * 0.35);
	CLEARCOAT = wet_clearcoat * wet_clearcoat_strength;
	AO = mix(0.82, 1.0, micro) * mix(0.9, 1.0, elevation);
}
