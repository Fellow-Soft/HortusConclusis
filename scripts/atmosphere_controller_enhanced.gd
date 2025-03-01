extends Node3D
class_name AtmosphereControllerEnhanced

# Enhanced atmosphere controller for the Hortus Conclusus cinematic demo
# This script provides more sophisticated atmospheric effects and transitions

# Time of day types
enum TimeOfDay {
	MIDNIGHT,      # Deep night
	DAWN,          # Early morning, pre-sunrise
	SUNRISE,       # Sunrise moment
	MORNING,       # Early to mid-morning
	NOON,          # Midday
	AFTERNOON,     # Mid to late afternoon
	GOLDEN_HOUR,   # Late afternoon, golden light
	SUNSET,        # Sunset moment
	DUSK,          # Early evening, post-sunset
	NIGHT          # Night
}

# Weather types
enum WeatherType {
	CLEAR,         # Clear sky
	PARTLY_CLOUDY, # Partly cloudy
	CLOUDY,        # Overcast
	MISTY,         # Light fog/mist
	FOGGY,         # Heavy fog
	RAINY,         # Rain
	STORMY,        # Thunderstorm
	SNOWY,         # Snow
	ETHEREAL,      # Mystical/ethereal atmosphere
	DIVINE         # Divine/sacred atmosphere
}

# Season types
enum SeasonType {
	SPRING,        # Spring
	SUMMER,        # Summer
	AUTUMN,        # Autumn/Fall
	WINTER,        # Winter
	TIMELESS       # Timeless/eternal
}

# Atmosphere nodes
var directional_light: DirectionalLight3D
var world_environment: WorldEnvironment
var fog_volume: FogVolume
var sky: Sky
var clouds: Node3D
var particles: GPUParticles3D
var audio_player: AudioStreamPlayer

# Atmosphere parameters
var current_time: TimeOfDay = TimeOfDay.DAWN
var current_weather: WeatherType = WeatherType.CLEAR
var current_season: SeasonType = SeasonType.SPRING
var time_cycle_speed: float = 1.0
var time_of_day: float = 0.0  # 0.0 to 1.0 (midnight to midnight)
var sun_angle: float = 0.0
var moon_angle: float = 0.0
var cloud_coverage: float = 0.0
var fog_density: float = 0.0
var wind_strength: float = 0.0
var rain_intensity: float = 0.0
var snow_intensity: float = 0.0
var thunder_probability: float = 0.0
var is_time_cycling: bool = false
var is_weather_transitioning: bool = false
var transition_duration: float = 5.0
var transition_timer: float = 0.0
var target_time: TimeOfDay
var target_weather: WeatherType
var target_season: SeasonType
var celestial_events_enabled: bool = false
var ambient_sounds_enabled: bool = true

# Color parameters
var sky_top_color: Color
var sky_horizon_color: Color
var sun_color: Color
var moon_color: Color
var ambient_light_color: Color
var fog_color: Color
var cloud_color: Color

