# Hortus Conclusus Project

A medieval garden simulation project with procedurally generated textures and custom shaders.

## Overview

The Hortus Conclusus (enclosed garden) was a common feature in medieval European monasteries and castles. This project aims to recreate the aesthetic and atmosphere of these historical gardens using procedural generation techniques and custom shaders.

## Texture and Shader System

This project includes a comprehensive texture and shader generation system designed to create authentic medieval aesthetics:

### Texture Generator

The texture generator (`scripts/texture_generator.py`) is a Python script that creates procedural textures for various medieval elements:

- **Ground Textures**: Soil, grass, stone, brick, and water
- **Plant Textures**: Flowers and leaves in various colors and styles
- **Structure Textures**: Wood, thatch, and other building materials
- **Decorative Textures**: Parchment and other medieval decorative elements

Each texture is generated procedurally with parameters that can be adjusted to create variations. The textures are designed to be historically accurate, using color palettes based on pigments available in the high medieval period (1000-1300 CE).

### Shader Pack

The medieval shader pack (`scripts/shaders/medieval_shader_pack.gd`) provides a collection of custom shaders designed to enhance the medieval aesthetic:

- **Illuminated Shader**: Simulates the gold leaf and illumination effects seen in medieval manuscripts
- **Weathered Shader**: Creates a weathered, aged appearance for materials
- **Stained Glass Shader**: Recreates the look of medieval stained glass with lead lines
- **Parchment Shader**: Simulates aged parchment with ink and decorations
- **Stone Wall Shader**: Creates realistic stone walls with mortar and moss
- **Medieval Wood Shader**: Simulates aged wood with grain and knots
- **Medieval Fabric Shader**: Creates fabric with period-appropriate patterns
- **Medieval Water Shader**: Stylized water shader inspired by medieval art
- **Medieval Ground Shader**: Creates realistic soil and ground textures

### Integration System

The texture and shader systems are integrated through the `TextureShaderGenerator` class (`scripts/texture_shader_generator.gd`), which provides methods to:

- Generate all textures using the Python script
- Apply shaders to materials based on texture types
- Create a complete set of medieval materials for use in the project

## Usage

### Demo Scene

A demo scene is provided to showcase the texture and shader system:

1. Open the `scenes/texture_shader_demo.tscn` scene
2. Run the scene
3. Use the following controls:
   - **G**: Generate all textures
   - **S**: Apply shaders to materials
   - **D**: Create demo objects with materials

### Using in Your Own Scenes

To use the texture and shader system in your own scenes:

1. Create an instance of `TextureShaderGenerator`:
   ```gdscript
   var texture_generator = TextureShaderGenerator.new()
   add_child(texture_generator)
   ```

2. Generate textures:
   ```gdscript
   texture_generator.generate_all_textures()
   ```

3. Apply shaders to create materials:
   ```gdscript
   var materials = texture_generator.apply_shaders_to_materials()
   ```

4. Apply materials to objects:
   ```gdscript
   mesh_instance.material_override = materials["ground"]["stone_cobble"]
   ```

5. For a quick set of basic materials:
   ```gdscript
   var basic_materials = TextureShaderGenerator.create_medieval_material_set()
   mesh_instance.material_override = basic_materials["stone"]
   ```

## Requirements

- Godot 4.0 or higher
- Python 3.6 or higher with PIL (Pillow) library installed

## Installation

1. Clone this repository
2. Install Python dependencies:
   ```
   pip install pillow
   ```
3. Open the project in Godot

## Customization

### Adding New Textures

To add new texture types:

1. Add a new generation function to `texture_generator.py`
2. Update the command-line argument handling in the script
3. Add the new texture type to the appropriate category in `texture_shader_generator.gd`

### Adding New Shaders

To add new shader types:

1. Add a new shader creation function to `medieval_shader_pack.gd`
2. Update the shader material creation function to handle the new shader type
3. Add the new shader to the appropriate category in `texture_shader_generator.gd`

## Ambrose: The Gardener of Hortus Conclusus

The project features Ambrose, an AI-powered gardener character that serves as both guide and caretaker of the medieval garden. Ambrose is implemented using Claude 3.7 and provides a natural language interface for interacting with the garden.

### Ambrose Agent Framework

The Ambrose agent framework consists of several components:

