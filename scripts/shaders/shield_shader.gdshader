shader_type spatial;
uniform sampler2D shield_text: filter_nearest, source_color;
uniform sampler2D other_image;
uniform float shield_percent = 0.5;
uniform float shield_strength = 0.1;
float getCenterDist(float x, float y){
	float rel_x = x-0.5;
	float rel_y = y-0.5;
	return sqrt(pow(rel_x,2)+pow(rel_y,2));
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALPHA = texture(shield_text, UV).a;
	float centerDist = getCenterDist(UV.x,UV.y);
	ALBEDO = texture(shield_text, UV).rgb * centerDist + texture(other_image, UV).rgb * (shield_percent-centerDist);
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	METALLIC =1.0;
}