# Presets for different times of day
const TIME_PRESETS = {
	TimeOfDay.MIDNIGHT: {
		"sun_angle": -45.0,
		"moon_angle": 45.0,
		"sky_top_color": Color(0.05, 0.05, 0.1),
		"sky_horizon_color": Color(0.1, 0.1, 0.2),
		"sun_color": Color(0.0, 0.0, 0.0),
		"moon_color": Color(0.6, 0.7, 0.9, 0.5),
		"ambient_light_color": Color(0.1, 0.1, 0.2),
		"fog_color": Color(0.05, 0.05, 0.1),
		"cloud_color": Color(0.05, 0.05, 0.1)
	},
	TimeOfDay.DAWN: {
		"sun_angle": -10.0,
		"moon_angle": 10.0,
		"sky_top_color": Color(0.2, 0.2, 0.4),
		"sky_horizon_color": Color(0.5, 0.3, 0.4),
		"sun_color": Color(1.0, 0.6, 0.4, 0.7),
		"moon_color": Color(0.6, 0.7, 0.9, 0.3),
		"ambient_light_color": Color(0.3, 0.2, 0.3),
		"fog_color": Color(0.4, 0.3, 0.4),
		"cloud_color": Color(0.5, 0.3, 0.4)
	},
	TimeOfDay.SUNRISE: {
		"sun_angle": -5.0,
		"moon_angle": 5.0,
		"sky_top_color": Color(0.3, 0.4, 0.7),
		"sky_horizon_color": Color(0.9, 0.6, 0.4),
		"sun_color": Color(1.0, 0.7, 0.4, 1.0),
		"moon_color": Color(0.6, 0.7, 0.9, 0.1),
		"ambient_light_color": Color(0.7, 0.5, 0.3),
		"fog_color": Color(0.8, 0.6, 0.4),
		"cloud_color": Color(0.9, 0.7, 0.5)
	},
	TimeOfDay.MORNING: {
		"sun_angle": 15.0,
		"moon_angle": -15.0,
		"sky_top_color": Color(0.4, 0.6, 0.9),
		"sky_horizon_color": Color(0.7, 0.8, 0.9),
		"sun_color": Color(1.0, 0.9, 0.7, 1.0),
		"moon_color": Color(0.0, 0.0, 0.0),
		"ambient_light_color": Color(0.7, 0.7, 0.8),
		"fog_color": Color(0.8, 0.9, 1.0),
		"cloud_color": Color(1.0, 1.0, 1.0)
	},
	TimeOfDay.NOON: {
		"sun_angle": 45.0,
		"moon_angle": -45.0,
		"sky_top_color": Color(0.3, 0.5, 0.95),
		"sky_horizon_color": Color(0.6, 0.8, 0.95),
		"sun_color": Color(1.0, 0.98, 0.9, 1.0),
		"moon_color": Color(0.0, 0.0, 0.0),
		"ambient_light_color": Color(0.9, 0.9, 0.9),
		"fog_color": Color(0.8, 0.9, 1.0),
		"cloud_color": Color(1.0, 1.0, 1.0)
	},
	TimeOfDay.AFTERNOON: {
		"sun_angle": 30.0,
		"moon_angle": -30.0,
		"sky_top_color": Color(0.3, 0.5, 0.9),
		"sky_horizon_color": Color(0.6, 0.8, 0.9),
		"sun_color": Color(1.0, 0.95, 0.8, 1.0),
		"moon_color": Color(0.0, 0.0, 0.0),
		"ambient_light_color": Color(0.8, 0.8, 0.7),
		"fog_color": Color(0.7, 0.8, 0.9),
		"cloud_color": Color(0.9, 0.9, 0.9)
	},
	TimeOfDay.GOLDEN_HOUR: {
		"sun_angle": 10.0,
		"moon_angle": -10.0,
		"sky_top_color": Color(0.4, 0.5, 0.8),
		"sky_horizon_color": Color(0.9, 0.7, 0.4),
		"sun_color": Color(1.0, 0.8, 0.4, 1.0),
		"moon_color": Color(0.0, 0.0, 0.0),
		"ambient_light_color": Color(0.8, 0.6, 0.3),
		"fog_color": Color(0.8, 0.7, 0.5),
		"cloud_color": Color(0.9, 0.7, 0.5)
	},
	TimeOfDay.SUNSET: {
		"sun_angle": 5.0,
		"moon_angle": -5.0,
		"sky_top_color": Color(0.3, 0.3, 0.6),
		"sky_horizon_color": Color(0.9, 0.5, 0.3),
		"sun_color": Color(1.0, 0.6, 0.3, 1.0),
		"moon_color": Color(0.6, 0.7, 0.9, 0.1),
		"ambient_light_color": Color(0.7, 0.4, 0.3),
		"fog_color": Color(0.7, 0.5, 0.4),
		"cloud_color": Color(0.8, 0.5, 0.4)
	},
	TimeOfDay.DUSK: {
		"sun_angle": -5.0,
		"moon_angle": 5.0,
		"sky_top_color": Color(0.2, 0.2, 0.4),
		"sky_horizon_color": Color(0.5, 0.3, 0.4),
		"sun_color": Color(0.8, 0.4, 0.3, 0.5),
		"moon_color": Color(0.6, 0.7, 0.9, 0.5),
		"ambient_light_color": Color(0.4, 0.3, 0.4),
		"fog_color": Color(0.4, 0.3, 0.4),
		"cloud_color": Color(0.4, 0.3, 0.4)
	},
	TimeOfDay.NIGHT: {
		"sun_angle": -30.0,
		"moon_angle": 30.0,
		"sky_top_color": Color(0.05, 0.05, 0.15),
		"sky_horizon_color": Color(0.1, 0.1, 0.2),
		"sun_color": Color(0.0, 0.0, 0.0),
		"moon_color": Color(0.7, 0.8, 1.0, 0.8),
		"ambient_light_color": Color(0.15, 0.15, 0.25),
		"fog_color": Color(0.1, 0.1, 0.2),
		"cloud_color": Color(0.1, 0.1, 0.2)
	}
}

