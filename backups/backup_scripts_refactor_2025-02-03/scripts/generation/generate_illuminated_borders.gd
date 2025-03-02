extends Node

# This script generates decorative border elements with various patterns
# inspired by medieval illuminated manuscripts

class_name BorderGenerator

# Border patterns
enum BorderPattern {
    CORNER_FLOURISH,
    VINE_BORDER,
    GEOMETRIC_KNOT,
    SACRED_GEOMETRY,
    FLORAL_ORNAMENT,
    CELTIC_KNOT
}

# Utility functions for generating borders
static func generate_corner_flourish(size: Vector2, color: Color = Color(0.9, 0.7, 0.2, 1.0)) -> Texture2D:
    var image = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
    image.fill(Color(0, 0, 0, 0))  # Start with transparent
    
    var center = size / 2
    var radius = min(size.x, size.y) * 0.45
    
    # Draw the main spiral
    for i in range(0, 360 * 3, 2):
        var angle = deg_to_rad(i)
        var spiral_radius = radius * (1.0 - i / (360.0 * 3.0))
        var x = center.x + cos(angle) * spiral_radius
        var y = center.y + sin(angle) * spiral_radius
        
        if x >= 0 and x < size.x and y >= 0 and y < size.y:
            var pixel_color = color
            pixel_color.a = 0.6 + 0.4 * (1.0 - i / (360.0 * 3.0))
            image.set_pixel(int(x), int(y), pixel_color)
    
    # Add ornamental dots along spiral
    for i in range(0, 360 * 3, 45):
        var angle = deg_to_rad(i)
        var dot_radius = radius * (1.0 - i / (360.0 * 3.0))
        var x = center.x + cos(angle) * dot_radius
        var y = center.y + sin(angle) * dot_radius
        
        if x >= 0 and x < size.x and y >= 0 and y < size.y:
            _draw_circle(image, Vector2(x, y), 3, color)
    
    # Add leaf-like elements
    for i in range(0, 360, 90):
        var angle = deg_to_rad(i)
        var leaf_dist = radius * 0.7
        var leaf_center = Vector2(
            center.x + cos(angle) * leaf_dist,
            center.y + sin(angle) * leaf_dist
        )
        
        _draw_leaf(image, leaf_center, 15, angle + PI/4, color)
    
    var texture = ImageTexture.create_from_image(image)
    return texture

static func generate_sacred_geometry(size: Vector2, color: Color = Color(0.9, 0.7, 0.2, 1.0)) -> Texture2D:
    var image = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
    image.fill(Color(0, 0, 0, 0))  # Start with transparent
    
    var center = size / 2
    var radius = min(size.x, size.y) * 0.45
    
    # Draw Flower of Life pattern
    _draw_flower_of_life(image, center, radius, color)
    
    var texture = ImageTexture.create_from_image(image)
    return texture

static func generate_vine_border(size: Vector2, color: Color = Color(0.9, 0.7, 0.2, 1.0)) -> Texture2D:
    var image = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
    image.fill(Color(0, 0, 0, 0))  # Start with transparent
    
    var center = size / 2
    var max_radius = min(size.x, size.y) * 0.45
    
    # Draw vine spirals
    for i in range(0, 360, 45):
        var angle = deg_to_rad(i)
        var start_point = Vector2(
            center.x + cos(angle) * max_radius * 0.2,
            center.y + sin(angle) * max_radius * 0.2
        )
        
        _draw_vine(image, start_point, angle, max_radius * 0.8, color)
    
    var texture = ImageTexture.create_from_image(image)
    return texture

# Helper functions
static func _draw_circle(image: Image, center: Vector2, radius: float, color: Color) -> void:
    for x in range(max(0, int(center.x - radius)), min(image.get_width(), int(center.x + radius + 1))):
        for y in range(max(0, int(center.y - radius)), min(image.get_height(), int(center.y + radius + 1))):
            var dist = Vector2(x, y).distance_to(center)
            if dist <= radius:
                var alpha = 1.0 - dist / radius
                var pixel_color = color
                pixel_color.a = color.a * alpha
                image.set_pixel(x, y, pixel_color)

