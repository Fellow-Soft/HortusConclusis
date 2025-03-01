extends Node
class_name CinematicEffectsEnhanced

# Static reference to self for static methods
static var instance: CinematicEffectsEnhanced

# Enhanced cinematic effects for the Hortus Conclusus cinematic demo
# This script provides more sophisticated visual effects to create a deeply immersive experience

# Particle effect presets for different stages of the cinematic
const PARTICLE_PRESETS = {
	"mist": {
		"amount": 50,
		"lifetime": 8.0,
		"size": Vector2(0.5, 2.0),
		"color": Color(0.9, 0.95, 1.0, 0.15),
		"speed": Vector2(0.1, 0.3),
		"direction": Vector3(0.1, 0.05, 0.1),
		"gravity": Vector3(0, -0.01, 0)
	},
	"divine_light": {
		"amount": 30,
		"lifetime": 5.0,
		"size": Vector2(0.2, 0.8),
		"color": Color(1.0, 0.95, 0.8, 0.4),
		"speed": Vector2(0.2, 0.5),
		"direction": Vector3(0, -1.0, 0),
		"gravity": Vector3(0, -0.05, 0)
	},
	"materialization": {
		"amount": 40,
		"lifetime": 3.0,
		"size": Vector2(0.1, 0.3),
		"color": Color(0.7, 0.8, 1.0, 0.5),
		"speed": Vector2(0.3, 0.7),
		"direction": Vector3(0, 1.0, 0),
		"gravity": Vector3(0, 0.02, 0)
	},
	"growth": {
		"amount": 25,
		"lifetime": 4.0,
		"size": Vector2(0.05, 0.2),
		"color": Color(0.4, 0.8, 0.4, 0.6),
		"speed": Vector2(0.1, 0.4),
		"direction": Vector3(0, 1.0, 0),
		"gravity": Vector3(0, 0.03, 0)
	},
	"flowering": {
		"amount": 35,
		"lifetime": 6.0,
		"size": Vector2(0.05, 0.15),
		"color": Color(1.0, 0.8, 0.9, 0.7),
		"speed": Vector2(0.05, 0.2),
		"direction": Vector3(0, 0.5, 0),
		"gravity": Vector3(0, -0.01, 0)
	},
	"divine": {
		"amount": 60,
		"lifetime": 10.0,
		"size": Vector2(0.1, 0.4),
		"color": Color(1.0, 0.9, 0.6, 0.5),
		"speed": Vector2(0.1, 0.3),
		"direction": Vector3(0, -0.5, 0),
		"gravity": Vector3(0, -0.02, 0)
	},
	"celestial": {
		"amount": 70,
		"lifetime": 15.0,
		"size": Vector2(0.05, 0.1),
		"color": Color(0.9, 0.95, 1.0, 0.8),
		"speed": Vector2(0.01, 0.05),
		"direction": Vector3(0, 0, 0),
		"gravity": Vector3(0, 0, 0)
	},
	"sacred_dust": {
		"amount": 100,
		"lifetime": 20.0,
		"size": Vector2(0.01, 0.05),
		"color": Color(1.0, 0.9, 0.7, 0.3),
		"speed": Vector2(0.01, 0.03),
		"direction": Vector3(0, -0.1, 0),
		"gravity": Vector3(0, -0.001, 0)
	}
}

# Light effect presets for different stages of the cinematic
const LIGHT_PRESETS = {
	"dawn": {
		"color": Color(1.0, 0.8, 0.6),
		"energy": 1.0,
		"range": 20.0,
		"shadow": true,
		"specular": 0.5
	},
	"noon": {
		"color": Color(1.0, 0.95, 0.9),
		"energy": 1.5,
		"range": 30.0,
		"shadow": true,
		"specular": 1.0
	},
	"dusk": {
		"color": Color(0.9, 0.7, 0.5),
		"energy": 0.8,
		"range": 15.0,
		"shadow": true,
		"specular": 0.3
	},
	"night": {
		"color": Color(0.6, 0.7, 0.9),
		"energy": 0.5,
		"range": 10.0,
		"shadow": true,
		"specular": 0.1
	},
	"divine": {
		"color": Color(1.0, 0.9, 0.7),
		"energy": 2.0,
		"range": 40.0,
		"shadow": true,
		"specular": 1.5
	},
	"sacred": {
		"color": Color(0.9, 0.8, 1.0),
		"energy": 1.2,
		"range": 25.0,
		"shadow": true,
		"specular": 0.8
	},
	"mystical": {
		"color": Color(0.7, 0.9, 1.0),
		"energy": 1.0,
		"range": 20.0,
		"shadow": true,
		"specular": 0.6
	}
}

