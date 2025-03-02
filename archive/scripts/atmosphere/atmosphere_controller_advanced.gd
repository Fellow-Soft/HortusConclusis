extends Node
class_name AtmosphereControllerAdvanced

# Constants
const UP_VECTOR = Vector3(0, 1, 0)

# Time of day states
enum TimeOfDay {
    DAWN,
    NOON,
    DUSK,
    NIGHT
}

# Current time of day
var current_time: TimeOfDay = TimeOfDay.DAWN
var current_time_string: String = "dawn"
var transition_progress: float = 0.0
var is_transitioning: bool = false

# Environment reference
var environment: Environment
var world_environment: WorldEnvironment

# Directional light reference
var sun_light: DirectionalLight3D

# Fog parameters
var fog_enabled: bool = true
var volumetric_fog_enabled: bool = true
var fog_density_values = {
    "dawn": 0.003,
    "noon": 0.001,
    "dusk": 0.004,
    "night": 0.006
}
var fog_color_values = {
    "dawn": Color(0.8, 0.7, 0.6, 1.0),
    "noon": Color(0.9, 0.9, 0.95, 1.0),
    "dusk": Color(0.7, 0.5, 0.6, 1.0),
    "night": Color(0.1, 0.1, 0.2, 1.0)
}
var fog_height_values = {
    "dawn": 5.0,
    "noon": 10.0,
    "dusk": 3.0,
    "night": 2.0
}

# Sky parameters
var sky_enabled: bool = true
var sky_color_top_values = {
    "dawn": Color(0.5, 0.6, 0.8, 1.0),
    "noon": Color(0.3, 0.6, 0.9, 1.0),
    "dusk": Color(0.6, 0.4, 0.6, 1.0),
    "night": Color(0.05, 0.05, 0.1, 1.0)
}
var sky_color_horizon_values = {
    "dawn": Color(0.9, 0.7, 0.6, 1.0),
    "noon": Color(0.8, 0.9, 1.0, 1.0),
    "dusk": Color(0.9, 0.6, 0.5, 1.0),
    "night": Color(0.1, 0.1, 0.2, 1.0)
}
var sky_sun_angle_values = {
    "dawn": 10.0,
    "noon": 60.0,
    "dusk": -10.0,
    "night": -60.0
}
var sky_sun_color_values = {
    "dawn": Color(1.0, 0.8, 0.6, 1.0),
    "noon": Color(1.0, 1.0, 0.9, 1.0),
    "dusk": Color(1.0, 0.6, 0.4, 1.0),
    "night": Color(0.1, 0.1, 0.3, 1.0)
}

# Light parameters
var sun_light_energy_values = {
    "dawn": 0.8,
    "noon": 1.2,
    "dusk": 0.7,
    "night": 0.2
}
var sun_light_color_values = {
    "dawn": Color(1.0, 0.8, 0.7, 1.0),
    "noon": Color(1.0, 1.0, 0.9, 1.0),
    "dusk": Color(1.0, 0.6, 0.5, 1.0),
    "night": Color(0.2, 0.2, 0.4, 1.0)
}
var sun_light_angle_values = {
    "dawn": Vector2(10.0, 80.0),  # Elevation, Azimuth
    "noon": Vector2(60.0, 180.0),
    "dusk": Vector2(10.0, 280.0),
    "night": Vector2(-30.0, 0.0)
}
var sun_shadow_enabled_values = {
    "dawn": true,
    "noon": true,
    "dusk": true,
    "night": false
}

# Ambient light parameters
var ambient_light_energy_values = {
    "dawn": 0.3,
    "noon": 0.2,
    "dusk": 0.25,
    "night": 0.4
}
var ambient_light_color_values = {
    "dawn": Color(0.8, 0.7, 0.6, 1.0),
    "noon": Color(0.9, 0.9, 0.95, 1.0),
    "dusk": Color(0.7, 0.5, 0.6, 1.0),
    "night": Color(0.1, 0.1, 0.3, 1.0)
}
var ambient_light_sky_contribution_values = {
    "dawn": 0.5,
    "noon": 0.3,
    "dusk": 0.4,
    "night": 0.7
}

