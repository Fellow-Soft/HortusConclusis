extends Node3D
class_name CameraSystemEnhanced

# Constants
const UP_VECTOR = Vector3(0, 1, 0)

# Camera movement types
enum MovementType {
    LINEAR,        # Simple linear movement along path
    EASE_IN_OUT,   # Smooth acceleration and deceleration
    SINE_WAVE,     # Gentle oscillating movement
    BREATHE,       # Camera movement that mimics breathing
    ORBIT,         # Circular movement around a target
    DOLLY_ZOOM,    # Zoom effect while moving forward/backward
    CRANE,         # Vertical arc movement
    REVEAL         # Slow reveal movement
}

# Camera transition types
enum TransitionType {
    CUT,           # Immediate transition
    FADE,          # Fade to black and back
    DISSOLVE,      # Dissolve between cameras
    SWIPE,         # Directional swipe transition
    ZOOM,          # Zoom in/out transition
    BLUR,          # Blur transition
    IRIS           # Iris transition
}

# Camera path node
var path: Path3D
var path_follow: PathFollow3D
var camera: Camera3D

# Camera movement parameters
var movement_type: MovementType = MovementType.LINEAR
var movement_speed: float = 0.1
var is_moving: bool = false
var target_position: Vector3
var target_rotation: Vector3
var transition_duration: float = 1.0
var transition_type: TransitionType = TransitionType.FADE
var orbit_target: Node3D
var orbit_distance: float = 10.0
var orbit_height: float = 5.0
var orbit_speed: float = 0.5

# Camera effects parameters
var shake_trauma: float = 0.0
var shake_decay: float = 0.8
var noise: FastNoiseLite
var noise_y: float = 0.0
var tilt_amount: float = 0.0
var tilt_recovery_speed: float = 1.0
var fov_default: float = 75.0
var fov_target: float = 75.0
var fov_speed: float = 1.0
var dof_enabled: bool = false
var dof_target: Node3D
var dof_distance: float = 5.0
var dof_transition_speed: float = 1.0
var chromatic_aberration: float = 0.0
var vignette_intensity: float = 0.0
var bloom_intensity: float = 0.0

# Signals
signal camera_reached_target
signal transition_completed
signal movement_completed

# Called when the node enters the scene tree for the first time
func _ready():
    # Initialize noise for camera shake
    noise = FastNoiseLite.new()
    noise.seed = randi()
    noise.frequency = 0.5

# Look at target
func look_at_target(target: Node3D, duration: float = 1.0):
    if not camera or not target:
        return
    
    var target_transform = camera.global_transform.looking_at(target.global_position, UP_VECTOR)
    var target_rotation = target_transform.basis.get_euler()
    
    # Create tween for rotation
    var tween = create_tween()
    tween.tween_property(camera, "rotation", target_rotation, duration)

# Start camera movement along path
func start_movement(speed: float = 0.1, type: MovementType = MovementType.LINEAR):
    if not path or not path_follow:
        return
    
    movement_speed = speed
    movement_type = type
    is_moving = true

# Stop camera movement
func stop_movement():
    is_moving = false

# Set camera position directly
func set_camera_position(position: Vector3):
    if camera:
        camera.global_position = position

# Set camera rotation directly
func set_camera_rotation(rotation: Vector3):
    if camera:
        camera.rotation = rotation

# Move camera to target position with transition
func move_to_position(position: Vector3, duration: float = 1.0, transition: TransitionType = TransitionType.FADE):
    if not camera:
        return
    
    target_position = position
    transition_duration = duration
    transition_type = transition
    
    # Create tween for movement
    var tween = create_tween()
    tween.tween_property(camera, "global_position", position, duration)
    tween.tween_callback(Callable(self, "_on_camera_reached_target"))

# Rotate camera to target rotation
func rotate_to(rotation: Vector3, duration: float = 1.0):
    if not camera:
        return
    
    target_rotation = rotation
    
    # Create tween for rotation
    var tween = create_tween()
    tween.tween_property(camera, "rotation", rotation, duration)

# Start orbiting around target
func start_orbiting(target: Node3D, distance: float = 10.0, height: float = 5.0, speed: float = 0.5):
    if not camera or not target:
        return
    
    movement_type = MovementType.ORBIT
    orbit_target = target
    orbit_distance = distance
    orbit_height = height
    orbit_speed = speed
    is_moving = true

# Add camera shake effect
func add_shake(amount: float = 0.5):
    shake_trauma = min(shake_trauma + amount, 1.0)

# Set camera tilt
func set_tilt(amount: float = 0.1, recovery_speed: float = 1.0):
    tilt_amount = amount
    tilt_recovery_speed = recovery_speed

# Set camera field of view
func set_fov(fov: float = 75.0, speed: float = 1.0):
    if not camera:
        return
    
    fov_target = fov
    fov_speed = speed

# Enable depth of field effect
func enable_dof(target: Node3D = null, distance: float = 5.0, transition_speed: float = 1.0):
    if not camera:
        return
    
    dof_enabled = true
    dof_target = target
    dof_distance = distance
    dof_transition_speed = transition_speed

