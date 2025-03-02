import os
import sys
import argparse
import subprocess
from PIL import Image, ImageFilter

# Add the project root to the path so we can import our modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Import our texture generators
import scripts.texture_generator as base_generator
import scripts.medieval_texture_generator as medieval_generator

# Base directories
BASE_TEXTURE_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 
                               "assets", "textures")
MEDIEVAL_TEXTURE_DIR = os.path.join(BASE_TEXTURE_DIR, "medieval_garden_pack")
OUTPUT_DIR = os.path.join(BASE_TEXTURE_DIR, "integrated_packs")

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

def generate_normal_map(texture_path, strength=1.0):
    """Generate a normal map from a texture using PIL"""
    # Load the texture
    img = Image.open(texture_path).convert('L')  # Convert to grayscale
    
    # Get dimensions
    width, height = img.size
    
    # Create a new RGB image for the normal map
    normal_map = Image.new('RGB', (width, height), (128, 128, 255))
    
    # Calculate normals based on height differences
    for y in range(1, height - 1):
        for x in range(1, width - 1):
            # Get surrounding pixel values
            top = img.getpixel((x, y - 1))
            bottom = img.getpixel((x, y + 1))
            left = img.getpixel((x - 1, y))
            right = img.getpixel((x + 1, y))
            
            # Calculate normal vector components (simplified)
            nx = (left - right) * strength
            ny = (bottom - top) * strength
            nz = 1.0  # Fixed Z component
            
            # Normalize and convert to 0-255 range
            length = (nx * nx + ny * ny + nz * nz) ** 0.5
            nx = int(128 + 127 * nx / length)
            ny = int(128 + 127 * ny / length)
            nz = int(128 + 127 * nz / length)
            
            # Set the pixel in the normal map
            normal_map.putpixel((x, y), (nx, ny, nz))
    
    return normal_map

def generate_roughness_map(texture_path, base_roughness=0.7, variation=0.3):
    """Generate a roughness map from a texture"""
    # Load the texture
    img = Image.open(texture_path).convert('L')  # Convert to grayscale
    
    # Get dimensions
    width, height = img.size
    
    # Create a new grayscale image for the roughness map
    roughness_map = Image.new('L', (width, height))
    
    # Calculate roughness based on texture details
    for y in range(height):
        for x in range(width):
            # Get pixel value
            pixel = img.getpixel((x, y))
            
            # Calculate roughness with variation based on pixel intensity
            roughness = base_roughness + (pixel / 255.0 - 0.5) * variation
            roughness = max(0.0, min(1.0, roughness))  # Clamp to 0-1
            
            # Set the pixel in the roughness map
            roughness_map.putpixel((x, y), int(roughness * 255))
    
    return roughness_map

def create_texture_set(base_texture_path, output_name, shader_type="medieval"):
    """Create a complete texture set (albedo, normal, roughness) for use with shaders"""
    # Create output directory
    output_dir = os.path.join(OUTPUT_DIR, output_name)
    os.makedirs(output_dir, exist_ok=True)
    
    # Get base texture name
    base_texture_name = os.path.basename(base_texture_path)
    
    # Copy the base texture as albedo
    albedo_path = os.path.join(output_dir, f"{output_name}_albedo.png")
    albedo_img = Image.open(base_texture_path)
    albedo_img.save(albedo_path)
    
    # Generate normal map
    normal_map = generate_normal_map(base_texture_path, strength=1.5)
    normal_path = os.path.join(output_dir, f"{output_name}_normal.png")
    normal_map.save(normal_path)
    
    # Generate roughness map
    roughness_map = generate_roughness_map(base_texture_path)
    roughness_path = os.path.join(output_dir, f"{output_name}_roughness.png")
    roughness_map.save(roughness_path)
    
    # Generate shader-specific maps based on shader type
    if shader_type == "medieval":
        # For medieval shader, create a detail texture
        detail_path = os.path.join(output_dir, f"{output_name}_detail.png")
        detail_img = albedo_img.copy()
        detail_img = detail_img.filter(ImageFilter.FIND_EDGES)
        detail_img = detail_img.convert('L')
        detail_img.save(detail_path)
        
        # Create a weathering mask
        weathering_path = os.path.join(output_dir, f"{output_name}_weathering.png")
        weathering_img = Image.new('L', albedo_img.size)
        
        # Add some weathering patterns
        width, height = weathering_img.size
        for y in range(height):
            for x in range(width):
                # More weathering at edges and corners
                edge_factor = min(x, y, width - x, height - y) / (min(width, height) * 0.25)
                edge_factor = max(0.0, min(1.0, edge_factor))
                
                # Random variation
                import random
                random_factor = random.uniform(0.0, 1.0)
                
                # Combine factors
                weathering = (edge_factor * 0.7 + random_factor * 0.3) * 255
                weathering_img.putpixel((x, y), int(weathering))
        
        weathering_img.save(weathering_path)
    
    print(f"Created texture set in {output_dir}")
    return {
        "albedo": albedo_path,
        "normal": normal_path,
        "roughness": roughness_path
    }

