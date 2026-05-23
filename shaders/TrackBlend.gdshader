shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D ballast_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D ballast_roughness : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D ballast_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D ballast_ao : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D sleeper_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D sleeper_roughness : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D sleeper_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D sleeper_ao : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rail_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rail_roughness : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rail_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rail_ao : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;

uniform vec3 side_color : source_color = vec3(0.26, 0.24, 0.22);
uniform float ballast_scale_x = 2.5;
uniform float ballast_scale_y = 10.0;
uniform float sleeper_scale_x = 1.2;
uniform float sleeper_repeat = 18.0;
uniform float sleeper_thickness = 0.14;
uniform float sleeper_softness = 0.05;
uniform float rail_center_offset = 0.17;
uniform float rail_half_width = 0.03;
uniform float rail_softness = 0.012;
uniform float paint_rails = 1.0;
uniform float center_grime_strength = 0.22;
uniform float shoulder_brighten = 0.12;
uniform float rain_wetness = 0.0;
uniform float snow_cover = 0.0;
uniform float normal_strength = 0.55;
uniform float wet_clearcoat_strength = 0.85;

vec3 decode_normal(vec3 encoded) {
	return normalize(encoded * 2.0 - 1.0);
}

void fragment() {
	vec2 ballast_uv = vec2(UV.x * ballast_scale_x, UV.y * ballast_scale_y);
	vec2 sleeper_uv = vec2(UV.x * sleeper_scale_x, UV.y * sleeper_repeat);
	vec2 rail_uv = vec2(UV.x * 1.4, UV.y * 16.0);

	vec3 ballast = texture(ballast_albedo, ballast_uv).rgb;
	float ballast_r = texture(ballast_roughness, ballast_uv).r;
	vec3 ballast_n = decode_normal(texture(ballast_normal, ballast_uv).rgb);
	float ballast_ao_v = texture(ballast_ao, ballast_uv).r;
	vec3 sleeper = texture(sleeper_albedo, sleeper_uv).rgb;
	float sleeper_r = texture(sleeper_roughness, sleeper_uv).r;
	vec3 sleeper_n = decode_normal(texture(sleeper_normal, sleeper_uv).rgb);
	float sleeper_ao_v = texture(sleeper_ao, sleeper_uv).r;
	vec3 rail = texture(rail_albedo, rail_uv).rgb;
	float rail_r = texture(rail_roughness, rail_uv).r;
	vec3 rail_n = decode_normal(texture(rail_normal, rail_uv).rgb);
	float rail_ao_v = texture(rail_ao, rail_uv).r;

	float top_mask = clamp(abs(NORMAL.y) * 1.35, 0.0, 1.0);
	float sleeper_phase = abs(fract(UV.y * sleeper_repeat) - 0.5);
	float sleeper_mask = 1.0 - smoothstep(sleeper_thickness, sleeper_thickness + sleeper_softness, sleeper_phase);
	sleeper_mask *= smoothstep(0.10, 0.24, UV.x) * smoothstep(0.10, 0.24, 1.0 - UV.x);

	float rail_left = 1.0 - smoothstep(rail_half_width, rail_half_width + rail_softness, abs(UV.x - (0.5 - rail_center_offset)));
	float rail_right = 1.0 - smoothstep(rail_half_width, rail_half_width + rail_softness, abs(UV.x - (0.5 + rail_center_offset)));
	float rail_mask = max(rail_left, rail_right) * paint_rails;
	float shoulder_mask = smoothstep(0.18, 0.47, abs(UV.x - 0.5));
	float center_grime_mask = 1.0 - smoothstep(0.08, 0.24, abs(UV.x - 0.5));
	float ballast_mask = clamp(1.0 - max(sleeper_mask * 0.82, rail_mask), 0.0, 1.0);

	vec3 top_color = mix(ballast, sleeper, sleeper_mask * 0.88);
	top_color = mix(top_color, top_color * vec3(1.0 + shoulder_brighten), shoulder_mask * 0.45);
	top_color = mix(top_color, top_color * vec3(1.0 - center_grime_strength), center_grime_mask * (1.0 - rail_mask));
	top_color = mix(top_color, rail, rail_mask);
	float top_roughness = mix(ballast_r, sleeper_r, sleeper_mask * 0.75);
	top_roughness = mix(top_roughness, clamp(top_roughness + 0.08, 0.0, 1.0), shoulder_mask * 0.35);
	top_roughness = mix(top_roughness, rail_r, rail_mask * 0.92);
	float snow_mask = clamp(snow_cover * (0.24 + shoulder_mask * 0.46 + sleeper_mask * 0.22), 0.0, 1.0);
	top_color = mix(top_color, top_color * vec3(0.86, 0.89, 0.92), rain_wetness * (0.18 + center_grime_mask * 0.22));
	top_color = mix(top_color, vec3(0.91, 0.92, 0.94), snow_mask * 0.72);
	top_roughness = mix(top_roughness, max(0.08, top_roughness * 0.62), rain_wetness * 0.72);
	top_roughness = mix(top_roughness, 0.68, snow_mask * 0.45);
	float wet_clearcoat = clamp((rain_wetness * (0.34 + rail_mask * 0.36 + shoulder_mask * 0.18)) * (1.0 - snow_mask), 0.0, 1.0);

	float normal_weight_sum = max(0.001, ballast_mask + sleeper_mask + rail_mask);
	vec3 blended_normal = normalize(
		ballast_n * ballast_mask +
		sleeper_n * sleeper_mask +
		rail_n * rail_mask * 1.15
	);
	float top_ao = clamp(
		(ballast_ao_v * ballast_mask + sleeper_ao_v * sleeper_mask + rail_ao_v * rail_mask) / normal_weight_sum,
		0.18,
		1.0
	);

	ALBEDO = mix(side_color, top_color, top_mask);
	ROUGHNESS = mix(0.88, clamp(top_roughness, 0.08, 1.0), top_mask);
	METALLIC = rail_mask * top_mask * 0.55;
	NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), blended_normal * 0.5 + 0.5, normal_strength * top_mask);
	NORMAL_MAP_DEPTH = normal_strength * top_mask;
	AO = mix(0.76, top_ao, top_mask);
	SPECULAR = mix(0.08, 0.26, rain_wetness * 0.72 + rail_mask * 0.38);
	CLEARCOAT = wet_clearcoat * wet_clearcoat_strength * top_mask;
}
