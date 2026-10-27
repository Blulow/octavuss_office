shader_type spatial;

uniform float curve_strength : hint_range(-1.0, 1.0) = 0.1;

uniform sampler2D albedo_tex : source_color;
uniform vec4 albedo_color : source_color = vec4(1.0);

void vertex() {
    VERTEX.y -= (VERTEX.x * VERTEX.x) * curve_strength;
}

void fragment() {
	vec4 tex_color = texture(albedo_tex, UV);
    ALBEDO = tex_color.rgb * albedo_color.rgb;
    ALPHA = tex_color.a * albedo_color.a;
} 
