import os
import random
import math
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance, ImageChops

# Base directory for saving textures
BASE_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 
                        "assets", "textures", "medieval_pack_1")

# Ensure directories exist
for subdir in ["ground", "plants", "structures", "decorative"]:
    os.makedirs(os.path.join(BASE_DIR, subdir), exist_ok=True)

# Texture size
TEXTURE_SIZE = 512

# Color palettes for medieval aesthetics
# These colors are based on pigments available in the high medieval period (1000-1300 CE)
PALETTES = {
    "earth_tones": [
        (92, 64, 51),    # Dark brown
        (115, 79, 56),   # Medium brown
        (143, 117, 85),  # Light brown
        (171, 145, 123), # Tan
        (120, 100, 80),  # Umber
    ],
    "greens": [
        (44, 85, 40),    # Dark green (Verdigris)
        (80, 125, 42),   # Medium green
        (121, 136, 64),  # Olive green
        (155, 175, 82),  # Light green
        (188, 197, 129), # Pale green
    ],
    "stone": [
        (130, 130, 130), # Medium gray
        (160, 160, 160), # Light gray
        (180, 175, 165), # Warm gray
        (200, 195, 185), # Light warm gray
        (110, 110, 115), # Cool gray
    ],
    "medieval_pigments": [
        (170, 30, 30),   # Vermilion (red)
        (25, 60, 120),   # Ultramarine (blue)
        (180, 140, 40),  # Ochre (yellow)
        (90, 10, 30),    # Madder lake (deep red)
        (20, 75, 60),    # Malachite (green)
        (60, 20, 80),    # Tyrian purple
        (140, 100, 40),  # Raw sienna
        (80, 60, 30),    # Burnt umber
    ]
}

def add_noise(image, intensity=0.1):
    """Add random noise to an image"""
    noise = Image.new("RGB", image.size)
    width, height = image.size
    
    for x in range(width):
        for y in range(height):
            r = random.randint(-int(255 * intensity), int(255 * intensity))
            g = random.randint(-int(255 * intensity), int(255 * intensity))
            b = random.randint(-int(255 * intensity), int(255 * intensity))
            noise.putpixel((x, y), (r, g, b))
    
    return ImageChops.add(image, noise, scale=1.0, offset=0)

def add_texture_variation(image, variation_type="cracks", intensity=0.5):
    """Add texture variations like cracks, spots, or grain"""
    width, height = image.size
    texture = Image.new("L", image.size, 255)
    draw = ImageDraw.Draw(texture)
    
    if variation_type == "cracks":
        # Create cracks
        num_cracks = int(20 * intensity)
        for _ in range(num_cracks):
            start_x = random.randint(0, width)
            start_y = random.randint(0, height)
            length = random.randint(20, 100)
            angle = random.uniform(0, 2 * math.pi)
            
            end_x = start_x + int(length * math.cos(angle))
            end_y = start_y + int(length * math.sin(angle))
            
            # Draw main crack
            draw.line((start_x, start_y, end_x, end_y), fill=0, width=random.randint(1, 3))
            
            # Add some branches
            num_branches = random.randint(0, 3)
            for _ in range(num_branches):
                branch_start = random.uniform(0.3, 0.7)
                branch_x = int(start_x + (end_x - start_x) * branch_start)
                branch_y = int(start_y + (end_y - start_y) * branch_start)
                
                branch_angle = angle + random.uniform(-math.pi/4, math.pi/4)
                branch_length = random.randint(10, 50)
                
                branch_end_x = branch_x + int(branch_length * math.cos(branch_angle))
                branch_end_y = branch_y + int(branch_length * math.sin(branch_angle))
                
                draw.line((branch_x, branch_y, branch_end_x, branch_end_y), fill=0, width=random.randint(1, 2))
    
    elif variation_type == "spots":
        # Create spots/stains
        num_spots = int(50 * intensity)
        for _ in range(num_spots):
            x = random.randint(0, width)
            y = random.randint(0, height)
            radius = random.randint(5, 20)
            opacity = random.randint(100, 200)
            draw.ellipse((x-radius, y-radius, x+radius, y+radius), fill=opacity)
    
    elif variation_type == "grain":
        # Create wood grain-like pattern
        num_lines = int(50 * intensity)
        for _ in range(num_lines):
            y = random.randint(0, height)
            wave_height = random.randint(5, 15)
            wave_length = random.randint(100, 300)
            thickness = random.randint(1, 3)
            opacity = random.randint(150, 230)
            
            points = []
            for x in range(0, width + wave_length, 10):
                wave_y = y + wave_height * math.sin(x * 2 * math.pi / wave_length)
                points.append((x, wave_y))
            
            draw.line(points, fill=opacity, width=thickness)
    
    # Blur the texture slightly
    texture = texture.filter(ImageFilter.GaussianBlur(radius=1))
    
    # Apply the texture as a mask
    texture_inverted = ImageChops.invert(texture)
    texture_inverted = texture_inverted.convert("RGB")
    
    # Blend with original image
    blended = Image.blend(image, texture_inverted, alpha=0.2 * intensity)
    return blended

def add_medieval_border(image, border_width=20, color=(60, 30, 10)):
    """Add a medieval-style border to the image"""
    width, height = image.size
    bordered = Image.new("RGB", image.size, color)
    
    # Create inner rectangle
    inner_width = width - 2 * border_width
    inner_height = height - 2 * border_width
    
    # Paste original image in center
    bordered.paste(image.crop((border_width, border_width, width - border_width, height - border_width)), 
                  (border_width, border_width))
    
    # Add some decorative elements to the border
    draw = ImageDraw.Draw(bordered)
    
    # Corner decorations
    corner_size = border_width * 1.5
    for x, y in [(0, 0), (width - corner_size, 0), (0, height - corner_size), (width - corner_size, height - corner_size)]:
        draw.rectangle((x, y, x + corner_size, y + corner_size), outline=(100, 70, 30), width=2)
    
    return bordered

