extends Node
class_name AtmosphereController

# Signals
signal time_changed(time_of_day)
signal weather_changed(weather_type)

# Time of day constants
enum TimeOfDay {
	DAWN,
	MORNING,
	NOON,
	AFTERNOON,
	GOLDEN_HOUR,
	DUSK,
	NIGHT,
	MIDNIGHT
}

# Weather constants
enum WeatherType {
	CLEAR,
	CLOUDY,
	MISTY,
	LIGHT_RAIN,
	HEAVY_RAIN,
	STORMY
}

# Current time and weather
var current_time: TimeOfDay = TimeOfDay.NOON
var current_weather: WeatherType = WeatherType.CLEAR

# Time cycle parameters
var day_cycle_enabled: bool = true
var day_cycle_speed: float = 0.1  # Full day cycle in minutes (lower = faster)
var time_progress: float = 0.5  # 0.0 to 1.0 (0 = midnight, 0.5 = noon)

# Environment resources
var environment: Environment
var world_environment: WorldEnvironment

# Light resources
var directional_light: DirectionalLight3D
var ambient_light: OmniLight3D

# Weather effect nodes
var mist_particles: GPUParticles3D
var rain_particles: GPUParticles3D
var cloud_mesh: MeshInstance3D

# Sound resources
var ambient_audio_player: AudioStreamPlayer
var weather_audio_player: AudioStreamPlayer
var ambient_sounds = {}
var weather_sounds = {}

# Medieval bell timer
var bell_timer: Timer
var bell_audio_player: AudioStreamPlayer
var bell_sounds = []

# Random number generator
var rng = RandomNumberGenerator.new()

func _init():
	rng.randomize()

func _ready():
	# Create environment
	_setup_environment()
	
	# Create lights
	_setup_lights()
	
	# Create weather effects
	_setup_weather_effects()
	
	# Create audio players
	_setup_audio()
	
	# Create bell timer
	_setup_bell_timer()
	
	# Set initial time and weather
	set_time_of_day(current_time)
	set_weather(current_weather)

func _process(delta):
	if day_cycle_enabled:
		# Update time progress
		time_progress += delta * (0.01 / day_cycle_speed)
		if time_progress >= 1.0:
			time_progress -= 1.0
		
		# Update time of day based on progress
		_update_time_from_progress()
		
		# Update environment based on time
		_update_environment_for_time()

# Setup the environment
func _setup_environment():
	# Create world environment
	world_environment = WorldEnvironment.new()
	environment = Environment.new()
	
	# Sky settings
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.sky.sky_material = ProceduralSkyMaterial.new()
	
	# Ambient light settings
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_color = Color(0.6, 0.7, 0.9)
	environment.ambient_light_energy = 0.5
	
	# Fog settings
	environment.fog_enabled = true
	environment.fog_density = 0.001
	environment.fog_aerial_perspective = 0.5
	environment.fog_sky_affect = 0.5
	
	# Glow settings
	environment.glow_enabled = true
	environment.glow_intensity = 0.2
	environment.glow_bloom = 0.2
	
	# Assign environment
	world_environment.environment = environment
	add_child(world_environment)

# Setup the lights
func _setup_lights():
	# Create directional light (sun/moon)
	directional_light = DirectionalLight3D.new()
	directional_light.shadow_enabled = true
	directional_light.light_color = Color(1.0, 0.95, 0.8)  # Warm sunlight
	directional_light.light_energy = 1.2
	add_child(directional_light)
	
	# Create ambient light (for night/indoor areas)
	ambient_light = OmniLight3D.new()
	ambient_light.light_color = Color(0.2, 0.3, 0.5)  # Blue-ish moonlight
	ambient_light.light_energy = 0.0  # Off during day
	ambient_light.omni_range = 50.0
	add_child(ambient_light)