func _init():
	# Set static instance for static method access
	instance = self

# Enhanced mist particles with volumetric effect
static func add_enhanced_mist_particles(parent: Node3D, position: Vector3 = Vector3.ZERO, color: Color = Color(0.9, 0.95, 1.0, 0.15)):
	var preset = PARTICLE_PRESETS["mist"]
	preset.color = color
	
	# Create multiple particle systems at different heights for volumetric effect
	for i in range(3):
		var height = 0.5 + i * 1.0
		var pos = position + Vector3(0, height, 0)
		
		# Create particles with slight variations for each layer
		var particles = _create_particle_system(
			preset.amount + i * 10,
			preset.lifetime + i * 1.0,
			Vector2(preset.size.x, preset.size.y + i * 0.5),
			preset.color,
			Vector2(preset.speed.x, preset.speed.y - i * 0.05),
			preset.direction,
			preset.gravity
		)
		
		particles.position = pos
		parent.add_child(particles)
		
		# Add subtle animation to the particles
		var tween = parent.create_tween()
		tween.tween_property(particles, "process_material:emission_box_extents", Vector3(15, 2, 15), 10.0)
		tween.tween_property(particles, "process_material:emission_box_extents", Vector3(10, 1, 10), 10.0)
		tween.set_loops()
	
	return true

# Enhanced divine light particles with beam effect
static func add_enhanced_divine_light(parent: Node3D, position: Vector3 = Vector3(0, 15, 0), color: Color = Color(1.0, 0.95, 0.8, 0.4)):
	var preset = PARTICLE_PRESETS["divine_light"]
	preset.color = color
	
	# Create main divine light
	var light = OmniLight3D.new()
	light.light_color = LIGHT_PRESETS["divine"].color
	light.light_energy = LIGHT_PRESETS["divine"].energy
	light.omni_range = LIGHT_PRESETS["divine"].range
	light.shadow_enabled = LIGHT_PRESETS["divine"].shadow
	light.position = position
	parent.add_child(light)
	
	# Create light beams
	for i in range(5):
		var angle = i * (2 * PI / 5)
		var beam_pos = position + Vector3(cos(angle) * 3, -5, sin(angle) * 3)
		var target_pos = Vector3(cos(angle) * 10, 0, sin(angle) * 10)
		
		# Create beam light
		var beam_light = SpotLight3D.new()
		beam_light.light_color = LIGHT_PRESETS["divine"].color
		beam_light.light_energy = LIGHT_PRESETS["divine"].energy * 0.7
		beam_light.spot_range = 20.0
		beam_light.spot_angle = 15.0
		beam_light.shadow_enabled = true
		beam_light.position = beam_pos
		beam_light.look_at(target_pos)
		parent.add_child(beam_light)
		
		# Create particles for the beam
		var particles = _create_particle_system(
			preset.amount,
			preset.lifetime,
			preset.size,
			preset.color,
			preset.speed,
			(target_pos - beam_pos).normalized(),
			preset.gravity
		)
		particles.position = beam_pos
		parent.add_child(particles)
		
		# Animate the beam
		var tween = parent.create_tween()
		tween.tween_property(beam_light, "light_energy", LIGHT_PRESETS["divine"].energy * 1.2, 2.0)
		tween.tween_property(beam_light, "light_energy", LIGHT_PRESETS["divine"].energy * 0.7, 2.0)
		tween.set_loops()
	
	# Animate the main light
	var light_tween = parent.create_tween()
	light_tween.tween_property(light, "light_energy", LIGHT_PRESETS["divine"].energy * 1.5, 3.0)
	light_tween.tween_property(light, "light_energy", LIGHT_PRESETS["divine"].energy, 3.0)
	light_tween.set_loops()
	
	return light

