shader_type spatial;

uniform sampler2D albedo_texture: source_color, filter_nearest;

void vertex() {
	vec2 pixel_size = 1.0 / vec2(textureSize(albedo_texture, 0));
	// pixel size snap = 5x + 3
	VERTEX += VERTEX * 78.0 * vec3(pixel_size, 1.0);
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	ALBEDO = tex.rgb;
	ALPHA = tex.a;
}