# Setup weather effects
func _setup_weather_effects():
	# Create mist particles
	mist_particles = GPUParticles3D.new()
	mist_particles.name = "MistParticles"
	mist_particles.emitting = false
	mist_particles.amount = 100
	mist_particles.lifetime = 10.0
	mist_particles.visibility_aabb = AABB(Vector3(-25, 0, -25), Vector3(50, 10, 50))
	
	var mist_material = ParticleProcessMaterial.new()
	mist_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mist_material.emission_box_extents = Vector3(25, 1, 25)
	mist_material.gravity = Vector3(0, 0.05, 0)
	mist_material.color = Color(0.9, 0.9, 0.9, 0.2)
	mist_particles.process_material = mist_material
	
	var mist_mesh = QuadMesh.new()
	mist_mesh.size = Vector2(2, 2)
	
	var mist_shader_material = ShaderMaterial.new()
	mist_shader_material.shader = _create_mist_shader()
	mist_mesh.material = mist_shader_material
	
	mist_particles.draw_pass_1 = mist_mesh
	add_child(mist_particles)
	
	# Create rain particles
	rain_particles = GPUParticles3D.new()
	rain_particles.name = "RainParticles"
	rain_particles.emitting = false
	rain_particles.amount = 1000
	rain_particles.lifetime = 2.0
	rain_particles.visibility_aabb = AABB(Vector3(-25, 0, -25), Vector3(50, 20, 50))
	
	var rain_material = ParticleProcessMaterial.new()
	rain_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	rain_material.emission_box_extents = Vector3(25, 0.1, 25)
	rain_material.direction = Vector3(0, -1, 0)
	rain_material.spread = 5.0
	rain_material.gravity = Vector3(0, -9.8, 0)
	rain_material.initial_velocity_min = 10.0
	rain_material.initial_velocity_max = 15.0
	rain_material.color = Color(0.7, 0.7, 0.9, 0.5)
	rain_particles.process_material = rain_material
	
	var rain_mesh = QuadMesh.new()
	rain_mesh.size = Vector2(0.05, 0.5)
	
	var rain_shader_material = ShaderMaterial.new()
	rain_shader_material.shader = _create_rain_shader()
	rain_mesh.material = rain_shader_material
	
	rain_particles.draw_pass_1 = rain_mesh
	add_child(rain_particles)
	
	# Create cloud mesh
	cloud_mesh = MeshInstance3D.new()
	cloud_mesh.name = "CloudMesh"
	cloud_mesh.visible = false
	
	var cloud_plane = PlaneMesh.new()
	cloud_plane.size = Vector2(100, 100)
	cloud_plane.subdivide_width = 10
	cloud_plane.subdivide_depth = 10
	
	var cloud_shader_material = ShaderMaterial.new()
	cloud_shader_material.shader = _create_cloud_shader()
	cloud_plane.material = cloud_shader_material
	
	cloud_mesh.mesh = cloud_plane
	cloud_mesh.position = Vector3(0, 20, 0)
	cloud_mesh.rotation = Vector3(PI/2, 0, 0)
	add_child(cloud_mesh)

# Setup audio
func _setup_audio():
	# Create ambient audio player
	ambient_audio_player = AudioStreamPlayer.new()
	ambient_audio_player.name = "AmbientAudioPlayer"
	ambient_audio_player.volume_db = -10.0
	add_child(ambient_audio_player)
	
	# Create weather audio player
	weather_audio_player = AudioStreamPlayer.new()
	weather_audio_player.name = "WeatherAudioPlayer"
	weather_audio_player.volume_db = -15.0
	add_child(weather_audio_player)
	
	# Create bell audio player
	bell_audio_player = AudioStreamPlayer.new()
	bell_audio_player.name = "BellAudioPlayer"
	bell_audio_player.volume_db = -5.0
	add_child(bell_audio_player)
	
	# Load ambient sounds (these would be actual files in a real project)
	ambient_sounds[TimeOfDay.DAWN] = _create_procedural_ambient_sound("dawn")
	ambient_sounds[TimeOfDay.MORNING] = _create_procedural_ambient_sound("morning")
	ambient_sounds[TimeOfDay.NOON] = _create_procedural_ambient_sound("noon")
	ambient_sounds[TimeOfDay.AFTERNOON] = _create_procedural_ambient_sound("afternoon")
	ambient_sounds[TimeOfDay.GOLDEN_HOUR] = _create_procedural_ambient_sound("golden_hour")
	ambient_sounds[TimeOfDay.DUSK] = _create_procedural_ambient_sound("dusk")
	ambient_sounds[TimeOfDay.NIGHT] = _create_procedural_ambient_sound("night")
	ambient_sounds[TimeOfDay.MIDNIGHT] = _create_procedural_ambient_sound("midnight")
	
	# Load weather sounds
	weather_sounds[WeatherType.CLEAR] = null  # No sound for clear weather
	weather_sounds[WeatherType.CLOUDY] = null  # No sound for cloudy weather
	weather_sounds[WeatherType.MISTY] = _create_procedural_ambient_sound("mist")
	weather_sounds[WeatherType.LIGHT_RAIN] = _create_procedural_ambient_sound("light_rain")
	weather_sounds[WeatherType.HEAVY_RAIN] = _create_procedural_ambient_sound("heavy_rain")
	weather_sounds[WeatherType.STORMY] = _create_procedural_ambient_sound("storm")
	
	# Load bell sounds
	for i in range(3):
		bell_sounds.append(_create_procedural_bell_sound(i))

