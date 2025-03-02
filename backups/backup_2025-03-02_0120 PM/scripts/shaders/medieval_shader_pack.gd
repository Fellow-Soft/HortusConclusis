extends Node
class_name MedievalShaderPack

# Constants for shader parameters
const ILLUMINATION_INTENSITY = 0.5
const WEATHERING_AMOUNT = 0.3
const PARCHMENT_EFFECT = 0.2
const GOLD_ACCENT_INTENSITY = 0.7
const OUTLINE_THICKNESS = 0.02

# Create shader functions
static func create_illuminated_shader() -> Shader:
    var shader = Shader.new()
    shader.code = """
    shader_type spatial;
    uniform vec4 base_color : source_color = vec4(0.8, 0.7, 0.5, 1.0);
    uniform float illumination_intensity : hint_range(0.0, 1.0) = 0.5;
    uniform float gold_accent_intensity : hint_range(0.0, 1.0) = 0.7;
    uniform bool use_gold_leaf = true;
    uniform sampler2D main_texture;
    uniform sampler2D noise_texture;

    void fragment() {
        vec4 tex_color = texture(main_texture, UV);
        vec4 noise = texture(noise_texture, UV);
        
        vec4 final_color = base_color * tex_color;
        final_color.rgb += illumination_intensity * noise.rgb;
        
        if (use_gold_leaf) {
            float gold_mask = step(0.7, noise.r);
            vec3 gold_color = vec3(1.0, 0.8, 0.0);
            final_color.rgb = mix(final_color.rgb, gold_color, gold_mask * gold_accent_intensity);
        }
        
        ALBEDO = final_color.rgb;
        METALLIC = use_gold_leaf ? gold_accent_intensity : 0.0;
        ROUGHNESS = 0.5;
    }
    """
    return shader

static func create_weathered_shader() -> Shader:
    var shader = Shader.new()
    shader.code = """
    shader_type spatial;
    uniform vec4 base_color : source_color;
    uniform float weathering_amount : hint_range(0.0, 1.0);
    uniform float roughness_value : hint_range(0.0, 1.0);
    uniform sampler2D main_texture;
    uniform sampler2D weathering_texture;

    void fragment() {
        vec4 tex_color = texture(main_texture, UV);
        vec4 weathering = texture(weathering_texture, UV);
        
        vec4 final_color = base_color * tex_color;
        final_color.rgb = mix(final_color.rgb, final_color.rgb * weathering.rgb, weathering_amount);
        
        ALBEDO = final_color.rgb;
        ROUGHNESS = roughness_value;
    }
    """
    return shader

static func create_stained_glass_shader() -> Shader:
    var shader = Shader.new()
    shader.code = """
    shader_type spatial;
    uniform vec4 glass_color : source_color;
    uniform float pattern_intensity : hint_range(0.0, 1.0);
    uniform float glass_roughness : hint_range(0.0, 1.0);
    uniform float lead_line_width : hint_range(0.0, 0.1);
    uniform sampler2D pattern_texture;

    void fragment() {
        vec4 pattern = texture(pattern_texture, UV);
        float lead_mask = step(1.0 - lead_line_width, max(fract(UV.x * 10.0), fract(UV.y * 10.0)));
        
        vec3 final_color = mix(glass_color.rgb, pattern.rgb, pattern_intensity);
        final_color = mix(final_color, vec3(0.2), lead_mask);
        
        ALBEDO = final_color;
        ALPHA = glass_color.a;
        METALLIC = lead_mask;
        ROUGHNESS = mix(glass_roughness, 0.8, lead_mask);
    }
    """
    return shader

static func create_parchment_shader() -> Shader:
    var shader = Shader.new()
    shader.code = """
    shader_type spatial;
    uniform vec4 parchment_color : source_color;
    uniform float ink_intensity : hint_range(0.0, 1.0);
    uniform float age_amount : hint_range(0.0, 1.0);
    uniform bool use_gold_decoration;
    uniform sampler2D parchment_texture;
    uniform sampler2D ink_texture;

    void fragment() {
        vec4 parchment = texture(parchment_texture, UV);
        vec4 ink = texture(ink_texture, UV);
        
        vec3 aged_color = mix(parchment_color.rgb, parchment_color.rgb * 0.7, age_amount * parchment.r);
        vec3 final_color = mix(aged_color, vec3(0.0), ink.r * ink_intensity);
        
        if (use_gold_decoration && ink.g > 0.5) {
            final_color = mix(final_color, vec3(1.0, 0.8, 0.0), ink.g);
        }
        
        ALBEDO = final_color;
        ROUGHNESS = mix(0.9, 0.3, float(use_gold_decoration && ink.g > 0.5));
        METALLIC = float(use_gold_decoration && ink.g > 0.5);
    }
    """
    return shader

