shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, repeat_disable, filter_nearest;
uniform float depth_range : hint_range(0.1, 100.0, 0.1);
uniform float petrify_val : hint_range(0.0, 1.0, .01);

float colorToGrey(float r, float g, float b) {
	return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

void vertex() {
  POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec3 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z / depth_range;
	
	
	if (linear_depth > (1.0 - petrify_val)) {
		float to_grey = colorToGrey(screen_color.r, screen_color.g, screen_color.b);
		ALBEDO.rgb = vec3(to_grey, to_grey, to_grey);
	} else {
		ALBEDO.rgb = screen_color;
	}
	//ALBEDO.rgb = (1.0-linear_depth) * screen_color + linear_depth * vec3(to_grey, to_grey, to_grey);
	//ALBEDO.rgb = vec3(linear_depth, linear_depth, linear_depth);
}


