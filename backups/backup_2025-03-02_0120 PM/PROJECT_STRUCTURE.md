# Hortus Conclusus Project Structure

This document provides an overview of the Hortus Conclusus project structure after consolidation and cleanup.

## Core Files

### Documentation
- `README.md` - Project overview and main documentation
- `AMBROSE_THE_GARDENER.md` - Comprehensive guide to Ambrose's character, philosophy, and capabilities
- `CINEMATIC_DEVELOPMENT.md` - Development history and enhancement plan for the cinematic experience
- `CINEMATIC_EXPERIENCE_COMPLETE.md` - Comprehensive guide to the cinematic experience
- `MEDIEVAL_TEXTURE_SHADER_SYSTEM.md` - Documentation for the texture and shader system
- `MEDITATION.md` - Poetic meditation on the enclosed garden concept
- `TASKS.md` - Current and future development tasks
- `PROJECT_STRUCTURE.md` - This file, explaining the project organization

### Batch Files
- `run_hortus_conclusus.bat` - Main launcher with menu for all experiences
- `play_complete_cinematic.bat` - Runs the complete cinematic experience
- `play_complete_experience.bat` - Runs the full experience including title, cinematic, and garden
- `project_cleanup.bat` - Script for cleaning up and consolidating project files

## Directory Structure

### Scripts
The `scripts/` directory contains all the GDScript files for the project:

#### Core Systems
- `hortus_conclusus_cinematic_complete.gd` - Main cinematic controller
- `atmosphere_controller_enhanced.gd` - Enhanced atmospheric effects system
- `meditation_display_enhanced.gd` - Enhanced meditation text display system
- `camera_system_enhanced.gd` - Enhanced camera movement system
- `camera_path_enhanced.gd` - Enhanced camera path system
- `cinematic_effects_enhanced.gd` - Enhanced visual effects system
- `sacred_geometry_enhanced.gd` - Sacred geometry visualization system

#### Particle Effects
- `particle_effects/dawn_particles.gd` - Dawn-specific particle effects
- `particle_effects/noon_particles.gd` - Noon-specific particle effects
- `particle_effects/dusk_particles.gd` - Dusk-specific particle effects
- `particle_effects/night_particles.gd` - Night-specific particle effects

#### Plant Systems
- `plants/growth_system.gd` - Plant growth simulation
- `plants/medieval_herb_garden.gd` - Medieval herb garden implementation
- `plants/plant_generator.gd` - Procedural plant generation

#### Shaders
- `shaders/medieval_shader_pack.gd` - Collection of medieval-themed shaders
- `shaders/medieval_shader_pack.gdshader` - Shader code for medieval effects
- `shaders/parchment_shader.gdshader` - Shader for parchment effects

#### AI Integration
- `ai/ambrose_agent.py` - Python implementation of Ambrose AI agent
- `ai/ambrose_godot_bridge.gd` - Bridge between Python AI and Godot
- `ai/README_AMBROSE.md` - Documentation for Ambrose AI integration

#### Interaction
- `interaction/command_executor.py` - Command execution for AI interaction
- `interaction/voice_system.py` - Voice recognition and synthesis

### Scenes
The `scenes/` directory contains all the Godot scene files:

- `hortus_conclusus_cinematic.tscn` - Main cinematic experience scene
- `main.tscn` - Main project scene
- `medieval_garden_demo.tscn` - Medieval garden demonstration scene
- `medieval_herb_garden_demo.tscn` - Herb garden demonstration scene
- `meditation_display.tscn` - Meditation display scene
- `texture_shader_demo.tscn` - Texture and shader demonstration scene
- `ambrose_interface.tscn` - Interface for interacting with Ambrose
- `medieval_ambrose_interface.tscn` - Medieval-styled Ambrose interface

### Assets
The `assets/` directory contains all media assets:

#### Textures
- `textures/integrated_packs/` - Integrated texture packs with materials
- `textures/medieval_garden_pack/` - Medieval garden texture collection

#### UI
- `ui/illuminated_borders/` - Illuminated manuscript border assets
- `ui/medieval/` - Medieval UI elements

#### Fonts
- `fonts/medieval/` - Medieval-style fonts

#### Music
- `music/medieval_background.wav` - Background music
- `music/medieval_evening.wav` - Evening ambiance music

### Archive
The `archive/` directory contains files that have been archived during cleanup:

- `batch/` - Archived batch files
- `docs/` - Archived documentation files
- `scripts/` - Archived script files
- `scenes/` - Archived scene files

## Key Components

### 1. Medieval Texture and Shader System
The texture and shader system provides procedurally generated textures and custom shaders for medieval garden elements.

**Key Files:**
- `scripts/medieval_texture_generator.py`
- `scripts/medieval_shader.gd`
- `scripts/texture_shader_generator.gd`
- `scenes/texture_shader_demo.tscn`

### 2. Ambrose AI System
Ambrose is an AI-powered gardener character that serves as guide and caretaker.

**Key Files:**
- `scripts/ai/ambrose_agent.py`
- `scripts/ai/ambrose_godot_bridge.gd`
- `scripts/interaction/voice_system.py`
- `scripts/interaction/command_executor.py`
- `scenes/ambrose_interface.tscn`

### 3. Meditation System
The meditation system provides contemplative texts with atmospheric effects.

**Key Files:**
- `scripts/meditation_display_enhanced.gd`
- `MEDITATION.md`
- `scenes/meditation_display.tscn`

### 4. Cinematic Experience
The cinematic experience provides an immersive journey through the medieval garden.

**Key Files:**
- `scripts/hortus_conclusus_cinematic_complete.gd`
- `scripts/atmosphere_controller_enhanced.gd`
- `scripts/sacred_geometry_enhanced.gd`
- `scripts/camera_system_enhanced.gd`
- `scenes/hortus_conclusus_cinematic.tscn`