# Presets for different weather types
const WEATHER_PRESETS = {
	WeatherType.CLEAR: {
		"cloud_coverage": 0.0,
		"fog_density": 0.0,
		"wind_strength": 0.1,
		"rain_intensity": 0.0,
		"snow_intensity": 0.0,
		"thunder_probability": 0.0
	},
	WeatherType.PARTLY_CLOUDY: {
		"cloud_coverage": 0.3,
		"fog_density": 0.0,
		"wind_strength": 0.3,
		"rain_intensity": 0.0,
		"snow_intensity": 0.0,
		"thunder_probability": 0.0
	},
	WeatherType.CLOUDY: {
		"cloud_coverage": 0.8,
		"fog_density": 0.1,
		"wind_strength": 0.5,
		"rain_intensity": 0.0,
		"snow_intensity": 0.0,
		"thunder_probability": 0.0
	},
	WeatherType.MISTY: {
		"cloud_coverage": 0.3,
		"fog_density": 0.4,
		"wind_strength": 0.1,
		"rain_intensity": 0.0,
		"snow_intensity": 0.0,
		"thunder_probability": 0.0
	},
	WeatherType.FOGGY: {
		"cloud_coverage": 0.5,
		"fog_density": 0.8,
		"wind_strength": 0.0,
		"rain_intensity": 0.0,
		"snow_intensity": 0.0,
		"thunder_probability": 0.0
	},
	WeatherType.RAINY: {
		"cloud_coverage": 0.9,
		"fog_density": 0.3,
		"wind_strength": 0.6,
		"rain_intensity": 0.7,
		"snow_intensity": 0.0,
		"thunder_probability": 0.1
	},
	WeatherType.STORMY: {
		"cloud_coverage": 1.0,
		"fog_density": 0.4,
		"wind_strength": 0.9,
		"rain_intensity": 1.0,
		"snow_intensity": 0.0,
		"thunder_probability": 0.8
	},
	WeatherType.SNOWY: {
		"cloud_coverage": 0.8,
		"fog_density": 0.5,
		"wind_strength": 0.4,
		"rain_intensity": 0.0,
		"snow_intensity": 0.7,
		"thunder_probability": 0.0
	},
	WeatherType.ETHEREAL: {
		"cloud_coverage": 0.2,
		"fog_density": 0.6,
		"wind_strength": 0.2,
		"rain_intensity": 0.0,
		"snow_intensity": 0.0,
		"thunder_probability": 0.0
	},
	WeatherType.DIVINE: {
		"cloud_coverage": 0.4,
		"fog_density": 0.3,
		"wind_strength": 0.3,
		"rain_intensity": 0.0,
		"snow_intensity": 0.0,
		"thunder_probability": 0.0
	}
}

# Presets for different seasons
const SEASON_PRESETS = {
	SeasonType.SPRING: {
		"ambient_light_color_modifier": Color(1.0, 1.0, 1.0),
		"fog_color_modifier": Color(1.0, 1.0, 1.0),
		"cloud_color_modifier": Color(1.0, 1.0, 1.0)
	},
	SeasonType.SUMMER: {
		"ambient_light_color_modifier": Color(1.1, 1.0, 0.9),
		"fog_color_modifier": Color(1.0, 1.0, 0.9),
		"cloud_color_modifier": Color(1.0, 1.0, 0.9)
	},
	SeasonType.AUTUMN: {
		"ambient_light_color_modifier": Color(1.1, 0.9, 0.8),
		"fog_color_modifier": Color(1.0, 0.9, 0.8),
		"cloud_color_modifier": Color(1.0, 0.9, 0.8)
	},
	SeasonType.WINTER: {
		"ambient_light_color_modifier": Color(0.9, 0.95, 1.1),
		"fog_color_modifier": Color(0.9, 0.95, 1.1),
		"cloud_color_modifier": Color(0.9, 0.95, 1.1)
	},
	SeasonType.TIMELESS: {
		"ambient_light_color_modifier": Color(1.0, 1.0, 1.0),
		"fog_color_modifier": Color(1.0, 1.0, 1.0),
		"cloud_color_modifier": Color(1.0, 1.0, 1.0)
	}
}