static func create_stone_wall_shader() -> Shader:
    var shader = Shader.new()
    shader.code = """
    shader_type spatial;
    uniform vec4 stone_color : source_color;
    uniform vec4 mortar_color : source_color;
    uniform float moss_amount : hint_range(0.0, 1.0);
    uniform float mortar_width : hint_range(0.0, 0.1);
    uniform float stone_roughness : hint_range(0.0, 1.0);
    uniform sampler2D stone_texture;
    uniform sampler2D moss_texture;

    void fragment() {
        vec4 stone = texture(stone_texture, UV);
        vec4 moss = texture(moss_texture, UV);
        
        float mortar_mask = step(1.0 - mortar_width, max(fract(UV.x * 5.0), fract(UV.y * 5.0)));
        vec3 base = mix(stone_color.rgb * stone.rgb, mortar_color.rgb, mortar_mask);
        vec3 final_color = mix(base, vec3(0.2, 0.4, 0.1), moss.g * moss_amount);
        
        ALBEDO = final_color;
        ROUGHNESS = mix(stone_roughness, 1.0, mortar_mask);
    }
    """
    return shader

static func create_medieval_wood_shader() -> Shader:
    var shader = Shader.new()
    shader.code = """
    shader_type spatial;
    uniform vec4 wood_color : source_color;
    uniform float grain_contrast : hint_range(0.0, 1.0);
    uniform float weathering_amount : hint_range(0.0, 1.0);
    uniform float wood_roughness : hint_range(0.0, 1.0);
    uniform sampler2D wood_texture;
    uniform sampler2D detail_texture;

    void fragment() {
        vec4 wood = texture(wood_texture, UV);
        vec4 detail = texture(detail_texture, UV);
        
        vec3 grain = mix(wood_color.rgb, wood_color.rgb * wood.rgb, grain_contrast);
        vec3 final_color = mix(grain, grain * detail.rgb, weathering_amount);
        
        ALBEDO = final_color.rgb;
        ROUGHNESS = wood_roughness;
    }
    """
    return shader

static func create_medieval_fabric_shader() -> Shader:
    var shader = Shader.new()
    shader.code = """
    shader_type spatial;
    uniform vec4 fabric_color : source_color;
    uniform float pattern_intensity : hint_range(0.0, 1.0);
    uniform bool use_gold_thread;
    uniform float fabric_roughness : hint_range(0.0, 1.0);
    uniform sampler2D fabric_texture;
    uniform sampler2D pattern_texture;

    void fragment() {
        vec4 fabric = texture(fabric_texture, UV);
        vec4 pattern = texture(pattern_texture, UV);
        
        vec3 base = fabric_color.rgb * fabric.rgb;
        vec3 pattern_color = use_gold_thread ? vec3(1.0, 0.8, 0.0) : fabric_color.rgb * 0.7;
        vec3 final_color = mix(base, pattern_color, pattern.r * pattern_intensity);
        
        ALBEDO = final_color;
        ROUGHNESS = fabric_roughness;
        METALLIC = float(use_gold_thread) * pattern.r * pattern_intensity;
    }
    """
    return shader

static func create_medieval_water_shader() -> Shader:
    var shader = Shader.new()
    shader.code = """
    shader_type spatial;
    uniform vec4 water_color : source_color;
    uniform float time_scale : hint_range(0.0, 2.0);
    uniform float ripple_strength : hint_range(0.0, 1.0);
    uniform float transparency : hint_range(0.0, 1.0);

    void fragment() {
        float time = TIME * time_scale;
        vec2 uv = UV * 10.0;
        
        float ripple = sin(uv.x + time) * cos(uv.y + time) * ripple_strength;
        vec3 final_color = water_color.rgb + ripple;
        
        ALBEDO = final_color;
        ALPHA = transparency;
        METALLIC = 0.3;
        ROUGHNESS = 0.1;
    }
    """
    return shader