# Disable depth of field effect
func disable_dof(transition_speed: float = 1.0):
    dof_enabled = false
    dof_transition_speed = transition_speed

# Set post-processing effects
func set_post_processing(chromatic: float = 0.0, vignette: float = 0.0, bloom: float = 0.0):
    chromatic_aberration = chromatic
    vignette_intensity = vignette
    bloom_intensity = bloom

# Create a cinematic sequence with multiple camera movements
func create_cinematic_sequence(sequence_data: Array):
    # Stop any current movement
    stop_movement()
    
    # Create a sequence of camera movements
    var sequence_tween = create_tween()
    
    for step in sequence_data:
        match step.type:
            "position":
                sequence_tween.tween_property(camera, "global_position", step.position, step.duration)
            "rotation":
                sequence_tween.tween_property(camera, "rotation", step.rotation, step.duration)
            "fov":
                sequence_tween.tween_property(camera, "fov", step.fov, step.duration)
            "shake":
                sequence_tween.tween_callback(Callable(self, "add_shake").bind(step.amount))
            "wait":
                sequence_tween.tween_interval(step.duration)
            "look_at":
                if step.target:
                    var target_transform = camera.global_transform.looking_at(step.target.global_position, UP_VECTOR)
                    var target_rotation = target_transform.basis.get_euler()
                    sequence_tween.tween_property(camera, "rotation", target_rotation, step.duration)
    
    sequence_tween.tween_callback(Callable(self, "_on_sequence_completed"))

# Update linear movement along path
func _update_linear_movement(delta):
    if not is_moving or not path_follow:
        return
    
    path_follow.progress += movement_speed * delta

# Update ease in/out movement along path
func _update_ease_in_out_movement(delta):
    if not is_moving or not path_follow:
        return
    
    # Calculate eased speed
    var progress_ratio = path_follow.progress_ratio
    var ease_factor = sin(progress_ratio * PI)
    var adjusted_speed = movement_speed * ease_factor
    
    path_follow.progress += adjusted_speed * delta

# Update sine wave movement along path
func _update_sine_wave_movement(delta):
    if not is_moving or not path_follow:
        return
    
    # Add sine wave motion to camera height
    path_follow.progress += movement_speed * delta
    
    if camera:
        var sine_offset = sin(Time.get_ticks_msec() * 0.001) * 0.5
        camera.position.y = sine_offset

# Update breathe movement (gentle rise and fall)
func _update_breathe_movement(delta):
    if not is_moving or not path_follow:
        return
    
    path_follow.progress += movement_speed * delta
    
    if camera:
        # Simulate breathing with slower sine wave
        var breathe_offset = sin(Time.get_ticks_msec() * 0.0005) * 0.3
        camera.position.y = breathe_offset
        
        # Slight forward/backward motion
        var forward_offset = sin(Time.get_ticks_msec() * 0.0003) * 0.2
        camera.position.z = forward_offset

# Update orbit movement around target
func _update_orbit_movement(delta):
    if not is_moving or not orbit_target:
        return
    
    var angle = Time.get_ticks_msec() * 0.001 * orbit_speed
    var orbit_pos = Vector3(
        cos(angle) * orbit_distance,
        orbit_height,
        sin(angle) * orbit_distance
    )
    
    if camera:
        camera.global_position = orbit_target.global_position + orbit_pos
        camera.look_at(orbit_target.global_position, UP_VECTOR)

# Update dolly zoom effect (zoom while moving)
func _update_dolly_zoom_movement(delta):
    if not is_moving or not path_follow or not camera:
        return
    
    path_follow.progress += movement_speed * delta
    
    # Calculate FOV based on distance
    var progress = path_follow.progress_ratio
    var fov_range = 40.0  # Range of FOV change
    camera.fov = fov_default - progress * fov_range

# Update crane movement (vertical arc)
func _update_crane_movement(delta):
    if not is_moving or not path_follow:
        return
    
    path_follow.progress += movement_speed * delta
    
    if camera:
        # Calculate vertical arc position
        var progress = path_follow.progress_ratio
        var height_offset = sin(progress * PI) * 5.0
        camera.position.y = height_offset
        
        # Adjust camera angle to look slightly down/up
        var tilt_angle = -sin(progress * PI) * 0.3
        camera.rotation.x = tilt_angle

# Update reveal movement (slow, dramatic reveal)
func _update_reveal_movement(delta):
    if not is_moving or not path_follow:
        return
    
    # Slower at start, faster at end
    var progress = path_follow.progress_ratio
    var speed_factor = 0.5 + progress * 2.0
    path_follow.progress += movement_speed * speed_factor * delta
    
    if camera:
        # Gradually tilt up
        var tilt_progress = min(1.0, progress * 2.0)
        camera.rotation.x = lerp(-0.2, 0.0, tilt_progress)

