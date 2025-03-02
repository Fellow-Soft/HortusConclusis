extends Node
class_name CinematicEffects

# Helper functions for cinematic effects in Hortus Conclusus

# Create a color gradient
static func create_color_gradient(start_color: Color, end_color: Color) -> Gradient:
	var gradient = Gradient.new()
	gradient.add_point(0.0, start_color)
	gradient.add_point(1.0, end_color)
	return gradient

# Add materialization particles
static func add_materialization_particles(parent: Node3D, position: Vector3, color: Color):
	var particles = GPUParticles3D.new()
	var material = ParticleProcessMaterial.new()

	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 1.0
	material.direction = Vector3(0, 1, 0)
	material.spread = 45.0
	material.gravity = Vector3(0, -0.5, 0)
	material.initial_velocity_min = 1.0
	material.initial_velocity_max = 2.0
	material.scale_min = 0.1
	material.scale_max = 0.3
	material.color = color

	var gradient = create_color_gradient(color, Color(color.r, color.g, color.b, 0.0))
	material.color_ramp = gradient

	particles.process_material = material
	particles.amount = 30
	particles.lifetime = 3.0
	particles.one_shot = true
	particles.explosiveness = 0.8
	particles.global_position = position

	parent.add_child(particles)
	particles.emitting = true

	# Auto-remove after emission
	var timer = Timer.new()
	timer.wait_time = 4.0
	timer.one_shot = true
	timer.connect("timeout", Callable(particles, "queue_free"))
	parent.add_child(timer)
	timer.start()

# Add growth particles
static func add_growth_particles(parent: Node3D, node: Node3D):
	var particles = GPUParticles3D.new()
	var material = ParticleProcessMaterial.new()

	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.3
	material.direction = Vector3(0, 1, 0)
	material.spread = 30.0
	material.gravity = Vector3(0, 0.1, 0)
	material.initial_velocity_min = 0.2
	material.initial_velocity_max = 0.5
	material.scale_min = 0.05
	material.scale_max = 0.1
	material.color = Color(0.3, 0.8, 0.3, 0.7)

	particles.process_material = material
	particles.amount = 20
	particles.lifetime = 4.0
	particles.global_position = node.global_position + Vector3(0, 0.2, 0)

	node.add_child(particles)
	particles.emitting = true

# Add flowering particles
static func add_flowering_particles(parent: Node3D, node: Node3D):
	var particles = GPUParticles3D.new()
	var material = ParticleProcessMaterial.new()

	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.4
	material.direction = Vector3(0, 0, 0)
	material.spread = 180.0
	material.gravity = Vector3(0, -0.05, 0)
	material.initial_velocity_min = 0.1
	material.initial_velocity_max = 0.3
	material.scale_min = 0.05
	material.scale_max = 0.1
	material.color = Color(1.0, 0.8, 0.8, 0.7)

	particles.process_material = material
	particles.amount = 15
	particles.lifetime = 5.0
	particles.global_position = node.global_position + Vector3(0, 0.4, 0)

	node.add_child(particles)
	particles.emitting = true

# Add divine particles
static func add_divine_particles(parent: Node3D, node: Node3D):
	var particles = GPUParticles3D.new()
	var material = ParticleProcessMaterial.new()

	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.5
	material.direction = Vector3(0, 1, 0)
	material.spread = 45.0
	material.gravity = Vector3(0, 0.1, 0)
	material.initial_velocity_min = 0.1
	material.initial_velocity_max = 0.3
	material.scale_min = 0.05
	material.scale_max = 0.1
	material.color = Color(1.0, 0.95, 0.7, 0.8)

	particles.process_material = material
	particles.amount = 25
	particles.lifetime = 6.0
	particles.global_position = node.global_position + Vector3(0, 0.5, 0)

	node.add_child(particles)
	particles.emitting = true
