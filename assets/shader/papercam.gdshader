shader_type spatial;
render_mode unshaded, skip_vertex_transform;

// Grab textures from Godot screen memory
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform sampler2D depth_texture : hint_depth_texture, filter_nearest;

// Style variables you can tune in Inspector
uniform vec4 line_color : source_color = vec4(0.1, 0.1, 0.1, 1.0);
uniform float line_thickness : hint_range(0.0, 5.0) = 1.0;
uniform float color_steps : hint_range(2.0, 16.0) = 5.0; // Flattens colors
uniform float paper_grain_strength : hint_range(0.0, 0.2) = 0.05;

void vertex() {
    // Locks the quad directly to the camera screen
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

// Pseudo-random function to generate a fast paper pulp noise grid
float noise(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // 1. Sample base screen colors
    vec3 scene_color = texture(screen_texture, uv).rgb;
    
    // 2. Posterize (Flatten the color shading into distinct paper-ink bands)
    scene_color = floor(scene_color * color_steps) / color_steps;
    
    // 3. Sobel Edge Detection (Draws ink lines based on 3D depth changes)
    vec2 size = (1.0 / VIEWPORT_SIZE) * line_thickness;
    float depth_center = texture(depth_texture, uv).r;
    float depth_left   = texture(depth_texture, uv + vec2(-size.x, 0.0)).r;
    float depth_right  = texture(depth_texture, uv + vec2(size.x, 0.0)).r;
    float depth_top    = texture(depth_texture, uv + vec2(0.0, -size.y)).r;
    float depth_bottom = texture(depth_texture, uv + vec2(0.0, size.y)).r;
    
    float edge = abs(depth_center - depth_left) + 
                 abs(depth_center - depth_right) + 
                 abs(depth_center - depth_top) + 
                 abs(depth_center - depth_bottom);
                 
    // 4. Mix in paper pulp grain over the screen
    float grain = noise(uv * 1000.0) * paper_grain_strength;
    scene_color -= vec3(grain);
    
    // 5. Output color or blend into ink outline if depth jumps sharply
    if (edge > 0.005) {
        ALBEDO = line_color.rgb;
    } else {
        ALBEDO = scene_color;
    }
}