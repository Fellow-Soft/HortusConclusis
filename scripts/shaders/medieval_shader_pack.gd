extends Node
class_name MedievalShaderPack

# Constants for shader parameters
const ILLUMINATION_INTENSITY = 0.5
const WEATHERING_AMOUNT = 0.3
const PARCHMENT_EFFECT = 0.2
const GOLD_ACCENT_INTENSITY = 0.7
const OUTLINE_THICKNESS = 0.02

# Create a medieval shader material with the specified shader type
static func create_medieval_shader_material(shader_type: String, base_color: Color = Color(0.8, 0.7, 0.5)) -> ShaderMaterial:
    var material = ShaderMaterial.new()
    var shader = null
    
    match shader_type:
        "illuminated":
            shader = create_illuminated_shader()
        "weathered":
            shader = create_weathered_shader()
        "stained_glass":
            shader = create_stained_glass_shader()
        "parchment":
            shader = create_parchment_shader()
        "stone_wall":
            shader = create_stone_wall_shader()
        "wood":
            shader = create_medieval_wood_shader()
        "fabric":
            shader = create_medieval_fabric_shader()
        "water":
            shader = create_medieval_water_shader()
        "ground":
            shader = create_medieval_ground_shader()
        "garden":
            shader = create_medieval_garden_shader()
        _:
            shader = create_illuminated_shader()
    
    material.shader = shader
    
    # Set common parameters
    if shader_type != "stained_glass" and shader_type != "water":
        material.set_shader_parameter("base_color", base_color)
    
    # Create and set noise texture (used by many shaders)
    var noise_texture = create_noise_texture()
    material.set_shader_parameter("noise_texture", noise_texture)
    
    # Set shader-specific parameters
    match shader_type:
        "illuminated":
            material.set_shader_parameter("illumination_intensity", ILLUMINATION_INTENSITY)
            material.set_shader_parameter("gold_accent_intensity", GOLD_ACCENT_INTENSITY)
            material.set_shader_parameter("use_gold_leaf", true)
            material.set_shader_parameter("main_texture", create_parchment_texture())
        
        "weathered":
            material.set_shader_parameter("weathering_amount", WEATHERING_AMOUNT)
            material.set_shader_parameter("roughness_value", 0.8)
            material.set_shader_parameter("main_texture", create_parchment_texture())
            material.set_shader_parameter("weathering_texture", noise_texture)
        
        "stained_glass":
            material.set_shader_parameter("glass_color", Color(0.2, 0.4, 0.8, 0.7))
            material.set_shader_parameter("pattern_intensity", 0.8)
            material.set_shader_parameter("glass_roughness", 0.1)
            material.set_shader_parameter("lead_line_width", 0.03)
            material.set_shader_parameter("pattern_texture", create_pattern_texture())
        
        "parchment":
            material.set_shader_parameter("parchment_color", Color(0.9, 0.85, 0.7))
            material.set_shader_parameter("ink_intensity", 0.8)
            material.set_shader_parameter("age_amount", 0.3)
            material.set_shader_parameter("use_gold_decoration", true)
            material.set_shader_parameter("parchment_texture", create_parchment_texture())
            material.set_shader_parameter("ink_texture", create_ink_texture())
        
        "stone_wall":
            material.set_shader_parameter("stone_color", Color(0.7, 0.7, 0.7))
            material.set_shader_parameter("mortar_color", Color(0.8, 0.8, 0.75))
            material.set_shader_parameter("moss_amount", 0.3)
            material.set_shader_parameter("mortar_width", 0.05)
            material.set_shader_parameter("stone_roughness", 0.8)
            material.set_shader_parameter("stone_texture", create_stone_texture())
            material.set_shader_parameter("moss_texture", create_moss_texture())
        
        "wood":
            material.set_shader_parameter("wood_color", Color(0.6, 0.4, 0.2))
            material.set_shader_parameter("grain_contrast", 0.5)
            material.set_shader_parameter("weathering_amount", 0.3)
            material.set_shader_parameter("wood_roughness", 0.8)
            material.set_shader_parameter("wood_texture", create_wood_texture())
            material.set_shader_parameter("detail_texture", noise_texture)
        
        "fabric":
            material.set_shader_parameter("fabric_color", Color(0.5, 0.2, 0.2))
            material.set_shader_parameter("pattern_intensity", 0.7)
            material.set_shader_parameter("use_gold_thread", false)
            material.set_shader_parameter("fabric_roughness", 0.9)
            material.set_shader_parameter("fabric_texture", create_fabric_texture())
            material.set_shader_parameter("pattern_texture", create_pattern_texture())
        
        "water":
            material.set_shader_parameter("water_color", Color(0.1, 0.3, 0.5, 0.8))
            material.set_shader_parameter("time_scale", 0.5)
            material.set_shader_parameter("ripple_strength", 0.2)
            material.set_shader_parameter("transparency", 0.7)
        
        "ground":
            material.set_shader_parameter("soil_color", Color(0.4, 0.3, 0.2))
            material.set_shader_parameter("detail_intensity", 0.5)
            material.set_shader_parameter("moisture", 0.5)
            material.set_shader_parameter("roughness_value", 0.9)
            material.set_shader_parameter("soil_texture", create_soil_texture())
            material.set_shader_parameter("detail_texture", noise_texture)
            
        "garden":
            material.set_shader_parameter("base_color", base_color)
            material.set_shader_parameter("pattern_intensity", 0.5)
            material.set_shader_parameter("geometric_intensity", 0.7)
            material.set_shader_parameter("weathering_amount", 0.3)
            material.set_shader_parameter("use_symbolic_elements", true)
            material.set_shader_parameter("garden_texture", create_soil_texture())
            material.set_shader_parameter("pattern_texture", create_pattern_texture())
    
    return material

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

