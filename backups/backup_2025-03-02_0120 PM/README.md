# Hortus Conclusus Project

A medieval garden simulation project with procedurally generated textures, custom shaders, and an immersive meditation experience.

## Repository

This project is hosted on GitHub at: https://github.com/Fellow-Soft/HortusConclusis

To clone the repository:
```
git clone https://github.com/Fellow-Soft/HortusConclusis.git
```

## Overview

The Hortus Conclusus (enclosed garden) was a common feature in medieval European monasteries and castles. This project recreates the aesthetic and atmosphere of these historical gardens using procedural generation techniques and custom shaders, while providing an immersive meditation experience guided by Ambrose, the AI gardener.

## Key Features

### 1. Medieval Texture and Shader System

A comprehensive system for generating authentic medieval textures and applying custom shaders to create historically accurate garden elements. The system includes procedurally generated textures for ground, plants, structures, and decorative elements, along with specialized shaders that enhance the medieval aesthetic.

[Detailed documentation available in MEDIEVAL_TEXTURE_SHADER_SYSTEM.md]

### 2. Ambrose: The Gardener of Hortus Conclusus

Ambrose is an AI-powered gardener character that serves as both guide and caretaker of the medieval garden. With a personality rooted in medieval garden philosophy, Ambrose provides a natural language interface for interacting with the garden.

#### Ambrose Agent Framework

- **Ambrose Agent** (`scripts/ai/ambrose_agent.py`): Integrates Claude 3.7 to provide the AI personality and capabilities
- **Voice System** (`scripts/interaction/voice_system.py`): Handles speech-to-text and text-to-speech functionality
- **Command Executor** (`scripts/interaction/command_executor.py`): Executes commands within the garden environment
- **Godot Bridge** (`scripts/ai/ambrose_godot_bridge.gd`): Interfaces between the Python-based agent and the Godot engine
- **Ambrose Interface** (`scenes/ambrose_interface.tscn`): UI for player interaction through text or voice

#### Interacting with Ambrose

- **Text Chat**: Type messages to Ambrose in the chat interface
- **Voice Interaction**: Speak to Ambrose using the microphone and hear his responses
- **Natural Language Commands**: Ask Ambrose to perform tasks in the garden using natural language

#### Ambrose's Capabilities

- Generate garden elements based on verbal descriptions
- Explain the symbolism and historical significance of garden elements
- Lead contemplative meditations inspired by medieval monastic practices
- Modify the garden based on player requests
- Provide information about medieval gardens, plants, and gardening practices

[Detailed documentation available in AMBROSE_THE_GARDENER.md]

### 3. Meditation System

An immersive meditation system inspired by medieval contemplative practices, featuring:

- **Meditation Texts**: Poetic meditations on the enclosed garden concept
- **Meditation Display**: Visual presentation of meditation texts with calligraphic styling
- **Atmospheric Elements**: Time-of-day specific lighting, sounds, and particle effects
- **Sacred Geometry**: Visualization of patterns that held spiritual significance in medieval times

### 4. Cinematic Experience

An immersive cinematic journey through the medieval garden that introduces the Hortus Conclusus concept:

#### Cinematic Structure
- **Introduction**: Empty landscape in pre-dawn mist
- **Garden Creation**: Gardens materialize with magical effects
- **Garden Exploration**: Camera explores fully formed gardens
- **Day-Night Transition**: Full day-night cycle with changing meditations
- **Divine Manifestation**: Sacred geometry patterns appear with divine light
- **Conclusion**: Final panoramic view and meditation

#### Enhanced Systems
- Rich particle effects for different times of day
- Dynamic camera movements with "breathing" effects
- Medieval-styled text presentation with illuminated effects
- Advanced atmospheric and lighting effects
- Sacred geometry visualization and animation

[Detailed documentation available in CINEMATIC_DEVELOPMENT.md and CINEMATIC_EXPERIENCE_COMPLETE.md]

## Usage

### Running the Project

1. Clone this repository:
   ```
   git clone https://github.com/Fellow-Soft/HortusConclusis.git
   ```
2. Install Python dependencies:
   ```
   pip install pillow anthropic
   ```
3. Open the project in Godot 4.0 or higher
4. Configure the environment variable for Claude API access (if using Ambrose):
   ```
   export CLAUDE_API_KEY="your_api_key_here"
   ```

### Experiencing the Cinematic

To experience the complete cinematic:
```bash
./play_complete_experience.bat
```

### Interacting with Ambrose

1. Open the `scenes/medieval_ambrose_interface.tscn` scene
2. Run the scene
3. Interact with Ambrose through text or voice

### Exploring the Texture System

1. Open the `scenes/texture_shader_demo.tscn` scene
2. Run the scene
3. Use the controls to generate textures and apply shaders

### Using the Meditation System

1. Open the `scenes/meditation_display.tscn` scene
2. Run the scene
3. Experience the meditation texts with atmospheric effects

## Requirements

- Godot 4.0 or higher
- Python 3.6 or higher with required libraries:
  - Pillow (for texture generation)
  - Anthropic (for Ambrose AI integration)

## Planned Features

The project will continue to expand with the following planned features:

### Vegetation System Enhancements
- Expanded medieval herb garden layouts
- More ornamental flower arrangements in geometric patterns
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

## Project Structure

The project is organized into the following directory structure:

### Scripts
- `scripts/terrain/` - Terrain generation and modification systems
- `scripts/plants/` - Plant growth, behavior, and interaction systems
- `scripts/weather/` - Weather simulation and effects
- `scripts/atmosphere/` - Environmental and atmospheric systems
- `scripts/interaction/` - User interaction and gameplay mechanics
- `scripts/ai/` - AI behaviors and intelligent systems
- `scripts/shaders/` - Custom shaders for medieval aesthetics

### Assets
- `assets/audio/` - Medieval music, ambient sounds, and effects
- `assets/models/` - 3D models for garden elements
- `assets/textures/` - Textures and materials
- `assets/fonts/medieval/` - Medieval-style fonts
- `assets/ui/` - UI elements with medieval styling

### Scenes
- `scenes/main.tscn` - Main garden scene
- `scenes/texture_shader_demo.tscn` - Demo for texture and shader system
- `scenes/medieval_garden_demo.tscn` - Demo for medieval garden elements
- `scenes/meditation_display.tscn` - Scene for displaying meditations
- `scenes/ambrose_interface.tscn` - UI for interacting with Ambrose
- `scenes/hortus_conclusus_cinematic.tscn` - Cinematic experience scene

### Documentation
- `README.md` - Project overview and documentation
- `TASKS.md` - Project task list and progress tracking
- `MEDIEVAL_TEXTURE_SHADER_SYSTEM.md` - Documentation for the texture and shader system
- `AMBROSE_THE_GARDENER.md` - The character and philosophy of Ambrose
- `CINEMATIC_DEVELOPMENT.md` - Development of the cinematic experience
- `CINEMATIC_EXPERIENCE_COMPLETE.md` - Guide to the cinematic experience
- `MEDITATION.md` - Poetic meditation on the enclosed garden concept

## Credits

This project was created for the Hortus Conclusus medieval garden simulation. The texture generation system uses procedural techniques to create historically accurate textures based on medieval art and architecture.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
