extends Node3D

# Particle system parameters
var particle_count = 150
var emission_box_size = Vector3(20, 15, 20)
var particle_lifetime = 4.0
var particle_speed = 1.5
var particle_size = 0.08
var particle_color = Color(1.0, 0.95, 0.9, 0.4)

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
    material.gravity = Vector3(0, -0.05, 0)  # Slight downward drift
    material.initial_velocity_min = 0.2
    material.initial_velocity_max = 0.4
    material.angle_min = -90
    material.angle_max = 90
    material.scale_min = 0.7
    material.scale_max = 1.3
    material.color = particle_color
    material.anim_speed_min = 1.5
    material.anim_speed_max = 2.5
    
    # Configure particle system
    particles.process_material = material
    particles.amount = particle_count
    particles.lifetime = particle_lifetime
    particles.explosiveness = 0.0
    particles.randomness = 0.7
    particles.fixed_fps = 30
    particles.draw_order = GPUParticles3D.DRAW_ORDER_VIEW_DEPTH
    particles.transform.origin = Vector3.ZERO
    
    # Start particle emission
    particles.emitting = true
    
    # Start animation sequence
    _animate_noon_sequence()

func _animate_noon_sequence():
    # Create a sequence of particle animations
    var tween = create_tween()
    tween.set_parallel(true)
    
    # Fade in particles
    tween.tween_property(material, "color:a", 0.4, 2.0).from(0.0)
    
    # Gradually increase particle count
    tween.tween_property(particles, "amount", particle_count, 3.0).from(0)
    
    # Animate emission box
    tween.tween_property(material, "emission_box_extents", emission_box_size, 4.0).from(Vector3.ZERO)
    
    # Start particle movement
    tween.tween_property(material, "initial_velocity_min", 0.2, 2.0).from(0.0)
    tween.tween_property(material, "initial_velocity_max", 0.4, 2.0).from(0.0)

func _process(_delta):
    if particles and material:
        # Add heat distortion effect
        var time = Time.get_ticks_msec() * 0.001
        var distortion = sin(time * 2.0) * 0.2
        material.initial_velocity_min = 0.2 + distortion
        material.initial_velocity_max = 0.4 + distortion
        
        # Subtle color variation
        var color_variation = sin(time) * 0.05
        material.color = Color(
            particle_color.r + color_variation,
            particle_color.g + color_variation,
            particle_color.b + color_variation,
            particle_color.a
        )