static func create_medieval_ground_shader() -> Shader:
    var shader = Shader.new()
    shader.code = """
    shader_type spatial;
    uniform vec4 soil_color : source_color;
    uniform float detail_intensity : hint_range(0.0, 1.0);
    uniform float moisture : hint_range(0.0, 1.0);
    uniform float roughness_value : hint_range(0.0, 1.0);
    uniform sampler2D soil_texture;
    uniform sampler2D detail_texture;

    void fragment() {
        vec4 soil = texture(soil_texture, UV);
        vec4 detail = texture(detail_texture, UV);
        
        vec3 base = soil_color.rgb * soil.rgb;
        vec3 final_color = mix(base, base * detail.rgb, detail_intensity);
        final_color *= mix(1.0, 0.7, moisture);
        
        ALBEDO = final_color;
        ROUGHNESS = roughness_value;
    }
    """
    return shader

static func create_medieval_garden_shader() -> Shader:
    var shader = Shader.new()
    shader.code = """
    shader_type spatial;
    uniform vec4 base_color : source_color;
    uniform float pattern_intensity : hint_range(0.0, 1.0);
    uniform float geometric_intensity : hint_range(0.0, 1.0);
    uniform float weathering_amount : hint_range(0.0, 1.0);
    uniform bool use_symbolic_elements;
    uniform sampler2D garden_texture;
    uniform sampler2D pattern_texture;

    void fragment() {
        vec4 garden = texture(garden_texture, UV);
        vec4 pattern = texture(pattern_texture, UV);
        
        vec3 base = base_color.rgb * garden.rgb;
        vec3 geometric = mix(base, pattern.rgb, geometric_intensity);
        vec3 final_color = mix(base, geometric, pattern_intensity);
        
        if (use_symbolic_elements) {
            float symbol_mask = step(0.8, pattern.r);
            final_color = mix(final_color, base_color.rgb, symbol_mask * 0.5);
        }
        
        final_color *= mix(1.0, garden.rgb, weathering_amount);
        
        ALBEDO = final_color;
        ROUGHNESS = 0.8;
    }
    """
    return shader

# Create a procedural noise texture
static func create_noise_texture() -> Texture2D:
    var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
    img.fill(Color(0.5, 0.5, 0.5, 1.0))
    
    var rng = RandomNumberGenerator.new()
    rng.seed = 67890
    
    # Generate noise
    for y in range(256):
        for x in range(256):
            var noise1 = rng.randf()
            var noise2 = rng.randf()
            var color = Color(noise1, noise2, rng.randf(), 1.0)
            img.set_pixel(x, y, color)
    
    return ImageTexture.create_from_image(img)

# Create a procedural parchment texture
static func create_parchment_texture() -> Texture2D:
    var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
    img.fill(Color(0.9, 0.85, 0.7, 1.0))
    
    var rng = RandomNumberGenerator.new()
    rng.seed = 12345
    
    # Add noise to create parchment texture
    for y in range(256):
        for x in range(256):
            var noise_val = rng.randf_range(0.85, 1.0)
            var color = Color(
                0.9 * noise_val, 
                0.85 * noise_val, 
                0.7 * noise_val, 
                1.0
            )
            img.set_pixel(x, y, color)
    
    # Add some darker spots randomly
    for i in range(100):
        var x = rng.randi_range(0, 255)
        var y = rng.randi_range(0, 255)
        var radius = rng.randi_range(1, 5)
        var darkness = rng.randf_range(0.7, 0.9)
        
        for dx in range(-radius, radius + 1):
            for dy in range(-radius, radius + 1):
                var dist = sqrt(dx * dx + dy * dy)
                if dist <= radius and x + dx >= 0 and x + dx < 256 and y + dy >= 0 and y + dy < 256:
                    var current_color = img.get_pixel(x + dx, y + dy)
                    var factor = 1.0 - (dist / radius) * (1.0 - darkness)
                    var new_color = Color(
                        current_color.r * factor,
                        current_color.g * factor,
                        current_color.b * factor,
                        1.0
                    )
                    img.set_pixel(x + dx, y + dy, new_color)
    
    return ImageTexture.create_from_image(img)

