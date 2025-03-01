extends Node3D
class_name DawnParticles

# Enhanced dawn particle effects for the Hortus Conclusus cinematic
# This script creates a rich, atmospheric dawn scene with multiple particle systems

# Constants for particle parameters
const MIST_AMOUNT = 200
const MIST_LIFETIME = 10.0
const MIST_SIZE_MIN = 0.5
const MIST_SIZE_MAX = 2.0
const MIST_COLOR = Color(0.9, 0.95, 1.0, 0.15)

const LIGHT_RAY_AMOUNT = 30
const LIGHT_RAY_LIFETIME = 8.0
const LIGHT_RAY_SIZE_MIN = 0.2
const LIGHT_RAY_SIZE_MAX = 1.0
const LIGHT_RAY_COLOR = Color(1.0, 0.9, 0.7, 0.3)

const DEW_AMOUNT = 150
const DEW_LIFETIME = 15.0
const DEW_SIZE_MIN = 0.02
const DEW_SIZE_MAX = 0.08
const DEW_COLOR = Color(0.9, 0.95, 1.0, 0.7)

const POLLEN_AMOUNT = 80
const POLLEN_LIFETIME = 12.0
const POLLEN_SIZE_MIN = 0.01
const POLLEN_SIZE_MAX = 0.05
const POLLEN_COLOR = Color(1.0, 0.95, 0.8, 0.4)

# Node references
var mist_particles: GPUParticles3D
var light_ray_particles: GPUParticles3D
var dew_particles: GPUParticles3D
var pollen_particles: GPUParticles3D
var dawn_light: DirectionalLight3D

# Called when the node enters the scene tree
func _ready():
    # Create the particle systems
    _create_mist_particles()
    _create_light_ray_particles()
    _create_dew_particles()
    _create_pollen_particles()
    _create_dawn_light()
    
    # Start animation sequence
    _animate_dawn_sequence()

# Create low-lying mist particles
func _create_mist_particles():
    mist_particles = GPUParticles3D.new()
    mist_particles.name = "MistParticles"
    mist_particles.amount = MIST_AMOUNT
    mist_particles.lifetime = MIST_LIFETIME
    mist_particles.explosiveness = 0.0
    mist_particles.randomness = 0.5
    mist_particles.fixed_fps = 30
    mist_particles.visibility_aabb = AABB(Vector3(-30, -5, -30), Vector3(60, 10, 60))
    
    # Create particle material
    var material = ParticleProcessMaterial.new()
    material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    material.emission_box_extents = Vector3(30, 1, 30)
    material.direction = Vector3(0, 0.05, 0)
    material.spread = 10.0
    material.gravity = Vector3(0, -0.01, 0)
    material.initial_velocity_min = 0.1
    material.initial_velocity_max = 0.3
    material.angular_velocity_min = -0.1
    material.angular_velocity_max = 0.1
    material.scale_min = MIST_SIZE_MIN
    material.scale_max = MIST_SIZE_MAX
    material.color = MIST_COLOR
    
    # Create color gradient for fading
    var gradient = Gradient.new()
    gradient.add_point(0.0, Color(MIST_COLOR.r, MIST_COLOR.g, MIST_COLOR.b, 0.0))
    gradient.add_point(0.2, Color(MIST_COLOR.r, MIST_COLOR.g, MIST_COLOR.b, MIST_COLOR.a))
    gradient.add_point(0.8, Color(MIST_COLOR.r, MIST_COLOR.g, MIST_COLOR.b, MIST_COLOR.a))
    gradient.add_point(1.0, Color(MIST_COLOR.r, MIST_COLOR.g, MIST_COLOR.b, 0.0))
    
    var gradient_texture = GradientTexture1D.new()
    gradient_texture.gradient = gradient
    material.color_ramp = gradient_texture
    
    # Set up mesh for particles
    var mesh = QuadMesh.new()
    mesh.size = Vector2(1, 1)
    
    # Assign material and mesh to particles
    mist_particles.process_material = material
    mist_particles.draw_pass_1 = mesh
    
    # Add to scene
    add_child(mist_particles)
    mist_particles.emitting = true

