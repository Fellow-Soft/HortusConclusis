# Hortus Conclusus Title Screen Implementation

## Overview

We've implemented a medieval-styled title screen for the Hortus Conclusus cinematic experience. The title screen appears before the main cinematic sequence, providing a proper introduction to the enclosed garden experience.

## Implementation Details

The title screen is implemented in `scripts/hortus_conclusus_cinematic_new.gd`, which extends the original cinematic script with the following enhancements:

1. **Title Screen Elements**:
   - Main title "Hortus Conclusus" with medieval styling
   - Subtitle "The Enclosed Garden"
   - Decorative border reminiscent of illuminated manuscripts
   - Golden glow effect for an ethereal, sacred atmosphere

2. **Animation Sequence**:
   - Starts with a black screen and medieval background music
   - Fades in the title elements with a subtle animation
   - Holds the title for a configurable duration
   - Fades out the title elements
   - Transitions smoothly to the main cinematic experience

3. **Integration with Existing Systems**:
   - Properly connects with the MissingFunctions helper class
   - Maintains compatibility with the cinematic integration script
   - Preserves all the original cinematic functionality
   - Ensures the day-night cycle, sacred geometry patterns, and meditation texts work as expected

## Title Screen Flow

The title screen sequence follows these steps:

1. **Initialization** (`_ready` function):
   - Sets up the UI elements for the title screen
   - Initializes the cinematic elements in the background
   - Starts with a black screen

2. **Title Screen Creation** (`_create_title_screen` function):
   - Creates the title label with medieval styling
   - Creates the subtitle label
   - Creates a decorative border
   - Creates a subtle glow effect
   - Positions all elements in the center of the screen
   - Sets initial visibility to invisible

3. **Title Sequence** (`_start_title_sequence` function):
   - Waits briefly with a black screen while music plays
   - Fades in the title elements over a configurable duration
   - Holds the title for a configurable duration
   - Fades out the title elements
   - Calls `_start_cinematic` to begin the main cinematic

4. **Transition to Cinematic** (`_start_cinematic` function):
   - Fades in the scene
   - Starts camera movement
   - Initializes meditation display
   - Starts the atmosphere controller
   - Begins the cinematic sequence
   - Starts the timers for progression

## Customization Options

The title screen can be easily customized by modifying these variables:

```gdscript
var title_fade_in_duration = 3.0
var title_display_duration = 5.0
var title_fade_out_duration = 3.0
var title_text = "Hortus Conclusus"
var title_subtitle = "The Enclosed Garden"
```

The visual styling can be adjusted by modifying the color values in the `_create_title_screen` function.

## Running the Title Screen

To run the cinematic with the title screen:

1. Use the `play_title_cinematic.bat` batch file
2. The title screen will appear first, followed by the full cinematic experience
3. Press ESC at any time to bring up a skip dialog

## Technical Notes

- The title screen uses Godot's tween system for smooth animations
- The UI elements are created programmatically rather than in the scene editor
- The script maintains compatibility with the existing cinematic integration system
- The title screen respects the medieval aesthetic of the overall project