def generate_soil_texture(variation="rich"):
    """Generate a soil texture with the specified variation"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Base color based on variation
    if variation == "rich":
        base_color = random.choice(PALETTES["earth_tones"][:3])  # Darker browns
    elif variation == "dry":
        base_color = random.choice(PALETTES["earth_tones"][2:])  # Lighter browns
    elif variation == "clay":
        base_color = (170, 120, 90)  # Reddish clay color
    else:
        base_color = random.choice(PALETTES["earth_tones"])
    
    # Fill with base color
    draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=base_color)
    
    # Add soil particles
    num_particles = random.randint(1000, 3000)
    for _ in range(num_particles):
        x = random.randint(0, TEXTURE_SIZE - 1)
        y = random.randint(0, TEXTURE_SIZE - 1)
        size = random.randint(1, 4)
        
        # Vary particle color slightly from base
        r_offset = random.randint(-20, 20)
        g_offset = random.randint(-20, 20)
        b_offset = random.randint(-20, 20)
        
        particle_color = (
            max(0, min(255, base_color[0] + r_offset)),
            max(0, min(255, base_color[1] + g_offset)),
            max(0, min(255, base_color[2] + b_offset))
        )
        
        draw.ellipse((x, y, x + size, y + size), fill=particle_color)
    
    # Add some larger clumps
    num_clumps = random.randint(20, 50)
    for _ in range(num_clumps):
        x = random.randint(0, TEXTURE_SIZE - 1)
        y = random.randint(0, TEXTURE_SIZE - 1)
        size = random.randint(5, 15)
        
        # Clumps are usually darker
        darkness = random.uniform(0.7, 0.9)
        clump_color = (
            int(base_color[0] * darkness),
            int(base_color[1] * darkness),
            int(base_color[2] * darkness)
        )
        
        draw.ellipse((x, y, x + size, y + size), fill=clump_color)
    
    # Add noise and texture
    img = add_noise(img, intensity=0.1)
    img = add_texture_variation(img, variation_type="spots", intensity=0.4)
    
    # Apply some blur for realism
    img = img.filter(ImageFilter.GaussianBlur(radius=0.5))
    
    return img

def generate_grass_texture(variation="common"):
    """Generate a grass texture with the specified variation"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Base color based on variation
    if variation == "common":
        base_color = random.choice(PALETTES["greens"][1:3])  # Medium greens
    elif variation == "lush":
        base_color = random.choice(PALETTES["greens"][:2])  # Darker greens
    elif variation == "dry":
        base_color = random.choice(PALETTES["greens"][3:])  # Lighter greens
    else:
        base_color = random.choice(PALETTES["greens"])
    
    # Fill with base color
    draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=base_color)
    
    # Add grass blades
    num_blades = random.randint(500, 1000)
    for _ in range(num_blades):
        x = random.randint(0, TEXTURE_SIZE - 1)
        y = random.randint(0, TEXTURE_SIZE - 1)
        length = random.randint(5, 15)
        width = random.randint(1, 3)
        angle = random.uniform(-0.2, 0.2)  # Slight angle variation
        
        # Vary blade color slightly from base
        r_offset = random.randint(-30, 30)
        g_offset = random.randint(-30, 30)
        b_offset = random.randint(-15, 15)
        
        blade_color = (
            max(0, min(255, base_color[0] + r_offset)),
            max(0, min(255, base_color[1] + g_offset)),
            max(0, min(255, base_color[2] + b_offset))
        )
        
        # Calculate end point with angle
        end_x = x + int(length * math.sin(angle))
        end_y = y - length  # Grass grows upward
        
        draw.line((x, y, end_x, end_y), fill=blade_color, width=width)
    
    # Add some soil/dirt patches
    if variation == "dry" or random.random() < 0.3:
        num_patches = random.randint(5, 15)
        for _ in range(num_patches):
            x = random.randint(0, TEXTURE_SIZE - 1)
            y = random.randint(0, TEXTURE_SIZE - 1)
            size = random.randint(10, 30)
            
            # Dirt color
            dirt_color = random.choice(PALETTES["earth_tones"])
            
            draw.ellipse((x, y, x + size, y + size), fill=dirt_color)
    
    # Add some small flowers for lush grass
    if variation == "lush" or random.random() < 0.2:
        num_flowers = random.randint(10, 30)
        for _ in range(num_flowers):
            x = random.randint(0, TEXTURE_SIZE - 1)
            y = random.randint(0, TEXTURE_SIZE - 1)
            size = random.randint(2, 5)
            
            # Flower color
            flower_color = random.choice(PALETTES["medieval_pigments"])
            
            draw.ellipse((x, y, x + size, y + size), fill=flower_color)
    
    # Add noise and texture
    img = add_noise(img, intensity=0.1)
    
    # Apply some blur for realism
    img = img.filter(ImageFilter.GaussianBlur(radius=0.5))
    
    return img