# Signals
signal time_changed(time_of_day)
signal weather_changed(weather_type)
signal season_changed(season_type)
signal celestial_event_started(event_name)
signal celestial_event_ended(event_name)
signal day_night_cycle_completed

# Called when the node enters the scene tree for the first time
func _ready():
	# Find atmosphere nodes
	directional_light = get_node_or_null("DirectionalLight3D")
	world_environment = get_node_or_null("WorldEnvironment")
	fog_volume = get_node_or_null("FogVolume")
	
	# Create nodes if they don't exist
	if not directional_light:
		directional_light = DirectionalLight3D.new()
		directional_light.name = "DirectionalLight3D"
		add_child(directional_light)
	
	if not world_environment:
		world_environment = WorldEnvironment.new()
		world_environment.name = "WorldEnvironment"
		world_environment.environment = Environment.new()
		add_child(world_environment)
	
	if not fog_volume:
		fog_volume = FogVolume.new()
		fog_volume.name = "FogVolume"
		add_child(fog_volume)
	
	# Create sky if it doesn't exist
	if not sky:
		sky = Sky.new()
		world_environment.environment.sky = sky
	
	# Create clouds if they don't exist
	if not clouds:
		clouds = Node3D.new()
		clouds.name = "Clouds"
		add_child(clouds)
		_create_clouds()
	
	# Create particles if they don't exist
	if not particles:
		particles = GPUParticles3D.new()
		particles.name = "WeatherParticles"
		add_child(particles)
	
	# Create audio player if it doesn't exist
	if not audio_player:
		audio_player = AudioStreamPlayer.new()
		audio_player.name = "AtmosphereAudio"
		add_child(audio_player)
	
	# Set initial atmosphere
	set_time_of_day(TimeOfDay.DAWN)
	set_weather(WeatherType.CLEAR)
	set_season(SeasonType.SPRING)

# Process function for continuous updates
func _process(delta):
	# Update time cycle
	if is_time_cycling:
		_update_time_cycle(delta)
	
	# Update weather transition
	if is_weather_transitioning:
		_update_weather_transition(delta)
	
	# Update celestial events
	if celestial_events_enabled:
		_update_celestial_events(delta)

# Set time of day
func set_time_of_day(time: TimeOfDay):
	current_time = time
	
	# Apply time preset
	var preset = TIME_PRESETS[time]
	sun_angle = preset.sun_angle
	moon_angle = preset.moon_angle
	sky_top_color = preset.sky_top_color
	sky_horizon_color = preset.sky_horizon_color
	sun_color = preset.sun_color
	moon_color = preset.moon_color
	ambient_light_color = preset.ambient_light_color
	fog_color = preset.fog_color
	cloud_color = preset.cloud_color
	
	# Apply time of day settings
	_apply_time_of_day()
	
	# Emit signal
	emit_signal("time_changed", time)

# Set weather type
func set_weather(weather: WeatherType):
	# If transitioning, stop current transition
	if is_weather_transitioning:
		is_weather_transitioning = false
	
	current_weather = weather
	
	# Apply weather preset
	var preset = WEATHER_PRESETS[weather]
	cloud_coverage = preset.cloud_coverage
	fog_density = preset.fog_density
	wind_strength = preset.wind_strength
	rain_intensity = preset.rain_intensity
	snow_intensity = preset.snow_intensity
	thunder_probability = preset.thunder_probability
	
	# Apply weather settings
	_apply_weather()
	
	# Emit signal
	emit_signal("weather_changed", weather)

# Set season
func set_season(season: SeasonType):
	current_season = season
	
	# Apply season settings
	_apply_season()
	
	# Emit signal
	emit_signal("season_changed", season)