# Post-processing parameters
var bloom_enabled: bool = true
var bloom_intensity_values = {
    "dawn": 0.3,
    "noon": 0.2,
    "dusk": 0.4,
    "night": 0.5
}
var bloom_threshold_values = {
    "dawn": 0.8,
    "noon": 1.0,
    "dusk": 0.7,
    "night": 0.6
}

var ssr_enabled: bool = true
var ssr_max_steps_values = {
    "dawn": 32,
    "noon": 64,
    "dusk": 32,
    "night": 16
}
var ssr_fade_in_values = {
    "dawn": 0.15,
    "noon": 0.1,
    "dusk": 0.15,
    "night": 0.2
}
var ssr_fade_out_values = {
    "dawn": 2.0,
    "noon": 1.0,
    "dusk": 2.0,
    "night": 3.0
}

var ssao_enabled: bool = true
var ssao_radius_values = {
    "dawn": 1.0,
    "noon": 0.5,
    "dusk": 1.0,
    "night": 2.0
}
var ssao_intensity_values = {
    "dawn": 1.0,
    "noon": 0.5,
    "dusk": 1.0,
    "night": 2.0
}
var ssao_power_values = {
    "dawn": 1.5,
    "noon": 1.0,
    "dusk": 1.5,
    "night": 2.0
}

var dof_enabled: bool = true
var dof_far_distance_values = {
    "dawn": 100.0,
    "noon": 200.0,
    "dusk": 80.0,
    "night": 50.0
}
var dof_far_transition_values = {
    "dawn": 20.0,
    "noon": 50.0,
    "dusk": 15.0,
    "night": 10.0
}
var dof_blur_amount_values = {
    "dawn": 0.05,
    "noon": 0.02,
    "dusk": 0.07,
    "night": 0.1
}

# Color correction parameters
var color_correction_enabled: bool = true
var brightness_values = {
    "dawn": 1.0,
    "noon": 1.1,
    "dusk": 0.9,
    "night": 0.8
}
var contrast_values = {
    "dawn": 1.1,
    "noon": 1.0,
    "dusk": 1.2,
    "night": 1.3
}
var saturation_values = {
    "dawn": 1.0,
    "noon": 1.0,
    "dusk": 0.9,
    "night": 0.7
}
var color_temperature_values = {
    "dawn": 5500.0,  # Kelvin
    "noon": 6500.0,
    "dusk": 4500.0,
    "night": 3500.0
}

# Volumetric light parameters
var volumetric_light_enabled: bool = true
var volumetric_light_intensity_values = {
    "dawn": 1.0,
    "noon": 0.5,
    "dusk": 1.2,
    "night": 0.3
}
var volumetric_light_size_values = {
    "dawn": 0.1,
    "noon": 0.05,
    "dusk": 0.15,
    "night": 0.2
}

# Weather parameters
var weather_type: String = "clear"
var weather_intensity: float = 0.0
var weather_types = ["clear", "mist", "rain", "snow"]
var weather_transition_duration: float = 10.0

# Particle systems
var mist_particles: GPUParticles3D
var rain_particles: GPUParticles3D
var snow_particles: GPUParticles3D

# Animation player for day-night cycle
var animation_player: AnimationPlayer

# Transition parameters
var transition_duration: float = 5.0
var transition_timer: Timer

# Signals
signal time_changed(time)
signal weather_changed(type, intensity)
signal transition_completed(from_time, to_time)

# Called when the node enters the scene tree for the first time
func _ready():
    # Initialize timers
    transition_timer = Timer.new()
    transition_timer.one_shot = true
    transition_timer.connect("timeout", Callable(self, "_on_transition_timer_timeout"))
    add_child(transition_timer)
    
    # Initialize animation player
    animation_player = AnimationPlayer.new()
    animation_player.name = "DayNightCycle"
    add_child(animation_player)
    
    # Find environment and directional light
    _find_environment_and_light()
    
    # Initialize particle systems
    _initialize_particle_systems()
    
    # Create day-night cycle animation
    create_day_night_cycle_animation()
    
    # Apply initial time of day
    set_time_of_day("dawn")

