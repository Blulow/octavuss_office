shader_type canvas_item;

uniform float min_dist: hint_range(0.0, 1.0, 0.1) = 0.3;
uniform float max_dist: hint_range(0.0, 1.0, 0.1) = 0.4;
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
	vec2 dist = abs(UV - center);
	
	if (dist.x < min_dist && dist.y < min_dist) {
		COLOR.a = 0.0;
	} else if (dist.x < max_dist && dist.y < max_dist) {
		float ax = smoothstep(min_dist, max_dist, dist.x);
		float ay = smoothstep(min_dist, max_dist, dist.y);
		COLOR = vec4(COLOR.rgb, max(ax, ay));
	}
}
