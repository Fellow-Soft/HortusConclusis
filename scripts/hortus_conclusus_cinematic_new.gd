extends Node3D
class_name HortusConclususCinematic

# Constants
const UP_VECTOR = Vector3(0, 1, 0)

# Enhanced systems
const CinematicEffectsEnhanced = preload("res://scripts/cinematic_effects_enhanced.gd")
const AtmosphereController = preload("res://scripts/atmosphere_controller_enhanced.gd")
const MeditationDisplay = preload("res://scripts/meditation_display_enhanced.gd")
const SacredGeometry = preload("res://scripts/sacred_geometry_enhanced.gd")
const MissingFunctions = preload("res://scripts/hortus_conclusus_cinematic_missing_functions.gd")
const PlantGenerator = preload("res://scripts/plants/plant_generator.gd")

# Audio resources with fallback
var medieval_evening_audio = preload("res://assets/music/medieval_background.wav") # Fallback audio
var medieval_background_audio = preload("res://assets/music/medieval_background.wav")

# Node references
@onready var world_environment = $WorldEnvironment
@onready var fade_overlay = $UI/FadeOverlay
@onready var meditation_label = $UI/Meditation
@onready var camera_path = $CameraPath
@onready var path_follow = $CameraPath/PathFollow3D
@onready var camera = $CameraPath/PathFollow3D/Camera3D
@onready var timer = $Timer
@onready var camera_system = $CameraSystem

# Camera movement parameters
var base_camera_speed = 0.1
var camera_speed_multiplier = 1.0
var camera_focus_point = Vector3.ZERO
var camera_focus_enabled = false

# Meditation parameters
var current_meditation = "dawn"
var meditation_text_speed = 0.05
var meditation_display_duration = 10.0

# Title screen parameters
var title_screen_active = true
var title_fade_in_duration = 3.0
var title_display_duration = 5.0
var title_fade_out_duration = 3.0
var title_text = "Hortus Conclusus"
var title_subtitle = "The Enclosed Garden"

# Particle effect references
var dawn_particles: Node3D
var noon_particles: Node3D
var dusk_particles: Node3D
var night_particles: Node3D

# Meditation texts for different times of day
const MEDITATIONS = {
    "dawn": [
        "As morning light filters through the mist,",
        "Ancient patterns emerge from darkness,",
        "The garden awakens to nature's geometry,",
        "Each plant a living expression of earth's wisdom."
    ],
    "noon": [
        "In the fullness of day, the garden reveals its secrets,",
        "Herbs arranged in spirals mirroring the sun's path,",
        "Flowers in five-fold symmetry echoing the elements,",
        "The natural order made manifest in living form."
    ],
    "dusk": [
        "As shadows lengthen across the garden paths,",
        "The day's cycle completed in perfect balance,",
        "Plants return their essence to the fading light,",
        "Preparing for night's regenerative silence."
    ],
    "night": [
        "Under starlight, the garden dreams of renewal,",
        "Earthly patterns continue their silent growth,",
        "In darkness, we find our deepest connection,",
        "As above in the stars, so below in the soil."
    ]
}

# Cinematic timing
var cinematic_duration = 305.0  # Total duration in seconds (about 5 minutes)

# Called when the node enters the scene tree for the first time
func _ready():
    # Initialize random number generator
    randomize()
    
    # Initialize node references
    world_environment = $WorldEnvironment
    fade_overlay = $UI/FadeOverlay
    meditation_label = $UI/Meditation
    camera_path = $CameraPath
    path_follow = $CameraPath/PathFollow3D
    camera = $CameraPath/PathFollow3D/Camera3D
    timer = $Timer
    camera_system = $CameraSystem
    
    # Create title screen elements
    _create_title_screen()
    
    # Start with black screen
    fade_overlay.color = Color(0, 0, 0, 1)
    
    # Start playing music
    $AudioStreamPlayer.play()
    
    # Start title screen sequence
    _start_title_sequence()
    
    # Initialize cinematic elements (but don't start them yet)
    _initialize_cinematic()