# Find environment and directional light in the scene
func _find_environment_and_light():
    # Find WorldEnvironment node
    var world_env_nodes = get_tree().get_nodes_in_group("WorldEnvironment")
    if world_env_nodes.size() > 0:
        world_environment = world_env_nodes[0]
        environment = world_environment.environment
    else:
        # Try to find it by class
        var root = get_tree().root
        for child in root.get_children():
            if child is WorldEnvironment:
                world_environment = child
                environment = world_environment.environment
                break
    
    # Find DirectionalLight3D node
    var light_nodes = get_tree().get_nodes_in_group("SunLight")
    if light_nodes.size() > 0:
        sun_light = light_nodes[0]
    else:
        # Try to find it by class
        var root = get_tree().root
        for child in root.get_children():
            if child is DirectionalLight3D:
                sun_light = child
                break

# Initialize particle systems for weather effects
func _initialize_particle_systems():
    # Create mist particles
    mist_particles = GPUParticles3D.new()
    mist_particles.name = "MistParticles"
    mist_particles.emitting = false
    mist_particles.amount = 1000
    mist_particles.lifetime = 5.0
    mist_particles.visibility_aabb = AABB(Vector3(-50, 0, -50), Vector3(100, 10, 100))
    add_child(mist_particles)
    
    # Create rain particles
    rain_particles = GPUParticles3D.new()
    rain_particles.name = "RainParticles"
    rain_particles.emitting = false
    rain_particles.amount = 2000
    rain_particles.lifetime = 2.0
    rain_particles.visibility_aabb = AABB(Vector3(-50, 0, -50), Vector3(100, 20, 100))
    add_child(rain_particles)
    
    # Create snow particles
    snow_particles = GPUParticles3D.new()
    snow_particles.name = "SnowParticles"
    snow_particles.emitting = false
    snow_particles.amount = 1000
    snow_particles.lifetime = 10.0
    snow_particles.visibility_aabb = AABB(Vector3(-50, 0, -50), Vector3(100, 20, 100))
    add_child(snow_particles)
    
    # Configure particle materials
    _configure_particle_materials()

# Configure particle materials for weather effects
func _configure_particle_materials():
    # This would require creating particle materials
    # For now, we'll just use placeholder code
    pass

# Set the time of day
func set_time_of_day(time: String, transition_time: float = 5.0):
    # Validate time
    if not time in ["dawn", "noon", "dusk", "night"]:
        push_error("Invalid time of day: " + time)
        return
    
    # Store previous time for transition
    var previous_time = current_time_string
    
    # Update current time
    current_time_string = time
    match time:
        "dawn":
            current_time = TimeOfDay.DAWN
        "noon":
            current_time = TimeOfDay.NOON
        "dusk":
            current_time = TimeOfDay.DUSK
        "night":
            current_time = TimeOfDay.NIGHT
    
    # Start transition
    transition_duration = transition_time
    is_transitioning = true
    transition_progress = 0.0
    
    # Start transition timer
    transition_timer.wait_time = transition_duration
    transition_timer.start()
    
    # Emit signal
    emit_signal("time_changed", time)
    
    # Apply immediate changes
    _apply_time_of_day_immediate(time)
    
    # Start transition tween
    _start_time_transition(previous_time, time, transition_duration)

# Apply immediate changes for time of day
func _apply_time_of_day_immediate(time: String):
    # Update shadow settings
    if sun_light:
        sun_light.shadow_enabled = sun_shadow_enabled_values[time]