# Enhanced materialization particles with swirling effect
static func add_enhanced_materialization_particles(parent: Node3D, position: Vector3, color: Color = Color(0.7, 0.8, 1.0, 0.5)):
	var preset = PARTICLE_PRESETS["materialization"]
	preset.color = color
	
	# Create swirling particles
	var particles = _create_particle_system(
		preset.amount,
		preset.lifetime,
		preset.size,
		preset.color,
		preset.speed,
		preset.direction,
		preset.gravity
	)
	
	particles.position = position
	parent.add_child(particles)
	
	# Add swirling motion
	var swirl_particles = _create_particle_system(
		preset.amount / 2,
		preset.lifetime * 1.5,
		preset.size,
		preset.color,
		Vector2(0.5, 1.0),
		Vector3(0, 0.5, 0),
		Vector3(0, 0.01, 0)
	)
	
	# Set up swirling motion
	var process_material = swirl_particles.process_material as ParticleProcessMaterial
	process_material.orbit_velocity_min = 1.0
	process_material.orbit_velocity_max = 2.0
	process_material.radial_accel_min = 1.0
	process_material.radial_accel_max = 2.0
	
	swirl_particles.position = position
	parent.add_child(swirl_particles)
	
	# Add subtle light
	var light = OmniLight3D.new()
	light.light_color = color
	light.light_energy = 0.5
	light.omni_range = 5.0
	light.position = position
	parent.add_child(light)
	
	# Animate the light
	var tween = parent.create_tween()
	tween.tween_property(light, "light_energy", 1.0, 1.0)
	tween.tween_property(light, "light_energy", 0.0, 2.0)
	tween.tween_callback(Callable(light, "queue_free"))
	
	return particles

# Enhanced growth particles with upward spiraling effect
static func add_enhanced_growth_particles(parent: Node3D, target: Node3D):
	var preset = PARTICLE_PRESETS["growth"]
	var target_pos = target.global_position
	
	# Create main growth particles
	var particles = _create_particle_system(
		preset.amount,
		preset.lifetime,
		preset.size,
		preset.color,
		preset.speed,
		preset.direction,
		preset.gravity
	)
	
	particles.position = target_pos
	parent.add_child(particles)
	
	# Create spiraling particles
	var spiral_particles = _create_particle_system(
		preset.amount / 2,
		preset.lifetime * 1.5,
		Vector2(preset.size.x / 2, preset.size.y / 2),
		Color(0.3, 0.7, 0.3, 0.7),
		Vector2(0.2, 0.5),
		Vector3(0, 1.0, 0),
		Vector3(0, 0.01, 0)
	)
	
	# Set up spiraling motion
	var process_material = spiral_particles.process_material as ParticleProcessMaterial
	process_material.orbit_velocity_min = 0.5
	process_material.orbit_velocity_max = 1.5
	process_material.tangential_accel_min = 0.5
	process_material.tangential_accel_max = 1.0
	
	spiral_particles.position = target_pos
	parent.add_child(spiral_particles)
	
	# Add subtle green light
	var light = OmniLight3D.new()
	light.light_color = Color(0.3, 0.8, 0.3)
	light.light_energy = 0.3
	light.omni_range = 3.0
	light.position = target_pos
	parent.add_child(light)
	
	# Animate the light
	var tween = parent.create_tween()
	tween.tween_property(light, "light_energy", 0.6, 1.0)
	tween.tween_property(light, "light_energy", 0.0, 3.0)
	tween.tween_callback(Callable(light, "queue_free"))
	
	return particles