# Setup bell timer
func _setup_bell_timer():
	bell_timer = Timer.new()
	bell_timer.name = "BellTimer"
	bell_timer.wait_time = 3600.0  # 1 hour
	bell_timer.autostart = true
	bell_timer.timeout.connect(_on_bell_timer_timeout)
	add_child(bell_timer)

# Create a mist shader
func _create_mist_shader() -> Shader:
	var shader = Shader.new()
	
	shader.code = """
	shader_type spatial;
	render_mode blend_add, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx, unshaded;
	
	uniform sampler2D depth_texture : hint_depth_texture;
	
	void fragment() {
		float depth = texture(depth_texture, SCREEN_UV).r;
		vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
		vec4 world = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
		world.xyz /= world.w;
		
		float dist = length(world.xyz - CAMERA_POSITION_WORLD);
		float fog_factor = 1.0 - exp(-dist * 0.05);
		
		ALBEDO = vec3(0.9, 0.9, 0.9);
		ALPHA = 0.2 * fog_factor * (1.0 - UV.y);
	}
	"""
	
	return shader

# Create a rain shader
func _create_rain_shader() -> Shader:
	var shader = Shader.new()
	
	shader.code = """
	shader_type spatial;
	render_mode blend_add, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx, unshaded;
	
	void fragment() {
		ALBEDO = vec3(0.7, 0.7, 0.9);
		ALPHA = 0.7 * (1.0 - UV.y);
	}
	"""
	
	return shader

# Create a cloud shader
func _create_cloud_shader() -> Shader:
	var shader = Shader.new()
	
	shader.code = """
	shader_type spatial;
	render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;
	
	uniform float time_scale = 0.1;
	uniform float cloud_density = 0.5;
	uniform vec3 cloud_color: source_color = vec3(0.9, 0.9, 0.9);
	uniform sampler2D screen_texture : hint_screen_texture;
	
	float noise(vec3 p) {
		vec3 i = floor(p);
		vec3 f = fract(p);
		f = f * f * (3.0 - 2.0 * f);
		
		vec2 uv = (i.xy + vec2(37.0, 17.0) * i.z) + f.xy;
		vec2 rg = texture(screen_texture, (uv + 0.5) / 256.0).yx;
		return mix(rg.x, rg.y, f.z);
	}
	
	float fbm(vec3 p) {
		float f = 0.0;
		f += 0.5000 * noise(p); p *= 2.01;
		f += 0.2500 * noise(p); p *= 2.02;
		f += 0.1250 * noise(p); p *= 2.03;
		f += 0.0625 * noise(p);
		return f;
	}
	
	void fragment() {
		vec3 p = vec3(UV * 10.0, TIME * time_scale);
		float clouds = fbm(p);
		clouds = smoothstep(0.3, 0.7, clouds);
		
		ALBEDO = cloud_color;
		ALPHA = clouds * cloud_density;
	}
	"""
	
	return shader

# Create a procedural ambient sound
func _create_procedural_ambient_sound(type: String) -> AudioStream:
	# In a real project, you would load actual audio files here
	# For this example, we'll create a simple procedural audio stream
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 44100
	stream.buffer_length = 0.5
	
	return stream

# Create a procedural bell sound
func _create_procedural_bell_sound(index: int) -> AudioStream:
	# In a real project, you would load actual audio files here
	# For this example, we'll create a simple procedural audio stream
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 44100
	stream.buffer_length = 0.5
	
	return stream

# Set the time of day
func set_time_of_day(time: TimeOfDay):
	current_time = time
	
	# Update environment based on time
	_update_environment_for_time()
	
	# Update ambient sound
	_update_ambient_sound()
	
	# Emit signal
	emit_signal("time_changed", current_time)

# Set the weather
func set_weather(weather: WeatherType):
	current_weather = weather
	
	# Update environment based on weather
	_update_environment_for_weather()
	
	# Update weather sound
	_update_weather_sound()
	
	# Emit signal
	emit_signal("weather_changed", current_weather)