# Start transition tween for time of day
func _start_time_transition(from_time: String, to_time: String, duration: float):
    # Create tween
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_IN_OUT)
    
    # Tween fog parameters
    if environment and fog_enabled:
        # Fog density
        tween.tween_method(Callable(self, "_tween_fog_density"), 
            fog_density_values[from_time], 
            fog_density_values[to_time], 
            duration)
        
        # Fog color
        tween.parallel().tween_method(Callable(self, "_tween_fog_color"), 
            fog_color_values[from_time], 
            fog_color_values[to_time], 
            duration)
        
        # Fog height
        tween.parallel().tween_method(Callable(self, "_tween_fog_height"), 
            fog_height_values[from_time], 
            fog_height_values[to_time], 
            duration)
    
    # Tween sky parameters
    if environment and sky_enabled:
        # Sky top color
        tween.parallel().tween_method(Callable(self, "_tween_sky_top_color"), 
            sky_color_top_values[from_time], 
            sky_color_top_values[to_time], 
            duration)
        
        # Sky horizon color
        tween.parallel().tween_method(Callable(self, "_tween_sky_horizon_color"), 
            sky_color_horizon_values[from_time], 
            sky_color_horizon_values[to_time], 
            duration)
        
        # Sky sun angle
        tween.parallel().tween_method(Callable(self, "_tween_sky_sun_angle"), 
            sky_sun_angle_values[from_time], 
            sky_sun_angle_values[to_time], 
            duration)
        
        # Sky sun color
        tween.parallel().tween_method(Callable(self, "_tween_sky_sun_color"), 
            sky_sun_color_values[from_time], 
            sky_sun_color_values[to_time], 
            duration)
    
    # Tween light parameters
    if sun_light:
        # Light energy
        tween.parallel().tween_method(Callable(self, "_tween_sun_light_energy"), 
            sun_light_energy_values[from_time], 
            sun_light_energy_values[to_time], 
            duration)
        
        # Light color
        tween.parallel().tween_method(Callable(self, "_tween_sun_light_color"), 
            sun_light_color_values[from_time], 
            sun_light_color_values[to_time], 
            duration)
        
        # Light angle
        tween.parallel().tween_method(Callable(self, "_tween_sun_light_angle"), 
            sun_light_angle_values[from_time], 
            sun_light_angle_values[to_time], 
            duration)
    
    # Tween ambient light parameters
    if environment:
        # Ambient light energy
        tween.parallel().tween_method(Callable(self, "_tween_ambient_light_energy"), 
            ambient_light_energy_values[from_time], 
            ambient_light_energy_values[to_time], 
            duration)
        
        # Ambient light color
        tween.parallel().tween_method(Callable(self, "_tween_ambient_light_color"), 
            ambient_light_color_values[from_time], 
            ambient_light_color_values[to_time], 
            duration)
        
        # Ambient light sky contribution
        tween.parallel().tween_method(Callable(self, "_tween_ambient_light_sky_contribution"), 
            ambient_light_sky_contribution_values[from_time], 
            ambient_light_sky_contribution_values[to_time], 
            duration)
    
    # Tween post-processing parameters
    if environment:
        # Bloom intensity
        if bloom_enabled:
            tween.parallel().tween_method(Callable(self, "_tween_bloom_intensity"), 
                bloom_intensity_values[from_time], 
                bloom_intensity_values[to_time], 
                duration)
            
            # Bloom threshold
            tween.parallel().tween_method(Callable(self, "_tween_bloom_threshold"), 
                bloom_threshold_values[from_time], 
                bloom_threshold_values[to_time], 
                duration)
        
        # SSR parameters
        if ssr_enabled:
            tween.parallel().tween_method(Callable(self, "_tween_ssr_fade_in"), 
                ssr_fade_in_values[from_time], 
                ssr_fade_in_values[to_time], 
                duration)
            
            tween.parallel().tween_method(Callable(self, "_tween_ssr_fade_out"), 
                ssr_fade_out_values[from_time], 
                ssr_fade_out_values[to_time], 
                duration)
        
        # SSAO parameters
        if ssao_enabled:
            tween.parallel().tween_method(Callable(self, "_tween_ssao_radius"), 
                ssao_radius_values[from_time], 
                ssao_radius_values[to_time], 
                duration)
            
            tween.parallel().tween_method(Callable(self, "_tween_ssao_intensity"), 
                ssao_intensity_values[from_time], 
                ssao_intensity_values[to_time], 
                duration)
            
            tween.parallel().tween_method(Callable(self, "_tween_ssao_power"), 
                ssao_power_values[from_time], 
                ssao_power_values[to_time], 
                duration)
        
        # DOF parameters
        if dof_enabled:
            tween.parallel().tween_method(Callable(self, "_tween_dof_far_distance"), 
                dof_far_distance_values[from_time], 
                dof_far_distance_values[to_time], 
                duration)
            
            tween.parallel().tween_method(Callable(self, "_tween_dof_far_transition"), 
                dof_far_transition_values[from_time], 
                dof_far_transition_values[to_time], 
                duration)
            
            tween.parallel().tween_method(Callable(self, "_tween_dof_blur_amount"), 
                dof_blur_amount_values[from_time], 
                dof_blur_amount_values[to_time], 
                duration)
    
    # Tween color correction parameters
    if environment and color_correction_enabled:
        # Brightness
        tween.parallel().tween_method(Callable(self, "_tween_brightness"), 
            brightness_values[from_time], 
            brightness_values[to_time], 
            duration)
        
        # Contrast
        tween.parallel().tween_method(Callable(self, "_tween_contrast"), 
            contrast_values[from_time], 
            contrast_values[to_time], 
            duration)
        
        # Saturation
        tween.parallel().tween_method(Callable(self, "_tween_saturation"), 
            saturation_values[from_time], 
            saturation_values[to_time], 
            duration)
        
        # Color temperature
        tween.parallel().tween_method(Callable(self, "_tween_color_temperature"), 
            color_temperature_values[from_time], 
            color_temperature_values[to_time], 
            duration)
    
    # Tween volumetric light parameters
    if environment and volumetric_light_enabled:
        # Volumetric light intensity
        tween.parallel().tween_method(Callable(self, "_tween_volumetric_light_intensity"), 
            volumetric_light_intensity_values[from_time], 
            volumetric_light_intensity_values[to_time], 
            duration)
        
        # Volumetric light size
        tween.parallel().tween_method(Callable(self, "_tween_volumetric_light_size"), 
            volumetric_light_size_values[from_time], 
            volumetric_light_size_values[to_time], 
            duration)
    
    # Connect tween completion
    tween.tween_callback(Callable(self, "_on_transition_tween_completed").bind(from_time, to_time))

