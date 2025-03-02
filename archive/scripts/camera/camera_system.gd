extends Node3D
class_name CameraSystem

# Signals
signal mode_changed(mode)

# Camera modes
enum CameraMode {
	BUILD,  # Top-down view for building
	EXPLORE  # First-person view for exploring
}

# Current camera mode
var current_mode = CameraMode.BUILD

# Camera nodes
var build_camera: Camera3D
var explore_camera: Camera3D

# Camera movement parameters
var build_camera_height = 15.0
var build_camera_distance = 15.0
var build_camera_angle = 45.0  # Degrees
var build_camera_rotation_speed = 0.5
var build_camera_zoom_speed = 0.5
var build_camera_pan_speed = 0.2

var explore_camera_height = 1.7  # Eye level
var explore_camera_move_speed = 5.0
var explore_camera_rotation_speed = 0.2

# Camera limits
var min_zoom = 5.0
var max_zoom = 30.0
var min_height = 5.0
var max_height = 30.0

# Camera target position (for smooth movement)
var build_target_position = Vector3.ZERO
var build_target_rotation = 0.0
var build_target_zoom = 15.0

# Player movement in explore mode
var explore_velocity = Vector3.ZERO
var explore_gravity = 9.8
var explore_jump_height = 1.0

# Reference to the terrain generator for height queries
var terrain_generator: TerrainGenerator

# Mouse state
var mouse_position = Vector2.ZERO
var right_mouse_pressed = false
var middle_mouse_pressed = false

func _ready():
	# Create build camera (top-down, tilt-shift)
	build_camera = Camera3D.new()
	build_camera.current = true
	build_camera.fov = 45.0
	add_child(build_camera)
	
	# Create explore camera (first-person)
	explore_camera = Camera3D.new()
	explore_camera.current = false
	explore_camera.fov = 70.0
	add_child(explore_camera)
	
	# Set initial camera positions
	_update_build_camera_transform()
	_update_explore_camera_transform()

func set_terrain_generator(generator: TerrainGenerator):
	terrain_generator = generator

func _process(delta):
	# Handle camera movement based on current mode
	if current_mode == CameraMode.BUILD:
		_process_build_camera(delta)
	else:
		_process_explore_camera(delta)

func _process_build_camera(delta):
	# Smooth camera movement towards target
	var current_pos = build_camera.global_position
	var target_pos = _calculate_build_camera_position()
	
	build_camera.global_position = current_pos.lerp(target_pos, delta * 5.0)
	build_camera.look_at(Vector3(build_target_position.x, 0, build_target_position.z), Vector3.UP)

func _process_explore_camera(delta):
	# Apply gravity in explore mode
	if not is_on_floor():
		explore_velocity.y -= explore_gravity * delta
	
	# Move the camera based on velocity
	var collision = move_and_collide(explore_velocity * delta)
	if collision:
		explore_velocity = explore_velocity.slide(collision.get_normal())

func _calculate_build_camera_position() -> Vector3:
	# Calculate the position based on target position, rotation, and zoom
	var angle_rad = deg_to_rad(build_camera_angle)
	var horizontal_distance = build_target_zoom * cos(angle_rad)
	var vertical_distance = build_target_zoom * sin(angle_rad)
	
	var rotation_rad = deg_to_rad(build_target_rotation)
	var offset = Vector3(
		horizontal_distance * sin(rotation_rad),
		vertical_distance,
		horizontal_distance * cos(rotation_rad)
	)
	
	return build_target_position + offset

func _update_build_camera_transform():
	build_camera.global_position = _calculate_build_camera_position()
	build_camera.look_at(Vector3(build_target_position.x, 0, build_target_position.z), Vector3.UP)

func _update_explore_camera_transform():
	if terrain_generator:
		var pos = explore_camera.global_position
		var height = terrain_generator.get_height_at_position(pos.x, pos.z)
		explore_camera.global_position.y = height + explore_camera_height