def create_medieval_garden_texture_sets():
    """Create texture sets for all medieval garden textures"""
    # Process garden elements
    garden_elements_dir = os.path.join(MEDIEVAL_TEXTURE_DIR, "garden_elements")
    for filename in os.listdir(garden_elements_dir):
        if filename.endswith(".png"):
            texture_path = os.path.join(garden_elements_dir, filename)
            output_name = os.path.splitext(filename)[0]
            create_texture_set(texture_path, f"garden_{output_name}")
    
    # Process ornamental elements
    ornamental_dir = os.path.join(MEDIEVAL_TEXTURE_DIR, "ornamental")
    for filename in os.listdir(ornamental_dir):
        if filename.endswith(".png"):
            texture_path = os.path.join(ornamental_dir, filename)
            output_name = os.path.splitext(filename)[0]
            create_texture_set(texture_path, f"ornamental_{output_name}")
    
    # Process symbolic elements
    symbolic_dir = os.path.join(MEDIEVAL_TEXTURE_DIR, "symbolic")
    for filename in os.listdir(symbolic_dir):
        if filename.endswith(".png"):
            texture_path = os.path.join(symbolic_dir, filename)
            output_name = os.path.splitext(filename)[0]
            create_texture_set(texture_path, f"symbolic_{output_name}")
    
    # Process materials
    materials_dir = os.path.join(MEDIEVAL_TEXTURE_DIR, "materials")
    for filename in os.listdir(materials_dir):
        if filename.endswith(".png"):
            texture_path = os.path.join(materials_dir, filename)
            output_name = os.path.splitext(filename)[0]
            create_texture_set(texture_path, f"material_{output_name}")

def generate_and_integrate_textures():
    """Generate all medieval textures and create shader-compatible texture sets"""
    # First, generate all the medieval textures
    print("Generating medieval textures...")
    medieval_generator.generate_all_medieval_textures()
    
    # Then create texture sets for all the generated textures
    print("Creating shader-compatible texture sets...")
    create_medieval_garden_texture_sets()
    
    print("All textures generated and integrated successfully!")

def create_godot_resource_file(texture_set, output_path, shader_type="medieval"):
    """Create a Godot resource file (.tres) for the texture set"""
    # Basic template for a ShaderMaterial resource
    resource_template = """[gd_resource type="ShaderMaterial" load_steps=6 format=3]

[ext_resource type="Shader" path="res://scripts/shaders/medieval_shader_pack.gdshader" id="1_shader"]
[ext_resource type="Texture2D" path="{albedo_path}" id="2_albedo"]
[ext_resource type="Texture2D" path="{normal_path}" id="3_normal"]
[ext_resource type="Texture2D" path="{roughness_path}" id="4_roughness"]
[ext_resource type="Texture2D" path="{detail_path}" id="5_detail"]

[resource]
shader = ExtResource("1_shader")
shader_parameter/base_color = Color(1, 1, 1, 1)
shader_parameter/roughness_value = 0.8
shader_parameter/metallic_value = 0.0
shader_parameter/normal_strength = 1.0
shader_parameter/detail_strength = 0.5
shader_parameter/weathering_amount = 0.3
shader_parameter/albedo_texture = ExtResource("2_albedo")
shader_parameter/normal_texture = ExtResource("3_normal")
shader_parameter/roughness_texture = ExtResource("4_roughness")
shader_parameter/detail_texture = ExtResource("5_detail")
"""
    
    # Fill in the template with the texture paths
    resource_content = resource_template.format(
        albedo_path=texture_set["albedo"].replace(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "res:"),
        normal_path=texture_set["normal"].replace(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "res:"),
        roughness_path=texture_set["roughness"].replace(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "res:"),
        detail_path=texture_set["detail"].replace(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "res:") if "detail" in texture_set else ""
    )
    
    # Write the resource file
    with open(output_path, 'w') as f:
        f.write(resource_content)
    
    print(f"Created Godot resource file: {output_path}")

def create_godot_resources_for_texture_sets():
    """Create Godot resource files for all texture sets"""
    # Process all texture sets in the output directory
    for texture_set_dir in os.listdir(OUTPUT_DIR):
        texture_set_path = os.path.join(OUTPUT_DIR, texture_set_dir)
        if os.path.isdir(texture_set_path):
            # Collect texture paths
            texture_set = {}
            for filename in os.listdir(texture_set_path):
                if filename.endswith("_albedo.png"):
                    texture_set["albedo"] = os.path.join(texture_set_path, filename)
                elif filename.endswith("_normal.png"):
                    texture_set["normal"] = os.path.join(texture_set_path, filename)
                elif filename.endswith("_roughness.png"):
                    texture_set["roughness"] = os.path.join(texture_set_path, filename)
                elif filename.endswith("_detail.png"):
                    texture_set["detail"] = os.path.join(texture_set_path, filename)
            
            # Create resource file if we have the required textures
            if "albedo" in texture_set and "normal" in texture_set and "roughness" in texture_set:
                resource_path = os.path.join(texture_set_path, f"{texture_set_dir}.tres")
                create_godot_resource_file(texture_set, resource_path)

def main():
    parser = argparse.ArgumentParser(description='Generate and integrate medieval textures with shaders')
    parser.add_argument('--generate', action='store_true', help='Generate all medieval textures')
    parser.add_argument('--integrate', action='store_true', help='Create shader-compatible texture sets')
    parser.add_argument('--resources', action='store_true', help='Create Godot resource files')
    parser.add_argument('--all', action='store_true', help='Perform all operations')
    
    args = parser.parse_args()
    
    if args.all or (args.generate and args.integrate and args.resources):
        # Do everything
        generate_and_integrate_textures()
        create_godot_resources_for_texture_sets()
    else:
        # Do individual steps as requested
        if args.generate:
            medieval_generator.generate_all_medieval_textures()
        
        if args.integrate:
            create_medieval_garden_texture_sets()
        
        if args.resources:
            create_godot_resources_for_texture_sets()
    
    print("Done!")

if __name__ == "__main__":
    main()