# Set the weather type and intensity
func set_weather(type: String, intensity: float = 1.0, transition_time: float = 10.0):
    # Validate weather type
    if not type in weather_types:
        push_error("Invalid weather type: " + type)
        return
    
    # Store previous weather
    var previous_weather = weather_type
    var previous_intensity = weather_intensity
    
    # Update weather
    weather_type = type
    weather_intensity = clamp(intensity, 0.0, 1.0)
    weather_transition_duration = transition_time
    
    # Start weather transition
    _start_weather_transition(previous_weather, previous_intensity, type, intensity, transition_time)
    
    # Emit signal
    emit_signal("weather_changed", type, intensity)

# Start weather transition
func _start_weather_transition(from_type: String, from_intensity: float, to_type: String, to_intensity: float, duration: float):
    # Create tween
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_IN_OUT)
    
    # Fade out previous weather
    if from_type != "clear" and from_intensity > 0.0:
        tween.tween_method(Callable(self, "_tween_weather_intensity"), 
            from_intensity, 
            0.0, 
            duration * 0.5)
        
        tween.tween_callback(Callable(self, "_set_weather_particles_emitting").bind(from_type, false))
    
    # Fade in new weather
    if to_type != "clear" and to_intensity > 0.0:
        tween.tween_callback(Callable(self, "_set_weather_particles_emitting").bind(to_type, true))
        
        tween.tween_method(Callable(self, "_tween_weather_intensity"), 
            0.0, 
            to_intensity, 
            duration * 0.5)
    
    # Connect tween completion
    tween.tween_callback(Callable(self, "_on_weather_transition_completed").bind(from_type, to_type))

# Create day-night cycle animation
func create_day_night_cycle_animation():
    # Create animation
    var animation = Animation.new()
    
    # Add tracks for time of day
    var track_index = animation.add_track(Animation.TYPE_METHOD)
    animation.track_set_path(track_index, ".")
    
    # Add key frames for each time of day
    animation.track_insert_key(track_index, 0.0, {
        "method": "set_time_of_day",
        "args": ["dawn", 5.0]
    })
    
    animation.track_insert_key(track_index, 30.0, {
        "method": "set_time_of_day",
        "args": ["noon", 5.0]
    })
    
    animation.track_insert_key(track_index, 60.0, {
        "method": "set_time_of_day",
        "args": ["dusk", 5.0]
    })
    
    animation.track_insert_key(track_index, 90.0, {
        "method": "set_time_of_day",
        "args": ["night", 5.0]
    })
    
    animation.track_insert_key(track_index, 120.0, {
        "method": "set_time_of_day",
        "args": ["dawn", 5.0]
    })
    
    # Set animation length
    animation.length = 120.0
    
    # Set animation loop
    animation.loop_mode = Animation.LOOP_LINEAR
    
    # Add animation to player
    animation_player.add_animation("day_night_cycle", animation)