# Update time of day based on progress
func _update_time_from_progress():
	var old_time = current_time
	
	if time_progress < 0.125:
		current_time = TimeOfDay.MIDNIGHT
	elif time_progress < 0.25:
		current_time = TimeOfDay.NIGHT
	elif time_progress < 0.3125:
		current_time = TimeOfDay.DAWN
	elif time_progress < 0.4375:
		current_time = TimeOfDay.MORNING
	elif time_progress < 0.5625:
		current_time = TimeOfDay.NOON
	elif time_progress < 0.6875:
		current_time = TimeOfDay.AFTERNOON
	elif time_progress < 0.75:
		current_time = TimeOfDay.GOLDEN_HOUR
	elif time_progress < 0.8125:
		current_time = TimeOfDay.DUSK
	else:
		current_time = TimeOfDay.NIGHT
	
	# If time changed, update ambient sound and emit signal
	if old_time != current_time:
		_update_ambient_sound()
		emit_signal("time_changed", current_time)

# Update environment based on time of day
func _update_environment_for_time():
	var sky_material = environment.sky.sky_material
	
	# Calculate sun position based on time progress
	var sun_angle = time_progress * 2.0 * PI
	var sun_height = sin(sun_angle)
	var sun_direction = Vector3(cos(sun_angle), sun_height, 0.0).normalized()
	
	# Update directional light
	directional_light.rotation = Vector3(
		-asin(sun_direction.y),
		atan2(sun_direction.x, sun_direction.z),
		0
	)
	
	# Update light color and energy based on time of day
	match current_time:
		TimeOfDay.DAWN:
			directional_light.light_color = Color(1.0, 0.8, 0.6)  # Orange-ish sunrise
			directional_light.light_energy = 0.8
			sky_material.sky_top_color = Color(0.5, 0.7, 1.0)
			sky_material.sky_horizon_color = Color(1.0, 0.7, 0.5)
			sky_material.ground_horizon_color = Color(0.7, 0.5, 0.3)
			sky_material.ground_bottom_color = Color(0.3, 0.2, 0.1)
			environment.ambient_light_color = Color(0.7, 0.6, 0.5)
			environment.ambient_light_energy = 0.3
			ambient_light.light_energy = 0.0
		
		TimeOfDay.MORNING:
			directional_light.light_color = Color(1.0, 0.95, 0.8)  # Warm morning light
			directional_light.light_energy = 1.0
			sky_material.sky_top_color = Color(0.3, 0.6, 1.0)
			sky_material.sky_horizon_color = Color(0.7, 0.8, 1.0)
			sky_material.ground_horizon_color = Color(0.5, 0.7, 0.5)
			sky_material.ground_bottom_color = Color(0.3, 0.4, 0.3)
			environment.ambient_light_color = Color(0.8, 0.8, 0.9)
			environment.ambient_light_energy = 0.4
			ambient_light.light_energy = 0.0
		
		TimeOfDay.NOON:
			directional_light.light_color = Color(1.0, 1.0, 0.95)  # Bright midday sun
			directional_light.light_energy = 1.2
			sky_material.sky_top_color = Color(0.1, 0.4, 0.8)
			sky_material.sky_horizon_color = Color(0.5, 0.7, 0.9)
			sky_material.ground_horizon_color = Color(0.5, 0.7, 0.5)
			sky_material.ground_bottom_color = Color(0.3, 0.4, 0.3)
			environment.ambient_light_color = Color(0.9, 0.9, 0.9)
			environment.ambient_light_energy = 0.5
			ambient_light.light_energy = 0.0
		
		TimeOfDay.AFTERNOON:
			directional_light.light_color = Color(1.0, 0.98, 0.9)  # Slightly warm afternoon
			directional_light.light_energy = 1.1
			sky_material.sky_top_color = Color(0.2, 0.5, 0.9)
			sky_material.sky_horizon_color = Color(0.6, 0.8, 1.0)
			sky_material.ground_horizon_color = Color(0.5, 0.7, 0.5)
			sky_material.ground_bottom_color = Color(0.3, 0.4, 0.3)
			environment.ambient_light_color = Color(0.9, 0.9, 0.8)
			environment.ambient_light_energy = 0.45
			ambient_light.light_energy = 0.0
		
		TimeOfDay.GOLDEN_HOUR:
			directional_light.light_color = Color(1.0, 0.7, 0.3)  # Golden sunset
			directional_light.light_energy = 0.9
			sky_material.sky_top_color = Color(0.4, 0.6, 0.9)
			sky_material.sky_horizon_color = Color(1.0, 0.6, 0.3)
			sky_material.ground_horizon_color = Color(0.8, 0.5, 0.3)
			sky_material.ground_bottom_color = Color(0.4, 0.3, 0.2)
			environment.ambient_light_color = Color(0.9, 0.7, 0.5)
			environment.ambient_light_energy = 0.4
			ambient_light.light_energy = 0.0
		
		TimeOfDay.DUSK:
			directional_light.light_color = Color(0.8, 0.5, 0.4)  # Reddish dusk
			directional_light.light_energy = 0.5
			sky_material.sky_top_color = Color(0.2, 0.2, 0.5)
			sky_material.sky_horizon_color = Color(0.8, 0.4, 0.3)
			sky_material.ground_horizon_color = Color(0.5, 0.3, 0.2)
			sky_material.ground_bottom_color = Color(0.2, 0.2, 0.2)
			environment.ambient_light_color = Color(0.6, 0.5, 0.4)
			environment.ambient_light_energy = 0.3
			ambient_light.light_energy = 0.1
		
		TimeOfDay.NIGHT:
			directional_light.light_color = Color(0.6, 0.7, 1.0)  # Blue-ish moonlight
			directional_light.light_energy = 0.2
			sky_material.sky_top_color = Color(0.05, 0.05, 0.1)
			sky_material.sky_horizon_color = Color(0.1, 0.1, 0.2)
			sky_material.ground_horizon_color = Color(0.1, 0.1, 0.15)
			sky_material.ground_bottom_color = Color(0.05, 0.05, 0.1)
			environment.ambient_light_color = Color(0.3, 0.4, 0.5)
			environment.ambient_light_energy = 0.2
			ambient_light.light_energy = 0.3
		
		TimeOfDay.MIDNIGHT:
			directional_light.light_color = Color(0.5, 0.6, 1.0)  # Dim blue moonlight
			directional_light.light_energy = 0.1
			sky_material.sky_top_color = Color(0.02, 0.02, 0.05)
			sky_material.sky_horizon_color = Color(0.05, 0.05, 0.1)
			sky_material.ground_horizon_color = Color(0.05, 0.05, 0.1)
			sky_material.ground_bottom_color = Color(0.02, 0.02, 0.05)
			environment.ambient_light_color = Color(0.2, 0.3, 0.4)
			environment.ambient_light_energy = 0.1
			ambient_light.light_energy = 0.4

