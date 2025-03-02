extends Node

# This script integrates the missing functions from hortus_conclusus_cinematic_missing_functions.gd
# into the main HortusConclususCinematic class

const MissingFunctions = preload("res://scripts/hortus_conclusus_cinematic_missing_functions.gd")

# Called when the node enters the scene tree for the first time
func _ready():
    # Find the main cinematic controller
    var cinematic_controller = get_parent()
    if not cinematic_controller is Node3D:  # Changed from HortusConclususCinematic to Node3D
        push_error("HortusConclususCinematic Integration must be a child of HortusConclususCinematic")
        return
    
    # Connect to signals
    cinematic_controller.connect("ready", Callable(self, "_on_cinematic_ready"))

# Called when the cinematic controller is ready
func _on_cinematic_ready():
    var cinematic_controller = get_parent()
    
    # Override missing functions with implementations from MissingFunctions
    _override_functions(cinematic_controller)

# Override missing functions with implementations from MissingFunctions
func _override_functions(cinematic_controller):
    # Use variables instead of trying to assign to constants
    # Connect the highlight_garden_types function
    if "highlight_garden_types" in cinematic_controller:
        cinematic_controller.highlight_garden_types = func():
            MissingFunctions.highlight_garden_types(cinematic_controller)
    
    # Connect the update_sacred_patterns function
    if "update_sacred_patterns" in cinematic_controller:
        cinematic_controller.update_sacred_patterns = func(delta: float):
            MissingFunctions.update_sacred_patterns(cinematic_controller, delta)
    
    # Connect the create_sacred_geometry_patterns function
    if "create_sacred_geometry_patterns" in cinematic_controller:
        cinematic_controller.create_sacred_geometry_patterns = func():
            MissingFunctions.create_sacred_geometry_patterns(cinematic_controller)
    
    # Connect the activate_sacred_patterns_sequence function
    if "activate_sacred_patterns_sequence" in cinematic_controller:
        cinematic_controller.activate_sacred_patterns_sequence = func():
            MissingFunctions.activate_sacred_patterns_sequence(cinematic_controller)
    
    # Connect the setup_day_night_effects function
    if "setup_day_night_effects" in cinematic_controller:
        cinematic_controller.setup_day_night_effects = func():
            MissingFunctions.setup_day_night_effects(cinematic_controller)
    
    # Connect the fade_in function
    if "fade_in" in cinematic_controller:
        cinematic_controller.fade_in = func():
            MissingFunctions.fade_in(cinematic_controller)
    
    # Connect the fade_out function
    if "fade_out" in cinematic_controller:
        cinematic_controller.fade_out = func():
            MissingFunctions.fade_out(cinematic_controller)
    
    # Connect helper functions
    if "highlight_garden" in cinematic_controller:
        cinematic_controller.highlight_garden = func(garden: Node3D):
            _highlight_garden(cinematic_controller, garden)
    
    if "activate_pattern" in cinematic_controller:
        cinematic_controller.activate_pattern = func(pattern: Node3D):
            _activate_pattern(cinematic_controller, pattern)
    
    if "add_pattern_light" in cinematic_controller:
        cinematic_controller.add_pattern_light = func(pattern: Node3D):
            _add_pattern_light(cinematic_controller, pattern)
    
    if "update_environment_for_time" in cinematic_controller:
        cinematic_controller.update_environment_for_time = func(time: String, fog_density: float, bloom_intensity: float, light_energy: float):
            _update_environment_for_time(cinematic_controller, time, fog_density, bloom_intensity, light_energy)
    
    if "on_fade_out_completed" in cinematic_controller:
        cinematic_controller.on_fade_out_completed = func():
            _on_fade_out_completed(cinematic_controller)
    
    if "on_time_changed" in cinematic_controller:
        cinematic_controller.on_time_changed = func(time: String):
            _on_time_changed(cinematic_controller, time)

# Helper function implementations
func _highlight_garden(cinematic_controller, garden: Node3D):
    # Get the garden's material
    var material = garden.get_surface_material(0)
    if material:
        # Create a glow effect
        material.emission_enabled = true
        material.emission = Color(1.0, 0.9, 0.7)  # Warm glow
        material.emission_energy = 2.0
        
        # Animate the glow
        var tween = create_tween()
        tween.tween_property(material, "emission_energy", 0.0, 2.0)
        tween.tween_callback(func(): material.emission_enabled = false)

func _activate_pattern(cinematic_controller, pattern: Node3D):
    # Make the pattern visible with a fade effect
    pattern.visible = true
    pattern.modulate.a = 0.0
    
    var tween = create_tween()
    tween.tween_property(pattern, "modulate:a", 1.0, 1.5)
    
    # Add a light to enhance the pattern
    _add_pattern_light(cinematic_controller, pattern)

func _add_pattern_light(cinematic_controller, pattern: Node3D):
    var light = OmniLight3D.new()
    pattern.add_child(light)
    
    # Position the light above the pattern
    light.position = Vector3(0, 2, 0)
    
    # Configure light properties
    light.light_color = Color(1.0, 0.9, 0.7)  # Warm light
    light.light_energy = 0.0
    light.omni_range = 5.0
    
    # Animate the light
    var tween = create_tween()
    tween.tween_property(light, "light_energy", 2.0, 1.0)
    tween.tween_property(light, "light_energy", 0.5, 1.0)

func _update_environment_for_time(cinematic_controller, time: String, fog_density: float, bloom_intensity: float, light_energy: float):
    var world_environment = cinematic_controller.get_node("WorldEnvironment")
    if not world_environment:
        return
        
    var environment = world_environment.environment
    
    # Update fog settings
    environment.fog_enabled = true
    environment.fog_density = fog_density
    
    # Update bloom settings
    environment.glow_enabled = true
    environment.glow_intensity = bloom_intensity
    
    # Update lighting
    var directional_light = cinematic_controller.get_node("DirectionalLight3D")
    if directional_light:
        directional_light.light_energy = light_energy
        
        # Adjust light color based on time of day
        match time:
            "dawn":
                directional_light.light_color = Color(1.0, 0.8, 0.7)  # Warm morning light
            "noon":
                directional_light.light_color = Color(1.0, 0.95, 0.9)  # Bright daylight
            "dusk":
                directional_light.light_color = Color(0.9, 0.7, 0.5)  # Golden hour
            "night":
                directional_light.light_color = Color(0.6, 0.6, 1.0)  # Cool moonlight

func _on_fade_out_completed(cinematic_controller):
    # Reset any temporary effects
    var world_environment = cinematic_controller.get_node("WorldEnvironment")
    if world_environment:
        world_environment.environment.glow_intensity = 0.5  # Reset bloom
        
    # Prepare for next sequence
    if cinematic_controller.has_signal("sequence_completed"):
        cinematic_controller.emit_signal("sequence_completed")

func _on_time_changed(cinematic_controller, time: String):
    # Update environment based on time of day
    match time:
        "dawn":
            _update_environment_for_time(cinematic_controller, time, 0.002, 0.5, 0.5)
        "noon":
            _update_environment_for_time(cinematic_controller, time, 0.001, 0.7, 1.5)
        "dusk":
            _update_environment_for_time(cinematic_controller, time, 0.003, 0.8, 0.8)
        "night":
            _update_environment_for_time(cinematic_controller, time, 0.004, 1.0, 0.1)
