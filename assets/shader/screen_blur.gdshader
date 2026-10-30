shader_type canvas_item;

uniform float radius : hint_range(0.0, 16.0) = 4.0;
uniform int direction : hint_range(0, 1) = 0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 pixel = 1.0 / vec2(textureSize(SCREEN_TEXTURE, 0));
	vec2 dir = direction == 0 ? vec2(pixel.x, 0.0) : vec2(0.0, pixel.y);

	// 5-tap separable Gaussian (run once horizontally, once vertically).
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV) * 0.227027;
	col += texture(SCREEN_TEXTURE, SCREEN_UV + dir * radius * 1.384615) * 0.316216;
	col += texture(SCREEN_TEXTURE, SCREEN_UV - dir * radius * 1.384615) * 0.316216;
	col += texture(SCREEN_TEXTURE, SCREEN_UV + dir * radius * 3.230769) * 0.070270;
	col += texture(SCREEN_TEXTURE, SCREEN_UV - dir * radius * 3.230769) * 0.070270;
	COLOR = col;
}