# Update environment based on weather
func _update_environment_for_weather():
	# Update fog and particles based on weather
	match current_weather:
		WeatherType.CLEAR:
			environment.fog_enabled = false
			mist_particles.emitting = false
			rain_particles.emitting = false
			cloud_mesh.visible = false
		
		WeatherType.CLOUDY:
			environment.fog_enabled = true
			environment.fog_density = 0.001
			environment.fog_aerial_perspective = 0.3
			environment.fog_sky_affect = 0.3
			mist_particles.emitting = false
			rain_particles.emitting = false
			cloud_mesh.visible = true
			cloud_mesh.get_surface_override_material(0).set_shader_parameter("cloud_density", 0.7)
			cloud_mesh.get_surface_override_material(0).set_shader_parameter("time_scale", 0.05)
		
		WeatherType.MISTY:
			environment.fog_enabled = true
			environment.fog_density = 0.005
			environment.fog_aerial_perspective = 0.7
			environment.fog_sky_affect = 0.5
			mist_particles.emitting = true
			rain_particles.emitting = false
			cloud_mesh.visible = true
			cloud_mesh.get_surface_override_material(0).set_shader_parameter("cloud_density", 0.5)
			cloud_mesh.get_surface_override_material(0).set_shader_parameter("time_scale", 0.02)
		
		WeatherType.LIGHT_RAIN:
			environment.fog_enabled = true
			environment.fog_density = 0.002
			environment.fog_aerial_perspective = 0.4
			environment.fog_sky_affect = 0.4
			mist_particles.emitting = false
			rain_particles.emitting = true
			rain_particles.amount = 500
			cloud_mesh.visible = true
			cloud_mesh.get_surface_override_material(0).set_shader_parameter("cloud_density", 0.8)
			cloud_mesh.get_surface_override_material(0).set_shader_parameter("time_scale", 0.1)
		
		WeatherType.HEAVY_RAIN:
			environment.fog_enabled = true
			environment.fog_density = 0.003
			environment.fog_aerial_perspective = 0.5
			environment.fog_sky_affect = 0.5
			mist_particles.emitting = true
			rain_particles.emitting = true
			rain_particles.amount = 1000
			cloud_mesh.visible = true
			cloud_mesh.get_surface_override_material(0).set_shader_parameter("cloud_density", 0.9)
			cloud_mesh.get_surface_override_material(0).set_shader_parameter("time_scale", 0.15)
		
		WeatherType.STORMY:
			environment.fog_enabled = true
			environment.fog_density = 0.004
			environment.fog_aerial_perspective = 0.6
			environment.fog_sky_affect = 0.6
			mist_particles.emitting = true
			rain_particles.emitting = true
			rain_particles.amount = 1500
			cloud_mesh.visible = true
			cloud_mesh.get_surface_override_material(0).set_shader_parameter("cloud_density", 1.0)
			cloud_mesh.get_surface_override_material(0).set_shader_parameter("time_scale", 0.2)

