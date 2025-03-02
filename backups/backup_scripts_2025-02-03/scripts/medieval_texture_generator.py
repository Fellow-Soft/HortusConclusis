import os
import random
import math
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance, ImageChops
import texture_generator as base_generator

# Base directory for saving textures
BASE_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 
                        "assets", "textures", "medieval_garden_pack")

# Ensure directories exist
for subdir in ["garden_elements", "ornamental", "symbolic", "materials"]:
    os.makedirs(os.path.join(BASE_DIR, subdir), exist_ok=True)

# Texture size
TEXTURE_SIZE = 512

# Medieval garden color palettes
# These colors are based on historical medieval garden paintings and illuminated manuscripts
MEDIEVAL_PALETTES = {
    "garden_greens": [
        (44, 85, 40),    # Dark green (Verdigris)
        (80, 125, 42),   # Medium green
        (121, 136, 64),  # Olive green
        (155, 175, 82),  # Light green
        (188, 197, 129), # Pale green
    ],
    "flower_colors": [
        (170, 30, 30),   # Vermilion (red)
        (25, 60, 120),   # Ultramarine (blue)
        (180, 140, 40),  # Ochre (yellow)
        (90, 10, 30),    # Madder lake (deep red)
        (20, 75, 60),    # Malachite (green)
        (60, 20, 80),    # Tyrian purple
        (255, 255, 255), # White
    ],
    "path_materials": [
        (180, 170, 150), # Light gravel
        (150, 140, 120), # Dark gravel
        (130, 120, 100), # Earth path
        (160, 155, 140), # Stone dust
    ],
    "symbolic_colors": [
        (180, 30, 30),   # Red (symbolizing Christ's blood)
        (20, 60, 120),   # Blue (symbolizing Heaven/Virgin Mary)
        (180, 150, 10),  # Gold (symbolizing divinity)
        (255, 255, 255), # White (symbolizing purity)
        (100, 20, 100),  # Purple (symbolizing royalty)
    ]
}

# Reuse some utility functions from the base generator
add_noise = base_generator.add_noise
add_texture_variation = base_generator.add_texture_variation
add_medieval_border = base_generator.add_medieval_border