func _input(event):
	# Track mouse position
	if event is InputEventMouseMotion:
		mouse_position = event.position
		
		# Rotate camera in build mode with right mouse button
		if current_mode == CameraMode.BUILD and right_mouse_pressed:
			build_target_rotation -= event.relative.x * build_camera_rotation_speed
			_update_build_camera_transform()
		
		# Pan camera in build mode with middle mouse button
		if current_mode == CameraMode.BUILD and middle_mouse_pressed:
			var camera_basis = build_camera.global_transform.basis
			var right = camera_basis.x.normalized()
			var forward = -camera_basis.z.normalized()
			forward.y = 0
			forward = forward.normalized()
			
			build_target_position -= right * event.relative.x * build_camera_pan_speed
			build_target_position -= forward * event.relative.y * build_camera_pan_speed
			_update_build_camera_transform()
		
		# Rotate camera in explore mode
		if current_mode == CameraMode.EXPLORE:
			explore_camera.rotation.y -= event.relative.x * explore_camera_rotation_speed * 0.01
			explore_camera.rotation.x -= event.relative.y * explore_camera_rotation_speed * 0.01
			explore_camera.rotation.x = clamp(explore_camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	# Handle mouse button events
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			right_mouse_pressed = event.pressed
		
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			middle_mouse_pressed = event.pressed
		
		# Zoom with mouse wheel in build mode
		if current_mode == CameraMode.BUILD:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				build_target_zoom = max(min_zoom, build_target_zoom - build_camera_zoom_speed)
				_update_build_camera_transform()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				build_target_zoom = min(max_zoom, build_target_zoom + build_camera_zoom_speed)
				_update_build_camera_transform()

func _physics_process(delta):
	# Handle keyboard input for camera movement
	if current_mode == CameraMode.BUILD:
		_handle_build_keyboard_input(delta)
	else:
		_handle_explore_keyboard_input(delta)

func _handle_build_keyboard_input(delta):
	var input_dir = Vector3.ZERO
	
	# WASD keys for panning
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_dir.z -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_dir.z += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	
	# QE keys for rotating
	if Input.is_key_pressed(KEY_Q):
		build_target_rotation += build_camera_rotation_speed * 2.0
	if Input.is_key_pressed(KEY_E):
		build_target_rotation -= build_camera_rotation_speed * 2.0
	
	# RF keys for height adjustment
	if Input.is_key_pressed(KEY_R):
		build_camera_angle = min(80, build_camera_angle + 1)
	if Input.is_key_pressed(KEY_F):
		build_camera_angle = max(20, build_camera_angle - 1)
	
	# Apply movement
	if input_dir.length_squared() > 0:
		input_dir = input_dir.normalized()
		
		# Transform input direction to camera space
		var camera_basis = build_camera.global_transform.basis
		var right = camera_basis.x.normalized()
		var forward = -camera_basis.z.normalized()
		forward.y = 0
		forward = forward.normalized()
		
		var movement = right * input_dir.x + forward * input_dir.z
		build_target_position += movement * build_camera_pan_speed * build_target_zoom * delta * 10.0
		
		_update_build_camera_transform()

func _handle_explore_keyboard_input(delta):
	var input_dir = Vector3.ZERO
	
	# WASD keys for movement
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_dir.z -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_dir.z += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	
	# Space for jump
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE):
		if is_on_floor():
			explore_velocity.y = sqrt(2 * explore_gravity * explore_jump_height)
	
	# Transform input direction to camera space
	if input_dir.length_squared() > 0:
		input_dir = input_dir.normalized()
		
		var camera_basis = explore_camera.global_transform.basis
		var forward = -camera_basis.z
		forward.y = 0
		forward = forward.normalized()
		var right = camera_basis.x.normalized()
		
		var movement = forward * input_dir.z + right * input_dir.x
		explore_velocity.x = movement.x * explore_camera_move_speed
		explore_velocity.z = movement.z * explore_camera_move_speed
	else:
		explore_velocity.x = 0
		explore_velocity.z = 0

func switch_mode():
	if current_mode == CameraMode.BUILD:
		# Switch to explore mode
		current_mode = CameraMode.EXPLORE
		
		# Position the explore camera at a reasonable position
		explore_camera.global_position = Vector3(
			build_target_position.x,
			0,
			build_target_position.z
		)
		
		# Adjust height based on terrain
		if terrain_generator:
			var height = terrain_generator.get_height_at_position(
				explore_camera.global_position.x,
				explore_camera.global_position.z
			)
			explore_camera.global_position.y = height + explore_camera_height
		
		# Make explore camera active
		build_camera.current = false
		explore_camera.current = true
		
		# Reset velocity
		explore_velocity = Vector3.ZERO
	else:
		# Switch to build mode
		current_mode = CameraMode.BUILD
		
		# Update build camera target position to be above the explore camera
		build_target_position = Vector3(
			explore_camera.global_position.x,
			0,
			explore_camera.global_position.z
		)
		
		# Make build camera active
		explore_camera.current = false
		build_camera.current = true
		_update_build_camera_transform()
	
	# Emit signal
	emit_signal("mode_changed", current_mode)

func is_on_floor() -> bool:
	# Simple check if the camera is on the floor
	if terrain_generator:
		var pos = explore_camera.global_position
		var terrain_height = terrain_generator.get_height_at_position(pos.x, pos.z)
		return abs(pos.y - (terrain_height + explore_camera_height)) < 0.1
	
	return false

func move_and_collide(velocity: Vector3) -> Dictionary:
	# Simple collision detection with the terrain
	var new_pos = explore_camera.global_position + velocity
	
	if terrain_generator:
		var terrain_height = terrain_generator.get_height_at_position(new_pos.x, new_pos.z)
		
		# Check if we're going below the terrain
		if new_pos.y < terrain_height + explore_camera_height:
			new_pos.y = terrain_height + explore_camera_height
			
			# Return collision information
			if velocity.y < 0:
				explore_camera.global_position = new_pos
				return {
					"get_normal": func(): return Vector3(0, 1, 0)
				}
	
	# No collision, just move
	explore_camera.global_position = new_pos
	return {}