# Update ambient sound based on time of day
func _update_ambient_sound():
	if ambient_sounds.has(current_time):
		ambient_audio_player.stream = ambient_sounds[current_time]
		if not ambient_audio_player.playing:
			ambient_audio_player.play()

# Update weather sound based on weather type
func _update_weather_sound():
	if weather_sounds.has(current_weather) and weather_sounds[current_weather] != null:
		weather_audio_player.stream = weather_sounds[current_weather]
		if not weather_audio_player.playing:
			weather_audio_player.play()
	else:
		weather_audio_player.stop()

# Bell timer timeout handler
func _on_bell_timer_timeout():
	# Ring the bell based on the time of day
	var hour = int(time_progress * 24.0)
	var num_rings = (hour % 12) if hour % 12 > 0 else 12
	
	# Schedule the bell rings
	for i in range(num_rings):
		var ring_timer = get_tree().create_timer(i * 2.0)
		ring_timer.timeout.connect(_ring_bell)

# Ring the bell
func _ring_bell():
	if bell_sounds.size() > 0:
		bell_audio_player.stream = bell_sounds[rng.randi() % bell_sounds.size()]
		bell_audio_player.play()

# Enable/disable day cycle
func set_day_cycle_enabled(enabled: bool):
	day_cycle_enabled = enabled

# Set day cycle speed (in minutes)
func set_day_cycle_speed(minutes: float):
	day_cycle_speed = max(0.1, minutes)

# Set time directly (0.0 to 1.0)
func set_time_progress(progress: float):
	time_progress = clamp(progress, 0.0, 1.0)
	_update_time_from_progress()
	_update_environment_for_time()

# Get current time as a string
func get_time_string() -> String:
	var hour = int(time_progress * 24.0)
	var minute = int((time_progress * 24.0 - hour) * 60.0)
	var am_pm = "AM" if hour < 12 else "PM"
	hour = hour % 12
	if hour == 0:
		hour = 12
	
	return "%d:%02d %s" % [hour, minute, am_pm]

# Get current weather as a string
func get_weather_string() -> String:
	match current_weather:
		WeatherType.CLEAR:
			return "Clear"
		WeatherType.CLOUDY:
			return "Cloudy"
		WeatherType.MISTY:
			return "Misty"
		WeatherType.LIGHT_RAIN:
			return "Light Rain"
		WeatherType.HEAVY_RAIN:
			return "Heavy Rain"
		WeatherType.STORMY:
			return "Stormy"
	
	return "Unknown"

# Get current time of day as a string
func get_time_of_day_string() -> String:
	match current_time:
		TimeOfDay.DAWN:
			return "Dawn"
		TimeOfDay.MORNING:
			return "Morning"
		TimeOfDay.NOON:
			return "Noon"
		TimeOfDay.AFTERNOON:
			return "Afternoon"
		TimeOfDay.GOLDEN_HOUR:
			return "Golden Hour"
		TimeOfDay.DUSK:
			return "Dusk"
		TimeOfDay.NIGHT:
			return "Night"
		TimeOfDay.MIDNIGHT:
			return "Midnight"
	
	return "Unknown"

# Randomly change the weather
func random_weather_change():
	var weather_types = [
		WeatherType.CLEAR,
		WeatherType.CLOUDY,
		WeatherType.MISTY,
		WeatherType.LIGHT_RAIN,
		WeatherType.HEAVY_RAIN,
		WeatherType.STORMY
	]
	
	var new_weather = weather_types[rng.randi() % weather_types.size()]
	set_weather(new_weather)

# Set the golden hour time
func set_golden_hour():
	set_time_progress(0.7)  # Golden hour is around 70% through the day

# Set the medieval noon time
func set_medieval_noon():
	set_time_progress(0.5)  # Noon is at 50% through the day