- **Ambrose Agent** (`scripts/ai/ambrose_agent.py`): A Python script that integrates Claude 3.7 to provide the AI personality and capabilities of Ambrose.
- **Voice System** (`scripts/interaction/voice_system.py`): Handles speech-to-text and text-to-speech functionality for voice interaction with Ambrose.
- **Command Executor** (`scripts/interaction/command_executor.py`): Executes commands requested by Ambrose within the garden environment.
- **Godot Bridge** (`scripts/ai/ambrose_godot_bridge.gd`): Provides the interface between the Python-based Ambrose agent and the Godot game engine.
- **Ambrose Interface** (`scenes/ambrose_interface.tscn`): A UI scene that allows players to interact with Ambrose through text or voice.

### Interacting with Ambrose

Players can interact with Ambrose in several ways:

1. **Text Chat**: Type messages to Ambrose in the chat interface.
2. **Voice Interaction**: Speak to Ambrose using the microphone and hear his responses.
3. **Natural Language Commands**: Ask Ambrose to perform tasks in the garden using natural language.

### Ambrose's Capabilities

Ambrose can:

- **Generate Garden Elements**: Create new plants, textures, and other garden elements based on verbal descriptions.
- **Provide Historical Context**: Explain the symbolism and historical significance of garden elements.
- **Guide Meditation**: Lead the player through contemplative meditations inspired by medieval monastic practices.
- **Modify the Garden**: Make changes to the garden based on the player's requests.
- **Answer Questions**: Provide information about medieval gardens, plants, and gardening practices.

### Using Ambrose in Your Project

To add Ambrose to your scene:

1. Add the `ambrose_interface.tscn` scene to your main scene:
   ```gdscript
   var ambrose_interface = preload("res://scenes/ambrose_interface.tscn").instantiate()
   add_child(ambrose_interface)
   ```

2. Configure the environment variable for Claude API access:
   ```
   export CLAUDE_API_KEY="your_api_key_here"
   ```

3. Interact with Ambrose programmatically:
   ```gdscript
   # Send a message to Ambrose
   ambrose_interface.send_message("Can you create a rose garden?")
   
   # Connect to Ambrose's signals
   ambrose_interface.connect("ambrose_message_received", Callable(self, "_on_ambrose_message"))
   ambrose_interface.connect("ambrose_command_executed", Callable(self, "_on_command_executed"))
   ```

## Meditation System

The project includes a meditation system inspired by medieval contemplative practices:

- **Meditation Text** (`MEDITATION.md`): A poetic meditation on the enclosed garden concept.
- **Meditation Display** (`scripts/meditation_display.gd`): A script that parses and presents the meditation text in-game.
- **Meditation Scene** (`scenes/meditation_display.tscn`): A ready-to-use meditation display that can be triggered in-game.

## Cinematic Experience

The project features an immersive cinematic experience that introduces the Hortus Conclusus concept through a carefully choreographed sequence:

### Cinematic Structure
The cinematic is structured into six distinct stages:
- **Introduction** (25s): Empty landscape in pre-dawn mist
- **Garden Creation** (60s): Gardens materialize with magical effects
- **Garden Exploration** (60s): Camera explores fully formed gardens
- **Day-Night Transition** (120s): Full day-night cycle with changing meditations
- **Divine Manifestation** (30s): Sacred geometry patterns appear with divine light
- **Conclusion** (10s): Final panoramic view and meditation before fade out

### Enhanced Systems
The cinematic experience leverages several enhanced systems:
- **CinematicEffectsEnhanced**: Sophisticated particle systems and visual effects
- **CameraSystemEnhanced**: Dynamic camera movements and transitions
- **MeditationDisplayEnhanced**: Rich text animations and visual presentations
- **AtmosphereControllerEnhanced**: Advanced environmental and lighting effects
- **SacredGeometryEnhanced**: Divine pattern visualization and animation

### Integration
The cinematic components are integrated through a modular architecture:
- **Main Script** (`scripts/hortus_conclusus_cinematic.gd`): Core cinematic controller
- **Helpers** (`scripts/hortus_conclusus_cinematic_helpers.gd`): Implementation details
- **Connections** (`scripts/hortus_conclusus_cinematic_connections.gd`): System integration
- **Scene** (`scenes/hortus_conclusus_cinematic.tscn`): Ready-to-play cinematic scene

### Usage
To experience the cinematic:
1. Open the `scenes/hortus_conclusus_cinematic.tscn` scene
2. Run the scene
3. The cinematic will play automatically, showcasing the garden's creation and divine nature

## Planned Features

The project will continue to expand with the following planned features:

### Atmospheric Effects
- Specialized atmospheric shaders for period-appropriate lighting
- Medieval-inspired fog and volumetric lighting effects
- Dynamic sky system based on medieval artistic representations

### Vegetation System

The project features a sophisticated plant generation system that combines medieval symbolism with procedural generation:

#### Sacred Geometry L-System
- Five-fold symmetry for roses (symbol of Mary)
- Trinity-based patterns for lilies
- Hexagonal patterns for medicinal herbs
- Eight-fold symmetry for sacred trees
- Spiral growth for climbing vines

#### Divine Growth Manifestation
- Sacred growth stages from seed to fruiting
- Divine light effects during flowering
- Prayer-enhanced growth mechanics
- Medieval-appropriate particle effects
- Seasonal transformations with shader integration

#### Plant Types
- Roses with Marian symbolism
- Trinity-inspired lilies
- Medicinal herbs with sacred geometry
- Sacred trees with cosmic order patterns
- Symbolic climbing vines

#### Growth Features
- Growth stage visualization
- Seasonal appearance changes
- Divine manifestation effects
- Integration with medieval shaders
- Historical accuracy in form and symbolism

Future planned features include:
- Historically accurate herb garden layouts
- Ornamental flower arrangements in geometric patterns
- Period-appropriate fruit trees and arbors
- Enhanced symbolic plant placement system

### Water Features
- Elaborate fountain systems with particle effects
- Reflecting pools with specialized shaders
- Medieval-style irrigation channels
- Flowing water simulations

### Architectural Elements
- Procedural generation of garden walls and gates
- Period-appropriate trellises and pergolas
- Medieval garden pavilions and seating areas
- Decorative elements (sundials, statuary)

### Seasonal Changes
- Dynamic seasonal cycle system
- Period-accurate plant growth simulation
- Medieval calendar-based weather changes
- Seasonal lighting variations

### Enhanced Interactive Elements
- Garden planting and tending mechanics
- Time-of-day and seasonal experience options
- Educational content about medieval garden symbolism
- Historical gardening practice simulations
- Expanded Ambrose capabilities and knowledge base

## Credits

This project was created for the Hortus Conclusus medieval garden simulation. The texture generation system uses procedural techniques to create historically accurate textures based on medieval art and architecture.

## Project Structure

The project is organized into the following directory structure:

### Scripts
- `scripts/terrain/` - Advanced terrain generation and modification systems
- `scripts/plants/` - Plant growth, behavior, and interaction systems
- `scripts/weather/` - Medieval weather simulation and effects
- `scripts/historical/` - Historical accuracy and period-specific features
- `scripts/rendering/` - Custom rendering and visual effects
- `scripts/atmosphere/` - Environmental and atmospheric systems
- `scripts/sound/` - Audio management and medieval sound effects
- `scripts/interaction/` - User interaction and gameplay mechanics
  - `scripts/interaction/voice_system.py` - Speech-to-text and text-to-speech for Ambrose
  - `scripts/interaction/command_executor.py` - Command execution framework for Ambrose
- `scripts/ai/` - AI behaviors and intelligent systems
  - `scripts/ai/ambrose_agent.py` - Claude 3.7 integration for Ambrose
  - `scripts/ai/ambrose_godot_bridge.gd` - Bridge between Python and Godot
- `scripts/documentation/` - In-game documentation and help systems

### Assets
- `assets/audio/` - Medieval music, ambient sounds, and effects
- `assets/models/medieval/` - 3D models for medieval garden elements
- `assets/textures/medieval/` - Period-accurate textures and materials
- `assets/fonts/medieval/` - Medieval-style fonts and typography
- `assets/ui/medieval/` - Period-appropriate UI elements
  - `assets/ui/medieval/portrait_frame.png` - Frame for Ambrose's portrait
  - `assets/ui/medieval/parchment_bg.png` - Parchment background for UI elements
- `assets/particles/` - Particle effects for weather and atmosphere
- `assets/documentation/` - Historical references and documentation

### Scenes
- `scenes/main.tscn` - Main garden scene
- `scenes/texture_shader_demo.tscn` - Demo for texture and shader system
- `scenes/medieval_garden_demo.tscn` - Demo for medieval garden elements
- `scenes/meditation_display.tscn` - Scene for displaying meditations
- `scenes/ambrose_interface.tscn` - UI for interacting with Ambrose

### Documentation
- `README.md` - Project overview and documentation
- `TASKS.md` - Project task list and progress tracking
- `MEDIEVAL_TEXTURE_SHADER_SYSTEM.md` - Documentation for the texture and shader system
- `GARDENER_PERSONA.md` - The character and philosophy of Ambrose
- `CUSTOM_INSTRUCTION.md` - Custom instructions for Ambrose's behavior
- `MEDITATION.md` - Poetic meditation on the enclosed garden concept

Each directory contains specialized components that work together to create an authentic medieval garden experience. The modular structure allows for easy expansion and maintenance of features.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
