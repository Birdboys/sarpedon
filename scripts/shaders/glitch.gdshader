shader_type spatial;
render_mode unshaded, depth_draw_opaque;
uniform sampler2D image1 : filter_nearest, source_color;
uniform sampler2D image2 : filter_nearest, source_color;
uniform sampler2D image3 : filter_nearest, source_color;
uniform float num_sections : hint_range(1, 50, 1);
uniform float max_section_offset : hint_range(0.0,1.0,0.05);
uniform float image_speed : hint_range(0.0,10.0,1.0);
uniform float offset_speed : hint_range(0.0,10.0,1.0);

uniform float image_seed : hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float offset_seed : hint_range(0.0, 100.0, 0.1) = 0.0;
uniform float transparency : hint_range(0.0,1.0,0.1) = 1.0;
void vertex() {
	// Called for every vertex the material is visible on.
}

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	float stripe_id = trunc(UV.y * num_sections); //get stripe
	float stripe_random = random(vec2(trunc(TIME * image_speed + image_seed),stripe_id)); //random value for picture
	float offset_random = random(vec2(trunc(TIME * offset_speed + 13.0 + offset_seed),stripe_id)); //random value for offset
	float stripe_offset = offset_random * 2.0 * max_section_offset - (max_section_offset);
	vec4 image_data;
	
	if ((UV.x + stripe_offset > 1.0) || (UV.x + stripe_offset < 0.0)) {
		image_data = vec4(0.0,0.0,0.0,0.0);
	} else if (stripe_random <= 0.33) {
		image_data = texture(image1, vec2(UV.x + stripe_offset, UV.y));
	} else if (stripe_random <= 0.66) {
		image_data = texture(image2, vec2(UV.x + stripe_offset, UV.y));
	} else {
		image_data = texture(image3, vec2(UV.x + stripe_offset, UV.y));
	}
	
	ALBEDO = image_data.rgb;
	ALPHA = image_data.a * transparency;
	//ALPHA_SCISSOR_THRESHOLD = 0.1;
}