def generate_stone_texture(variation="cobblestone"):
    """Generate a stone texture with the specified variation"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Base color based on variation
    if variation == "cobblestone":
        base_color = random.choice(PALETTES["stone"][1:3])  # Medium to light gray
    elif variation == "flagstone":
        base_color = random.choice(PALETTES["stone"][2:4])  # Warmer grays
    elif variation == "rough_stone":
        base_color = random.choice(PALETTES["stone"][:2])  # Darker grays
    else:
        base_color = random.choice(PALETTES["stone"])
    
    # Fill with base color
    draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=base_color)
    
    if variation == "cobblestone":
        # Create cobblestones
        stone_size_range = (30, 60)
        gap_size = 3
        
        # Create a grid of stones with some randomness
        x, y = 0, 0
        while y < TEXTURE_SIZE:
            row_height = 0
            x = random.randint(-20, 0)  # Start with some randomness
            
            while x < TEXTURE_SIZE:
                stone_width = random.randint(*stone_size_range)
                stone_height = random.randint(*stone_size_range)
                row_height = max(row_height, stone_height)
                
                # Stone color variation
                r_offset = random.randint(-20, 20)
                g_offset = random.randint(-20, 20)
                b_offset = random.randint(-20, 20)
                
                stone_color = (
                    max(0, min(255, base_color[0] + r_offset)),
                    max(0, min(255, base_color[1] + g_offset)),
                    max(0, min(255, base_color[2] + b_offset))
                )
                
                # Draw the stone
                draw.ellipse((x, y, x + stone_width, y + stone_height), fill=stone_color)
                
                # Add some texture to the stone
                for _ in range(random.randint(3, 8)):
                    tx = random.randint(x + 5, x + stone_width - 5)
                    ty = random.randint(y + 5, y + stone_height - 5)
                    ts = random.randint(2, 5)
                    
                    # Texture is usually darker
                    texture_color = (
                        int(stone_color[0] * 0.8),
                        int(stone_color[1] * 0.8),
                        int(stone_color[2] * 0.8)
                    )
                    
                    draw.ellipse((tx, ty, tx + ts, ty + ts), fill=texture_color)
                
                x += stone_width + gap_size
            
            y += row_height + gap_size
        
        # Draw mortar between stones
        mortar_color = (180, 170, 160)  # Light gray/tan for mortar
        img_with_mortar = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE), mortar_color)
        img_with_mortar.paste(img, (0, 0), mask=None)
        img = img_with_mortar
        
    elif variation == "flagstone":
        # Create larger, more irregular flagstones
        num_stones = random.randint(15, 25)
        
        # Draw mortar background first
        mortar_color = (180, 170, 160)  # Light gray/tan for mortar
        draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=mortar_color)
        
        # Generate random polygons for stones
        for _ in range(num_stones):
            # Random center point
            cx = random.randint(0, TEXTURE_SIZE)
            cy = random.randint(0, TEXTURE_SIZE)
            
            # Generate random polygon around center
            num_points = random.randint(5, 8)
            points = []
            
            for i in range(num_points):
                angle = 2 * math.pi * i / num_points
                distance = random.randint(30, 70)
                px = cx + int(distance * math.cos(angle))
                py = cy + int(distance * math.sin(angle))
                points.append((px, py))
            
            # Stone color variation
            r_offset = random.randint(-20, 20)
            g_offset = random.randint(-20, 20)
            b_offset = random.randint(-20, 20)
            
            stone_color = (
                max(0, min(255, base_color[0] + r_offset)),
                max(0, min(255, base_color[1] + g_offset)),
                max(0, min(255, base_color[2] + b_offset))
            )
            
            # Draw the stone
            draw.polygon(points, fill=stone_color)
            
            # Add some texture to the stone
            for _ in range(random.randint(5, 10)):
                tx = random.randint(cx - 20, cx + 20)
                ty = random.randint(cy - 20, cy + 20)
                ts = random.randint(2, 8)
                
                # Texture is usually darker
                texture_color = (
                    int(stone_color[0] * 0.85),
                    int(stone_color[1] * 0.85),
                    int(stone_color[2] * 0.85)
                )
                
                draw.ellipse((tx, ty, tx + ts, ty + ts), fill=texture_color)
    
    elif variation == "rough_stone":
        # Create a more natural, rough stone texture
        # Add base texture with noise
        img = add_noise(img, intensity=0.2)
        
        # Add cracks and texture variations
        img = add_texture_variation(img, variation_type="cracks", intensity=0.7)
        
        # Add some larger stone features
        num_features = random.randint(20, 40)
        for _ in range(num_features):
            x = random.randint(0, TEXTURE_SIZE - 1)
            y = random.randint(0, TEXTURE_SIZE - 1)
            size = random.randint(10, 30)
            
            # Feature color variation (usually darker or lighter than base)
            if random.random() < 0.5:
                # Darker feature
                feature_color = (
                    int(base_color[0] * 0.8),
                    int(base_color[1] * 0.8),
                    int(base_color[2] * 0.8)
                )
            else:
                # Lighter feature
                feature_color = (
                    min(255, int(base_color[0] * 1.2)),
                    min(255, int(base_color[1] * 1.2)),
                    min(255, int(base_color[2] * 1.2))
                )
            
            # Draw irregular shape
            num_points = random.randint(5, 8)
            points = []
            
            for i in range(num_points):
                angle = 2 * math.pi * i / num_points
                distance = random.randint(size // 2, size)
                px = x + int(distance * math.cos(angle))
                py = y + int(distance * math.sin(angle))
                points.append((px, py))
            
            draw = ImageDraw.Draw(img)
            draw.polygon(points, fill=feature_color)
    
    # Add noise and texture
    img = add_noise(img, intensity=0.05)
    
    # Apply some blur for realism
    img = img.filter(ImageFilter.GaussianBlur(radius=0.5))
    
    return img

def generate_brick_texture(variation="red_brick"):
    """Generate a brick texture with the specified variation"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Base brick color based on variation
    if variation == "red_brick":
        brick_color = (180, 60, 40)  # Traditional red brick
    elif variation == "clay_brick":
        brick_color = (200, 150, 100)  # Clay/tan brick
    elif variation == "dark_brick":
        brick_color = (100, 50, 40)  # Darker red/brown brick
    else:
        brick_color = random.choice([(180, 60, 40), (200, 150, 100), (100, 50, 40)])
    
    # Mortar color
    mortar_color = (200, 195, 190)  # Light gray
    
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
    
    # Add weathering effects
    if random.random() < 0.7:  # 70% chance of weathering
        img = add_texture_variation(img, variation_type="spots", intensity=0.3)
    
    # Add noise for realism
    img = add_noise(img, intensity=0.05)
    
    return img

