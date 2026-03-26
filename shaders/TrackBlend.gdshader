shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D ballast_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D ballast_roughness : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D sleeper_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D sleeper_roughness : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rail_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rail_roughness : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;

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

void fragment() {
	vec2 ballast_uv = vec2(UV.x * ballast_scale_x, UV.y * ballast_scale_y);
	vec2 sleeper_uv = vec2(UV.x * sleeper_scale_x, UV.y * sleeper_repeat);
	vec2 rail_uv = vec2(UV.x * 1.4, UV.y * 16.0);

	vec3 ballast = texture(ballast_albedo, ballast_uv).rgb;
	float ballast_r = texture(ballast_roughness, ballast_uv).r;
	vec3 sleeper = texture(sleeper_albedo, sleeper_uv).rgb;
	float sleeper_r = texture(sleeper_roughness, sleeper_uv).r;
	vec3 rail = texture(rail_albedo, rail_uv).rgb;
	float rail_r = texture(rail_roughness, rail_uv).r;

	float top_mask = clamp(abs(NORMAL.y) * 1.35, 0.0, 1.0);
	float sleeper_phase = abs(fract(UV.y * sleeper_repeat) - 0.5);
	float sleeper_mask = 1.0 - smoothstep(sleeper_thickness, sleeper_thickness + sleeper_softness, sleeper_phase);
	sleeper_mask *= smoothstep(0.10, 0.24, UV.x) * smoothstep(0.10, 0.24, 1.0 - UV.x);

	float rail_left = 1.0 - smoothstep(rail_half_width, rail_half_width + rail_softness, abs(UV.x - (0.5 - rail_center_offset)));
	float rail_right = 1.0 - smoothstep(rail_half_width, rail_half_width + rail_softness, abs(UV.x - (0.5 + rail_center_offset)));
	float rail_mask = max(rail_left, rail_right) * paint_rails;
	float shoulder_mask = smoothstep(0.18, 0.47, abs(UV.x - 0.5));
	float center_grime_mask = 1.0 - smoothstep(0.08, 0.24, abs(UV.x - 0.5));

	vec3 top_color = mix(ballast, sleeper, sleeper_mask * 0.88);
	top_color = mix(top_color, top_color * vec3(1.0 + shoulder_brighten), shoulder_mask * 0.45);
	top_color = mix(top_color, top_color * vec3(1.0 - center_grime_strength), center_grime_mask * (1.0 - rail_mask));
	top_color = mix(top_color, rail, rail_mask);
	float top_roughness = mix(ballast_r, sleeper_r, sleeper_mask * 0.75);
	top_roughness = mix(top_roughness, clamp(top_roughness + 0.08, 0.0, 1.0), shoulder_mask * 0.35);
	top_roughness = mix(top_roughness, rail_r, rail_mask * 0.92);

	ALBEDO = mix(side_color, top_color, top_mask);
	ROUGHNESS = mix(0.88, clamp(top_roughness, 0.08, 1.0), top_mask);
	METALLIC = rail_mask * top_mask * 0.55;
}