# Start time cycle
func start_time_cycle(speed: float = 1.0):
	time_cycle_speed = speed
	is_time_cycling = true
	time_of_day = _time_enum_to_float(current_time)

# Stop time cycle
func stop_time_cycle():
	is_time_cycling = false

# Transition to weather
func transition_to_weather(weather: WeatherType, duration: float = 5.0):
	target_weather = weather
	transition_duration = duration
	transition_timer = 0.0
	is_weather_transitioning = true

# Enable celestial events
func enable_celestial_events(enabled: bool = true):
	celestial_events_enabled = enabled

# Enable ambient sounds
func enable_ambient_sounds(enabled: bool = true):
	ambient_sounds_enabled = enabled
	
	if not enabled and audio_player.playing:
		audio_player.stop()

# Create a day-night cycle animation
func create_day_night_cycle_animation(duration: float = 120.0):
	# Create animation
	var animation = Animation.new()
	animation.length = duration
	animation.loop_mode = Animation.LOOP_NONE
	
	# Add track for time of day
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ".:time_of_day")
	
	# Add keyframes for full day cycle
	animation.track_insert_key(track_index, 0.0, 0.0)  # Midnight
	animation.track_insert_key(track_index, duration * 0.25, 0.25)  # Dawn/Morning
	animation.track_insert_key(track_index, duration * 0.5, 0.5)  # Noon
	animation.track_insert_key(track_index, duration * 0.75, 0.75)  # Dusk/Evening
	animation.track_insert_key(track_index, duration, 1.0)  # Midnight again
	
	# Create animation player if it doesn't exist
	var animation_player = get_node_or_null("AnimationPlayer")
	if not animation_player:
		animation_player = AnimationPlayer.new()
		animation_player.name = "AnimationPlayer"
		add_child(animation_player)
	
	# Add animation to player
	animation_player.add_animation("day_night_cycle", animation)
	
	# Connect to animation finished signal
	if not animation_player.is_connected("animation_finished", Callable(self, "_on_day_night_cycle_completed")):
		animation_player.connect("animation_finished", Callable(self, "_on_day_night_cycle_completed"))
	
	return animation_player

# Play day-night cycle animation
func play_day_night_cycle_animation():
	var animation_player = get_node_or_null("AnimationPlayer")
	if animation_player and animation_player.has_animation("day_night_cycle"):
		animation_player.play("day_night_cycle")
		return true
	
	return false

# Create a weather sequence
func create_weather_sequence(weather_sequence: Array, duration: float = 120.0):
	if weather_sequence.size() < 2:
		return false
	
	# Calculate timing
	var segment_duration = duration / (weather_sequence.size() - 1)
	
	# Schedule weather transitions
	for i in range(1, weather_sequence.size()):
		var delay = segment_duration * (i - 1)
		var transition_duration = segment_duration * 0.5
		
		var timer = Timer.new()
		timer.wait_time = delay
		timer.one_shot = true
		timer.connect("timeout", Callable(self, "transition_to_weather").bind(weather_sequence[i], transition_duration))
		add_child(timer)
		timer.start()
	
	# Set initial weather
	set_weather(weather_sequence[0])
	
	return true

# Create a celestial event
func create_celestial_event(event_name: String, duration: float = 10.0):
	match event_name:
		"shooting_stars":
			_create_shooting_stars_event(duration)
		"northern_lights":
			_create_northern_lights_event(duration)
		"divine_light":
			_create_divine_light_event(duration)
		"moonbow":
			_create_moonbow_event(duration)
		"eclipse":
			_create_eclipse_event(duration)
		_:
			return false
	
	return true

# Apply time of day settings
func _apply_time_of_day():
	if not directional_light or not world_environment:
		return
	
	# Set sun direction
	directional_light.rotation_degrees.x = sun_angle
	
	# Set sun color and energy
	directional_light.light_color = sun_color
	directional_light.light_energy = sun_color.a * 2.0
	
	# Set sky colors
	if world_environment.environment.sky:
		world_environment.environment.sky_top_color = sky_top_color
		world_environment.environment.sky_horizon_color = sky_horizon_color
	
	# Set ambient light
	world_environment.environment.ambient_light_color = ambient_light_color
	world_environment.environment.ambient_light_energy = 1.0
	
	# Set fog color
	if fog_volume:
		fog_volume.material.albedo = fog_color
	
	# Update cloud color
	_update_cloud_color()

