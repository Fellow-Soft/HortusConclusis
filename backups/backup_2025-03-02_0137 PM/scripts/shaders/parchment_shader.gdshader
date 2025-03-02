shader_type canvas_item;

// Parchment and illuminated manuscript parameters
uniform float age : hint_range(0.0, 1.0) = 0.7;
uniform float noise_scale : hint_range(0.1, 10.0) = 4.0;
uniform float texture_distortion : hint_range(0.0, 1.0) = 0.05;
uniform vec4 parchment_color : source_color = vec4(0.95, 0.9, 0.75, 1.0);
uniform vec4 aging_color : source_color = vec4(0.85, 0.75, 0.55, 1.0);
uniform vec4 ink_color : source_color = vec4(0.2, 0.1, 0.05, 1.0);
uniform float illumination_intensity : hint_range(0.0, 1.0) = 0.4;
uniform vec4 gold_color : source_color = vec4(1.0, 0.85, 0.3, 1.0);

// Time-based animation
uniform float animation_speed : hint_range(0.0, 2.0) = 0.2;

// Noise function for parchment texture
float medieval_noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

// Improved noise for better parchment texture
float improved_noise(vec2 p) {
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u * u * (3.0 - 2.0 * u);
    
    float res = mix(
        mix(medieval_noise(ip), medieval_noise(ip + vec2(1.0, 0.0)), u.x),
        mix(medieval_noise(ip + vec2(0.0, 1.0)), medieval_noise(ip + vec2(1.0, 1.0)), u.x),
        u.y);
    return res * res;
}

// Creates fiber-like patterns for parchment texture
float fbm(vec2 uv) {
    float f = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    for(int i = 0; i < 5; i++) {
        f += amplitude * improved_noise(frequency * uv);
        frequency *= 2.2;
        amplitude *= 0.5;
    }
    return f;
}

void fragment() {
    // Create base parchment texture
    vec2 distorted_uv = UV;
    distorted_uv.x += texture_distortion * sin(UV.y * 10.0 + TIME * animation_speed);
    distorted_uv.y += texture_distortion * cos(UV.x * 10.0 + TIME * animation_speed * 0.7);
    
    // Create fiber-like texture for parchment
    float noise = fbm(distorted_uv * noise_scale);
    
    // Create stains and aging patterns
    float aging_pattern = fbm(distorted_uv * noise_scale * 0.5 + vec2(0.1, 0.3));
    aging_pattern = pow(aging_pattern, 1.5) * age;
    
    // Create edge darkening effect
    float edge_x = min(UV.x, 1.0 - UV.x) * 2.0;
    float edge_y = min(UV.y, 1.0 - UV.y) * 2.0;
    float edge_darkening = min(edge_x, edge_y);
    edge_darkening = pow(edge_darkening, 0.5) * (1.0 - age * 0.5);
    
    // Mix parchment and aging colors
    vec4 color = mix(parchment_color, aging_color, aging_pattern);
    
    // Apply edge darkening
    color = mix(aging_color * 0.8, color, edge_darkening);
    
    // Add subtle illumination glow
    float time_factor = (sin(TIME * animation_speed) + 1.0) * 0.5;
    float illumination = pow(noise, 3.0) * illumination_intensity * time_factor;
    color = mix(color, gold_color, illumination);
    
    // Add tiny ink speckles
    float ink_speckles = step(0.98, medieval_noise(UV * 150.0));
    color = mix(color, ink_color, ink_speckles * 0.1);
    
    // Apply final color
    COLOR = color;
}
