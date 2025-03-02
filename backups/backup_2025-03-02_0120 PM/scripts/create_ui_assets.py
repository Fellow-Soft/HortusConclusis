#!/usr/bin/env python3
"""
Create UI assets for the Hortus Conclusus project
"""

from PIL import Image, ImageDraw, ImageFilter, ImageFont
import os
import random

# Create directories if they don't exist
os.makedirs("HortusConclusis/assets/ui/medieval", exist_ok=True)
os.makedirs("HortusConclusis/assets/fonts/medieval", exist_ok=True)

def create_parchment_bg():
    """Create a parchment background texture"""
    width, height = 512, 512
    
    # Create base image with parchment color
    image = Image.new("RGBA", (width, height), (230, 220, 180, 255))
    draw = ImageDraw.Draw(image)
    
    # Add noise to create parchment texture
    for y in range(height):
        for x in range(width):
            noise = random.randint(-15, 15)
            r, g, b, a = image.getpixel((x, y))
            r = max(0, min(255, r + noise))
            g = max(0, min(255, g + noise))
            b = max(0, min(255, b + noise))
            image.putpixel((x, y), (r, g, b, a))
    
    # Add some darker spots randomly
    for _ in range(100):
        x = random.randint(0, width - 1)
        y = random.randint(0, height - 1)
        radius = random.randint(5, 20)
        darkness = random.randint(20, 50)
        
        for dx in range(-radius, radius + 1):
            for dy in range(-radius, radius + 1):
                if x + dx >= 0 and x + dx < width and y + dy >= 0 and y + dy < height:
                    dist = (dx**2 + dy**2)**0.5
                    if dist <= radius:
                        factor = 1.0 - (dist / radius)
                        r, g, b, a = image.getpixel((x + dx, y + dy))
                        r = max(0, r - int(darkness * factor))
                        g = max(0, g - int(darkness * factor))
                        b = max(0, b - int(darkness * factor))
                        image.putpixel((x + dx, y + dy), (r, g, b, a))
    
    # Add a vignette effect
    for y in range(height):
        for x in range(width):
            # Calculate distance from center
            dx = x - width / 2
            dy = y - height / 2
            distance = (dx**2 + dy**2)**0.5
            max_distance = (width / 2)**2 + (height / 2)**2
            
            # Darken edges
            if distance > width / 3:
                factor = (distance - width / 3) / (width / 2)
                factor = min(factor, 0.7)  # Max darkening
                
                r, g, b, a = image.getpixel((x, y))
                r = max(0, int(r * (1 - factor)))
                g = max(0, int(g * (1 - factor)))
                b = max(0, int(b * (1 - factor)))
                image.putpixel((x, y), (r, g, b, a))
    
    # Apply slight blur
    image = image.filter(ImageFilter.GaussianBlur(1))
    
    # Save the image
    image.save("HortusConclusis/assets/ui/medieval/parchment_bg.png")
    print("Created parchment background")

def create_portrait_frame():
    """Create a medieval portrait frame"""
    width, height = 256, 256
    
    # Create base image with transparency
    image = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # Frame parameters
    border_width = 20
    inner_width = width - 2 * border_width
    inner_height = height - 2 * border_width
    
    # Draw outer frame (dark brown)
    draw.rectangle(
        [(0, 0), (width - 1, height - 1)],
        fill=(80, 50, 20, 255),
        outline=None
    )
    
    # Draw inner frame (lighter brown)
    draw.rectangle(
        [(border_width, border_width), (width - border_width - 1, height - border_width - 1)],
        fill=(120, 80, 40, 255),
        outline=None
    )
    
    # Draw inner cutout (transparent)
    draw.rectangle(
        [(border_width + 5, border_width + 5), 
         (width - border_width - 6, height - border_width - 6)],
        fill=(0, 0, 0, 0),
        outline=None
    )
    
    # Add decorative elements to the corners
    corner_size = 30
    
    # Top-left corner
    draw.rectangle(
        [(5, 5), (corner_size, corner_size)],
        fill=(150, 120, 50, 255),
        outline=None
    )
    
    # Top-right corner
    draw.rectangle(
        [(width - corner_size - 5, 5), (width - 6, corner_size)],
        fill=(150, 120, 50, 255),
        outline=None
    )
    
    # Bottom-left corner
    draw.rectangle(
        [(5, height - corner_size - 5), (corner_size, height - 6)],
        fill=(150, 120, 50, 255),
        outline=None
    )
    
    # Bottom-right corner
    draw.rectangle(
        [(width - corner_size - 5, height - corner_size - 5), (width - 6, height - 6)],
        fill=(150, 120, 50, 255),
        outline=None
    )
    
    # Add some gold accents
    for i in range(0, width, 20):
        draw.rectangle(
            [(i, 10), (i + 10, 15)],
            fill=(200, 170, 50, 255),
            outline=None
        )
        draw.rectangle(
            [(i, height - 15), (i + 10, height - 10)],
            fill=(200, 170, 50, 255),
            outline=None
        )
    
    for i in range(0, height, 20):
        draw.rectangle(
            [(10, i), (15, i + 10)],
            fill=(200, 170, 50, 255),
            outline=None
        )
        draw.rectangle(
            [(width - 15, i), (width - 10, i + 10)],
            fill=(200, 170, 50, 255),
            outline=None
        )
    
    # Save the image
    image.save("HortusConclusis/assets/ui/medieval/portrait_frame.png")
    print("Created portrait frame")

def create_placeholder_font():
    """Create a placeholder font file"""
    # Create a simple text file as a placeholder
    with open("HortusConclusis/assets/fonts/medieval/medieval_font.ttf", "w") as f:
        f.write("This is a placeholder for a medieval font file.\n")
        f.write("In a real project, you would use an actual TTF font file here.\n")
    
    print("Created placeholder font file")

if __name__ == "__main__":
    create_parchment_bg()
    create_portrait_frame()
    create_placeholder_font()
    print("All UI assets created successfully!")