# Create the title screen UI elements
func _create_title_screen():
    # Create title label
    var title_label = Label.new()
    title_label.name = "TitleLabel"
    title_label.text = title_text
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title_label.add_theme_font_size_override("font_size", 72)
    title_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
    title_label.add_theme_color_override("font_outline_color", Color(0.5, 0.3, 0.1))
    title_label.add_theme_constant_override("outline_size", 4)
    title_label.add_theme_constant_override("shadow_offset_x", 2)
    title_label.add_theme_constant_override("shadow_offset_y", 2)
    title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.5))
    
    # Position the title in the center of the screen
    title_label.anchors_preset = Control.PRESET_CENTER
    title_label.anchor_left = 0.5
    title_label.anchor_top = 0.5
    title_label.anchor_right = 0.5
    title_label.anchor_bottom = 0.5
    title_label.offset_left = -400
    title_label.offset_top = -100
    title_label.offset_right = 400
    title_label.offset_bottom = 0
    title_label.modulate = Color(1, 1, 1, 0)  # Start invisible
    
    # Create subtitle label
    var subtitle_label = Label.new()
    subtitle_label.name = "SubtitleLabel"
    subtitle_label.text = title_subtitle
    subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    subtitle_label.add_theme_font_size_override("font_size", 36)
    subtitle_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
    
    # Position the subtitle below the title
    subtitle_label.anchors_preset = Control.PRESET_CENTER
    subtitle_label.anchor_left = 0.5
    subtitle_label.anchor_top = 0.5
    subtitle_label.anchor_right = 0.5
    subtitle_label.anchor_bottom = 0.5
    subtitle_label.offset_left = -300
    subtitle_label.offset_top = 0
    subtitle_label.offset_right = 300
    subtitle_label.offset_bottom = 50
    subtitle_label.modulate = Color(1, 1, 1, 0)  # Start invisible
    
    # Create a decorative border for the title (illuminated manuscript style)
    var border = ColorRect.new()
    border.name = "TitleBorder"
    border.color = Color(0.5, 0.3, 0.1, 0)  # Start invisible
    
    # Position the border around the title
    border.anchors_preset = Control.PRESET_CENTER
    border.anchor_left = 0.5
    border.anchor_top = 0.5
    border.anchor_right = 0.5
    border.anchor_bottom = 0.5
    border.offset_left = -420
    border.offset_top = -120
    border.offset_right = 420
    border.offset_bottom = 70
    
    # Add a glow effect for the title
    var glow = ColorRect.new()
    glow.name = "TitleGlow"
    glow.color = Color(0.9, 0.8, 0.6, 0)  # Start invisible
    
    # Position the glow behind the title
    glow.anchors_preset = Control.PRESET_CENTER
    glow.anchor_left = 0.5
    glow.anchor_top = 0.5
    glow.anchor_right = 0.5
    glow.anchor_bottom = 0.5
    glow.offset_left = -410
    glow.offset_top = -110
    glow.offset_right = 410
    glow.offset_bottom = 60
    
    # Add elements to the UI
    $UI.add_child(glow)
    $UI.add_child(border)
    $UI.add_child(title_label)
    $UI.add_child(subtitle_label)

# Start the title screen sequence
func _start_title_sequence():
    # Create a sequence of tweens for the title screen
    var tween = create_tween()
    
    # Wait a moment with black screen and music
    tween.tween_interval(1.0)
    
    # Fade in the title elements
    tween.tween_property($UI/TitleGlow, "color:a", 0.3, title_fade_in_duration)
    tween.parallel().tween_property($UI/TitleBorder, "color:a", 0.8, title_fade_in_duration)
    tween.parallel().tween_property($UI/TitleLabel, "modulate:a", 1.0, title_fade_in_duration)
    tween.parallel().tween_property($UI/SubtitleLabel, "modulate:a", 1.0, title_fade_in_duration)
    
    # Hold the title for a few seconds
    tween.tween_interval(title_display_duration)
    
    # Fade out the title elements
    tween.tween_property($UI/TitleGlow, "color:a", 0.0, title_fade_out_duration)
    tween.parallel().tween_property($UI/TitleBorder, "color:a", 0.0, title_fade_out_duration)
    tween.parallel().tween_property($UI/TitleLabel, "modulate:a", 0.0, title_fade_out_duration)
    tween.parallel().tween_property($UI/SubtitleLabel, "modulate:a", 0.0, title_fade_out_duration)
    
    # Start the cinematic after the title sequence
    tween.tween_callback(Callable(self, "_start_cinematic"))