def generate_geometric_pattern(pattern_type="square_grid", color1=(30, 100, 40), color2=(150, 170, 100)):
    """Generate a geometric pattern common in medieval gardens"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Fill with base color
    draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=color1)
    
    if pattern_type == "square_grid":
        # Create a square grid pattern (common in medieval garden beds)
        grid_size = random.randint(4, 8)
        cell_size = TEXTURE_SIZE // grid_size
        
        for y in range(grid_size):
            for x in range(grid_size):
                # Alternate colors in a checkerboard pattern
                if (x + y) % 2 == 0:
                    continue
                
                # Draw the square
                draw.rectangle(
                    (x * cell_size, y * cell_size, (x + 1) * cell_size, (y + 1) * cell_size),
                    fill=color2
                )
    
    elif pattern_type == "cross":
        # Create a cross pattern (common in monastery gardens)
        path_width = TEXTURE_SIZE // 8
        
        # Horizontal path
        draw.rectangle(
            (0, TEXTURE_SIZE // 2 - path_width // 2, TEXTURE_SIZE, TEXTURE_SIZE // 2 + path_width // 2),
            fill=color2
        )
        
        # Vertical path
        draw.rectangle(
            (TEXTURE_SIZE // 2 - path_width // 2, 0, TEXTURE_SIZE // 2 + path_width // 2, TEXTURE_SIZE),
            fill=color2
        )
        
        # Central circle (often a fountain or feature)
        center = TEXTURE_SIZE // 2
        radius = path_width
        draw.ellipse(
            (center - radius, center - radius, center + radius, center + radius),
            fill=color1
        )
    
    elif pattern_type == "radial":
        # Create a radial pattern (common in some formal gardens)
        center = TEXTURE_SIZE // 2
        num_segments = random.randint(6, 12)
        
        for i in range(num_segments):
            angle1 = 2 * math.pi * i / num_segments
            angle2 = 2 * math.pi * (i + 1) / num_segments
            
            # Calculate points for a pie segment
            points = [
                (center, center),
                (center + int(center * math.cos(angle1)), center + int(center * math.sin(angle1))),
            ]
            
            # Add points along the arc
            steps = 10
            for j in range(1, steps):
                angle = angle1 + (angle2 - angle1) * j / steps
                points.append((
                    center + int(center * math.cos(angle)),
                    center + int(center * math.sin(angle))
                ))
            
            # Add the final point
            points.append((center + int(center * math.cos(angle2)), center + int(center * math.sin(angle2))))
            
            # Draw the segment
            if i % 2 == 0:
                draw.polygon(points, fill=color2)
    
    elif pattern_type == "knot_garden":
        # Create a simplified knot garden pattern
        # This is a very simplified version of the complex knot gardens
        line_width = TEXTURE_SIZE // 32
        
        # Draw the background
        draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=color1)
        
        # Draw the knot pattern
        for i in range(0, TEXTURE_SIZE, TEXTURE_SIZE // 4):
            # Horizontal lines
            draw.line([(0, i), (TEXTURE_SIZE, i)], fill=color2, width=line_width)
            # Vertical lines
            draw.line([(i, 0), (i, TEXTURE_SIZE)], fill=color2, width=line_width)
            
            # Diagonal lines
            draw.line([(0, i), (i, 0)], fill=color2, width=line_width)
            draw.line([(TEXTURE_SIZE - i, 0), (TEXTURE_SIZE, i)], fill=color2, width=line_width)
            draw.line([(0, TEXTURE_SIZE - i), (i, TEXTURE_SIZE)], fill=color2, width=line_width)
            draw.line([(TEXTURE_SIZE - i, TEXTURE_SIZE), (TEXTURE_SIZE, TEXTURE_SIZE - i)], fill=color2, width=line_width)
    
    # Add some noise and texture
    img = add_noise(img, intensity=0.05)
    
    return img

def generate_medieval_garden_bed(plant_type="herbs", density=0.7):
    """Generate a medieval garden bed texture with the specified plant type"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Base soil color
    soil_color = random.choice(base_generator.PALETTES["earth_tones"])
    draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=soil_color)
    
    # Determine plant colors based on type
    if plant_type == "herbs":
        # Herbs were common in medieval gardens for medicinal and culinary use
        plant_colors = [
            random.choice(MEDIEVAL_PALETTES["garden_greens"]),
            random.choice(MEDIEVAL_PALETTES["garden_greens"]),
            random.choice(MEDIEVAL_PALETTES["flower_colors"]),
        ]
        plant_size_range = (10, 25)
        num_plants = int(300 * density)
        
    elif plant_type == "flowers":
        # Flowers for decoration and symbolism
        plant_colors = [
            random.choice(MEDIEVAL_PALETTES["flower_colors"]),
            random.choice(MEDIEVAL_PALETTES["flower_colors"]),
            random.choice(MEDIEVAL_PALETTES["flower_colors"]),
        ]
        plant_size_range = (15, 30)
        num_plants = int(200 * density)
        
    elif plant_type == "vegetables":
        # Vegetables for sustenance
        plant_colors = [
            random.choice(MEDIEVAL_PALETTES["garden_greens"]),
            (150, 100, 50),  # Brown for root vegetables
            (180, 150, 30),  # Yellow for some vegetables
        ]
        plant_size_range = (20, 40)
        num_plants = int(150 * density)
        
    else:  # Mixed garden
        plant_colors = [
            random.choice(MEDIEVAL_PALETTES["garden_greens"]),
            random.choice(MEDIEVAL_PALETTES["flower_colors"]),
            random.choice(MEDIEVAL_PALETTES["garden_greens"]),
        ]
        plant_size_range = (15, 35)
        num_plants = int(200 * density)
    
    # Draw plants
    for _ in range(num_plants):
        x = random.randint(0, TEXTURE_SIZE - 1)
        y = random.randint(0, TEXTURE_SIZE - 1)
        size = random.randint(*plant_size_range)
        plant_color = random.choice(plant_colors)
        
        # Vary plant color slightly
        r_offset = random.randint(-20, 20)
        g_offset = random.randint(-20, 20)
        b_offset = random.randint(-20, 20)
        
        plant_color = (
            max(0, min(255, plant_color[0] + r_offset)),
            max(0, min(255, plant_color[1] + g_offset)),
            max(0, min(255, plant_color[2] + b_offset))
        )
        
        # Draw different plant shapes
        shape_type = random.choice(["circle", "oval", "cluster"])
        
        if shape_type == "circle":
            # Simple circular plant
            draw.ellipse((x - size // 2, y - size // 2, x + size // 2, y + size // 2), fill=plant_color)
            
        elif shape_type == "oval":
            # Oval/elongated plant
            height = size
            width = size // 2
            draw.ellipse((x - width // 2, y - height // 2, x + width // 2, y + height // 2), fill=plant_color)
            
        elif shape_type == "cluster":
            # Cluster of smaller plants
            for _ in range(3):
                cluster_x = x + random.randint(-size // 3, size // 3)
                cluster_y = y + random.randint(-size // 3, size // 3)
                cluster_size = size // 2
                draw.ellipse(
                    (cluster_x - cluster_size // 2, cluster_y - cluster_size // 2, 
                     cluster_x + cluster_size // 2, cluster_y + cluster_size // 2), 
                    fill=plant_color
                )
    
    # Add some soil texture
    img = add_texture_variation(img, variation_type="spots", intensity=0.3)
    
    return img

def generate_medieval_path(material="gravel"):
    """Generate a medieval garden path texture"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Base color based on material
    if material == "gravel":
        base_color = random.choice(MEDIEVAL_PALETTES["path_materials"][:2])
    elif material == "earth":
        base_color = MEDIEVAL_PALETTES["path_materials"][2]
    elif material == "stone_dust":
        base_color = MEDIEVAL_PALETTES["path_materials"][3]
    else:
        base_color = random.choice(MEDIEVAL_PALETTES["path_materials"])
    
    # Fill with base color
    draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=base_color)
    
    # Add texture based on material
    if material == "gravel":
        # Add many small stones
        num_stones = random.randint(1000, 2000)
        for _ in range(num_stones):
            x = random.randint(0, TEXTURE_SIZE - 1)
            y = random.randint(0, TEXTURE_SIZE - 1)
            size = random.randint(1, 4)
            
            # Stone color variation
            r_offset = random.randint(-30, 30)
            g_offset = random.randint(-30, 30)
            b_offset = random.randint(-30, 30)
            
            stone_color = (
                max(0, min(255, base_color[0] + r_offset)),
                max(0, min(255, base_color[1] + g_offset)),
                max(0, min(255, base_color[2] + b_offset))
            )
            
            draw.ellipse((x, y, x + size, y + size), fill=stone_color)
            
    elif material == "earth":
        # Add soil texture
        img = add_texture_variation(img, variation_type="spots", intensity=0.5)
        
    elif material == "stone_dust":
        # Add fine dust texture
        img = add_noise(img, intensity=0.1)
        
    # Add some footprints or wear patterns
    num_wear_patterns = random.randint(5, 15)
    for _ in range(num_wear_patterns):
        x = random.randint(0, TEXTURE_SIZE - 1)
        y = random.randint(0, TEXTURE_SIZE - 1)
        size = random.randint(20, 60)
        
        # Darker for worn areas
        wear_color = (
            int(base_color[0] * 0.85),
            int(base_color[1] * 0.85),
            int(base_color[2] * 0.85)
        )
        
        # Oval shape for footprints/wear
        width = size
        height = size // 2
        angle = random.uniform(0, math.pi)
        
        # Create a rotated ellipse by using an affine transform
        ellipse_img = Image.new("RGBA", (TEXTURE_SIZE, TEXTURE_SIZE), (0, 0, 0, 0))
        ellipse_draw = ImageDraw.Draw(ellipse_img)
        ellipse_draw.ellipse((x - width // 2, y - height // 2, x + width // 2, y + height // 2), fill=wear_color)
        
        # Rotate the ellipse
        rotated = ellipse_img.rotate(angle * 180 / math.pi, resample=Image.BICUBIC, expand=False)
        
        # Composite with the main image
        img = Image.alpha_composite(img.convert("RGBA"), rotated)
    
    # Convert back to RGB
    img = img.convert("RGB")
    
    return img

def generate_medieval_wall(material="stone", moss_amount=0.3):
    """Generate a medieval wall texture"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    if material == "stone":
        # Generate a stone wall
        # Base stone color
        stone_color = random.choice(base_generator.PALETTES["stone"])
        mortar_color = (180, 175, 165)  # Light gray for mortar
        
        # Fill with mortar color first
        draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=mortar_color)
        
        # Draw stones
        stone_size_range = (30, 80)
        stone_height_range = (20, 40)
        
        # Create rows of stones
        y = 0
        while y < TEXTURE_SIZE:
            row_height = random.randint(*stone_height_range)
            x = random.randint(-20, 0)  # Start with some randomness
            
            while x < TEXTURE_SIZE:
                stone_width = random.randint(*stone_size_range)
                
                # Stone color variation
                r_offset = random.randint(-20, 20)
                g_offset = random.randint(-20, 20)
                b_offset = random.randint(-20, 20)
                
                this_stone_color = (
                    max(0, min(255, stone_color[0] + r_offset)),
                    max(0, min(255, stone_color[1] + g_offset)),
                    max(0, min(255, stone_color[2] + b_offset))
                )
                
                # Draw the stone
                draw.rectangle(
                    (x, y, x + stone_width, y + row_height),
                    fill=this_stone_color
                )
                
                # Add some texture to the stone
                for _ in range(random.randint(3, 8)):
                    tx = random.randint(x + 5, x + stone_width - 5)
                    ty = random.randint(y + 5, y + row_height - 5)
                    ts = random.randint(2, 5)
                    
                    # Texture is usually darker
                    texture_color = (
                        int(this_stone_color[0] * 0.8),
                        int(this_stone_color[1] * 0.8),
                        int(this_stone_color[2] * 0.8)
                    )
                    
                    draw.ellipse((tx, ty, tx + ts, ty + ts), fill=texture_color)
                
                x += stone_width + random.randint(2, 5)  # Gap between stones
            
            y += row_height + random.randint(2, 5)  # Gap between rows
        
    elif material == "brick":
        # Generate a brick wall
        brick_color = (180, 60, 40)  # Traditional red brick
        mortar_color = (200, 195, 190)  # Light gray for mortar
        
        # Fill with mortar color first
        draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=mortar_color)
        
        # Brick dimensions
        brick_width = 60
        brick_height = 30
        mortar_thickness = 5
        
        # Draw bricks in alternating rows
        for row in range(0, TEXTURE_SIZE, brick_height + mortar_thickness):
            # Offset every other row
            offset = (brick_width + mortar_thickness) // 2 if row % (2 * (brick_height + mortar_thickness)) else 0
            
            for col in range(-offset, TEXTURE_SIZE, brick_width + mortar_thickness):
                # Vary brick color slightly
                r_offset = random.randint(-20, 20)
                g_offset = random.randint(-10, 10)
                b_offset = random.randint(-10, 10)
                
                this_brick_color = (
                    max(0, min(255, brick_color[0] + r_offset)),
                    max(0, min(255, brick_color[1] + g_offset)),
                    max(0, min(255, brick_color[2] + b_offset))
                )
                
                # Draw the brick
                draw.rectangle(
                    (col, row, col + brick_width, row + brick_height),
                    fill=this_brick_color
                )
                
                # Add some texture to the brick
                for _ in range(random.randint(3, 8)):
                    tx = random.randint(col + 5, col + brick_width - 5)
                    ty = random.randint(row + 5, row + brick_height - 5)
                    ts = random.randint(2, 5)
                    
                    # Texture is usually darker or lighter
                    if random.random() < 0.5:
                        texture_color = (
                            int(this_brick_color[0] * 0.9),
                            int(this_brick_color[1] * 0.9),
                            int(this_brick_color[2] * 0.9)
                        )
                    else:
                        texture_color = (
                            min(255, int(this_brick_color[0] * 1.1)),
                            min(255, int(this_brick_color[1] * 1.1)),
                            min(255, int(this_brick_color[2] * 1.1))
                        )
                    
                    draw.ellipse((tx, ty, tx + ts, ty + ts), fill=texture_color)
    
    # Add moss if requested
    if moss_amount > 0:
        # Create a moss layer
        moss_img = Image.new("RGBA", (TEXTURE_SIZE, TEXTURE_SIZE), (0, 0, 0, 0))
        moss_draw = ImageDraw.Draw(moss_img)
        
        # Moss color
        moss_color = (80, 120, 40, int(100 * moss_amount))  # Semi-transparent green
        
        # Add moss patches
        num_patches = int(30 * moss_amount)
        for _ in range(num_patches):
            x = random.randint(0, TEXTURE_SIZE - 1)
            y = random.randint(0, TEXTURE_SIZE - 1)
            size = random.randint(10, 40)
            
            # More moss at the top of the wall (where water collects)
            if y > TEXTURE_SIZE // 2 and random.random() > 0.3:
                continue
            
            # Draw moss patch
            for dx in range(-size, size + 1):
                for dy in range(-size, size + 1):
                    dist = math.sqrt(dx * dx + dy * dy)
                    if dist <= size and x + dx >= 0 and x + dx < TEXTURE_SIZE and y + dy >= 0 and y + dy < TEXTURE_SIZE:
                        # Fade out at the edges
                        alpha = int(moss_color[3] * (1 - dist / size))
                        moss_draw.point((x + dx, y + dy), fill=(moss_color[0], moss_color[1], moss_color[2], alpha))
        
        # Composite moss with the wall
        img = Image.alpha_composite(img.convert("RGBA"), moss_img)
        img = img.convert("RGB")
    
    # Add some weathering
    img = add_texture_variation(img, variation_type="spots", intensity=0.3)
    
    return img

def generate_symbolic_pattern(symbol_type="cross", color1=(180, 30, 30), color2=(255, 255, 255)):
    """Generate a symbolic pattern common in medieval religious gardens"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Fill with background color
    draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=color2)
    
    if symbol_type == "cross":
        # Draw a cross (symbol of Christianity)
        cross_width = TEXTURE_SIZE // 6
        vertical_height = TEXTURE_SIZE * 3 // 4
        horizontal_width = TEXTURE_SIZE // 2
        
        # Vertical part
        draw.rectangle(
            (TEXTURE_SIZE // 2 - cross_width // 2, 
             TEXTURE_SIZE // 8, 
             TEXTURE_SIZE // 2 + cross_width // 2, 
             TEXTURE_SIZE // 8 + vertical_height),
            fill=color1
        )
        
        # Horizontal part
        draw.rectangle(
            (TEXTURE_SIZE // 2 - horizontal_width // 2, 
             TEXTURE_SIZE // 3, 
             TEXTURE_SIZE // 2 + horizontal_width // 2, 
             TEXTURE_SIZE // 3 + cross_width),
            fill=color1
        )
    
    elif symbol_type == "fleur_de_lis":
        # Draw a fleur-de-lis (symbol of royalty and the Virgin Mary)
        center_x = TEXTURE_SIZE // 2
        center_y = TEXTURE_SIZE // 2
        size = TEXTURE_SIZE // 3
        
        # Draw the central petal
        points = [
            (center_x, center_y - size),
            (center_x - size // 4, center_y - size // 2),
            (center_x - size // 8, center_y),
            (center_x + size // 8, center_y),
            (center_x + size // 4, center_y - size // 2),
        ]
        draw.polygon(points, fill=color1)
        
        # Draw the left petal
        points = [
            (center_x, center_y),
            (center_x - size // 2, center_y - size // 4),
            (center_x - size, center_y - size // 2),
            (center_x - size // 2, center_y + size // 4),
        ]
        draw.polygon(points, fill=color1)
        
        # Draw the right petal
        points = [
            (center_x, center_y),
            (center_x + size // 2, center_y - size // 4),
            (center_x + size, center_y - size // 2),
            (center_x + size // 2, center_y + size // 4),
        ]
        draw.polygon(points, fill=color1)
        
        # Draw the stem
        draw.rectangle(
            (center_x - size // 8, center_y, center_x + size // 8, center_y + size),
            fill=color1
        )
        
        # Draw the base
        points = [
            (center_x - size // 3, center_y + size),
            (center_x + size // 3, center_y + size),
            (center_x + size // 2, center_y + size * 1.2),
            (center_x - size // 2, center_y + size * 1.2),
        ]
        draw.polygon(points, fill=color1)
    
    elif symbol_type == "rose":
        # Draw a stylized rose (symbol of the Virgin Mary)
        center_x = TEXTURE_SIZE // 2
        center_y = TEXTURE_SIZE // 2
        size = TEXTURE_SIZE // 3
        
        # Draw petals
        num_petals = 8
        for i in range(num_petals):
            angle = 2 * math.pi * i / num_petals
            petal_x = center_x + int(size * 0.7 * math.cos(angle))
            petal_y = center_y + int(size * 0.7 * math.sin(angle))
            petal_size = size // 2
            
            draw.ellipse(
                (petal_x - petal_size, petal_y - petal_size, 
                 petal_x + petal_size, petal_y + petal_size),
                fill=color1
            )
        
        # Draw center
        draw.ellipse(
            (center_x - size // 3, center_y - size // 3, 
             center_x + size // 3, center_y + size // 3),
            fill=color2
        )
        
        # Draw stem
        draw.rectangle(
            (center_x - size // 16, center_y + size // 2, 
             center_x + size // 16, center_y + size * 1.2),
            fill=(0, 100, 0)  # Green stem
        )
        
        # Draw leaves
        leaf_size = size // 3
        # Left leaf
        points = [
            (center_x, center_y + size * 0.8),
            (center_x - leaf_size, center_y + size * 0.7),
            (center_x - leaf_size // 2, center_y + size),
        ]
        draw.polygon(points, fill=(0, 120, 0))
        
        # Right leaf
        points = [
            (center_x, center_y + size * 0.9),
            (center_x + leaf_size, center_y + size * 0.8),
            (center_x + leaf_size // 2, center_y + size * 1.1),
        ]
        draw.polygon(points, fill=(0, 120, 0))
    
    elif symbol_type == "geometric":
        # Draw a geometric pattern (common in Islamic and some Christian gardens)
        # This is a simplified version of complex geometric patterns
        
        # Draw grid lines
        line_width = TEXTURE_SIZE // 64
        grid_size = 4
        cell_size = TEXTURE_SIZE // grid_size
        
        for i in range(grid_size + 1):
            # Horizontal lines
            draw.line(
                [(0, i * cell_size), (TEXTURE_SIZE, i * cell_size)],
                fill=color1,
                width=line_width
            )
            
            # Vertical lines
            draw.line(
                [(i * cell_size, 0), (i * cell_size, TEXTURE_SIZE)],
                fill=color1,
                width=line_width
            )
        
        # Draw diagonal lines
        for i in range(grid_size):
            for j in range(grid_size):
                # Diagonal from top-left to bottom-right
                draw.line(
                    [(i * cell_size, j * cell_size), 
                     ((i + 1) * cell_size, (j + 1) * cell_size)],
                    fill=color1,
                    width=line_width
                )
                
                # Diagonal from top-right to bottom-left
                draw.line(
                    [((i + 1) * cell_size, j * cell_size), 
                     (i * cell_size, (j + 1) * cell_size)],
                    fill=color1,
                    width=line_width
                )
    
    # Add some texture and noise
    img = add_noise(img, intensity=0.05)
    
    return img

def generate_medieval_fountain(style="simple"):
    """Generate a medieval fountain texture (top-down view)"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Background color (usually stone)
    bg_color = random.choice(base_generator.PALETTES["stone"])
    draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=bg_color)
    
    # Water color
    water_color = (80, 120, 180)  # Blue water
    
    if style == "simple":
        # Simple circular fountain
        center_x = TEXTURE_SIZE // 2
        center_y = TEXTURE_SIZE // 2
        outer_radius = TEXTURE_SIZE // 3
        inner_radius = TEXTURE_SIZE // 4
        
        # Outer stone rim
        draw.ellipse(
            (center_x - outer_radius, center_y - outer_radius,
             center_x + outer_radius, center_y + outer_radius),
            fill=bg_color,
            outline=(bg_color[0] - 20, bg_color[1] - 20, bg_color[2] - 20),
            width=3
        )
        
        # Inner water pool
        draw.ellipse(
            (center_x - inner_radius, center_y - inner_radius,
             center_x + inner_radius, center_y + inner_radius),
            fill=water_color
        )
        
        # Add water ripples
        for i in range(3):
            ripple_radius = inner_radius * (0.7 - i * 0.15)
            draw.ellipse(
                (center_x - ripple_radius, center_y - ripple_radius,
                 center_x + ripple_radius, center_y + ripple_radius),
                outline=(water_color[0] + 40, water_color[1] + 40, water_color[2] + 40),
                width=2
            )
        
        # Add central water jet
        jet_width = TEXTURE_SIZE // 40
        draw.ellipse(
            (center_x - jet_width, center_y - jet_width,
             center_x + jet_width, center_y + jet_width),
            fill=(water_color[0] + 60, water_color[1] + 60, water_color[2] + 60)
        )
    
    elif style == "ornate":
        # More complex ornate fountain with multiple basins
        center_x = TEXTURE_SIZE // 2
        center_y = TEXTURE_SIZE // 2
        
        # Outer stone structure (octagonal)
        outer_radius = TEXTURE_SIZE // 3
        points = []
        for i in range(8):
            angle = 2 * math.pi * i / 8
            x = center_x + int(outer_radius * math.cos(angle))
            y = center_y + int(outer_radius * math.sin(angle))
            points.append((x, y))
        
        draw.polygon(points, fill=bg_color, outline=(bg_color[0] - 30, bg_color[1] - 30, bg_color[2] - 30), width=3)
        
        # Middle basin (circular)
        middle_radius = TEXTURE_SIZE // 4
        draw.ellipse(
            (center_x - middle_radius, center_y - middle_radius,
             center_x + middle_radius, center_y + middle_radius),
            fill=(bg_color[0] - 10, bg_color[1] - 10, bg_color[2] - 10)
        )
        
        # Inner water pool
        inner_radius = TEXTURE_SIZE // 5
        draw.ellipse(
            (center_x - inner_radius, center_y - inner_radius,
             center_x + inner_radius, center_y + inner_radius),
            fill=water_color
        )
        
        # Central pedestal
        pedestal_radius = TEXTURE_SIZE // 12
        draw.ellipse(
            (center_x - pedestal_radius, center_y - pedestal_radius,
             center_x + pedestal_radius, center_y + pedestal_radius),
            fill=(bg_color[0] - 20, bg_color[1] - 20, bg_color[2] - 20)
        )
        
        # Add water jets and ripples
        for i in range(8):
            angle = 2 * math.pi * i / 8
            jet_x = center_x + int(inner_radius * 0.7 * math.cos(angle))
            jet_y = center_y + int(inner_radius * 0.7 * math.sin(angle))
            jet_size = TEXTURE_SIZE // 60
            
            # Small water jet
            draw.ellipse(
                (jet_x - jet_size, jet_y - jet_size,
                 jet_x + jet_size, jet_y + jet_size),
                fill=(water_color[0] + 60, water_color[1] + 60, water_color[2] + 60)
            )
            
            # Ripples around jet
            for r in range(2):
                ripple_radius = jet_size * (3 + r * 2)
                draw.ellipse(
                    (jet_x - ripple_radius, jet_y - ripple_radius,
                     jet_x + ripple_radius, jet_y + ripple_radius),
                    outline=(water_color[0] + 40, water_color[1] + 40, water_color[2] + 40),
                    width=1
                )
        
        # Central water jet
        center_jet_size = TEXTURE_SIZE // 30
        draw.ellipse(
            (center_x - center_jet_size, center_y - center_jet_size,
             center_x + center_jet_size, center_y + center_jet_size),
            fill=(water_color[0] + 70, water_color[1] + 70, water_color[2] + 70)
        )
    
    elif style == "wall":
        # Wall fountain (common in medieval gardens)
        # Background wall
        wall_color = (bg_color[0] - 20, bg_color[1] - 20, bg_color[2] - 20)
        draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE * 2 // 3), fill=wall_color)
        
        # Basin at bottom
        basin_height = TEXTURE_SIZE // 3
        draw.rectangle((0, TEXTURE_SIZE * 2 // 3, TEXTURE_SIZE, TEXTURE_SIZE), fill=bg_color)
        
        # Water in basin
        water_height = basin_height * 2 // 3
        draw.rectangle((TEXTURE_SIZE // 8, TEXTURE_SIZE * 2 // 3 + basin_height - water_height, 
                        TEXTURE_SIZE * 7 // 8, TEXTURE_SIZE), fill=water_color)
        
        # Wall spout
        spout_width = TEXTURE_SIZE // 10
        spout_height = TEXTURE_SIZE // 15
        spout_x = TEXTURE_SIZE // 2
        spout_y = TEXTURE_SIZE * 2 // 3 - spout_height
        
        # Spout structure
        draw.rectangle(
            (spout_x - spout_width // 2, spout_y,
             spout_x + spout_width // 2, spout_y + spout_height),
            fill=(bg_color[0] - 40, bg_color[1] - 40, bg_color[2] - 40)
        )
        
        # Water stream
        stream_width = spout_width // 3
        draw.rectangle(
            (spout_x - stream_width // 2, spout_y + spout_height,
             spout_x + stream_width // 2, TEXTURE_SIZE * 2 // 3 + basin_height - water_height),
            fill=(water_color[0] + 30, water_color[1] + 30, water_color[2] + 30)
        )
        
        # Add ripples where water hits the basin
        ripple_y = TEXTURE_SIZE * 2 // 3 + basin_height - water_height
        for i in range(3):
            ripple_width = stream_width * (2 + i)
            draw.ellipse(
                (spout_x - ripple_width, ripple_y - ripple_width // 4,
                 spout_x + ripple_width, ripple_y + ripple_width // 4),
                outline=(water_color[0] + 50, water_color[1] + 50, water_color[2] + 50),
                width=1
            )
        
        # Decorative elements on wall
        # Simple arch above spout
        arch_width = spout_width * 2
        arch_height = TEXTURE_SIZE // 8
        draw.arc(
            (spout_x - arch_width // 2, spout_y - arch_height,
             spout_x + arch_width // 2, spout_y + arch_height),
            180, 0,
            fill=(bg_color[0] - 30, bg_color[1] - 30, bg_color[2] - 30),
            width=2
        )
    
    # Add some texture and weathering
    img = add_texture_variation(img, variation_type="spots", intensity=0.2)
    img = add_noise(img, intensity=0.05)
    
    return img

def generate_all_medieval_textures():
    """Generate all medieval textures and save them to the appropriate directories"""
    print("Generating medieval garden elements...")
    # Garden elements
    garden_herbs = generate_medieval_garden_bed("herbs")
    garden_herbs.save(os.path.join(BASE_DIR, "garden_elements", "herb_bed.png"))
    
    garden_flowers = generate_medieval_garden_bed("flowers")
    garden_flowers.save(os.path.join(BASE_DIR, "garden_elements", "flower_bed.png"))
    
    garden_vegetables = generate_medieval_garden_bed("vegetables")
    garden_vegetables.save(os.path.join(BASE_DIR, "garden_elements", "vegetable_bed.png"))
    
    garden_mixed = generate_medieval_garden_bed("mixed")
    garden_mixed.save(os.path.join(BASE_DIR, "garden_elements", "mixed_bed.png"))
    
    # Paths
    path_gravel = generate_medieval_path("gravel")
    path_gravel.save(os.path.join(BASE_DIR, "garden_elements", "gravel_path.png"))
    
    path_earth = generate_medieval_path("earth")
    path_earth.save(os.path.join(BASE_DIR, "garden_elements", "earth_path.png"))
    
    path_stone = generate_medieval_path("stone_dust")
    path_stone.save(os.path.join(BASE_DIR, "garden_elements", "stone_path.png"))
    
    # Geometric patterns
    pattern_grid = generate_geometric_pattern("square_grid")
    pattern_grid.save(os.path.join(BASE_DIR, "garden_elements", "square_grid_pattern.png"))
    
    pattern_cross = generate_geometric_pattern("cross")
    pattern_cross.save(os.path.join(BASE_DIR, "garden_elements", "cross_pattern.png"))
    
    pattern_radial = generate_geometric_pattern("radial")
    pattern_radial.save(os.path.join(BASE_DIR, "garden_elements", "radial_pattern.png"))
    
    pattern_knot = generate_geometric_pattern("knot_garden")
    pattern_knot.save(os.path.join(BASE_DIR, "garden_elements", "knot_garden_pattern.png"))
    
    print("Generating medieval ornamental elements...")
    # Fountains
    fountain_simple = generate_medieval_fountain("simple")
    fountain_simple.save(os.path.join(BASE_DIR, "ornamental", "simple_fountain.png"))
    
    fountain_ornate = generate_medieval_fountain("ornate")
    fountain_ornate.save(os.path.join(BASE_DIR, "ornamental", "ornate_fountain.png"))
    
    fountain_wall = generate_medieval_fountain("wall")
    fountain_wall.save(os.path.join(BASE_DIR, "ornamental", "wall_fountain.png"))
    
    # Walls
    wall_stone = generate_medieval_wall("stone")
    wall_stone.save(os.path.join(BASE_DIR, "materials", "stone_wall.png"))
    
    wall_brick = generate_medieval_wall("brick")
    wall_brick.save(os.path.join(BASE_DIR, "materials", "brick_wall.png"))
    
    wall_mossy = generate_medieval_wall("stone", 0.6)
    wall_mossy.save(os.path.join(BASE_DIR, "materials", "mossy_wall.png"))
    
    print("Generating medieval symbolic elements...")
    # Symbolic patterns
    symbol_cross = generate_symbolic_pattern("cross")
    symbol_cross.save(os.path.join(BASE_DIR, "symbolic", "cross_symbol.png"))
    
    symbol_fleur = generate_symbolic_pattern("fleur_de_lis")
    symbol_fleur.save(os.path.join(BASE_DIR, "symbolic", "fleur_de_lis_symbol.png"))
    
    symbol_rose = generate_symbolic_pattern("rose")
    symbol_rose.save(os.path.join(BASE_DIR, "symbolic", "rose_symbol.png"))
    
    symbol_geometric = generate_symbolic_pattern("geometric")
    symbol_geometric.save(os.path.join(BASE_DIR, "symbolic", "geometric_symbol.png"))
    
    print("All medieval textures generated successfully!")

if __name__ == "__main__":
    import sys
    import argparse
    
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Generate medieval textures for Hortus Conclusus')
    parser.add_argument('--single', help='Generate a single texture type')
    parser.add_argument('--variation', help='Specify variation for the single texture')
    args = parser.parse_args()
    
    # Generate a single texture if requested
    if args.single:
        texture_type = args.single
        variation = args.variation if args.variation else ""
        
        # Generate the texture based on the type
        texture_path = ""
        
        if texture_type == "garden_bed":
            img = generate_medieval_garden_bed(variation)
            texture_path = os.path.join(BASE_DIR, "garden_elements", f"{variation}_bed.png")
            img.save(texture_path)
        
        elif texture_type == "path":
            img = generate_medieval_path(variation)
            texture_path = os.path.join(BASE_DIR, "garden_elements", f"{variation}_path.png")
            img.save(texture_path)
        
        elif texture_type == "pattern":
            img = generate_geometric_pattern(variation)
            texture_path = os.path.join(BASE_DIR, "garden_elements", f"{variation}_pattern.png")
            img.save(texture_path)
        
        elif texture_type == "fountain":
            img = generate_medieval_fountain(variation)
            texture_path = os.path.join(BASE_DIR, "ornamental", f"{variation}_fountain.png")
            img.save(texture_path)
        
        elif texture_type == "wall":
            moss_amount = 0.3
            if "mossy" in variation:
                moss_amount = 0.6
                variation = variation.replace("_mossy", "")
            
            img = generate_medieval_wall(variation, moss_amount)
            texture_path = os.path.join(BASE_DIR, "materials", f"{variation}_wall.png")
            img.save(texture_path)
        
        elif texture_type == "symbol":
            img = generate_symbolic_pattern(variation)
            texture_path = os.path.join(BASE_DIR, "symbolic", f"{variation}_symbol.png")
            img.save(texture_path)
        
        # Print the path for the Godot script to capture
        if texture_path:
            print(f"TEXTURE_PATH:{texture_path}")
        else:
            print(f"ERROR: Unknown texture type: {texture_type}")
            sys.exit(1)
    
    # Generate all textures by default
    else:
        generate_all_medieval_textures()