def generate_wood_texture(variation="oak"):
    """Generate a wood texture with the specified variation"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Base wood color based on variation
    if variation == "oak":
        wood_color = (150, 110, 70)  # Medium brown
    elif variation == "dark_wood":
        wood_color = (100, 70, 40)  # Dark brown
    elif variation == "light_wood":
        wood_color = (180, 140, 100)  # Light brown
    else:
        wood_color = random.choice([(150, 110, 70), (100, 70, 40), (180, 140, 100)])
    
    # Fill with base color
    draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=wood_color)
    
    # Add wood grain
    num_grain_lines = random.randint(20, 40)
    for i in range(num_grain_lines):
        # Position grain lines evenly with some randomness
        y = int(i * TEXTURE_SIZE / num_grain_lines) + random.randint(-10, 10)
        
        # Skip if out of bounds
        if y < 0 or y >= TEXTURE_SIZE:
            continue
        
        # Grain color variation
        if random.random() < 0.7:  # 70% darker grain
            grain_color = (
                int(wood_color[0] * 0.85),
                int(wood_color[1] * 0.85),
                int(wood_color[2] * 0.85)
            )
        else:  # 30% lighter grain
            grain_color = (
                min(255, int(wood_color[0] * 1.15)),
                min(255, int(wood_color[1] * 1.15)),
                min(255, int(wood_color[2] * 1.15))
            )
        
        # Draw wavy grain line
        points = []
        wave_amplitude = random.randint(5, 15)
        wave_frequency = random.uniform(0.01, 0.03)
        
        for x in range(0, TEXTURE_SIZE, 5):
            wave_y = y + wave_amplitude * math.sin(x * wave_frequency)
            points.append((x, wave_y))
        
        # Draw the grain line
        if len(points) > 1:
            draw.line(points, fill=grain_color, width=random.randint(1, 3))
    
    # Add knots
    num_knots = random.randint(1, 5)
    for _ in range(num_knots):
        x = random.randint(0, TEXTURE_SIZE)
        y = random.randint(0, TEXTURE_SIZE)
        size = random.randint(10, 30)
        
        # Knot is usually darker
        knot_color = (
            int(wood_color[0] * 0.7),
            int(wood_color[1] * 0.7),
            int(wood_color[2] * 0.7)
        )
        
        # Draw concentric circles for knot
        for radius in range(size, 0, -2):
            circle_color = (
                knot_color[0] + random.randint(-10, 10),
                knot_color[1] + random.randint(-10, 10),
                knot_color[2] + random.randint(-10, 10)
            )
            draw.ellipse(
                (x - radius, y - radius, x + radius, y + radius),
                outline=circle_color
            )
    
    # Add texture variation
    img = add_texture_variation(img, variation_type="grain", intensity=0.6)
    
    # Add noise for realism
    img = add_noise(img, intensity=0.05)
    
    return img

def generate_thatch_texture():
    """Generate a thatch roof texture"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Base thatch color
    thatch_color = (180, 160, 100)  # Straw yellow/tan
    
    # Fill with base color
    draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=thatch_color)
    
    # Draw thatch strands
    strand_length = 80
    strand_width = 3
    num_strands = 300
    
    for _ in range(num_strands):
        x = random.randint(0, TEXTURE_SIZE)
        y = random.randint(0, TEXTURE_SIZE)
        angle = random.uniform(-0.2, 0.2)  # Mostly horizontal
        
        # Strand color variation
        r_offset = random.randint(-30, 30)
        g_offset = random.randint(-30, 30)
        b_offset = random.randint(-20, 20)
        
        strand_color = (
            max(0, min(255, thatch_color[0] + r_offset)),
            max(0, min(255, thatch_color[1] + g_offset)),
            max(0, min(255, thatch_color[2] + b_offset))
        )
        
        # Calculate end point with angle
        end_x = x + int(strand_length * math.cos(angle))
        end_y = y + int(strand_length * math.sin(angle))
        
        draw.line((x, y, end_x, end_y), fill=strand_color, width=strand_width)
    
    # Add some darker patches for depth
    num_patches = random.randint(10, 20)
    for _ in range(num_patches):
        x = random.randint(0, TEXTURE_SIZE)
        y = random.randint(0, TEXTURE_SIZE)
        size = random.randint(20, 50)
        
        # Darker patch
        patch_color = (
            int(thatch_color[0] * 0.8),
            int(thatch_color[1] * 0.8),
            int(thatch_color[2] * 0.8)
        )
        
        draw.ellipse((x, y, x + size, y + size), fill=patch_color)
    
    # Add noise and texture
    img = add_noise(img, intensity=0.1)
    img = add_texture_variation(img, variation_type="grain", intensity=0.3)
    
    # Apply some blur for realism
    img = img.filter(ImageFilter.GaussianBlur(radius=0.5))
    
    return img

