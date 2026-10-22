shader_type spatial;
render_mode unshaded, blend_mix, cull_back;

instance uniform bool show = false;
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D normal_roughness_texture : hint_normal_roughness_texture, filter_linear_mipmap;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float normal_threshold : hint_range(0.0, 2.0) = 0.5;
uniform float depth_threshold : hint_range(0.0, 1.0) = 0.05;
uniform float outline_thickness : hint_range(0.5, 10.0) = 1.0;

uniform bool constant_width = true;
uniform float distance_falloff : hint_range(0.01, 1.0) = 0.1;

void fragment() {
	if (!show) discard;
	
    vec2 pixel_size = vec2(1.0) / vec2(VIEWPORT_SIZE);
    
    float final_thickness = outline_thickness;
    
    if (!constant_width) {
        float depth = texture(depth_texture, SCREEN_UV).r;
        
        vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
        vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
        float linear_depth = -view.z / view.w;
        
        final_thickness = outline_thickness / max(linear_depth * distance_falloff, 0.1);
    }
    
    vec2 offset = pixel_size * final_thickness;
    
    vec2 uv = SCREEN_UV;
    vec2 uv_u = uv + vec2(0.0, offset.y);
    vec2 uv_d = uv - vec2(0.0, offset.y);
    vec2 uv_l = uv + vec2(offset.x, 0.0);
    vec2 uv_r = uv - vec2(offset.x, 0.0);
    
    vec3 n_u = texture(normal_roughness_texture, uv_u).xyz * 2.0 - 1.0;
    vec3 n_d = texture(normal_roughness_texture, uv_d).xyz * 2.0 - 1.0;
    vec3 n_l = texture(normal_roughness_texture, uv_l).xyz * 2.0 - 1.0;
    vec3 n_r = texture(normal_roughness_texture, uv_r).xyz * 2.0 - 1.0;
    
    float d_u = texture(depth_texture, uv_u).r;
    float d_d = texture(depth_texture, uv_d).r;
    float d_l = texture(depth_texture, uv_l).r;
    float d_r = texture(depth_texture, uv_r).r;
    
    float normal_edge = length(n_l - n_r) + length(n_u - n_d);
    float depth_edge = abs(d_l - d_r) + abs(d_u - d_d);
    
    bool is_edge = (normal_edge > normal_threshold) || (depth_edge > depth_threshold);
    
    if (is_edge) {
        ALBEDO = outline_color.rgb;
        ALPHA = outline_color.a;
    } else {
        discard; 
    }
}