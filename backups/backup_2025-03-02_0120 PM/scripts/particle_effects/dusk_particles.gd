extends Node3D

# Particle system parameters for mist
var mist_count = 120
var mist_box_size = Vector3(20, 5, 20)
var mist_lifetime = 6.0
var mist_size = 0.15
var mist_color = Color(0.9, 0.6, 0.4, 0.3)

# Particle system parameters for fireflies
var firefly_count = 50
var firefly_box_size = Vector3(15, 8, 15)
var firefly_lifetime = 8.0
var firefly_size = 0.05
var firefly_color = Color(1.0, 0.8, 0.2, 0.8)

# Particle system nodes
var mist_particles: GPUParticles3D
var firefly_particles: GPUParticles3D
var mist_material: ParticleProcessMaterial
var firefly_material: ParticleProcessMaterial
var mist_mesh: QuadMesh
var firefly_mesh: QuadMesh

func _ready():
    # Create mist particle system
    mist_particles = GPUParticles3D.new()
    add_child(mist_particles)
    
    # Create mist mesh
    mist_mesh = QuadMesh.new()
    mist_mesh.size = Vector2(mist_size, mist_size)
    mist_particles.draw_pass_1 = mist_mesh
    
    # Configure mist material
    mist_material = ParticleProcessMaterial.new()
    mist_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    mist_material.emission_box_extents = mist_box_size
    mist_material.particle_flag_align_y = true
    mist_material.gravity = Vector3(0, 0.05, 0)  # Gentle upward drift
    mist_material.initial_velocity_min = 0.1
    mist_material.initial_velocity_max = 0.2
    mist_material.angle_min = -45
    mist_material.angle_max = 45
    mist_material.scale_min = 0.8
    mist_material.scale_max = 1.2
    mist_material.color = mist_color
    
    # Configure mist particle system
    mist_particles.process_material = mist_material
    mist_particles.amount = mist_count
    mist_particles.lifetime = mist_lifetime
    mist_particles.explosiveness = 0.0
    mist_particles.randomness = 0.5
    mist_particles.fixed_fps = 30
    mist_particles.draw_order = GPUParticles3D.DRAW_ORDER_VIEW_DEPTH
    
    # Create firefly particle system
    firefly_particles = GPUParticles3D.new()
    add_child(firefly_particles)
    
    # Create firefly mesh
    firefly_mesh = QuadMesh.new()
    firefly_mesh.size = Vector2(firefly_size, firefly_size)
    firefly_particles.draw_pass_1 = firefly_mesh
    
    # Configure firefly material
    firefly_material = ParticleProcessMaterial.new()
    firefly_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    firefly_material.emission_box_extents = firefly_box_size
    firefly_material.particle_flag_align_y = true
    firefly_material.gravity = Vector3.ZERO
    firefly_material.initial_velocity_min = 0.3
    firefly_material.initial_velocity_max = 0.6
    firefly_material.angle_min = -180
    firefly_material.angle_max = 180
    firefly_material.scale_min = 0.8
    firefly_material.scale_max = 1.2
    firefly_material.color = firefly_color
    
    # Configure firefly particle system
    firefly_particles.process_material = firefly_material
    firefly_particles.amount = firefly_count
    firefly_particles.lifetime = firefly_lifetime
    firefly_particles.explosiveness = 0.0
    firefly_particles.randomness = 0.8
    firefly_particles.fixed_fps = 30
    firefly_particles.draw_order = GPUParticles3D.DRAW_ORDER_VIEW_DEPTH
    
    # Start particle emission
    mist_particles.emitting = true
    firefly_particles.emitting = true
    
    # Start animation sequence
    _animate_dusk_sequence()

func _animate_dusk_sequence():
    # Create a sequence of particle animations
    var tween = create_tween()
    tween.set_parallel(true)
    
    # Fade in mist
    tween.tween_property(mist_material, "color:a", 0.3, 3.0).from(0.0)
    
    # Fade in fireflies
    tween.tween_property(firefly_material, "color:a", 0.8, 4.0).from(0.0)
    
    # Gradually increase particle counts
    tween.tween_property(mist_particles, "amount", mist_count, 5.0).from(0)
    tween.tween_property(firefly_particles, "amount", firefly_count, 6.0).from(0)
    
    # Animate emission boxes
    tween.tween_property(mist_material, "emission_box_extents", mist_box_size, 4.0).from(Vector3.ZERO)
    tween.tween_property(firefly_material, "emission_box_extents", firefly_box_size, 5.0).from(Vector3.ZERO)

func _process(_delta):
    if firefly_particles and firefly_material:
        # Add firefly pulsing effect
        var time = Time.get_ticks_msec() * 0.001
        var pulse = (sin(time * 2.0) * 0.5 + 0.5) * 0.3 + 0.5
        firefly_material.color.a = pulse
        
        # Random direction changes
        if randf() < 0.05:  # 5% chance per frame
            var new_velocity = Vector3(
                randf_range(-0.5, 0.5),
                randf_range(-0.3, 0.3),
                randf_range(-0.5, 0.5)
            ).normalized() * randf_range(0.3, 0.6)
            
            firefly_material.initial_velocity_min = new_velocity.length() * 0.8
            firefly_material.initial_velocity_max = new_velocity.length() * 1.2
    
    if mist_particles and mist_material:
        # Add subtle mist movement
        var time = Time.get_ticks_msec() * 0.001
        var drift = sin(time * 0.5) * 0.05
        mist_material.gravity = Vector3(drift, 0.05 + drift * 0.1, drift)