# Update camera shake effect
func _update_camera_shake(delta):
    if not camera or shake_trauma <= 0:
        return
    
    # Decay trauma over time
    shake_trauma = max(0, shake_trauma - shake_decay * delta)
    
    # Calculate shake amount (squared for more natural feel)
    var shake_amount = shake_trauma * shake_trauma
    
    # Update noise sample
    noise_y += delta * 10.0
    
    # Apply noise-based shake
    var shake_offset = Vector3(
        noise.get_noise_2d(noise.seed, noise_y) * shake_amount,
        noise.get_noise_2d(noise.seed * 2, noise_y) * shake_amount,
        0
    ) * 0.5
    
    camera.position = shake_offset

# Update camera tilt effect
func _update_camera_tilt(delta):
    if not camera or tilt_amount == 0:
        return
    
    # Apply tilt
    camera.rotation.z = tilt_amount
    
    # Recover tilt over time
    tilt_amount = move_toward(tilt_amount, 0, tilt_recovery_speed * delta)

# Update camera field of view
func _update_camera_fov(delta):
    if not camera or camera.fov == fov_target:
        return
    
    # Smoothly adjust FOV
    camera.fov = lerp(camera.fov, fov_target, fov_speed * delta)

# Update depth of field effect
func _update_dof_effect(delta):
    if not camera:
        return
    
    # Get environment
    var environment = get_viewport().world_3d.environment
    if not environment:
        return
    
    # Update DOF settings - using Godot 4 property names
    if dof_enabled:
        # Use the correct property names for Godot 4
        # Check if the property exists before setting it
        if "dof_blur_far_enabled" in environment:
            environment.dof_blur_far_enabled = true
        else:
            # Alternative property names in Godot 4
            environment.set("dof_blur_enabled", true)
            
        # Calculate focus distance if target is set
        if dof_target:
            var distance_to_target = camera.global_position.distance_to(dof_target.global_position)
            dof_distance = lerp(dof_distance, distance_to_target, dof_transition_speed * delta)
        
        # Try different property names for distance
        if "dof_blur_far_distance" in environment:
            environment.dof_blur_far_distance = dof_distance
        else:
            # Alternative property names in Godot 4
            environment.set("dof_blur_distance", dof_distance)
    else:
        # Disable DOF using the appropriate property
        if "dof_blur_far_enabled" in environment:
            environment.dof_blur_far_enabled = false
        else:
            # Alternative property names in Godot 4
            environment.set("dof_blur_enabled", false)

# Update post-processing effects
func _update_post_processing(delta):
    # Get environment
    var environment = get_viewport().world_3d.environment
    if not environment:
        return
    
    # Update chromatic aberration
    # Note: This would require a custom shader in Godot 4
    
    # Update vignette
    # Note: This would require a custom shader in Godot 4
    
    # Update bloom
    environment.glow_enabled = bloom_intensity > 0
    environment.glow_intensity = bloom_intensity
    environment.glow_bloom = bloom_intensity * 0.5

# Signal callbacks
func _on_camera_reached_target():
    emit_signal("camera_reached_target")

func _on_transition_completed():
    emit_signal("transition_completed")

func _on_sequence_completed():
    emit_signal("movement_completed")

# Create a dramatic reveal sequence
func create_dramatic_reveal_sequence(target: Node3D, duration: float = 10.0):
    if not camera or not target:
        return
    
    # Start position (hidden)
    var start_pos = target.global_position + Vector3(-5, 1, -5)
    var mid_pos = target.global_position + Vector3(-3, 2, -3)
    var end_pos = target.global_position + Vector3(0, 3, -5)
    
    # Create sequence
    var sequence = [
        {
            "type": "position",
            "position": start_pos,
            "duration": 0.1
        },
        {
            "type": "look_at",
            "target": target,
            "duration": 1.0
        },
        {
            "type": "wait",
            "duration": 1.0
        },
        {
            "type": "position",
            "position": mid_pos,
            "duration": duration * 0.4
        },
        {
            "type": "position",
            "position": end_pos,
            "duration": duration * 0.6
        },
        {
            "type": "fov",
            "fov": 65.0,
            "duration": duration * 0.5
        }
    ]
    
    create_cinematic_sequence(sequence)

# Called every frame to update camera
func _process(delta):
    if not camera:
        return
    
    # Update camera movement
    match movement_type:
        MovementType.LINEAR:
            _update_linear_movement(delta)
        MovementType.EASE_IN_OUT:
            _update_ease_in_out_movement(delta)
        MovementType.SINE_WAVE:
            _update_sine_wave_movement(delta)
        MovementType.BREATHE:
            _update_breathe_movement(delta)
        MovementType.ORBIT:
            _update_orbit_movement(delta)
        MovementType.DOLLY_ZOOM:
            _update_dolly_zoom_movement(delta)
        MovementType.CRANE:
            _update_crane_movement(delta)
        MovementType.REVEAL:
            _update_reveal_movement(delta)
    
    # Update camera effects
    _update_camera_shake(delta)
    _update_camera_tilt(delta)
    _update_camera_fov(delta)
    _update_dof_effect(delta)
    _update_post_processing(delta)
