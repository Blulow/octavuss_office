shader_type spatial;

uniform bool use_color = false;
uniform vec4 color : source_color;
uniform sampler2D albedo_texture;
uniform float noise_amount : hint_range(0.0, 1.0) = 0.1;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 base_color;
    if (!use_color) base_color = texture(albedo_texture, UV);
    
	float n = hash(UV) * 2.0 - 1.0; // Dynamic noise changing with TIME
    
    if (use_color) {
		ALBEDO = color.rgb + n * noise_amount;
	    ALPHA = color.a;
	} else {
		ALBEDO = base_color.rgb + n * noise_amount;
	   	ALPHA = base_color.a;
	}
}