# Initialize cinematic elements without starting them
func _initialize_cinematic():
    # Load audio resources with fallback
    _load_audio_resources()

    # Check rendering backend for volumetric fog
    _check_rendering_backend()

    # Load meditation text with fallback
    _load_meditation_text()

    # Instantiate enhanced systems
    atmosphere_controller = AtmosphereController.new()
    add_child(atmosphere_controller)
    meditation_display = MeditationDisplay.new()
    add_child(meditation_display)
    sacred_geometry = SacredGeometry.new()
    add_child(sacred_geometry)
    cinematic_effects = CinematicEffectsEnhanced.new()
    add_child(cinematic_effects)
    plant_generator = PlantGenerator.new()
    add_child(plant_generator)

    # Connect signals
    timer.connect("timeout", Callable(self, "_on_timer_timeout"))
    if meditation_display.has_signal("display_completed"):
        meditation_display.connect("display_completed", Callable(self, "_on_meditation_completed"))
    if atmosphere_controller.has_signal("time_changed"):
        atmosphere_controller.connect("time_changed", Callable(self, "_on_time_changed"))

    # Initialize meditation display
    if meditation_label:
        # Create a string by joining array elements with newlines
        var meditation_lines = ""
        for i in range(MEDITATIONS[current_meditation].size()):
            meditation_lines += MEDITATIONS[current_meditation][i]
            if i < MEDITATIONS[current_meditation].size() - 1:
                meditation_lines += "\n"
        
        meditation_label.text = meditation_lines
        
        # Configure meditation display
        meditation_display.text_label = meditation_label # Connect to the existing label
        _setup_meditation_display()
    
    # Create initial particle effects for dawn
    _create_particle_effects()
    
    # Create sacred geometry patterns
    _create_sacred_geometry_patterns()
    
    # Setup day-night effects
    _setup_day_night_effects()
    
    # Schedule the end of the cinematic (but don't start the timer yet)
    var end_timer = Timer.new()
    end_timer.name = "EndTimer"
    end_timer.wait_time = cinematic_duration
    end_timer.one_shot = true
    end_timer.timeout.connect(_on_cinematic_completed)
    add_child(end_timer)
    
    # Schedule initial setup timer (but don't start it yet)
    timer.wait_time = 10.0

# Start the actual cinematic after the title sequence
func _start_cinematic():
    # Fade in the scene
    _fade_in()
    
    # Configure camera system
    if camera_system:
        camera_system.path = camera_path
        camera_system.path_follow = path_follow
        camera_system.camera = camera
        camera_system.start_movement(base_camera_speed)
    
    # Initialize meditation display
    if meditation_display:
        meditation_display.set_text(MEDITATIONS[current_meditation].join("\n"))
        meditation_display.start_display()
    
    # Start the atmosphere controller
    if atmosphere_controller:
        atmosphere_controller.set_time_of_day(current_meditation)
        atmosphere_controller.create_day_night_cycle_animation()
        atmosphere_controller.play_day_night_cycle_animation()
    
    # Start the cinematic sequence
    _start_cinematic_sequence()
    
    # Start timers
    timer.start()
    get_node("EndTimer").start()
    
    # Set title screen as inactive
    title_screen_active = false