# Create a procedural pattern texture
static func create_pattern_texture() -> Texture2D:
    var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
    img.fill(Color(0.5, 0.5, 0.5, 1.0))
    
    var rng = RandomNumberGenerator.new()
    rng.seed = 23456
    
    # Create a medieval-style pattern
    var grid_size = 64
    var num_cells = 256 / grid_size
    
    for cy in range(num_cells):
        for cx in range(num_cells):
            # Choose a pattern type for this cell
            var pattern_type = rng.randi() % 5
            var cell_color = Color(
                rng.randf_range(0.3, 0.9),
                rng.randf_range(0.3, 0.9),
                rng.randf_range(0.3, 0.9),
                1.0
            )
            
            # Fill the cell with the pattern
            for y in range(grid_size):
                for x in range(grid_size):
                    var px = cx * grid_size + x
                    var py = cy * grid_size + y
                    
                    var pattern_value = 0.0
                    
                    match pattern_type:
                        0: # Diagonal stripes
                            pattern_value = float((x + y) % 16 < 8)
                        1: # Checkerboard
                            pattern_value = float(int(x / 8 + y / 8) % 2 == 0)
                        2: # Circles
                            var center_x = grid_size / 2
                            var center_y = grid_size / 2
                            var dist = sqrt(pow(x - center_x, 2) + pow(y - center_y, 2))
                            pattern_value = float(int(dist) % 16 < 8)
                        3: # Cross
                            var center_x = grid_size / 2
                            var center_y = grid_size / 2
                            pattern_value = float(abs(x - center_x) < 8 or abs(y - center_y) < 8)
                        4: # Fleur-de-lis (simplified)
                            var center_x = grid_size / 2
                            var center_y = grid_size / 2
                            var dist = sqrt(pow(x - center_x, 2) + pow(y - center_y, 2))
                            pattern_value = float(dist < 20 and (
                                abs(x - center_x) < 8 or 
                                abs(y - center_y) < 8 or
                                (y < center_y and abs(x - center_x) < 16 * (1 - y / center_y))
                            ))
                    
                    var pixel_color = Color(
                        cell_color.r * pattern_value,
                        cell_color.g * pattern_value,
                        cell_color.b * pattern_value,
                        1.0
                    )
                    
                    img.set_pixel(px, py, pixel_color)
    
    return ImageTexture.create_from_image(img)

# Create a procedural ink texture
static func create_ink_texture() -> Texture2D:
    var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
    img.fill(Color(0.0, 0.0, 0.0, 0.0))
    
    var rng = RandomNumberGenerator.new()
    rng.seed = 34567
    
    # Create some text-like patterns
    var num_lines = 12
    var line_height = 256 / num_lines
    
    for line in range(num_lines):
        var y = line * line_height + line_height / 2
        var line_length = rng.randi_range(150, 220)
        var x_start = rng.randi_range(10, 30)
        
        # Draw a line of "text"
        for x in range(x_start, x_start + line_length):
            if x >= 256:
                break
                
            # Vary the height slightly to simulate handwriting
            var y_offset = rng.randf_range(-2, 2)
            var height = rng.randf_range(2, 6)
            
            # Draw a vertical line for this character
            for dy in range(-int(height), int(height) + 1):
                var py = y + dy + y_offset
                if py >= 0 and py < 256:
                    var intensity = 1.0 - abs(float(dy) / height)
                    var color = Color(intensity, intensity * 0.5, 0.0, 1.0)
                    img.set_pixel(x, py, color)
            
            # Skip some space for the next "character"
            x += rng.randi_range(3, 8)
    
    # Add some decorative elements (for gold decoration)
    var num_decorations = rng.randi_range(3, 6)
    for decoration_index in range(num_decorations):
        var x = rng.randi_range(20, 236)
        var y = rng.randi_range(20, 236)
        var size = rng.randi_range(10, 20)
        
        # Draw a decorative element (circle, cross, etc.)
        var decoration_type = rng.randi() % 3
        
        match decoration_type:
            0: # Circle
                for dx in range(-size, size + 1):
                    for dy in range(-size, size + 1):
                        var dist = sqrt(dx * dx + dy * dy)
                        if dist <= size and x + dx >= 0 and x + dx < 256 and y + dy >= 0 and y + dy < 256:
                            var intensity = 1.0 - dist / size
                            var color = Color(0.0, intensity, intensity, 1.0)
                            img.set_pixel(x + dx, y + dy, color)
            
            1: # Cross
                for dx in range(-size, size + 1):
                    for dy in range(-size, size + 1):
                        if (abs(dx) < size / 4 or abs(dy) < size / 4) and x + dx >= 0 and x + dx < 256 and y + dy >= 0 and y + dy < 256:
                            var dist = max(abs(dx), abs(dy))
                            var intensity = 1.0 - float(dist) / size
                            var color = Color(0.0, intensity, intensity, 1.0)
                            img.set_pixel(x + dx, y + dy, color)
            
            2: # Border
                for dx in range(-size, size + 1):
                    for dy in range(-size, size + 1):
                        if (abs(dx) == size or abs(dy) == size) and x + dx >= 0 and x + dx < 256 and y + dy >= 0 and y + dy < 256:
                            var color = Color(0.0, 1.0, 1.0, 1.0)
                            img.set_pixel(x + dx, y + dy, color)
    
    return ImageTexture.create_from_image(img)