# Play day-night cycle animation
func play_day_night_cycle_animation():
    if animation_player.has_animation("day_night_cycle"):
        animation_player.play("day_night_cycle")

# Stop day-night cycle animation
func stop_day_night_cycle_animation():
    animation_player.stop()

# Tween callback functions
func _tween_fog_density(value: float):
    if environment:
        environment.fog_density = value

func _tween_fog_color(value: Color):
    if environment:
        environment.fog_color = value

func _tween_fog_height(value: float):
    if environment:
        environment.fog_height = value

func _tween_sky_top_color(value: Color):
    if environment and environment.sky:
        environment.sky.sky_top_color = value

func _tween_sky_horizon_color(value: Color):
    if environment and environment.sky:
        environment.sky.sky_horizon_color = value

func _tween_sky_sun_angle(value: float):
    if environment and environment.sky:
        # This would require a custom sky shader
        pass

func _tween_sky_sun_color(value: Color):
    if environment and environment.sky:
        environment.sky.sun_color = value

func _tween_sun_light_energy(value: float):
    if sun_light:
        sun_light.light_energy = value

func _tween_sun_light_color(value: Color):
    if sun_light:
        sun_light.light_color = value

func _tween_sun_light_angle(value: Vector2):
    if sun_light:
        # Convert elevation and azimuth to direction vector
        var elevation_rad = deg_to_rad(value.x)
        var azimuth_rad = deg_to_rad(value.y)
        
        var direction = Vector3(
            cos(elevation_rad) * sin(azimuth_rad),
            sin(elevation_rad),
            cos(elevation_rad) * cos(azimuth_rad)
        )
        
        sun_light.rotation = Vector3(0, 0, 0)
        sun_light.look_at_from_position(Vector3.ZERO, direction, UP_VECTOR)

func _tween_ambient_light_energy(value: float):
    if environment:
        environment.ambient_light_energy = value

func _tween_ambient_light_color(value: Color):
    if environment:
        environment.ambient_light_color = value

func _tween_ambient_light_sky_contribution(value: float):
    if environment:
        environment.ambient_light_sky_contribution = value

func _tween_bloom_intensity(value: float):
    if environment:
        environment.glow_intensity = value

func _tween_bloom_threshold(value: float):
    if environment:
        environment.glow_threshold = value

func _tween_ssr_fade_in(value: float):
    if environment:
        environment.ssr_fade_in = value

func _tween_ssr_fade_out(value: float):
    if environment:
        environment.ssr_fade_out = value

func _tween_ssao_radius(value: float):
    if environment:
        environment.ssao_radius = value

func _tween_ssao_intensity(value: float):
    if environment:
        environment.ssao_intensity = value

func _tween_ssao_power(value: float):
    if environment:
        environment.ssao_power = value

func _tween_dof_far_distance(value: float):
    if environment:
        environment.dof_blur_far_distance = value

func _tween_dof_far_transition(value: float):
    if environment:
        environment.dof_blur_far_transition = value

func _tween_dof_blur_amount(value: float):
    if environment:
        environment.dof_blur_amount = value

func _tween_brightness(value: float):
    if environment and environment.adjustment:
        environment.adjustment_brightness = value

func _tween_contrast(value: float):
    if environment and environment.adjustment:
        environment.adjustment_contrast = value

func _tween_saturation(value: float):
    if environment and environment.adjustment:
        environment.adjustment_saturation = value

func _tween_color_temperature(value: float):
    # This would require a custom color correction shader
    pass

func _tween_volumetric_light_intensity(value: float):
    # This would require a custom volumetric light shader
    pass

func _tween_volumetric_light_size(value: float):
    # This would require a custom volumetric light shader
    pass

