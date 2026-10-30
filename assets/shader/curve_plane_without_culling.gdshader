shader_type spatial;

uniform float curve_strength : hint_range(-1.0, 1.0) = 0.1;
uniform int axis : hint_range(0, 5, 1) = 0;

uniform sampler2D albedo_tex : source_color;
uniform vec4 albedo_color : source_color = vec4(1.0);

void vertex() {
	switch (axis) {
		case 0:
    		VERTEX.y -= (VERTEX.x * VERTEX.x) * curve_strength;
			break;
		case 1:
    		VERTEX.x -= (VERTEX.z * VERTEX.z) * curve_strength;
			break;
		case 2:
    		VERTEX.z -= (VERTEX.y * VERTEX.y) * curve_strength;
			break;
		case 3:
    		VERTEX.x -= (VERTEX.y * VERTEX.y) * curve_strength;
			break;
		case 4:
    		VERTEX.y -= (VERTEX.z * VERTEX.z) * curve_strength;
			break;
		case 5:
    		VERTEX.z -= (VERTEX.x * VERTEX.x) * curve_strength;
			break;
	}
}

void fragment() {
	vec4 tex_color = texture(albedo_tex, UV);
    ALBEDO = tex_color.rgb * albedo_color.rgb;
    ALPHA = tex_color.a * albedo_color.a;
} 
