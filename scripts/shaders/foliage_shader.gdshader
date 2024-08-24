shader_type spatial;
render_mode depth_prepass_alpha, world_vertex_coords;
uniform sampler2D texture_albedo : source_color, filter_nearest_mipmap;
uniform float sway_speed = 1.0;
uniform float sway_strength = 0.05;
uniform float sway_phase_len = 8.0;
uniform float max_world_pos = 30.0;
void vertex() {
	float height_mod = sqrt(VERTEX.y/max_world_pos);
	if (height_mod > 1.0) {height_mod = 1.0;}
	if (height_mod < 0.5) {height_mod = 0.5;}
	float strength = COLOR.r * sway_strength * height_mod;
    VERTEX.x += sin(VERTEX.x * sway_phase_len * 1.123 + TIME * sway_speed) * strength;
    VERTEX.y += sin(VERTEX.y * sway_phase_len + TIME * sway_speed * 1.12412) * strength;
    VERTEX.z += sin(VERTEX.z * sway_phase_len * 0.9123 + TIME * sway_speed * 1.3123) * strength;
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
    ALBEDO = albedo_tex.rgb;
    ALPHA = albedo_tex.a;
    METALLIC = 0.0;
    ROUGHNESS = 1.0;
}