# Create light ray particles
func _create_light_ray_particles():
    light_ray_particles = GPUParticles3D.new()
    light_ray_particles.name = "LightRayParticles"
    light_ray_particles.amount = LIGHT_RAY_AMOUNT
    light_ray_particles.lifetime = LIGHT_RAY_LIFETIME
    light_ray_particles.explosiveness = 0.0
    light_ray_particles.randomness = 0.7
    light_ray_particles.fixed_fps = 30
    light_ray_particles.visibility_aabb = AABB(Vector3(-30, 0, -30), Vector3(60, 40, 60))
    
    # Create particle material
    var material = ParticleProcessMaterial.new()
    material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    material.emission_box_extents = Vector3(30, 1, 30)
    material.direction = Vector3(0, -1, 0)
    material.spread = 15.0
    material.gravity = Vector3(0, -0.02, 0)
    material.initial_velocity_min = 0.5
    material.initial_velocity_max = 1.0
    material.scale_min = LIGHT_RAY_SIZE_MIN
    material.scale_max = LIGHT_RAY_SIZE_MAX
    material.color = LIGHT_RAY_COLOR
    
    # Create color gradient for fading
    var gradient = Gradient.new()
    gradient.add_point(0.0, Color(LIGHT_RAY_COLOR.r, LIGHT_RAY_COLOR.g, LIGHT_RAY_COLOR.b, 0.0))
    gradient.add_point(0.2, Color(LIGHT_RAY_COLOR.r, LIGHT_RAY_COLOR.g, LIGHT_RAY_COLOR.b, LIGHT_RAY_COLOR.a))
    gradient.add_point(0.8, Color(LIGHT_RAY_COLOR.r, LIGHT_RAY_COLOR.g, LIGHT_RAY_COLOR.b, LIGHT_RAY_COLOR.a))
    gradient.add_point(1.0, Color(LIGHT_RAY_COLOR.r, LIGHT_RAY_COLOR.g, LIGHT_RAY_COLOR.b, 0.0))
    
    var gradient_texture = GradientTexture1D.new()
    gradient_texture.gradient = gradient
    material.color_ramp = gradient_texture
    
    # Set up mesh for particles
    var mesh = QuadMesh.new()
    mesh.size = Vector2(1, 1)
    
    # Assign material and mesh to particles
    light_ray_particles.process_material = material
    light_ray_particles.draw_pass_1 = mesh
    
    # Position above the scene
    light_ray_particles.position = Vector3(0, 30, 0)
    
    # Add to scene
    add_child(light_ray_particles)
    light_ray_particles.emitting = true

# Create morning dew particles
func _create_dew_particles():
    dew_particles = GPUParticles3D.new()
    dew_particles.name = "DewParticles"
    dew_particles.amount = DEW_AMOUNT
    dew_particles.lifetime = DEW_LIFETIME
    dew_particles.explosiveness = 0.0
    dew_particles.randomness = 0.3
    dew_particles.fixed_fps = 30
    dew_particles.visibility_aabb = AABB(Vector3(-30, 0, -30), Vector3(60, 5, 60))
    
    # Create particle material
    var material = ParticleProcessMaterial.new()
    material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    material.emission_box_extents = Vector3(30, 0.1, 30)
    material.direction = Vector3(0, 0, 0)
    material.spread = 0.0
    material.gravity = Vector3(0, 0, 0)
    material.initial_velocity_min = 0.0
    material.initial_velocity_max = 0.0
    material.scale_min = DEW_SIZE_MIN
    material.scale_max = DEW_SIZE_MAX
    material.color = DEW_COLOR
    
    # Create color gradient for subtle pulsing
    var gradient = Gradient.new()
    gradient.add_point(0.0, Color(DEW_COLOR.r, DEW_COLOR.g, DEW_COLOR.b, DEW_COLOR.a * 0.7))
    gradient.add_point(0.5, Color(DEW_COLOR.r, DEW_COLOR.g, DEW_COLOR.b, DEW_COLOR.a))
    gradient.add_point(1.0, Color(DEW_COLOR.r, DEW_COLOR.g, DEW_COLOR.b, DEW_COLOR.a * 0.7))
    
    var gradient_texture = GradientTexture1D.new()
    gradient_texture.gradient = gradient
    material.color_ramp = gradient_texture
    
    # Set up mesh for particles
    var mesh = SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    
    # Assign material and mesh to particles
    dew_particles.process_material = material
    dew_particles.draw_pass_1 = mesh
    
    # Position at ground level
    dew_particles.position = Vector3(0, 0.5, 0)
    
    # Add to scene
    add_child(dew_particles)
    dew_particles.emitting = true

# Create pollen particles
func _create_pollen_particles():
    pollen_particles = GPUParticles3D.new()
    pollen_particles.name = "PollenParticles"
    pollen_particles.amount = POLLEN_AMOUNT
    pollen_particles.lifetime = POLLEN_LIFETIME
    pollen_particles.explosiveness = 0.0
    pollen_particles.randomness = 0.8
    pollen_particles.fixed_fps = 30
    pollen_particles.visibility_aabb = AABB(Vector3(-30, 0, -30), Vector3(60, 10, 60))
    
    # Create particle material
    var material = ParticleProcessMaterial.new()
    material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    material.emission_box_extents = Vector3(30, 5, 30)
    material.direction = Vector3(0, 0.01, 0)
    material.spread = 180.0
    material.gravity = Vector3(0, -0.001, 0)
    material.initial_velocity_min = 0.02
    material.initial_velocity_max = 0.05
    material.angular_velocity_min = -0.2
    material.angular_velocity_max = 0.2
    material.scale_min = POLLEN_SIZE_MIN
    material.scale_max = POLLEN_SIZE_MAX
    material.color = POLLEN_COLOR
    
    # Create color gradient for fading
    var gradient = Gradient.new()
    gradient.add_point(0.0, Color(POLLEN_COLOR.r, POLLEN_COLOR.g, POLLEN_COLOR.b, 0.0))
    gradient.add_point(0.1, Color(POLLEN_COLOR.r, POLLEN_COLOR.g, POLLEN_COLOR.b, POLLEN_COLOR.a))
    gradient.add_point(0.9, Color(POLLEN_COLOR.r, POLLEN_COLOR.g, POLLEN_COLOR.b, POLLEN_COLOR.a))
    gradient.add_point(1.0, Color(POLLEN_COLOR.r, POLLEN_COLOR.g, POLLEN_COLOR.b, 0.0))
    
    var gradient_texture = GradientTexture1D.new()
    gradient_texture.gradient = gradient
    material.color_ramp = gradient_texture
    
    # Set up mesh for particles
    var mesh = QuadMesh.new()
    mesh.size = Vector2(1, 1)
    
    # Assign material and mesh to particles
    pollen_particles.process_material = material
    pollen_particles.draw_pass_1 = mesh
    
    # Position above ground
    pollen_particles.position = Vector3(0, 2, 0)
    
    # Add to scene
    add_child(pollen_particles)
    pollen_particles.emitting = true

