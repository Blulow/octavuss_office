shader_type canvas_item;

// Grab the fully rendered 3D screen texture
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// Tune these parameters inside the Inspector
uniform vec4 line_color : source_color = vec4(0.1, 0.1, 0.1, 1.0);
uniform float line_thickness : hint_range(0.0, 5.0) = 1.0;
uniform float color_steps : hint_range(2.0, 50.0) = 5.0; // Flattens shading
uniform float paper_grain_strength : hint_range(0.0, 0.2) = 0.05;

// Pseudo-random noise for the paper pulp texture
float noise(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // 1. Sample the rendered 3D scene
    vec3 scene_color = texture(screen_texture, uv).rgb;
    
    // 2. Posterize (Compress smooth gradients into flat paper-ink blocks)
    scene_color = floor(scene_color * color_steps) / color_steps;
    
    // 3. Screen-space Edge Detection (Detects sharp color differences for lines)
    vec2 size = SCREEN_PIXEL_SIZE * line_thickness;
    
    vec3 col_c = texture(screen_texture, uv).rgb;
    vec3 col_l = texture(screen_texture, uv + vec2(-size.x, 0.0)).rgb;
    vec3 col_r = texture(screen_texture, uv + vec2(size.x, 0.0)).rgb;
    vec3 col_t = texture(screen_texture, uv + vec2(0.0, -size.y)).rgb;
    vec3 col_b = texture(screen_texture, uv + vec2(0.0, size.y)).rgb;
    
    // Calculate color variance across neighbors
    float edge = distance(col_c, col_l) + 
                 distance(col_c, col_r) + 
                 distance(col_c, col_t) + 
                 distance(col_c, col_b);
                 
    // 4. Inject paper pulp noise grain
    float grain = noise(uv * 900.0) * paper_grain_strength;
    scene_color -= vec3(grain);
    
    // 5. Apply the ink line if the color boundary changes fast enough
    if (edge > 0.15) {
        COLOR = vec4(line_color.rgb, 1.0);
    } else {
        COLOR = vec4(scene_color, 1.0);
    }
}