# Create particle effects based on time of day
func _create_particle_effects():
    # Create dawn particles
    # Handle the case where we can't instantiate directly
    dawn_particles = Node3D.new()
    dawn_particles.name = "DawnParticles"
    add_child(dawn_particles)
    
    # Add a simple light to simulate dawn particles
    var light = OmniLight3D.new()
    light.name = "DawnLight"
    light.light_color = Color(1.0, 0.9, 0.7, 1.0)
    light.light_energy = 0.5
    light.omni_range = 20.0
    light.transform.origin = Vector3(0, 5, 0)
    dawn_particles.add_child(light)
    
    # Initially only show dawn particles
    _update_particle_effects(current_meditation)

# Update particle effects based on time of day
func _update_particle_effects(time_of_day: String):
    # Hide all particle systems
    if dawn_particles:
        dawn_particles.visible = false
    if noon_particles:
        noon_particles.visible = false
    if dusk_particles:
        dusk_particles.visible = false
    if night_particles:
        night_particles.visible = false
    
    # Show only the appropriate particle system
    match time_of_day:
        "dawn":
            if dawn_particles:
                dawn_particles.visible = true
        "noon":
            if noon_particles:
                noon_particles.visible = true
        "dusk":
            if dusk_particles:
                dusk_particles.visible = true
        "night":
            if night_particles:
                night_particles.visible = true

# Handle input events for skip functionality
func _input(event):
    # Skip option with ESC key
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE:
            _show_skip_dialog()

# Show skip dialog
func _show_skip_dialog():
    var skip_dialog = ConfirmationDialog.new()
    skip_dialog.title = "Hortus Conclusus"
    skip_dialog.dialog_text = "Skip cinematic experience?"
    skip_dialog.get_ok_button().text = "Skip"
    skip_dialog.get_cancel_button().text = "Continue"
    skip_dialog.connect("confirmed", Callable(self, "_skip_cinematic"))
    add_child(skip_dialog)
    skip_dialog.popup_centered()

# Skip cinematic sequence
func _skip_cinematic():
    # Fade out
    var tween = create_tween()
    tween.tween_property(fade_overlay, "color:a", 1.0, 1.0)
    tween.tween_callback(Callable(self, "_on_skip_completed"))

# Handle skip completion
func _on_skip_completed():
    # Transition to main garden scene
    get_tree().change_scene_to_file("res://scenes/medieval_garden_demo.tscn")

# Update time of day (called by animation)
func update_time_of_day(time: String):
    current_meditation = time
    
    # Update meditation text
    if meditation_label:
        # Create a string by joining array elements with newlines
        var meditation_lines = ""
        for i in range(MEDITATIONS[time].size()):
            meditation_lines += MEDITATIONS[time][i]
            if i < MEDITATIONS[time].size() - 1:
                meditation_lines += "\n"
        
        meditation_label.text = meditation_lines
    
    # Update particle effects
    _update_particle_effects(time)

# Get up vector (used by camera system)
func get_up_vector() -> Vector3:
    return UP_VECTOR

# Fade in effect
func _fade_in():
    MissingFunctions.fade_in(self)

# Fade out effect
func _fade_out():
    MissingFunctions.fade_out(self)

# Signal handlers
func _on_timer_timeout():
    # Advance to the next sequence stage
    current_sequence_stage += 1
    
    # Determine which sequence to play based on stage
    match current_sequence_stage:
        1:  # First transition - to noon
            current_meditation = "noon"
            update_time_of_day("noon")
            if atmosphere_controller:
                atmosphere_controller.set_time_of_day("noon")
        
        2:  # Second transition - to dusk
            current_meditation = "dusk"
            update_time_of_day("dusk")
            if atmosphere_controller:
                atmosphere_controller.set_time_of_day("dusk")
        
        3:  # Third transition - to night
            current_meditation = "night"
            update_time_of_day("night")
            if atmosphere_controller:
                atmosphere_controller.set_time_of_day("night")
        
        4:  # Final sequence - garden overview
            # Create a final overview sequence
            if camera_system:
                camera_speed_multiplier = 0.5  # Slow down for final overview
                camera_system.set_speed(base_camera_speed * camera_speed_multiplier)
        
        _:  # End of cinematic
            _fade_out()

# Called when the cinematic duration timer expires
func _on_cinematic_completed():
    # Start the fade out effect
    _fade_out()