# Create a procedural stone texture
static func create_stone_texture() -> Texture2D:
    var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
    img.fill(Color(0.7, 0.7, 0.7, 1.0))
    
    var rng = RandomNumberGenerator.new()
    rng.seed = 45678
    
    # Create a base stone texture with noise
    for y in range(256):
        for x in range(256):
            var noise_val = rng.randf_range(0.7, 1.0)
            var color = Color(
                0.7 * noise_val, 
                0.7 * noise_val, 
                0.7 * noise_val, 
                1.0
            )
            img.set_pixel(x, y, color)
    
    # Add some cracks
    var num_cracks = rng.randi_range(5, 10)
    for _ in range(num_cracks):
        var x = rng.randi_range(0, 255)
        var y = rng.randi_range(0, 255)
        var length = rng.randi_range(20, 100)
        var angle = rng.randf_range(0, 2 * PI)
        
        var end_x = x + int(length * cos(angle))
        var end_y = y + int(length * sin(angle))
        
        # Draw the crack
        var steps = length
        for i in range(steps):
            var t = float(i) / steps
            var crack_x = int(x + (end_x - x) * t + rng.randf_range(-2, 2))
            var crack_y = int(y + (end_y - y) * t + rng.randf_range(-2, 2))
            
            if crack_x >= 0 and crack_x < 256 and crack_y >= 0 and crack_y < 256:
                var current_color = img.get_pixel(crack_x, crack_y)
                var crack_color = Color(
                    current_color.r * 0.7,
                    current_color.g * 0.7,
                    current_color.b * 0.7,
                    1.0
                )
                img.set_pixel(crack_x, crack_y, crack_color)
                
                # Add some width to the crack
                for dx in range(-1, 2):
                    for dy in range(-1, 2):
                        var px = crack_x + dx
                        var py = crack_y + dy
                        if px >= 0 and px < 256 and py >= 0 and py < 256:
                            var dist = sqrt(dx * dx + dy * dy)
                            if dist <= 1.0:
                                var pixel_color = img.get_pixel(px, py)
                                var factor = 1.0 - (1.0 - 0.7) * (1.0 - dist)
                                var new_color = Color(
                                    pixel_color.r * factor,
                                    pixel_color.g * factor,
                                    pixel_color.b * factor,
                                    1.0
                                )
                                img.set_pixel(px, py, new_color)
    
    # Add some darker and lighter spots
    var num_spots = rng.randi_range(20, 40)
    for _ in range(num_spots):
        var x = rng.randi_range(0, 255)
        var y = rng.randi_range(0, 255)
        var radius = rng.randi_range(3, 10)
        var is_dark = rng.randf() < 0.7  # 70% chance of darker spots
        var factor = 0.8 if is_dark else 1.2
        
        for dx in range(-radius, radius + 1):
            for dy in range(-radius, radius + 1):
                var dist = sqrt(dx * dx + dy * dy)
                if dist <= radius and x + dx >= 0 and x + dx < 256 and y + dy >= 0 and y + dy < 256:
                    var current_color = img.get_pixel(x + dx, y + dy)
                    var spot_factor = factor * (1.0 - dist / radius)
                    var blend_factor = 0.5 * (1.0 - dist / radius)
                    var new_color = Color(
                        current_color.r * (1.0 - blend_factor) + current_color.r * spot_factor * blend_factor,
                        current_color.g * (1.0 - blend_factor) + current_color.g * spot_factor * blend_factor,
                        current_color.b * (1.0 - blend_factor) + current_color.b * spot_factor * blend_factor,
                        1.0
                    )
                    img.set_pixel(x + dx, y + dy, new_color)
    
    return ImageTexture.create_from_image(img)

