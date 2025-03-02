extends Node3D

# Particle system parameters
var particle_count = 100
var emission_box_size = Vector3(20, 10, 20)
var particle_lifetime = 5.0
var particle_speed = 1.0
var particle_size = 0.1
var particle_color = Color(1.0, 0.8, 0.6, 0.5)

# Particle system nodes
var particles: GPUParticles3D
var material: ParticleProcessMaterial
var mesh: QuadMesh

func _ready():
    # Create particle system
    particles = GPUParticles3D.new()
    add_child(particles)
    
    # Create particle mesh
    mesh = QuadMesh.new()
    mesh.size = Vector2(particle_size, particle_size)
    particles.draw_pass_1 = mesh
    
    # Configure particle material
    material = ParticleProcessMaterial.new()
    material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    material.emission_box_extents = emission_box_size
    material.particle_flag_align_y = true
    material.gravity = Vector3(0, 0.1, 0)  # Slight upward drift
    material.initial_velocity_min = 0.1
    material.initial_velocity_max = 0.3
    material.angle_min = -45
    material.angle_max = 45
    material.scale_min = 0.8
    material.scale_max = 1.2
    material.color = particle_color
    material.anim_speed_min = 1.0
    material.anim_speed_max = 2.0
    
    # Configure particle system
    particles.process_material = material
    particles.amount = particle_count
    particles.lifetime = particle_lifetime
    particles.explosiveness = 0.0
    particles.randomness = 0.5
    particles.fixed_fps = 30
    particles.draw_order = GPUParticles3D.DRAW_ORDER_VIEW_DEPTH
    particles.transform.origin = Vector3.ZERO
    
    # Start particle emission
    particles.emitting = true
    
    # Start animation sequence
    _animate_dawn_sequence()

func _animate_dawn_sequence():
    # Create a sequence of particle animations
    var tween = create_tween()
    tween.set_parallel(true)
    
    # Fade in particles
    tween.tween_property(material, "color:a", 0.5, 2.0).from(0.0)
    
    # Gradually increase particle count
    tween.tween_property(particles, "amount", particle_count, 3.0).from(0)
    
    # Animate emission box
    tween.tween_property(material, "emission_box_extents", emission_box_size, 4.0).from(Vector3.ZERO)
    
    # Start particle movement
    tween.tween_property(material, "initial_velocity_min", 0.1, 2.0).from(0.0)
    tween.tween_property(material, "initial_velocity_max", 0.3, 2.0).from(0.0)

func _process(_delta):
    if particles and material:
        # Add subtle variation to particle color
        var time = Time.get_ticks_msec() * 0.001
        var color_variation = sin(time) * 0.1
        material.color = Color(
            particle_color.r + color_variation,
            particle_color.g + color_variation,
            particle_color.b + color_variation,
            particle_color.a
        )
