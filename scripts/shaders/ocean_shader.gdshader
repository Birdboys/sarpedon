shader_type spatial;
render_mode world_vertex_coords;
uniform sampler2D wave_noise;
uniform sampler2D normal_noise;
uniform float noise_scale = 1.0;
uniform float time_scale : hint_range(0,1.0,.005) = 1.0;
uniform float height_scale = 1.0;
uniform float current_time;
uniform vec3 ocean_color : source_color;
uniform vec3 ocean_depth_color : source_color;
varying vec3 world_pos;
varying float noise_val;

float getNoise() {
	return texture(wave_noise, vec2(world_pos.x, world_pos.z)/noise_scale + TIME * time_scale).r;
}
vec3 getNormalNoise() {
	return texture(normal_noise, vec2(world_pos.x, world_pos.z)/noise_scale + TIME * time_scale).rgb;
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