static func _draw_line(image: Image, from: Vector2, to: Vector2, width: float, color: Color) -> void:
    var direction = to - from
    var length = direction.length()
    direction = direction.normalized()
    var perpendicular = Vector2(-direction.y, direction.x)
    
    for i in range(int(length)):
        var point = from + direction * i
        for w in range(-int(width/2), int(width/2) + 1):
            var offset = perpendicular * w
            var px = int(point.x + offset.x)
            var py = int(point.y + offset.y)
            
            if px >= 0 and px < image.get_width() and py >= 0 and py < image.get_height():
                var alpha = 1.0 - abs(w) / (width / 2)
                var pixel_color = color
                pixel_color.a = color.a * alpha
                image.set_pixel(px, py, pixel_color)

static func _draw_leaf(image: Image, center: Vector2, size: float, angle: float, color: Color) -> void:
    var direction = Vector2(cos(angle), sin(angle))
    var perpendicular = Vector2(-direction.y, direction.x)
    
    for i in range(int(size)):
        var width = size * 0.5 * sin(PI * i / size)
        var point = center + direction * i
        
        for w in range(-int(width), int(width) + 1):
            var offset = perpendicular * w / width * 0.5
            var px = int(point.x + offset.x * width)
            var py = int(point.y + offset.y * width)
            
            if px >= 0 and px < image.get_width() and py >= 0 and py < image.get_height():
                var alpha = 1.0 - abs(w) / width
                var pixel_color = color
                pixel_color.a = color.a * alpha
                image.set_pixel(px, py, pixel_color)

static func _draw_flower_of_life(image: Image, center: Vector2, radius: float, color: Color) -> void:
    # Draw center circle
    _draw_circle(image, center, radius * 0.2, color)
    
    # Draw surrounding circles
    for i in range(0, 6):
        var angle = deg_to_rad(i * 60)
        var circle_center = Vector2(
            center.x + cos(angle) * radius * 0.4,
            center.y + sin(angle) * radius * 0.4
        )
        _draw_circle(image, circle_center, radius * 0.2, color)
    
    # Draw outer ring
    for i in range(0, 12):
        var angle = deg_to_rad(i * 30)
        var circle_center = Vector2(
            center.x + cos(angle) * radius * 0.7,
            center.y + sin(angle) * radius * 0.7
        )
        _draw_circle(image, circle_center, radius * 0.2, color)

static func _draw_vine(image: Image, start: Vector2, angle: float, length: float, color: Color) -> void:
    var current_point = start
    var current_angle = angle
    var step_size = 2.0
    
    for i in range(int(length / step_size)):
        # Add some oscillation to create the spiral
        current_angle += sin(i * 0.1) * 0.1
        
        var next_point = Vector2(
            current_point.x + cos(current_angle) * step_size,
            current_point.y + sin(current_angle) * step_size
        )
        
        if (next_point.x >= 0 and next_point.x < image.get_width() and 
            next_point.y >= 0 and next_point.y < image.get_height()):
            _draw_line(image, current_point, next_point, 2.0, color)
            
            # Occasionally add leaf
            if i % 10 == 0:
                _draw_leaf(image, next_point, 8, current_angle + PI/2, color)
        
        current_point = next_point

# Main function to generate and save borders
static func generate_border_set() -> void:
    # Create directory if it doesn't exist
    var dir = DirAccess.open("res://")
    if !dir.dir_exists("assets/ui/illuminated_borders"):
        dir.make_dir_recursive("assets/ui/illuminated_borders")
    
    # Generate different border types
    var border_types = {
        "corner_flourish": Vector2(128, 128),
        "sacred_geometry": Vector2(128, 128),
        "vine_border": Vector2(128, 128)
    }
    
    var gold_color = Color(0.9, 0.78, 0.25, 0.9)
    
    for border_name in border_types:
        var size = border_types[border_name]
        var texture: Texture2D
        
        if border_name == "corner_flourish":
            texture = generate_corner_flourish(size, gold_color)
        elif border_name == "sacred_geometry":
            texture = generate_sacred_geometry(size, gold_color)
        elif border_name == "vine_border":
            texture = generate_vine_border(size, gold_color)
        
        # Save the texture as an image
        var image = texture.get_image()
        var path = "res://assets/ui/illuminated_borders/" + border_name + ".png"
        image.save_png(path)
        print("Generated border: " + path)

# Editor utility function to generate borders 
# (can be called from the editor with a custom tool)
func generate_all_borders() -> void:
    BorderGenerator.generate_border_set()
