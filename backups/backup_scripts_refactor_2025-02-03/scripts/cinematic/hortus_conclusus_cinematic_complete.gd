extends Node3D

# Constants
const UP_VECTOR = Vector3(0, 1, 0)

# Enhanced systems
var CinematicEffectsEnhanced = load("res://scripts/cinematic_effects.gd")
var AtmosphereController = load("res://scripts/atmosphere_controller.gd")
var MeditationDisplay = load("res://scripts/meditation_display.gd")
var SacredGeometry = load("res://scripts/sacred_geometry.gd")
var CameraPathEnhanced = load("res://scripts/camera_path.gd")
var CameraPathIntegration = load("res://scripts/camera_path_integration.gd")
var MissingFunctions = load("res://scripts/hortus_conclusus_cinematic_missing_functions.gd")
var PlantGenerator = load("res://scripts/plants/plant_generator.gd")
var UpVectorHandler = load("res://scripts/up_vector_handler.gd")

# Node references
var world_environment: WorldEnvironment
var fade_overlay: ColorRect
var meditation_label: Label
var camera_path: Path3D
var path_follow: PathFollow3D
var camera: Camera3D
var timer: Timer

# Enhanced system instances
var atmosphere_controller: Node
var meditation_display: Node
var sacred_geometry: Node
var cinematic_effects: Node
var plant_generator: Node
var camera_path_integration: Node

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
var current_sequence_name = "intro"

# Visual effect parameters
var bloom_intensity = 0.0
var vignette_intensity = 0.0
var chromatic_aberration = 0.0
var color_correction_enabled = false
var color_temperature = 6500.0  # Kelvin
var saturation = 1.0
var contrast = 1.0

# Particle effect references
var dawn_particles: Node3D
var noon_particles: Node3D
var dusk_particles: Node3D
var night_particles: Node3D

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

func _initialize_cinematic():
    # Initialize enhanced systems
    atmosphere_controller = AtmosphereController.new()
    add_child(atmosphere_controller)
    
    meditation_display = MeditationDisplay.new()
    add_child(meditation_display)
    
    sacred_geometry = SacredGeometry.new()
    add_child(sacred_geometry)
    
    cinematic_effects = CinematicEffectsEnhanced.new()
    add_child(cinematic_effects)
    
    # Create and add PlantGenerator node at the correct path
    plant_generator = PlantGenerator.new()
    plant_generator.name = "PlantGenerator"
    add_child(plant_generator)
    
    # Initialize camera path integration
    camera_path_integration = CameraPathIntegration.new()
    add_child(camera_path_integration)
    
    # Convert standard camera path to enhanced camera path
    _convert_to_enhanced_camera_path()

    # Connect signals
    timer.connect("timeout", Callable(self, "_on_timer_timeout"))
    if meditation_display.has_signal("display_completed"):
        meditation_display.connect("display_completed", Callable(self, "_on_meditation_completed"))
    if atmosphere_controller.has_signal("time_changed"):
        atmosphere_controller.connect("time_changed", Callable(self, "_on_time_changed"))
    if camera_path_integration:
        camera_path_integration.connect("sequence_completed", Callable(self, "_on_camera_sequence_completed"))

    # Configure meditation display
    meditation_display.text_label = meditation_label
    
    # Create initial particle effects for dawn
    _create_particle_effects()
    
    # Create sacred geometry patterns
    _create_sacred_geometry_patterns()
    
    # Setup day-night effects
    _setup_day_night_effects()
    
    # Schedule the end of the cinematic
    var end_timer = Timer.new()
    end_timer.name = "EndTimer"
    end_timer.wait_time = 305.0  # Total duration in seconds (about 5 minutes)
    end_timer.one_shot = true
    end_timer.timeout.connect(_on_cinematic_completed)
    add_child(end_timer)
    
    # Schedule initial setup timer
    timer.wait_time = 10.0

func _start_cinematic():
    # Fade in the scene
    _fade_in()
    
    # Initialize camera path integration
    if camera_path_integration and camera_path is CameraPathEnhanced:
        camera_path_integration.initialize(self, camera_path, camera, atmosphere_controller)
        camera_path_integration.create_cinematic_sequences()
    
    # Initialize meditation display
    if meditation_display:
        var lines = MEDITATIONS[current_meditation]
        var meditation_text = ""
        for i in range(lines.size()):
            meditation_text += lines[i]
            if i < lines.size() - 1:
                meditation_text += "\n"
        meditation_text = meditation_text.strip_edges()
        meditation_display.set_text(meditation_text)
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

# Update time of day (called by animation)
func update_time_of_day(time: String):
    current_meditation = time
    if meditation_display:
        var lines = MEDITATIONS[time]
        var meditation_text = ""
        for i in range(lines.size()):
            meditation_text += lines[i]
            if i < lines.size() - 1:
                meditation_text += "\n"
        meditation_display.set_text(meditation_text)
        meditation_display.restart_display()
    if atmosphere_controller:
        atmosphere_controller.set_time_of_day(time)
    _on_time_changed(time)
    
    # Update particle effects
    _update_particle_effects(time)

# Signal handlers
func _on_timer_timeout():
    # Move to next sequence stage
    _advance_to_next_sequence()

func _on_meditation_completed():
    # Schedule next meditation if needed
    if current_sequence_stage < 4:  # 4 stages: dawn, noon, dusk, night
        timer.start()

