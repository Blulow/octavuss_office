shader_type canvas_item;

uniform float radius : hint_range(0.0, 16.0) = 4.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 pixel = 1.0 / vec2(textureSize(SCREEN_TEXTURE, 0));
	vec4 col = vec4(0.0);
	for (int x = -3; x <= 3; x++) {
		for (int y = -3; y <= 3; y++) {
			col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(float(x), float(y)) * pixel * radius);
		}
	}
	COLOR = col / 49.0;
}
