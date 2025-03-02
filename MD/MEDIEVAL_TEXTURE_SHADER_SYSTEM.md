# Medieval Texture and Shader System for Hortus Conclusus

This document provides an overview of the medieval texture and shader system implemented for the Hortus Conclusus project. The system includes procedural texture generation, shader enhancements, and integration tools to create an authentic medieval garden aesthetic.

## Overview

The medieval texture and shader system consists of several components:

1. **Medieval Texture Generator**: A Python script that generates procedural textures specifically designed for medieval gardens, including garden beds, paths, walls, and symbolic elements.

2. **Medieval Shader Pack**: A collection of Godot shaders that enhance the visual appearance of the textures, adding effects like weathering, illumination, and period-appropriate lighting.

3. **Texture-Shader Integration**: Tools to combine the textures with the shaders, creating complete material sets that can be easily used in the Godot engine.

4. **Medieval Garden Demo**: A demonstration scene that showcases the textures and shaders in action.

## Medieval Texture Generator

The `medieval_texture_generator.py` script generates a variety of textures that are appropriate for medieval gardens. These textures are organized into four categories:

### Garden Elements
- Herb beds
- Flower beds
- Vegetable beds
- Mixed garden beds
- Paths (gravel, earth, stone)
- Geometric patterns (square grid, cross, radial, knot garden)

### Ornamental Elements
- Fountains (simple, ornate, wall)

### Symbolic Elements
- Religious symbols (cross, fleur-de-lis, rose)
- Geometric patterns

### Materials
- Stone walls
- Brick walls
- Mossy walls

The textures are generated using procedural algorithms that create realistic variations and details. The color palettes are based on historical medieval pigments and materials.

### Usage

To generate all textures:
```
python medieval_texture_generator.py
```

To generate a specific texture:
```
python medieval_texture_generator.py --single [texture_type] --variation [variation]
```

Example:
```
python medieval_texture_generator.py --single garden_bed --variation herbs
```

## Medieval Shader Pack

The `medieval_shader_pack.gd` script provides a collection of shaders designed to enhance the medieval aesthetic. These shaders include:

### Illuminated Shader
Mimics the illuminated manuscript style with gold accents and rich colors.

### Weathered Shader
Adds realistic weathering and aging effects to materials.

### Garden Shader
Specifically designed for garden elements with geometric patterns and symbolic elements.

### Stone Wall Shader
Enhances stone textures with moss, mortar lines, and period-appropriate lighting.

### Wood Shader
Creates authentic medieval wood textures with grain and weathering.

### Fabric Shader
For tapestries and cloth elements with period-appropriate patterns.

### Parchment Shader
Creates the look of aged parchment with ink and decorative elements.

### Water Shader
Stylized water effects based on medieval artistic representations.

### Usage in GDScript

```gdscript
# Create a medieval shader material
var shader_material = MedievalShaderPack.create_medieval_shader_material("illuminated", Color(0.8, 0.7, 0.5))

# Apply to an object
$YourObject.material_override = shader_material
```

## Texture-Shader Integration

The `medieval_texture_shader_integrator.py` script combines the generated textures with the shaders to create complete material sets. It:

1. Generates normal maps from the textures
2. Creates roughness maps
3. Adds detail textures for the shaders
4. Creates Godot resource files (.tres) for easy use

### Usage

To generate and integrate all textures:
```
python medieval_texture_shader_integrator.py --all
```

To perform individual steps:
```
python medieval_texture_shader_integrator.py --generate  # Generate textures
python medieval_texture_shader_integrator.py --integrate  # Create texture sets
python medieval_texture_shader_integrator.py --resources  # Create Godot resources
```

## Medieval Garden Demo

The `medieval_garden_demo.tscn` scene demonstrates the textures and shaders in action. It provides an interactive way to explore the different textures and shader combinations.

### Controls

- **Space**: Cycle through textures
- **Tab**: Cycle through categories
- **S**: Cycle through shaders
- **WASD**: Move camera
- **Q/E**: Rotate camera
- **Generate Textures button**: Generate all medieval textures
- **Integrate with Shaders button**: Integrate textures with shaders

## Historical Accuracy

The textures and shaders are designed to reflect the aesthetics of medieval gardens, particularly the "hortus conclusus" (enclosed garden) style that was popular in the high medieval period (1000-1300 CE). Key features include:

- **Color Palettes**: Based on pigments available in the medieval period
- **Geometric Patterns**: Common in monastery and castle gardens
- **Symbolic Elements**: Religious and heraldic symbols used in medieval art
- **Material Textures**: Authentic representations of medieval building materials
- **Lighting Effects**: Mimics the illuminated manuscript style of the period

## Integration with Godot

The system is fully integrated with the Godot engine and can be used in any Godot project. The generated textures and materials are saved in the following directories:

- **Textures**: `res://assets/textures/medieval_garden_pack/`
- **Integrated Packs**: `res://assets/textures/integrated_packs/`

## Extending the System

### Adding New Textures

To add new texture types:

1. Add a new generation function to `medieval_texture_generator.py`
2. Add the new texture type to the appropriate category
3. Update the `generate_all_medieval_textures()` function to include your new texture

### Adding New Shaders

To add new shader types:

1. Add a new shader creation function to `medieval_shader_pack.gd`
2. Add the shader type to the `create_medieval_shader_material()` function
3. Set appropriate default parameters for the shader

## Technical Details

### Texture Generation

The texture generation uses the Python Imaging Library (PIL) to create procedural textures. Key techniques include:

- Noise generation for natural variations
- Geometric pattern creation for garden layouts
- Color palette selection based on historical pigments
- Texture variations for weathering and aging effects

### Shader Implementation

The shaders are implemented in Godot's shader language and use various techniques:

- Normal mapping for surface detail
- Roughness mapping for material properties
- Procedural patterns for decorative elements
- View-dependent effects for illumination and gold leaf

### Performance Considerations

- The texture generation process can be resource-intensive, especially for high-resolution textures
- The shaders are optimized for real-time rendering but may impact performance on lower-end hardware
- Consider using lower resolution textures (256x256) for mobile platforms

## Credits

This medieval texture and shader system was created specifically for the Hortus Conclusus project. It draws inspiration from:

- Historical manuscripts and paintings from the medieval period
- Archaeological evidence of medieval gardens
- Contemporary academic research on medieval aesthetics and garden design

## License

This system is provided as part of the Hortus Conclusus project and is subject to the same licensing terms.