func _tween_weather_intensity(value: float):
    # Update weather intensity
    weather_intensity = value
    
    # Update particle emission based on weather type and intensity
    match weather_type:
        "mist":
            if mist_particles:
                mist_particles.amount = int(1000.0 * value)
        "rain":
            if rain_particles:
                rain_particles.amount = int(2000.0 * value)
        "snow":
            if snow_particles:
                snow_particles.amount = int(1000.0 * value)

func _set_weather_particles_emitting(type: String, emitting: bool):
    match type:
        "mist":
            if mist_particles:
                mist_particles.emitting = emitting
        "rain":
            if rain_particles:
                rain_particles.emitting = emitting
        "snow":
            if snow_particles:
                snow_particles.emitting = emitting

# Signal handlers
func _on_transition_timer_timeout():
    is_transitioning = false
    transition_progress = 1.0

func _on_transition_tween_completed(from_time: String, to_time: String):
    # Emit signal
    emit_signal("transition_completed", from_time, to_time)

func _on_weather_transition_completed(from_type: String, to_type: String):
    # Weather transition completed
    pass

# Public methods for customization
func set_fog_enabled(enabled: bool):
    fog_enabled = enabled
    
    # Apply immediately
    if environment:
        environment.fog_enabled = enabled

func set_volumetric_fog_enabled(enabled: bool):
    volumetric_fog_enabled = enabled
    
    # Apply immediately
    if environment:
        environment.volumetric_fog_enabled = enabled

func set_sky_enabled(enabled: bool):
    sky_enabled = enabled
    
    # Apply immediately
    if environment and environment.sky:
        environment.sky_enabled = enabled

func set_bloom_enabled(enabled: bool):
    bloom_enabled = enabled
    
    # Apply immediately
    if environment:
        environment.glow_enabled = enabled

func set_ssr_enabled(enabled: bool):
    ssr_enabled = enabled
    
    # Apply immediately
    if environment:
        environment.ssr_enabled = enabled

func set_ssao_enabled(enabled: bool):
    ssao_enabled = enabled
    
    # Apply immediately
    if environment:
        environment.ssao_enabled = enabled

func set_dof_enabled(enabled: bool):
    dof_enabled = enabled
    
    # Apply immediately
    if environment:
        environment.dof_blur_enabled = enabled

func set_color_correction_enabled(enabled: bool):
    color_correction_enabled = enabled
    
    # Apply immediately
    if environment:
        environment.adjustment_enabled = enabled

func set_volumetric_light_enabled(enabled: bool):
    volumetric_light_enabled = enabled
    
    # Apply immediately
    # This would require a custom volumetric light shader
    pass

func customize_time_of_day_parameters(time: String, parameters: Dictionary):
    # Validate time
    if not time in ["dawn", "noon", "dusk", "night"]:
        push_error("Invalid time of day: " + time)
        return
    
    # Update parameters
    for key in parameters:
        match key:
            "fog_density":
                fog_density_values[time] = parameters[key]
            "fog_color":
                fog_color_values[time] = parameters[key]
            "fog_height":
                fog_height_values[time] = parameters[key]
            "sky_color_top":
                sky_color_top_values[time] = parameters[key]
            "sky_color_horizon":
                sky_color_horizon_values[time] = parameters[key]
            "sky_sun_angle":
                sky_sun_angle_values[time] = parameters[key]
            "sky_sun_color":
                sky_sun_color_values[time] = parameters[key]
            "sun_light_energy":
                sun_light_energy_values[time] = parameters[key]
            "sun_light_color":
                sun_light_color_values[time] = parameters[key]
            "sun_light_angle":
                sun_light_angle_values[time] = parameters[key]
            "sun_shadow_enabled":
                sun_shadow_enabled_values[time] = parameters[key]
            "ambient_light_energy":
                ambient_light_energy_values[time] = parameters[key]
            "ambient_light_color":
                ambient_light_color_values[time] = parameters[key]
            "ambient_light_sky_contribution":
                ambient_light_sky_contribution_values[time] = parameters[key]
            "bloom_intensity":
                bloom_intensity_values[time] = parameters[key]
            "bloom_threshold":
                bloom_threshold_values[time] = parameters[key]
            "ssr_max_steps":
                ssr_max_steps_values[time] = parameters[key]
            "ssr_fade_in":
                ssr_fade_in_values[time] = parameters[key]
            "ssr_fade_out":
                ssr_fade_out_values[time] = parameters[key]
            "ssao_radius":
                ssao_radius_values[time] = parameters[key]
            "ssao_intensity":
                ssao_intensity_values[time] = parameters[key]
            "ssao_power":
                ssao_power_values[time] = parameters[key]
            "dof_far_distance":
                dof_far_distance_values[time] = parameters[key]
            "dof_far_transition":
                dof_far_transition_values[time] = parameters[key]
            "dof_blur_amount":
                dof_blur_amount_values[time] = parameters[key]
            "brightness":
                brightness_values[time] = parameters[key]
            "contrast":
                contrast_values[time] = parameters[key]
            "saturation":
                saturation_values[time] = parameters[key]
            "color_temperature":
                color_temperature_values[time] = parameters[key]
            "volumetric_light_intensity":
                volumetric_light_intensity_values[time] = parameters[key]
            "volumetric_light_size":
                volumetric_light_size_values[time] = parameters[key]
    
    # Apply immediately if this is the current time of day
    if time == current_time_string:
        set_time_of_day(time, 0.0)  # Instant transition

