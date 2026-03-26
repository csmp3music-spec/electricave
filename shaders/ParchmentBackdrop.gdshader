shader_type canvas_item;

uniform vec4 color_top : source_color = vec4(0.92, 0.86, 0.76, 1.0);
uniform vec4 color_bottom : source_color = vec4(0.78, 0.70, 0.58, 1.0);
uniform float noise_scale = 28.0;
uniform float noise_strength = 0.08;
uniform float alpha = 0.18;

float rand(vec2 n) {
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u * u * (3.0 - 2.0 * u);

	float res = mix(
		mix(rand(ip), rand(ip + vec2(1.0, 0.0)), u.x),
		mix(rand(ip + vec2(0.0, 1.0)), rand(ip + vec2(1.0, 1.0)), u.x),
		u.y
	);
	return res;
}

void fragment() {
	vec2 uv = UV;
	vec4 base = mix(color_top, color_bottom, uv.y);
	float n = noise(uv * noise_scale);
	float grain = (n - 0.5) * noise_strength;
	COLOR = vec4(base.rgb + grain, alpha);
}
