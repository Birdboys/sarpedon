shader_type spatial;
render_mode world_vertex_coords;
uniform sampler2D wave_noise;
uniform sampler2D normal_noise;
uniform sampler2D wave_noise_2;
uniform sampler2D normal_noise_2;
uniform float noise_scale = 1.0;
uniform float noise_scale_2 = 1.0;
uniform float time_scale : hint_range(0,1.0,.005) = 1.0;
uniform float time_scale_2 : hint_range(-1.0,1.0,.005) = 1.0;
uniform float height_scale = 1.0;
global uniform float current_time;
uniform vec3 ocean_color : source_color;
uniform vec3 ocean_depth_color : source_color;
varying vec3 world_pos;
varying float noise_val;

float getNoise() {
	float noise1_val = texture(wave_noise, vec2(world_pos.x, world_pos.z)/noise_scale + current_time * time_scale).r;
	float noise2_val = texture(wave_noise_2, vec2(world_pos.x, world_pos.z)/noise_scale_2 + current_time * time_scale_2).r;
	float noise_mix = mix(noise1_val, noise2_val, 0.5);
	return noise_mix;
}
vec3 getNormalNoise() {
	vec3 noise1_val = texture(normal_noise, vec2(world_pos.x, world_pos.z)/noise_scale + current_time * time_scale).rgb;
	vec3 noise2_val = texture(normal_noise_2, vec2(world_pos.x, world_pos.z)/noise_scale_2 + current_time * time_scale_2).rgb;
	vec3 noise_mix = mix(noise1_val, noise2_val, 0.5);
	return noise_mix;
}

void vertex() {
	world_pos = VERTEX;
	noise_val = getNoise();
	VERTEX.y += (noise_val-0.5) * height_scale;
}

void fragment() {
	ALBEDO = mix(ocean_depth_color, ocean_color, noise_val);
	NORMAL_MAP = getNormalNoise();
}