# Create dawn directional light
func _create_dawn_light():
    dawn_light = DirectionalLight3D.new()
    dawn_light.name = "DawnLight"
    dawn_light.light_color = Color(1.0, 0.8, 0.6)  # Warm amber light
    dawn_light.light_energy = 0.8
    dawn_light.shadow_enabled = true
    
    # Set light direction for dawn (low angle from horizon)
    dawn_light.rotation = Vector3(-PI/6, PI/4, 0)  # Angle from east-southeast
    
    # Add to scene
    add_child(dawn_light)
    
    # Animate the light
    _animate_dawn_light()

# Animate the dawn light
func _animate_dawn_light():
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_IN_OUT)
    
    # Gradually increase light intensity
    tween.tween_property(dawn_light, "light_energy", 1.2, 20.0)
    
    # Gradually change color from amber to more neutral
    tween.parallel().tween_property(dawn_light, "light_color", Color(1.0, 0.9, 0.8), 20.0)
    
    # Gradually raise the sun
    tween.parallel().tween_property(dawn_light, "rotation:x", -PI/3, 20.0)

# Animate the dawn sequence
func _animate_dawn_sequence():
    # Animate mist particles
    var mist_tween = create_tween()
    mist_tween.set_trans(Tween.TRANS_SINE)
    mist_tween.set_ease(Tween.EASE_IN_OUT)
    
    # Gradually reduce mist as sun rises
    mist_tween.tween_property(mist_particles.process_material, "emission_box_extents", Vector3(40, 0.5, 40), 10.0)
    mist_tween.tween_property(mist_particles, "amount", MIST_AMOUNT * 0.7, 15.0)
    mist_tween.tween_property(mist_particles, "amount", MIST_AMOUNT * 0.3, 15.0)
    
    # Animate light rays
    var ray_tween = create_tween()
    ray_tween.set_trans(Tween.TRANS_SINE)
    ray_tween.set_ease(Tween.EASE_IN_OUT)
    
    # Gradually increase light rays as sun rises
    ray_tween.tween_property(light_ray_particles, "amount", LIGHT_RAY_AMOUNT * 1.5, 10.0)
    ray_tween.tween_property(light_ray_particles.process_material, "initial_velocity_max", 1.5, 10.0)
    
    # Animate dew particles
    var dew_tween = create_tween()
    dew_tween.set_trans(Tween.TRANS_SINE)
    dew_tween.set_ease(Tween.EASE_IN_OUT)
    
    # Gradually reduce dew as sun rises
    dew_tween.tween_wait(20.0)  # Wait for sun to rise a bit
    dew_tween.tween_property(dew_particles, "amount", DEW_AMOUNT * 0.5, 15.0)
    dew_tween.tween_property(dew_particles, "amount", DEW_AMOUNT * 0.2, 15.0)
    
    # Animate pollen particles
    var pollen_tween = create_tween()
    pollen_tween.set_trans(Tween.TRANS_SINE)
    pollen_tween.set_ease(Tween.EASE_IN_OUT)
    
    # Gradually increase pollen as sun rises
    pollen_tween.tween_wait(10.0)  # Wait for sun to rise a bit
    pollen_tween.tween_property(pollen_particles, "amount", POLLEN_AMOUNT * 1.2, 10.0)
    pollen_tween.tween_property(pollen_particles.process_material, "initial_velocity_max", 0.08, 10.0)

# Public method to start the dawn sequence
func start_dawn_sequence():
    mist_particles.emitting = true
    light_ray_particles.emitting = true
    dew_particles.emitting = true
    pollen_particles.emitting = true
    _animate_dawn_sequence()
    _animate_dawn_light()

# Public method to stop the dawn sequence
func stop_dawn_sequence():
    mist_particles.emitting = false
    light_ray_particles.emitting = false
    dew_particles.emitting = false
    pollen_particles.emitting = false
