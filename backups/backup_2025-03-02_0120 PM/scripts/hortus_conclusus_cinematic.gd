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
var world_environment: WorldEnvironment
var fade_overlay: ColorRect
var meditation_label: Label
var camera_path: Path3D
var path_follow: PathFollow3D
var camera: Camera3D
var timer: Timer
var camera_system: Node3D

# Enhanced system instances
var atmosphere_controller: Node
var meditation_display: Node
var sacred_geometry: Node
var cinematic_effects: Node
var plant_generator: Node

# Camera movement parameters
var base_camera_speed = 0.1
var camera_speed_multiplier = 1.0
var camera_focus_point = Vector3.ZERO
var camera_focus_enabled = false

# Meditation parameters
var current_meditation = "dawn"
var meditation_text_speed = 0.05
var meditation_display_duration = 10.0

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

# Meditation texts for different times of day
const MEDITATIONS = {
    "dawn": [
        "As morning light filters through the mist,",
        "Sacred patterns emerge from darkness,",
        "The garden awakens to divine geometry,",
        "Each plant a symbol of celestial order."
    ],
    "noon": [
        "In the fullness of day, the garden reveals its wisdom,",
        "Herbs arranged in patterns of the Trinity,",
        "Roses in five-fold symmetry honoring the Virgin,",
        "The cosmic order made manifest in living form."
    ],
    "dusk": [
        "As shadows lengthen across the garden paths,",
        "The day's work completed in sacred harmony,",
        "Plants return their essence to the fading light,",
        "Preparing for night's contemplative silence."
    ],
    "night": [
        "Under starlight, the garden dreams of eternity,",
        "Divine patterns continue their silent growth,",
        "In darkness, the soul finds its deepest truths,",
        "As above in the heavens, so below in the garden."
    ]
}

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

    # Configure enhanced systems
    camera_system.path = camera_path
    camera_system.path_follow = path_follow
    camera_system.camera = camera
    meditation_display.text_label = meditation_label # Connect to the existing label
    
    # Start with fade in
    fade_overlay.color = Color(0, 0, 0, 1)
    _fade_in()
    
    # Configure meditation display
    _setup_meditation_display()
    
    # Start camera movement
    camera_system.start_movement(base_camera_speed)
    
    # Schedule garden materialization
    timer.wait_time = 10.0
    timer.start()
    
    # Initialize meditation display
    meditation_display.set_text(MEDITATIONS[current_meditation].join("\n"))
    meditation_display.start_display()
    
    # Create sacred geometry patterns
    _create_sacred_geometry_patterns()
    
    # Setup day-night effects
    _setup_day_night_effects()
    
    # Start the cinematic sequence
    _start_cinematic_sequence()

# Process function for continuous updates
func _process(delta: float):
    # Update sacred patterns if active
    if active_sacred_pattern:
        _update_sacred_patterns(delta)
    
    # Update camera movement
    if camera_system and camera_focus_enabled:
        camera_system.update_focus(camera_focus_point, delta)

# Update time of day (called by animation)
func update_time_of_day(time: String):
    current_meditation = time
    if meditation_display:
        meditation_display.set_text(MEDITATIONS[time].join("\n"))
        meditation_display.restart_display()
    if atmosphere_controller:
        atmosphere_controller.set_time_of_day(time)
    _on_time_changed(time)

# Get up vector (used by camera system)
func get_up_vector() -> Vector3:
    return UP_VECTOR

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

# Fade in effect
func _fade_in():
    MissingFunctions.fade_in(self)

# Fade out effect
func _fade_out():
    MissingFunctions.fade_out(self)

# Signal handlers
func _on_timer_timeout():
    # Move to next sequence stage
    current_sequence_stage += 1
    _start_cinematic_sequence()

func _on_meditation_completed():
    # Schedule next meditation if needed
    if current_sequence_stage < 4:  # 4 stages: dawn, noon, dusk, night
        timer.start()

func _on_time_changed(time: String):
    MissingFunctions._on_time_changed(self, time)

func _on_fade_out_completed():
    MissingFunctions._on_fade_out_completed(self)