def generate_flower_texture(color_name="random"):
    """Generate a flower texture with the specified color"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Background color (transparent in a real texture)
    bg_color = (0, 0, 0, 0)  # Transparent
    draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=bg_color)
    
    # Flower color
    if color_name == "random":
        flower_color = random.choice(PALETTES["medieval_pigments"])
    elif color_name == "red":
        flower_color = PALETTES["medieval_pigments"][0]  # Vermilion
    elif color_name == "blue":
        flower_color = PALETTES["medieval_pigments"][1]  # Ultramarine
    elif color_name == "yellow":
        flower_color = PALETTES["medieval_pigments"][2]  # Ochre
    elif color_name == "purple":
        flower_color = PALETTES["medieval_pigments"][5]  # Tyrian purple
    else:
        flower_color = random.choice(PALETTES["medieval_pigments"])
    
    # Center of the flower
    center_x = TEXTURE_SIZE // 2
    center_y = TEXTURE_SIZE // 2
    
    # Draw petals
    num_petals = random.randint(5, 12)
    petal_length = random.randint(TEXTURE_SIZE // 4, TEXTURE_SIZE // 3)
    petal_width = random.randint(TEXTURE_SIZE // 10, TEXTURE_SIZE // 6)
    
    for i in range(num_petals):
        angle = 2 * math.pi * i / num_petals
        
        # Petal color variation
        r_offset = random.randint(-20, 20)
        g_offset = random.randint(-20, 20)
        b_offset = random.randint(-20, 20)
        
        petal_color = (
            max(0, min(255, flower_color[0] + r_offset)),
            max(0, min(255, flower_color[1] + g_offset)),
            max(0, min(255, flower_color[2] + b_offset))
        )
        
        # Calculate petal points
        # Base of petal
        base_x = center_x
        base_y = center_y
        
        # Tip of petal
        tip_x = center_x + int(petal_length * math.cos(angle))
        tip_y = center_y + int(petal_length * math.sin(angle))
        
        # Control points for the petal curve
        ctrl1_x = center_x + int(petal_length * 0.5 * math.cos(angle - 0.3))
        ctrl1_y = center_y + int(petal_length * 0.5 * math.sin(angle - 0.3))
        
        ctrl2_x = center_x + int(petal_length * 0.5 * math.cos(angle + 0.3))
        ctrl2_y = center_y + int(petal_length * 0.5 * math.sin(angle + 0.3))
        
        # Draw the petal as a polygon
        points = [
            (base_x, base_y),
            (ctrl1_x, ctrl1_y),
            (tip_x, tip_y),
            (ctrl2_x, ctrl2_y)
        ]
        
        draw.polygon(points, fill=petal_color)
    
    # Draw flower center
    center_radius = random.randint(TEXTURE_SIZE // 15, TEXTURE_SIZE // 10)
    
    # Center color (usually contrasting with petals)
    center_color = (
        255 - flower_color[0],
        255 - flower_color[1],
        255 - flower_color[2]
    )
    
    draw.ellipse(
        (center_x - center_radius, center_y - center_radius,
         center_x + center_radius, center_y + center_radius),
        fill=center_color
    )
    
    # Add some texture to the center
    for _ in range(random.randint(10, 20)):
        tx = random.randint(center_x - center_radius + 2, center_x + center_radius - 2)
        ty = random.randint(center_y - center_radius + 2, center_y + center_radius - 2)
        ts = random.randint(1, 3)
        
        # Texture dots are usually darker
        texture_color = (
            int(center_color[0] * 0.7),
            int(center_color[1] * 0.7),
            int(center_color[2] * 0.7)
        )
        
        draw.ellipse((tx, ty, tx + ts, ty + ts), fill=texture_color)
    
    # Add some subtle texture to the petals
    img = add_noise(img, intensity=0.05)
    
    return img

def generate_leaf_texture(variation="green"):
    """Generate a leaf texture with the specified variation"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Background color (transparent in a real texture)
    bg_color = (0, 0, 0, 0)  # Transparent
    draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=bg_color)
    
    # Leaf color based on variation
    if variation == "green":
        leaf_color = random.choice(PALETTES["greens"][:3])  # Darker to medium greens
    elif variation == "autumn":
        leaf_color = random.choice([
            (180, 100, 30),  # Orange
            (170, 60, 40),   # Red-orange
            (150, 120, 30)   # Yellow-brown
        ])
    elif variation == "dry":
        leaf_color = random.choice([
            (140, 120, 40),  # Olive
            (120, 100, 50),  # Brown-green
            (150, 130, 70)   # Tan
        ])
    else:
        leaf_color = random.choice(PALETTES["greens"])
    
    # Center of the leaf
    center_x = TEXTURE_SIZE // 2
    center_y = TEXTURE_SIZE // 2
    
    # Leaf dimensions
    leaf_length = random.randint(TEXTURE_SIZE // 2, int(TEXTURE_SIZE * 0.8))
    leaf_width = random.randint(TEXTURE_SIZE // 4, TEXTURE_SIZE // 3)
    
    # Draw the leaf shape
    # Main leaf shape as an ellipse
    draw.ellipse(
        (center_x - leaf_width // 2, center_y - leaf_length // 2,
         center_x + leaf_width // 2, center_y + leaf_length // 2),
        fill=leaf_color
    )
    
    # Draw the stem
    stem_length = random.randint(TEXTURE_SIZE // 8, TEXTURE_SIZE // 6)
    stem_width = random.randint(2, 5)
    
    stem_color = (
        int(leaf_color[0] * 0.7),
        int(leaf_color[1] * 0.7),
        int(leaf_color[2] * 0.7)
    )
    
    draw.line(
        (center_x, center_y + leaf_length // 2,
         center_x, center_y + leaf_length // 2 + stem_length),
        fill=stem_color,
        width=stem_width
    )
    
    # Draw the veins
    main_vein_color = (
        int(leaf_color[0] * 0.8),
        int(leaf_color[1] * 0.8),
        int(leaf_color[2] * 0.8)
    )
    
    # Main vein
    draw.line(
        (center_x, center_y - leaf_length // 2,
         center_x, center_y + leaf_length // 2),
        fill=main_vein_color,
        width=2
    )
    
    # Side veins
    num_veins = random.randint(5, 10)
    for i in range(num_veins):
        # Position along main vein
        y_pos = center_y - leaf_length // 2 + i * leaf_length // num_veins
        
        # Left vein
        angle = random.uniform(math.pi / 4, math.pi / 2)
        length = random.randint(leaf_width // 4, leaf_width // 2)
        
        end_x = center_x - int(length * math.cos(angle))
        end_y = y_pos + int(length * math.sin(angle))
        
        draw.line((center_x, y_pos, end_x, end_y), fill=main_vein_color, width=1)
        
        # Right vein
        angle = random.uniform(math.pi / 4, math.pi / 2)
        length = random.randint(leaf_width // 4, leaf_width // 2)
        
        end_x = center_x + int(length * math.cos(angle))
        end_y = y_pos + int(length * math.sin(angle))
        
        draw.line((center_x, y_pos, end_x, end_y), fill=main_vein_color, width=1)
    
    # Add some texture
    if variation == "dry" or random.random() < 0.3:
        img = add_texture_variation(img, variation_type="spots", intensity=0.3)
    
    # Add noise for realism
    img = add_noise(img, intensity=0.05)
    
    return img

def generate_water_texture(variation="calm"):
    """Generate a water texture with the specified variation"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Base water color based on variation
    if variation == "calm":
        water_color = (60, 100, 140)  # Blue
    elif variation == "murky":
        water_color = (80, 100, 80)  # Greenish
    elif variation == "shallow":
        water_color = (100, 140, 160)  # Light blue
    else:
        water_color = (60, 100, 140)  # Default blue
    
    # Fill with base color
    draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=water_color)
    
    # Add wave patterns
    num_waves = random.randint(10, 30)
    for i in range(num_waves):
        # Wave parameters
        wave_y = random.randint(0, TEXTURE_SIZE)
        wave_amplitude = random.randint(5, 20)
        wave_length = random.randint(100, 300)
        wave_width = random.randint(2, 8)
        
        # Wave color variation
        if random.random() < 0.7:  # 70% darker waves
            wave_color = (
                int(water_color[0] * 0.8),
                int(water_color[1] * 0.8),
                int(water_color[2] * 0.8)
            )
        else:  # 30% lighter waves (highlights)
            wave_color = (
                min(255, int(water_color[0] * 1.2)),
                min(255, int(water_color[1] * 1.2)),
                min(255, int(water_color[2] * 1.2))
            )
        
        # Draw wavy line
        points = []
        for x in range(0, TEXTURE_SIZE, 5):
            wave_offset = wave_amplitude * math.sin(x * 2 * math.pi / wave_length)
            points.append((x, wave_y + wave_offset))
        
        if len(points) > 1:
            draw.line(points, fill=wave_color, width=wave_width)
    
    # Add some ripple effects
    if variation != "calm" or random.random() < 0.5:
        num_ripples = random.randint(5, 15)
        for _ in range(num_ripples):
            x = random.randint(0, TEXTURE_SIZE)
            y = random.randint(0, TEXTURE_SIZE)
            
            # Multiple concentric circles for each ripple
            for radius in range(random.randint(10, 40), 0, -5):
                ripple_color = (
                    int(water_color[0] * (0.8 + 0.4 * (radius % 10) / 10)),
                    int(water_color[1] * (0.8 + 0.4 * (radius % 10) / 10)),
                    int(water_color[2] * (0.8 + 0.4 * (radius % 10) / 10))
                )
                
                draw.ellipse(
                    (x - radius, y - radius, x + radius, y + radius),
                    outline=ripple_color
                )
    
    # Add some random highlights for sparkle
    num_highlights = random.randint(20, 100)
    for _ in range(num_highlights):
        x = random.randint(0, TEXTURE_SIZE)
        y = random.randint(0, TEXTURE_SIZE)
        size = random.randint(1, 3)
        
        highlight_color = (
            min(255, int(water_color[0] * 1.5)),
            min(255, int(water_color[1] * 1.5)),
            min(255, int(water_color[2] * 1.5))
        )
        
        draw.ellipse((x, y, x + size, y + size), fill=highlight_color)
    
    # Add noise for realism
    img = add_noise(img, intensity=0.05)
    
    # Apply blur for a smoother water look
    img = img.filter(ImageFilter.GaussianBlur(radius=1.0))
    
    return img

def generate_parchment_texture():
    """Generate a medieval parchment/paper texture"""
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE))
    draw = ImageDraw.Draw(img)
    
    # Base parchment color
    parchment_color = (230, 220, 200)  # Off-white/cream
    
    # Fill with base color
    draw.rectangle((0, 0, TEXTURE_SIZE, TEXTURE_SIZE), fill=parchment_color)
    
    # Add subtle color variations
    num_variations = random.randint(100, 300)
    for _ in range(num_variations):
        x = random.randint(0, TEXTURE_SIZE)
        y = random.randint(0, TEXTURE_SIZE)
        size = random.randint(10, 50)
        
        # Variation color (subtle)
        r_offset = random.randint(-15, 15)
        g_offset = random.randint(-15, 15)
        b_offset = random.randint(-15, 15)
        
        variation_color = (
            max(200, min(255, parchment_color[0] + r_offset)),
            max(190, min(255, parchment_color[1] + g_offset)),
            max(170, min(255, parchment_color[2] + b_offset))
        )
        
        # Draw with low opacity
        for i in range(size, 0, -5):
            opacity = random.randint(0, 100)
            blend_color = (
                int(parchment_color[0] * (1 - opacity/255) + variation_color[0] * (opacity/255)),
                int(parchment_color[1] * (1 - opacity/255) + variation_color[1] * (opacity/255)),
                int(parchment_color[2] * (1 - opacity/255) + variation_color[2] * (opacity/255))
            )
            draw.ellipse((x-i, y-i, x+i, y+i), fill=blend_color)
    
    # Add some darker spots/stains
    num_stains = random.randint(5, 15)
    for _ in range(num_stains):
        x = random.randint(0, TEXTURE_SIZE)
        y = random.randint(0, TEXTURE_SIZE)
        size = random.randint(5, 20)
        
        # Stain color (darker brown)
        stain_color = (
            random.randint(160, 200),
            random.randint(140, 180),
            random.randint(100, 140)
        )
        
        # Draw with low opacity
        for i in range(size, 0, -2):
            opacity = random.randint(50, 150)
            blend_color = (
                int(parchment_color[0] * (1 - opacity/255) + stain_color[0] * (opacity/255)),
                int(parchment_color[1] * (1 - opacity/255) + stain_color[1] * (opacity/255)),
                int(parchment_color[2] * (1 - opacity/255) + stain_color[2] * (opacity/255))
            )
            draw.ellipse((x-i, y-i, x+i, y+i), fill=blend_color)
    
    # Add some fiber texture
    num_fibers = random.randint(200, 500)
    for _ in range(num_fibers):
        x = random.randint(0, TEXTURE_SIZE)
        y = random.randint(0, TEXTURE_SIZE)
        length = random.randint(5, 20)
        angle = random.uniform(0, 2 * math.pi)
        
        # Fiber color (subtle variation)
        r_offset = random.randint(-10, 10)
        g_offset = random.randint(-10, 10)
        b_offset = random.randint(-10, 10)
        
        fiber_color = (
            max(200, min(255, parchment_color[0] + r_offset)),
            max(190, min(255, parchment_color[1] + g_offset)),
            max(170, min(255, parchment_color[2] + b_offset))
        )
        
        # Calculate end point
        end_x = x + int(length * math.cos(angle))
        end_y = y + int(length * math.sin(angle))
        
        draw.line((x, y, end_x, end_y), fill=fiber_color, width=1)
    
    # Add some creases/folds
    num_creases = random.randint(2, 5)
    for _ in range(num_creases):
        # Decide between horizontal, vertical, or diagonal crease
        crease_type = random.choice(["horizontal", "vertical", "diagonal"])
        
        if crease_type == "horizontal":
            y = random.randint(TEXTURE_SIZE // 4, 3 * TEXTURE_SIZE // 4)
            points = [(0, y)]
            
            # Create a slightly wavy line
            for x in range(50, TEXTURE_SIZE, 50):
                y_offset = random.randint(-10, 10)
                points.append((x, y + y_offset))
            
            points.append((TEXTURE_SIZE, y + random.randint(-10, 10)))
            
        elif crease_type == "vertical":
            x = random.randint(TEXTURE_SIZE // 4, 3 * TEXTURE_SIZE // 4)
            points = [(x, 0)]
            
            # Create a slightly wavy line
            for y in range(50, TEXTURE_SIZE, 50):
                x_offset = random.randint(-10, 10)
                points.append((x + x_offset, y))
            
            points.append((x + random.randint(-10, 10), TEXTURE_SIZE))
            
        else:  # diagonal
            start_x = random.choice([0, TEXTURE_SIZE])
            start_y = random.choice([0, TEXTURE_SIZE])
            end_x = TEXTURE_SIZE - start_x
            end_y = TEXTURE_SIZE - start_y
            
            points = [(start_x, start_y)]
            
            # Create a slightly wavy line
            steps = 10
            for i in range(1, steps):
                t = i / steps
                x = start_x + (end_x - start_x) * t
                y = start_y + (end_y - start_y) * t
                
                # Add some waviness
                x_offset = random.randint(-15, 15)
                y_offset = random.randint(-15, 15)
                
                points.append((x + x_offset, y + y_offset))
            
            points.append((end_x, end_y))
        
        # Draw the crease
        crease_color = (
            int(parchment_color[0] * 0.9),
            int(parchment_color[1] * 0.9),
            int(parchment_color[2] * 0.9)
        )
        
        draw.line(points, fill=crease_color, width=random.randint(1, 3))
    
    # Add noise and texture
    img = add_noise(img, intensity=0.05)
    img = add_texture_variation(img, variation_type="spots", intensity=0.2)
    
    # Apply very slight blur
    img = img.filter(ImageFilter.GaussianBlur(radius=0.5))
    
    return img

def generate_all_textures():
    """Generate all textures and save them to the appropriate directories"""
    print("Generating ground textures...")
    # Ground textures
    soil_rich = generate_soil_texture("rich")
    soil_rich.save(os.path.join(BASE_DIR, "ground", "soil_rich.png"))
    
    soil_dry = generate_soil_texture("dry")
    soil_dry.save(os.path.join(BASE_DIR, "ground", "soil_dry.png"))
    
    soil_clay = generate_soil_texture("clay")
    soil_clay.save(os.path.join(BASE_DIR, "ground", "soil_clay.png"))
    
    grass_common = generate_grass_texture("common")
    grass_common.save(os.path.join(BASE_DIR, "ground", "grass_common.png"))
    
    grass_lush = generate_grass_texture("lush")
    grass_lush.save(os.path.join(BASE_DIR, "ground", "grass_lush.png"))
    
    grass_dry = generate_grass_texture("dry")
    grass_dry.save(os.path.join(BASE_DIR, "ground", "grass_dry.png"))
    
    stone_cobble = generate_stone_texture("cobblestone")
    stone_cobble.save(os.path.join(BASE_DIR, "ground", "stone_cobble.png"))
    
    stone_flag = generate_stone_texture("flagstone")
    stone_flag.save(os.path.join(BASE_DIR, "ground", "stone_flag.png"))
    
    stone_rough = generate_stone_texture("rough_stone")
    stone_rough.save(os.path.join(BASE_DIR, "ground", "stone_rough.png"))
    
    brick_red = generate_brick_texture("red_brick")
    brick_red.save(os.path.join(BASE_DIR, "ground", "brick_red.png"))
    
    brick_clay = generate_brick_texture("clay_brick")
    brick_clay.save(os.path.join(BASE_DIR, "ground", "brick_clay.png"))
    
    water_calm = generate_water_texture("calm")
    water_calm.save(os.path.join(BASE_DIR, "ground", "water_calm.png"))
    
    water_murky = generate_water_texture("murky")
    water_murky.save(os.path.join(BASE_DIR, "ground", "water_murky.png"))
    
    print("Generating plant textures...")
    # Plant textures
    flower_red = generate_flower_texture("red")
    flower_red.save(os.path.join(BASE_DIR, "plants", "flower_red.png"))
    
    flower_blue = generate_flower_texture("blue")
    flower_blue.save(os.path.join(BASE_DIR, "plants", "flower_blue.png"))
    
    flower_yellow = generate_flower_texture("yellow")
    flower_yellow.save(os.path.join(BASE_DIR, "plants", "flower_yellow.png"))
    
    flower_purple = generate_flower_texture("purple")
    flower_purple.save(os.path.join(BASE_DIR, "plants", "flower_purple.png"))
    
    leaf_green = generate_leaf_texture("green")
    leaf_green.save(os.path.join(BASE_DIR, "plants", "leaf_green.png"))
    
    leaf_autumn = generate_leaf_texture("autumn")
    leaf_autumn.save(os.path.join(BASE_DIR, "plants", "leaf_autumn.png"))
    
    leaf_dry = generate_leaf_texture("dry")
    leaf_dry.save(os.path.join(BASE_DIR, "plants", "leaf_dry.png"))
    
    print("Generating structure textures...")
    # Structure textures
    wood_oak = generate_wood_texture("oak")
    wood_oak.save(os.path.join(BASE_DIR, "structures", "wood_oak.png"))
    
    wood_dark = generate_wood_texture("dark_wood")
    wood_dark.save(os.path.join(BASE_DIR, "structures", "wood_dark.png"))
    
    wood_light = generate_wood_texture("light_wood")
    wood_light.save(os.path.join(BASE_DIR, "structures", "wood_light.png"))
    
    thatch = generate_thatch_texture()
    thatch.save(os.path.join(BASE_DIR, "structures", "thatch.png"))
    
    print("Generating decorative textures...")
    # Decorative textures
    parchment = generate_parchment_texture()
    parchment.save(os.path.join(BASE_DIR, "decorative", "parchment.png"))
    
    # Add medieval border to some textures for decorative variants
    parchment_bordered = add_medieval_border(parchment)
    parchment_bordered.save(os.path.join(BASE_DIR, "decorative", "parchment_bordered.png"))
    
    print("All textures generated successfully!")

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
        
        if texture_type == "soil":
            img = generate_soil_texture(variation)
            texture_path = os.path.join(BASE_DIR, "ground", f"soil_{variation}.png")
            img.save(texture_path)
        
        elif texture_type == "grass":
            img = generate_grass_texture(variation)
            texture_path = os.path.join(BASE_DIR, "ground", f"grass_{variation}.png")
            img.save(texture_path)
        
        elif texture_type == "stone":
            img = generate_stone_texture(variation)
            texture_path = os.path.join(BASE_DIR, "ground", f"stone_{variation}.png")
            img.save(texture_path)
        
        elif texture_type == "brick":
            img = generate_brick_texture(variation)
            texture_path = os.path.join(BASE_DIR, "ground", f"brick_{variation}.png")
            img.save(texture_path)
        
        elif texture_type == "wood":
            img = generate_wood_texture(variation)
            texture_path = os.path.join(BASE_DIR, "structures", f"wood_{variation}.png")
            img.save(texture_path)
        
        elif texture_type == "thatch":
            img = generate_thatch_texture()
            texture_path = os.path.join(BASE_DIR, "structures", "thatch.png")
            img.save(texture_path)
        
        elif texture_type == "flower":
            img = generate_flower_texture(variation)
            texture_path = os.path.join(BASE_DIR, "plants", f"flower_{variation}.png")
            img.save(texture_path)
        
        elif texture_type == "leaf":
            img = generate_leaf_texture(variation)
            texture_path = os.path.join(BASE_DIR, "plants", f"leaf_{variation}.png")
            img.save(texture_path)
        
        elif texture_type == "water":
            img = generate_water_texture(variation)
            texture_path = os.path.join(BASE_DIR, "ground", f"water_{variation}.png")
            img.save(texture_path)
        
        elif texture_type == "parchment":
            img = generate_parchment_texture()
            texture_path = os.path.join(BASE_DIR, "decorative", "parchment.png")
            img.save(texture_path)
            
            # Also create a bordered version
            bordered_img = add_medieval_border(img)
            bordered_path = os.path.join(BASE_DIR, "decorative", "parchment_bordered.png")
            bordered_img.save(bordered_path)
        
        # Print the path for the Godot script to capture
        if texture_path:
            print(f"TEXTURE_PATH:{texture_path}")
        else:
            print(f"ERROR: Unknown texture type: {texture_type}")
            sys.exit(1)
    
    # Generate all textures by default
    else:
        generate_all_textures()