# Enhanced flowering particles with petal-like effect
static func add_enhanced_flowering_particles(parent: Node3D, target: Node3D):
	var preset = PARTICLE_PRESETS["flowering"]
	var target_pos = target.global_position
	
	# Create main flowering particles
	var particles = _create_particle_system(
		preset.amount,
		preset.lifetime,
		preset.size,
		preset.color,
		preset.speed,
		preset.direction,
		preset.gravity
	)
	
	particles.position = target_pos
	parent.add_child(particles)
	
	# Create petal-like particles in different colors
	var colors = [
		Color(1.0, 0.5, 0.5, 0.7), # Pink
		Color(1.0, 0.8, 0.5, 0.7), # Orange
		Color(0.8, 0.8, 1.0, 0.7), # Light blue
		Color(0.8, 1.0, 0.8, 0.7)  # Light green
	]
	
	for i in range(colors.size()):
		var petal_particles = _create_particle_system(
			preset.amount / 4,
			preset.lifetime * 1.2,
			Vector2(0.05, 0.1),
			colors[i],
			Vector2(0.1, 0.3),
			Vector3(0, 0.3, 0),
			Vector3(0, -0.01, 0)
		)
		
		# Set up petal-like motion
		var process_material = petal_particles.process_material as ParticleProcessMaterial
		process_material.orbit_velocity_min = 0.2
		process_material.orbit_velocity_max = 0.5
		process_material.tangential_accel_min = 0.1
		process_material.tangential_accel_max = 0.3
		process_material.damping_min = 0.1
		process_material.damping_max = 0.3
		
		petal_particles.position = target_pos
		parent.add_child(petal_particles)
	
	# Add subtle colorful light
	var light = OmniLight3D.new()
	light.light_color = Color(1.0, 0.8, 0.9)
	light.light_energy = 0.4
	light.omni_range = 3.0
	light.position = target_pos
	parent.add_child(light)
	
	# Animate the light with color changes
	var tween = parent.create_tween()
	tween.tween_property(light, "light_energy", 0.7, 1.0)
	tween.tween_property(light, "light_color", Color(0.9, 0.8, 1.0), 2.0)
	tween.tween_property(light, "light_energy", 0.0, 3.0)
	tween.tween_callback(Callable(light, "queue_free"))
	
	return particles

# Enhanced divine particles with sacred geometry patterns
static func add_enhanced_divine_particles(parent: Node3D, position: Vector3, color: Color = Color(1.0, 0.9, 0.6, 0.5)):
	var preset = PARTICLE_PRESETS["divine"]
	if color:
		preset.color = color
	
	var pos = position
	if position is Node3D:
		pos = position.global_position
	
	# Create main divine particles
	var particles = _create_particle_system(
		preset.amount,
		preset.lifetime,
		preset.size,
		preset.color,
		preset.speed,
		preset.direction,
		preset.gravity
	)
	
	particles.position = pos
	parent.add_child(particles)
	
	# Create sacred geometry pattern particles
	var sacred_particles = _create_particle_system(
		preset.amount / 2,
		preset.lifetime * 1.5,
		Vector2(0.05, 0.2),
		Color(1.0, 0.95, 0.8, 0.6),
		Vector2(0.05, 0.2),
		Vector3(0, -0.3, 0),
		Vector3(0, -0.01, 0)
	)
	
	# Set up sacred geometry pattern
	var process_material = sacred_particles.process_material as ParticleProcessMaterial
	process_material.orbit_velocity_min = 0.1
	process_material.orbit_velocity_max = 0.3
	process_material.radial_accel_min = 0.5
	process_material.radial_accel_max = 1.0
	process_material.tangential_accel_min = 0.2
	process_material.tangential_accel_max = 0.5
	
	sacred_particles.position = pos
	parent.add_child(sacred_particles)
	
	# Add divine light
	var light = OmniLight3D.new()
	light.light_color = LIGHT_PRESETS["sacred"].color
	light.light_energy = LIGHT_PRESETS["sacred"].energy
	light.omni_range = LIGHT_PRESETS["sacred"].range / 2
	light.position = pos
	parent.add_child(light)
	
	# Animate the light
	var tween = parent.create_tween()
	tween.tween_property(light, "light_energy", LIGHT_PRESETS["sacred"].energy * 1.5, 2.0)
	tween.tween_property(light, "light_energy", LIGHT_PRESETS["sacred"].energy * 0.8, 2.0)
	tween.set_loops(3)
	tween.tween_property(light, "light_energy", 0.0, 3.0)
	tween.tween_callback(Callable(light, "queue_free"))
	
	return particles