func _on_fade_out_completed():
    # Transition to the main garden scene when cinematic ends
    get_tree().change_scene_to_file("res://scenes/medieval_garden_demo.tscn")

# Enhanced system variables
var atmosphere_controller: Node
var meditation_display: Node
var sacred_geometry: Node
var cinematic_effects: Node
var plant_generator: Node

# Garden materialization parameters
var current_materialization_stage = 0
var gardens_initialized = false

# Sacred geometry parameters
var sacred_geometry_patterns = []
var active_sacred_pattern = null
var pattern_rotation_speed = 0.5
var pattern_scale_pulse = 0.0
var pattern_emission_intensity = 1.0

# Cinematic sequence parameters
var current_sequence_stage = 0
var sequence_timer = 0.0

# Visual effect parameters
var bloom_intensity = 0.0
var vignette_intensity = 0.0
var chromatic_aberration = 0.0
var color_correction_enabled = false
var color_temperature = 6500.0  # Kelvin
var saturation = 1.0
var contrast = 1.0

# Process function for continuous updates
func _process(delta: float):
    # Update sacred patterns if active
    if active_sacred_pattern:
        _update_sacred_patterns(delta)
    
    # Update camera movement
    if camera_system and camera_focus_enabled:
        camera_system.update_focus(camera_focus_point, delta)

# Load audio resources with fallback
func _load_audio_resources():
    # Try to load the evening audio
    if ResourceLoader.exists("res://assets/music/medieval_evening.wav"):
        medieval_evening_audio = load("res://assets/music/medieval_evening.wav")
    
    # Try to load the background audio
    if ResourceLoader.exists("res://assets/music/medieval_background.wav"):
        medieval_background_audio = load("res://assets/music/medieval_background.wav")

# Check rendering backend for volumetric fog
func _check_rendering_backend():
    # Volumetric fog requires forward_plus rendering method
    var rendering_method = ProjectSettings.get_setting("rendering/renderer/rendering_method")
    if rendering_method != "forward_plus":
        print("Warning: Volumetric fog requires forward_plus rendering method. Current method: " + rendering_method)

# Load meditation text with fallback
func _load_meditation_text():
    # If meditation texts are not defined, use fallback
    if MEDITATIONS.size() == 0:
        MEDITATIONS["dawn"] = ["In the garden of sacred geometry, divine patterns emerge."]
        MEDITATIONS["noon"] = ["As above, so below, the cosmic order affirms."]
        MEDITATIONS["dusk"] = ["Through seasons of growth and dormancy, the eternal cycle turns."]
        MEDITATIONS["night"] = ["In this enclosed garden, the soul's wisdom silently yearns."]

# Setup meditation display
func _setup_meditation_display():
    if meditation_display:
        meditation_display.set_durations(2.0, meditation_display_duration, 2.0)
        meditation_display.set_letter_reveal_speed(meditation_text_speed)

# Create sacred geometry patterns
func _create_sacred_geometry_patterns():
    MissingFunctions.create_sacred_geometry_patterns(self)

# Update sacred patterns
func _update_sacred_patterns(delta: float):
    MissingFunctions.update_sacred_patterns(self, delta)

# Setup day-night effects
func _setup_day_night_effects():
    MissingFunctions.setup_day_night_effects(self)

# Start cinematic sequence
func _start_cinematic_sequence():
    current_sequence_stage = 0
    _highlight_garden_types()
    _activate_sacred_patterns_sequence()

# Highlight garden types
func _highlight_garden_types():
    MissingFunctions.highlight_garden_types(self)

# Activate sacred patterns sequence
func _activate_sacred_patterns_sequence():
    MissingFunctions.activate_sacred_patterns_sequence(self)

# Signal handlers for enhanced systems
func _on_meditation_completed():
    # Schedule next meditation if needed
    if current_sequence_stage < 4:  # 4 stages: dawn, noon, dusk, night
        timer.start()

func _on_time_changed(time: String):
    MissingFunctions._on_time_changed(self, time)
