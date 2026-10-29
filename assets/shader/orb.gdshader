shader_type spatial;
render_mode unshaded, blend_add, cull_front, depth_draw_never;
uniform vec4 glow_color : source_color = vec4(0.3, 0.7, 1.0, 1.0);
uniform float intensity : hint_range(0.0, 5.0) = 2.0;
uniform float falloff : hint_range(0.5, 8.0) = 2.5;

uniform sampler2D noise_tex : repeat_enable;
uniform float noise_strength : hint_range(0.0, 1.0) = 0.5;
uniform float noise_scale = 2.0;
uniform float scroll_speed = 0.05;

varying vec3 local_pos;

void vertex() {
    local_pos = VERTEX;
}

void fragment() {
	float facing = clamp(abs(dot(NORMAL, VIEW)), 0.0, 1.0);
    float glow = pow(facing, falloff);

    vec2 uv = local_pos.xy * noise_scale + vec2(TIME * scroll_speed, TIME * scroll_speed * 0.7);
    float n = texture(noise_tex, uv).r;
    glow *= mix(1.0, n, noise_strength);

    ALBEDO = glow_color.rgb * intensity;
    ALPHA = clamp(glow, 0.0, 1.0);
}