# Enhanced celestial particles for night sky
static func add_enhanced_celestial_particles(parent: Node3D, position: Vector3 = Vector3(0, 50, 0)):
	var preset = PARTICLE_PRESETS["celestial"]
	
	# Create star-like particles
	var particles = _create_particle_system(
		preset.amount,
		preset.lifetime,
		preset.size,
		preset.color,
		preset.speed,
		preset.direction,
		preset.gravity
	)
	
	# Set up star-like behavior
	var process_material = particles.process_material as ParticleProcessMaterial
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_material.emission_box_extents = Vector3(50, 10, 50)
	
	particles.position = position
	parent.add_child(particles)
	
	# Create occasional shooting stars
	var shooting_star_timer = Timer.new()
	shooting_star_timer.wait_time = 5.0
	shooting_star_timer.connect("timeout", Callable(parent, "_create_shooting_star").bind(position))
	parent.add_child(shooting_star_timer)
	shooting_star_timer.start()
	
	return particles

# Create a shooting star effect
static func create_shooting_star(parent: Node3D, position: Vector3):
	var start_pos = position + Vector3(randf_range(-40, 40), 0, randf_range(-40, 40))
	var direction = Vector3(randf_range(-1, 1), -0.5, randf_range(-1, 1)).normalized()
	
	# Create shooting star particles
	var particles = _create_particle_system(
		20,
		1.0,
		Vector2(0.05, 0.2),
		Color(1.0, 0.95, 0.9, 0.8),
		Vector2(2.0, 5.0),
		direction,
		Vector3(0, 0, 0)
	)
	
	particles.position = start_pos
	particles.emitting = true
	particles.one_shot = true
	parent.add_child(particles)
	
	# Add trail particles
	var trail_particles = _create_particle_system(
		30,
		2.0,
		Vector2(0.02, 0.1),
		Color(0.9, 0.9, 1.0, 0.5),
		Vector2(0.1, 0.3),
		Vector3(0, 0, 0),
		Vector3(0, 0, 0)
	)
	
	trail_particles.position = start_pos
	trail_particles.emitting = true
	trail_particles.one_shot = true
	parent.add_child(trail_particles)
	
	# Move the shooting star
	var tween = parent.create_tween()
	tween.tween_property(particles, "position", start_pos + direction * 100, 2.0)
	tween.parallel().tween_property(trail_particles, "position", start_pos + direction * 100, 2.0)
	tween.tween_callback(Callable(particles, "queue_free"))
	tween.tween_callback(Callable(trail_particles, "queue_free"))
	
	return particles

# Add sacred dust particles that float throughout the scene
static func add_enhanced_sacred_dust(parent: Node3D, position: Vector3 = Vector3(0, 10, 0)):
	var preset = PARTICLE_PRESETS["sacred_dust"]
	
	# Create dust particles
	var particles = _create_particle_system(
		preset.amount,
		preset.lifetime,
		preset.size,
		preset.color,
		preset.speed,
		preset.direction,
		preset.gravity
	)
	
	# Set up dust-like behavior
	var process_material = particles.process_material as ParticleProcessMaterial
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_material.emission_box_extents = Vector3(30, 10, 30)
	process_material.turbulence_enabled = true
	process_material.turbulence_noise_strength = 0.2
	process_material.turbulence_noise_scale = 2.0
	
	particles.position = position
	parent.add_child(particles)
	
	return particles

# Helper function to create a particle system
static func _create_particle_system(amount: int, lifetime: float, size: Vector2, color: Color, speed: Vector2, direction: Vector3, gravity: Vector3) -> GPUParticles3D:
	var particles = GPUParticles3D.new()
	var material = ParticleProcessMaterial.new()
	
	# Configure particle material
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 1.0
	material.particle_flag_align_y = true
	material.direction = direction
	material.spread = 45.0
	material.gravity = gravity
	material.initial_velocity_min = speed.x
	material.initial_velocity_max = speed.y
	material.scale_min = size.x
	material.scale_max = size.y
	material.color = color
	material.anim_speed_min = 1.0
	material.anim_speed_max = 2.0
	
	# Configure particle system
	particles.process_material = material
	particles.amount = amount
	particles.lifetime = lifetime
	particles.explosiveness = 0.1
	particles.randomness = 0.5
	particles.fixed_fps = 30
	particles.visibility_aabb = AABB(Vector3(-10, -10, -10), Vector3(20, 20, 20))
	
	# Create mesh for particles
	var mesh = QuadMesh.new()
	mesh.size = Vector2(1, 1)
	particles.draw_pass_1 = mesh
	
	return particles