# Apply weather settings
func _apply_weather():
	if not world_environment:
		return
	
	# Set fog density
	world_environment.environment.fog_enabled = fog_density > 0.0
	world_environment.environment.fog_density = fog_density * 0.01
	
	if fog_volume:
		fog_volume.material.density = fog_density
	
	# Update clouds
	_update_clouds()
	
	# Update weather particles
	_update_weather_particles()
	
	# Update ambient sounds
	if ambient_sounds_enabled:
		_update_ambient_sounds()

# Apply season settings
func _apply_season():
	var preset = SEASON_PRESETS[current_season]
	
	# Apply color modifiers
	if directional_light:
		directional_light.light_color = sun_color * preset.ambient_light_color_modifier
	
	if world_environment:
		world_environment.environment.ambient_light_color = ambient_light_color * preset.ambient_light_color_modifier
	
	if fog_volume:
		fog_volume.material.albedo = fog_color * preset.fog_color_modifier
	
	# Update cloud color with season modifier
	_update_cloud_color(preset.cloud_color_modifier)

# Update time cycle
func _update_time_cycle(delta):
	# Update time of day
	time_of_day += delta * time_cycle_speed * 0.01
	
	# Wrap around
	if time_of_day >= 1.0:
		time_of_day = 0.0
		emit_signal("day_night_cycle_completed")
	
	# Convert to time enum
	var new_time = _float_to_time_enum(time_of_day)
	
	# If time changed, update
	if new_time != current_time:
		set_time_of_day(new_time)
	else:
		# Interpolate between time presets
		_interpolate_time_of_day()

# Update weather transition
func _update_weather_transition(delta):
	# Update transition timer
	transition_timer += delta
	
	# Calculate progress
	var progress = min(transition_timer / transition_duration, 1.0)
	
	# Interpolate weather parameters
	var current_preset = WEATHER_PRESETS[current_weather]
	var target_preset = WEATHER_PRESETS[target_weather]
	
	cloud_coverage = lerp(current_preset.cloud_coverage, target_preset.cloud_coverage, progress)
	fog_density = lerp(current_preset.fog_density, target_preset.fog_density, progress)
	wind_strength = lerp(current_preset.wind_strength, target_preset.wind_strength, progress)
	rain_intensity = lerp(current_preset.rain_intensity, target_preset.rain_intensity, progress)
	snow_intensity = lerp(current_preset.snow_intensity, target_preset.snow_intensity, progress)
	thunder_probability = lerp(current_preset.thunder_probability, target_preset.thunder_probability, progress)
	
	# Apply interpolated weather
	_apply_weather()
	
	# Check if transition is complete
	if progress >= 1.0:
		current_weather = target_weather
		is_weather_transitioning = false
		emit_signal("weather_changed", current_weather)

# Update celestial events
func _update_celestial_events(delta):
	# Check for random celestial events
	if randf() < 0.0001 * delta:
		var events = ["shooting_stars", "northern_lights", "moonbow"]
		var event = events[randi() % events.size()]
		create_celestial_event(event, 10.0)

# Create clouds
func _create_clouds():
	# Create cloud particles
	var cloud_particles = GPUParticles3D.new()
	cloud_particles.name = "CloudParticles"
	clouds.add_child(cloud_particles)
	
	# Create cloud material
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(100, 10, 100)
	material.gravity = Vector3(0, 0, 0)
	material.initial_velocity_min = 0.1
	material.initial_velocity_max = 0.5
	material.angular_velocity_min = 0.0
	material.angular_velocity_max = 0.1
	material.linear_accel_min = 0.0
	material.linear_accel_max = 0.0
	material.radial_accel_min = 0.0
	material.radial_accel_max = 0.0
	material.tangential_accel_min = 0.0
	material.tangential_accel_max = 0.0
	material.damping_min = 0.0
	material.damping_max = 0.0
	material.angle_min = 0.0
	material.angle_max = 360.0
	material.scale_min = 10.0
	material.scale_max = 20.0
	material.color = Color(1, 1, 1)
	material.color_ramp = Gradient.new()
	
	cloud_particles.process_material = material
	
	# Create
