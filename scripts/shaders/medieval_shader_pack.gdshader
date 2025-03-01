shader_type spatial;

// Medieval aesthetic parameters
uniform vec4 base_color : source_color = vec4(0.8, 0.7, 0.5, 1.0);
uniform vec4 divine_light_color : source_color = vec4(1.0, 0.95, 0.7, 1.0);
uniform vec4 weathered_tint : source_color = vec4(0.6, 0.55, 0.5, 1.0);

// Textures
uniform sampler2D albedo_texture;
uniform sampler2D normal_texture;
uniform sampler2D roughness_texture;
uniform sampler2D detail_texture;
uniform sampler2D weathering_mask;

// Effect parameters
uniform float divine_light_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float weathering_amount : hint_range(0.0, 1.0) = 0.3;
uniform float detail_blend : hint_range(0.0, 1.0) = 0.5;
uniform float time_of_day : hint_range(0.0, 24.0) = 12.0;
uniform bool is_sacred : hint_boolean = false;

// Medieval-specific parameters
uniform float manuscript_rim : hint_range(0.0, 1.0) = 0.0;  // Illuminated manuscript effect
uniform float patina_amount : hint_range(0.0, 1.0) = 0.3;   // Medieval metal aging
uniform float moss_growth : hint_range(0.0, 1.0) = 0.2;     // Organic weathering

// Medieval-appropriate noise function
float medieval_noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
    // Add organic movement for plants and sacred objects
    if (is_sacred) {
        float movement = sin(TIME * 0.5 + VERTEX.x + VERTEX.z) * 0.02;
        VERTEX.y += movement;
    }
    
    // Normal-based displacement for weathering
    if (normal_texture != null) {
        vec4 normal_data = texture(normal_texture, UV);
        float weathering_disp = normal_data.r * weathering_amount * 0.2;
        VERTEX += NORMAL * weathering_disp;
    }
}

void fragment() {
    // Sample base textures
    vec4 albedo = texture(albedo_texture, UV);
    vec4 detail = texture(detail_texture, UV * 2.0);
    vec4 weather = texture(weathering_mask, UV);
    
    // Base color with medieval-appropriate mixing
    vec3 color = mix(base_color.rgb, albedo.rgb, 0.8);
    
    // Add detail with period-appropriate blending
    color = mix(color, color * detail.rgb, detail_blend);
    
    // Medieval weathering effects
    vec3 weathered = mix(color, weathered_tint.rgb, weather.r * weathering_amount);
    
    // Add patina effect for metals
    vec3 patina_color = vec3(0.4, 0.6, 0.5);  // Verdigris color
    weathered = mix(weathered, patina_color, weather.g * patina_amount);
    
    // Add moss effect
    vec3 moss_color = vec3(0.2, 0.3, 0.1);
    weathered = mix(weathered, moss_color, weather.b * moss_growth);
    
    // Time-of-day lighting
    float day_cycle = abs(sin(time_of_day * 3.14159 / 12.0));
    vec3 daylight = mix(vec3(0.7, 0.7, 1.0), vec3(1.0, 0.9, 0.7), day_cycle);
    color = weathered * daylight;
    
    // Illuminated manuscript rim effect
    float rim = pow(1.0 - dot(NORMAL, VIEW), 3.0);
    vec3 manuscript_gold = vec3(1.0, 0.9, 0.3);
    color = mix(color, manuscript_gold, rim * manuscript_rim);
    
    // Divine light effect for sacred objects
    if (is_sacred) {
        // Pulsing divine light
        float divine_pulse = (sin(TIME) * 0.5 + 0.5) * divine_light_intensity;
        
        // Calculate divine rim light
        float divine_rim = pow(1.0 - dot(NORMAL, VIEW), 2.0);
        vec3 divine_glow = mix(color, divine_light_color.rgb, divine_rim * divine_pulse);
        
        // Add subtle divine patterns
        float pattern = medieval_noise(UV * 10.0 + TIME * 0.1);
        divine_glow += divine_light_color.rgb * pattern * divine_pulse * 0.2;
        
        color = divine_glow;
    }
    
    // Output final color
    ALBEDO = color;
    
    // Material properties
    if (roughness_texture != null) {
        ROUGHNESS = texture(roughness_texture, UV).r;
    } else {
        // Default medieval material roughness
        ROUGHNESS = mix(0.8, 0.4, manuscript_rim);  // Smoother for manuscript effects
    }
    
    // Normal mapping
    if (normal_texture != null) {
        NORMAL_MAP = texture(normal_texture, UV).rgb;
    }
    
    // Specular reflection
    SPECULAR = mix(0.1, 0.4, manuscript_rim);  // Higher for manuscript gold
    
    // Emission for divine objects
    if (is_sacred) {
        float emission_pulse = (sin(TIME) * 0.5 + 0.5) * divine_light_intensity;
        EMISSION = divine_light_color.rgb * emission_pulse * 0.3;
    }
}
