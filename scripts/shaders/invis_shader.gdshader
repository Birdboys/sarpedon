shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D noise_texture : repeat_enable;
uniform sampler2D noise_texture_2 : repeat_enable;
uniform float distortion_strength : hint_range(-1, 1) = 0.2;
uniform float noise_scale = 1.0;
uniform float time_scale : hint_range(-1.0,1.0,.01) = 1.0;
uniform float time_scale_2 : hint_range(-1.0,1.0,.01) = 1.0;
uniform vec3 invis_color : source_color;

float getNoise(vec2 uv) {
	float noise_val_1 = texture(noise_texture, uv/noise_scale + TIME * time_scale).r;
	float noise_val_2 = texture(noise_texture_2, uv/noise_scale + TIME * time_scale).r;
	return clamp(0.5 * (noise_val_1 + noise_val_2), 0.0, 1.0);
}
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float noise_val = getNoise(UV);
	vec2 noise_offset = vec2(distortion_strength * noise_val);
	vec3 screen_color = texture(screen_texture, SCREEN_UV + noise_offset).rgb;
	COLOR.rgb = mix(screen_color, invis_color, (1.0-noise_val)/4.0 + 0.25);
}