extends Node3D

# Particle system parameters for stars
var star_count = 200
var star_box_size = Vector3(30, 20, 30)
var star_lifetime = 10.0
var star_size = 0.03
var star_color = Color(1.0, 1.0, 1.0, 0.8)

# Particle system parameters for moonlight beams
var beam_count = 30
var beam_box_size = Vector3(25, 15, 25)
var beam_lifetime = 8.0
var beam_size = 0.2
var beam_color = Color(0.4, 0.4, 0.8, 0.2)

# Particle system nodes
var star_particles: GPUParticles3D
var beam_particles: GPUParticles3D
var star_material: ParticleProcessMaterial
var beam_material: ParticleProcessMaterial
var star_mesh: QuadMesh
var beam_mesh: QuadMesh

func _ready():
    # Create star particle system
    star_particles = GPUParticles3D.new()
    add_child(star_particles)
    
    # Create star mesh
    star_mesh = QuadMesh.new()
    star_mesh.size = Vector2(star_size, star_size)
    star_particles.draw_pass_1 = star_mesh
    
    # Configure star material
    star_material = ParticleProcessMaterial.new()
    star_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    star_material.emission_box_extents = star_box_size
    star_material.particle_flag_align_y = true
    star_material.gravity = Vector3.ZERO
    star_material.initial_velocity_min = 0.0
    star_material.initial_velocity_max = 0.0
    star_material.angle_min = 0
    star_material.angle_max = 360
    star_material.scale_min = 0.8
    star_material.scale_max = 1.2
    star_material.color = star_color
    
    # Configure star particle system
    star_particles.process_material = star_material
    star_particles.amount = star_count
    star_particles.lifetime = star_lifetime
    star_particles.explosiveness = 0.0
    star_particles.randomness = 0.8
    star_particles.fixed_fps = 30
    star_particles.draw_order = GPUParticles3D.DRAW_ORDER_VIEW_DEPTH
    
    # Create moonlight beam particle system
    beam_particles = GPUParticles3D.new()
    add_child(beam_particles)
    
    # Create beam mesh
    beam_mesh = QuadMesh.new()
    beam_mesh.size = Vector2(beam_size, beam_size * 3.0)  # Elongated for beam effect
    beam_particles.draw_pass_1 = beam_mesh
    
    # Configure beam material
    beam_material = ParticleProcessMaterial.new()
    beam_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    beam_material.emission_box_extents = beam_box_size
    beam_material.particle_flag_align_y = true
    beam_material.gravity = Vector3(0, -0.05, 0)  # Gentle downward drift
    beam_material.initial_velocity_min = 0.1
    beam_material.initial_velocity_max = 0.2
    beam_material.angle_min = -15
    beam_material.angle_max = 15
    beam_material.scale_min = 0.7
    beam_material.scale_max = 1.3
    beam_material.color = beam_color
    
    # Configure beam particle system
    beam_particles.process_material = beam_material
    beam_particles.amount = beam_count
    beam_particles.lifetime = beam_lifetime
    beam_particles.explosiveness = 0.0
    beam_particles.randomness = 0.5
    beam_particles.fixed_fps = 30
    beam_particles.draw_order = GPUParticles3D.DRAW_ORDER_VIEW_DEPTH
    
    # Start particle emission
    star_particles.emitting = true
    beam_particles.emitting = true
    
    # Start animation sequence
    _animate_night_sequence()

func _animate_night_sequence():
    # Create a sequence of particle animations
    var tween = create_tween()
    tween.set_parallel(true)
    
    # Fade in stars
    tween.tween_property(star_material, "color:a", 0.8, 4.0).from(0.0)
    
    # Fade in moonlight beams
    tween.tween_property(beam_material, "color:a", 0.2, 5.0).from(0.0)
    
    # Gradually increase particle counts
    tween.tween_property(star_particles, "amount", star_count, 6.0).from(0)
    tween.tween_property(beam_particles, "amount", beam_count, 7.0).from(0)
    
    # Animate emission boxes
    tween.tween_property(star_material, "emission_box_extents", star_box_size, 5.0).from(Vector3.ZERO)
    tween.tween_property(beam_material, "emission_box_extents", beam_box_size, 6.0).from(Vector3.ZERO)

func _process(_delta):
    if star_particles and star_material:
        # Add twinkling effect to stars
        var time = Time.get_ticks_msec() * 0.001
        for i in range(star_count):
            var twinkle = sin(time * 2.0 + float(i) * 0.5) * 0.3 + 0.7
            if i == 0:  # Only update material once
                star_material.color.a = twinkle
    
    if beam_particles and beam_material:
        # Add subtle beam movement
        var time = Time.get_ticks_msec() * 0.001
        var drift = sin(time * 0.3) * 0.03
        beam_material.gravity = Vector3(drift, -0.05 + drift * 0.1, drift)
        
        # Subtle beam intensity variation
        var intensity = sin(time * 0.5) * 0.05 + 0.15
        beam_material.color.a = intensity