# Create a procedural moss texture
static func create_moss_texture() -> Texture2D:
    var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
    img.fill(Color(0.0, 0.0, 0.0, 0.0))
    
    var rng = RandomNumberGenerator.new()
    rng.seed = 56789
    
    # Create a noise base for moss
    for y in range(256):
        for x in range(256):
            var noise1 = rng.randf()
            var noise2 = rng.randf()
            var noise3 = rng.randf()
            
            # Create a patchy pattern for moss
            var value = noise1 * noise2 * noise3
            value = pow(value, 0.5)  # Adjust contrast
            
            var color = Color(value, value, value, 1.0)
            img.set_pixel(x, y, color)
    
    # Add some moss clusters
    var num_clusters = rng.randi_range(10, 20)
    for _ in range(num_clusters):
        var x = rng.randi_range(0, 255)
        var y = rng.randi_range(0, 255)
        var radius = rng.randi_range(10, 30)
        
        for dx in range(-radius, radius + 1):
            for dy in range(-radius, radius + 1):
                var dist = sqrt(dx * dx + dy * dy)
                if dist <= radius and x + dx >= 0 and x + dx < 256 and y + dy >= 0 and y + dy < 256:
                    var current_color = img.get_pixel(x + dx, y + dy)
                    var intensity = 1.0 - dist / radius
                    intensity = pow(intensity, 0.5)  # Soften the falloff
                    
                    var new_color = Color(
                        current_color.r,
                        current_color.g + intensity * 0.5,  # Increase green channel for moss
                        current_color.b,
                        1.0
                    )
                    img.set_pixel(x + dx, y + dy, new_color)
    
    return ImageTexture.create_from_image(img)

# Create a procedural wood texture
static func create_wood_texture() -> Texture2D:
    var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
    img.fill(Color(0.6, 0.4, 0.2, 1.0))
    
    var rng = RandomNumberGenerator.new()
    rng.seed = 67890
    
    # Create wood grain pattern
    for y in range(256):
        for x in range(256):
            var noise = rng.randf()
            var grain = sin(y * 0.1 + noise * 0.5) * 0.5 + 0.5
            grain = pow(grain, 1.5)  # Adjust contrast
            
            var color = Color(
                0.6 * grain,
                0.4 * grain,
                0.2 * grain,
                1.0
            )
            img.set_pixel(x, y, color)
    
    # Add knots
    var num_knots = rng.randi_range(3, 7)
    for _ in range(num_knots):
        var x = rng.randi_range(20, 236)
        var y = rng.randi_range(20, 236)
        var radius = rng.randi_range(5, 15)
        
        for dx in range(-radius, radius + 1):
            for dy in range(-radius, radius + 1):
                var dist = sqrt(dx * dx + dy * dy)
                if dist <= radius and x + dx >= 0 and x + dx < 256 and y + dy >= 0 and y + dy < 256:
                    var current_color = img.get_pixel(x + dx, y + dy)
                    var intensity = 1.0 - dist / radius
                    intensity = pow(intensity, 0.5)
                    
                    var new_color = Color(
                        current_color.r * 0.7,  # Darker for knots
                        current_color.g * 0.7,
                        current_color.b * 0.7,
                        1.0
                    )
                    img.set_pixel(x + dx, y + dy, new_color)
    
    return ImageTexture.create_from_image(img)

# Create a procedural fabric texture
static func create_fabric_texture() -> Texture2D:
    var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
    img.fill(Color(0.5, 0.2, 0.2, 1.0))
    
    var rng = RandomNumberGenerator.new()
    rng.seed = 78901
    
    # Create fabric weave pattern
    for y in range(256):
        for x in range(256):
            var weave_x = sin(x * 0.5) * 0.5 + 0.5
            var weave_y = sin(y * 0.5) * 0.5 + 0.5
            var weave = (weave_x + weave_y) * 0.5
            
            var noise = rng.randf() * 0.2 + 0.9  # Slight random variation
            
            var color = Color(
                0.5 * weave * noise,
                0.2 * weave * noise,
                0.2 * weave * noise,
                1.0
            )
            img.set_pixel(x, y, color)
    
    return ImageTexture.create_from_image(img)

# Create a procedural soil texture
static func create_soil_texture() -> Texture2D:
    var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
    img.fill(Color(0.4, 0.3, 0.2, 1.0))
    
    var rng = RandomNumberGenerator.new()
    rng.seed = 89012
    
    # Create soil texture with variations
    for y in range(256):
        for x in range(256):
            var noise1 = rng.randf()
            var noise2 = rng.randf()
            var noise3 = rng.randf()
            
            var value = (noise1 + noise2 + noise3) / 3.0
            value = pow(value, 0.7)  # Adjust contrast
            
            var color = Color(
                0.4 * value,
                0.3 * value,
                0.2 * value,
                1.0
            )
            img.set_pixel(x, y, color)
    
    # Add some small rocks and debris
    var num_details = rng.randi_range(50, 100)
    for _ in range(num_details):
        var x = rng.randi_range(0, 255)
        var y = rng.randi_range(0, 255)
        var size = rng.randi_range(1, 4)
        var brightness = rng.randf_range(0.8, 1.2)
        
        for dx in range(-size, size + 1):
            for dy in range(-size, size + 1):
                if x + dx >= 0 and x + dx < 256 and y + dy >= 0 and y + dy < 256:
                    var current_color = img.get_pixel(x + dx, y + dy)
                    var new_color = Color(
                        current_color.r * brightness,
                        current_color.g * brightness,
                        current_color.b * brightness,
                        1.0
                    )
                    img.set_pixel(x + dx, y + dy, new_color)
    
    return ImageTexture.create_from_image(img)