func create_custom_time_of_day(name: String, parameters: Dictionary):
    # Add new time of day
    fog_density_values[name] = parameters.get("fog_density", 0.002)
    fog_color_values[name] = parameters.get("fog_color", Color(0.8, 0.8, 0.8, 1.0))
    fog_height_values[name] = parameters.get("fog_height", 5.0)
    
    sky_color_top_values[name] = parameters.get("sky_color_top", Color(0.4, 0.6, 0.8, 1.0))
    sky_color_horizon_values[name] = parameters.get("sky_color_horizon", Color(0.8, 0.8, 0.9, 1.0))
    sky_sun_angle_values[name] = parameters.get("sky_sun_angle", 30.0)
    sky_sun_color_values[name] = parameters.get("sky_sun_color", Color(1.0, 0.9, 0.7, 1.0))
    
    sun_light_energy_values[name] = parameters.get("sun_light_energy", 1.0)
    sun_light_color_values[name] = parameters.get("sun_light_color", Color(1.0, 0.9, 0.8, 1.0))
    sun_light_angle_values[name] = parameters.get("sun_light_angle", Vector2(30.0, 180.0))
    sun_shadow_enabled_values[name] = parameters.get("sun_shadow_enabled", true)
    
    ambient_light_energy_values[name] = parameters.get("ambient_light_energy", 0.3)
    ambient_light_color_values[name] = parameters.get("ambient_light_color", Color(0.8, 0.8, 0.9, 1.0))
    ambient_light_sky_contribution_values[name] = parameters.get("ambient_light_sky_contribution", 0.5)
    
    bloom_intensity_values[name] = parameters.get("bloom_intensity", 0.3)
    bloom_threshold_values[name] = parameters.get("bloom_threshold", 0.8)
    
    ssr_max_steps_values[name] = parameters.get("ssr_max_steps", 32)
    ssr_fade_in_values[name] = parameters.get("ssr_fade_in", 0.15)
    ssr_fade_out_values[name] = parameters.get("ssr_fade_out", 2.0)
    
    ssao_radius_values[name] = parameters.get("ssao_radius", 1.0)
    ssao_intensity_values[name] = parameters.get("ssao_intensity", 1.0)
    ssao_power_values[name] = parameters.get("ssao_power", 1.5)
    
    dof_far_distance_values[name] = parameters.get("dof_far_distance", 100.0)
    dof_far_transition_values[name] = parameters.get("dof_far_transition", 20.0)
    dof_blur_amount_values[name] = parameters.get("dof_blur_amount", 0.05)
    
    brightness_values[name] = parameters.get("brightness", 1.0)
    contrast_values[name] = parameters.get("contrast", 1.0)
    saturation_values[name] = parameters.get("saturation", 1.0)
    color_temperature_values[name] = parameters.get("color_temperature", 6500.0)
    
    volumetric_light_intensity_values[name] = parameters.get("volumetric_light_intensity", 1.0)
    volumetric_light_size_values[name] = parameters.get("volumetric_light_size", 0.1)