func _on_time_changed(time: String):
    # Update sacred geometry colors
    if sacred_geometry and active_sacred_pattern:
        sacred_geometry.set_time_of_day(time)
    
    # Update environment settings
    if atmosphere_controller:
        # Environment settings are handled by atmosphere controller
        pass
    else:
        # Fallback implementation - update environment settings directly
        var fog_densities = {
            "dawn": 0.003,
            "noon": 0.001,
            "dusk": 0.004,
            "night": 0.006
        }
        
        var bloom_intensities = {
            "dawn": 0.3,
            "noon": 0.2,
            "dusk": 0.4,
            "night": 0.5
        }
        
        var light_energies = {
            "dawn": 0.8,
            "noon": 1.2,
            "dusk": 0.7,
            "night": 0.4
        }
        
        # Update environment settings if world_environment exists
        if world_environment and world_environment.environment:
            var env = world_environment.environment
            
            # Update fog density
            if time in fog_densities:
                env.fog_density = fog_densities[time]
            
            # Update bloom intensity
            if time in bloom_intensities:
                env.glow_intensity = bloom_intensities[time]
        
        # Update directional light if it exists
        var directional_light = get_node_or_null("DirectionalLight3D")
        if directional_light and time in light_energies:
            directional_light.light_energy = light_energies[time]

func _on_fade_out_completed():
    # Transition to main garden scene
    get_tree().change_scene_to_file("res://scenes/medieval_garden_demo.tscn")

func _on_camera_sequence_completed(sequence_name: String):
    # Handle camera sequence completion
    match sequence_name:
        "path_completed":
            # Path has completed, move to next sequence
            timer.wait_time = 2.0  # Short delay before next sequence
            timer.start()
        
        "approaching_end":
            # Near the end of the path, prepare for transition
            if meditation_display:
                meditation_display.fade_out()

# Called when the cinematic duration timer expires
func _on_cinematic_completed():
    # Start the fade out effect
    _fade_out()

func _create_title_screen():
    # Create title screen UI elements
    var title_label = Label.new()
    title_label.text = title_text
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title_label.add_theme_font_size_override("font_size", 32)
    title_label.modulate.a = 0
    $UI.add_child(title_label)
    
    var subtitle_label = Label.new()
    subtitle_label.text = title_subtitle
    subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    subtitle_label.add_theme_font_size_override("font_size", 24)
    subtitle_label.modulate.a = 0
    $UI.add_child(subtitle_label)

func _start_title_sequence():
    # Start title screen fade in
    var tween = create_tween()
    tween.tween_property($UI/Title, "modulate:a", 1.0, title_fade_in_duration)
    tween.tween_interval(title_display_duration)
    tween.tween_property($UI/Title, "modulate:a", 0.0, title_fade_out_duration)
    tween.tween_callback(_start_cinematic)

func _convert_to_enhanced_camera_path():
    if camera_path:
        camera_path.set_script(CameraPathEnhanced)

func _create_particle_effects():
    # Create particle systems for each time of day
    dawn_particles = load("res://scripts/particle_effects/dawn_particles.gd").new()
    noon_particles = load("res://scripts/particle_effects/noon_particles.gd").new()
    dusk_particles = load("res://scripts/particle_effects/dusk_particles.gd").new()
    night_particles = load("res://scripts/particle_effects/night_particles.gd").new()
    
    add_child(dawn_particles)
    add_child(noon_particles)
    add_child(dusk_particles)
    add_child(night_particles)
    
    # Initially only dawn particles are visible
    dawn_particles.visible = true
    noon_particles.visible = false
    dusk_particles.visible = false
    night_particles.visible = false

func _create_sacred_geometry_patterns():
    if sacred_geometry:
        sacred_geometry.create_patterns()

func _setup_day_night_effects():
    if atmosphere_controller:
        atmosphere_controller.setup_effects()

func _start_cinematic_sequence():
    current_sequence_stage = 0
    current_sequence_name = "intro"
    _advance_to_next_sequence()

func _advance_to_next_sequence():
    current_sequence_stage += 1
    match current_sequence_stage:
        1:  # Dawn sequence
            atmosphere_controller.set_time_of_day("dawn")
            camera_path_integration.start_sequence("dawn_path")
        2:  # Noon sequence
            atmosphere_controller.set_time_of_day("noon")
            camera_path_integration.start_sequence("noon_path")
        3:  # Dusk sequence
            atmosphere_controller.set_time_of_day("dusk")
            camera_path_integration.start_sequence("dusk_path")
        4:  # Night sequence
            atmosphere_controller.set_time_of_day("night")
            camera_path_integration.start_sequence("night_path")
        _:  # End of sequences
            _on_cinematic_completed()

func _update_particle_effects(time: String):
    # Update particle system visibility based on time of day
    dawn_particles.visible = (time == "dawn")
    noon_particles.visible = (time == "noon")
    dusk_particles.visible = (time == "dusk")
    night_particles.visible = (time == "night")

func _fade_in():
    if fade_overlay:
        var tween = create_tween()
        tween.tween_property(fade_overlay, "color:a", 0.0, 2.0)

func _fade_out():
    if fade_overlay:
        var tween = create_tween()
        tween.tween_property(fade_overlay, "color:a", 1.0, 2.0)
        tween.tween_callback(_on_fade_out_completed)
