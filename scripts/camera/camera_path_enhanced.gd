extends Path3D
class_name CameraPathEnhanced

# Constants
const UP_VECTOR = Vector3(0, 1, 0)

# Path follow node
@onready var path_follow = $PathFollow3D

# Camera movement parameters
var movement_speed: float = 0.1
var is_moving: bool = false
var loop_path: bool = true

# Enhanced movement parameters
var speed_profile: Array = []  # Array of {position, speed} dictionaries
var height_profile: Array = []  # Array of {position, height} dictionaries
var focus_points: Array = []   # Array of {position, target} dictionaries
var current_focus_target: Node3D = null
var current_focus_weight: float = 0.0
var focus_transition_speed: float = 2.0

# Interpolation parameters
var ease_in_distance: float = 0.1  # Percentage of path for easing in
var ease_out_distance: float = 0.1  # Percentage of path for easing out
var use_ease_in_out: bool = true
var use_catmull_rom: bool = true  # Use Catmull-Rom interpolation for smoother curves

# Micro-movement parameters
var breathing_enabled: bool = false
var breathing_amplitude: float = 0.05
var breathing_frequency: float = 0.5
var micro_shake_enabled: bool = false
var micro_shake_amplitude: float = 0.02
var micro_shake_frequency: float = 2.0

# Noise generator for natural movement
var noise: FastNoiseLite

# Signals
signal point_of_interest_reached(point_name)
signal path_completed
signal focus_changed(target)

# Called when the node enters the scene tree for the first time
func _ready():
	# Ensure path follow is at the start
	path_follow.progress_ratio = 0.0
	
	# Initialize noise for natural movement
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.5

# Start camera movement along the path
func start_movement(speed: float = 0.1):
	movement_speed = speed
	is_moving = true

# Stop camera movement
func stop_movement():
	is_moving = false

# Set camera position directly to a specific point on the path
func set_camera_position(ratio: float):
	path_follow.progress_ratio = clamp(ratio, 0.0, 1.0)
	_update_height_at_current_position()
	_update_focus_at_current_position()

# Add a speed change point to the speed profile
func add_speed_point(position_ratio: float, speed: float):
	speed_profile.append({
		"position": position_ratio,
		"speed": speed
	})
	# Sort by position
	speed_profile.sort_custom(Callable(self, "_sort_by_position"))

# Add a height adjustment point to the height profile
func add_height_point(position_ratio: float, height: float):
	height_profile.append({
		"position": position_ratio,
		"height": height
	})
	# Sort by position
	height_profile.sort_custom(Callable(self, "_sort_by_position"))

# Add a focus point to the focus points array
func add_focus_point(position_ratio: float, target: Node3D, transition_duration: float = 1.0):
	focus_points.append({
		"position": position_ratio,
		"target": target,
		"transition_duration": transition_duration
	})
	# Sort by position
	focus_points.sort_custom(Callable(self, "_sort_by_position"))

# Add a point of interest that will trigger a signal when reached
func add_point_of_interest(position_ratio: float, point_name: String):
	var point = {
		"position": position_ratio,
		"name": point_name,
		"triggered": false
	}
	
	# Store in a separate array if not already present
	if not hasattr(self, "points_of_interest"):
		self.points_of_interest = []
	
	self.points_of_interest.append(point)
	# Sort by position
	self.points_of_interest.sort_custom(Callable(self, "_sort_by_position"))

# Enable breathing-like micro-movement
func enable_breathing(amplitude: float = 0.05, frequency: float = 0.5):
	breathing_enabled = true
	breathing_amplitude = amplitude
	breathing_frequency = frequency

# Disable breathing-like micro-movement
func disable_breathing():
	breathing_enabled = false

# Enable micro-shake for subtle camera movement
func enable_micro_shake(amplitude: float = 0.02, frequency: float = 2.0):
	micro_shake_enabled = true
	micro_shake_amplitude = amplitude
	micro_shake_frequency = frequency

# Disable micro-shake
func disable_micro_shake():
	micro_shake_enabled = false

# Set interpolation method
func set_interpolation(use_ease: bool = true, use_catmull: bool = true):
	use_ease_in_out = use_ease
	use_catmull_rom = use_catmull

# Set ease in/out distances (as percentage of path)
func set_ease_distances(ease_in: float = 0.1, ease_out: float = 0.1):
	ease_in_distance = clamp(ease_in, 0.0, 0.5)
	ease_out_distance = clamp(ease_out, 0.0, 0.5)

# Create a dramatic reveal sequence
func create_dramatic_reveal_sequence(target_position_ratio: float, duration: float = 10.0):
	# Clear existing profiles
	speed_profile.clear()
	height_profile.clear()
	
	# Create a sequence that starts slow, speeds up, then slows down for the reveal
	var start_speed = movement_speed * 0.5
	var mid_speed = movement_speed * 2.0
	var end_speed = movement_speed * 0.3
	
	# Add speed points
	add_speed_point(0.0, start_speed)
	add_speed_point(0.3, mid_speed)
	add_speed_point(0.7, mid_speed)
	add_speed_point(0.9, end_speed)
	
	# Add height variation
	var base_height = 0.0
	add_height_point(0.0, base_height)
	add_height_point(0.2, base_height + 1.0)
	add_height_point(0.5, base_height + 2.0)
	add_height_point(0.7, base_height + 1.5)
	add_height_point(0.9, base_height + 3.0)
	
	# Calculate total path length
	var path_length = curve.get_baked_length()
	
	# Adjust movement speed to complete in the specified duration
	var avg_speed = path_length / duration
	movement_speed = avg_speed
	
	# Start movement
	start_movement()

# Create a contemplative sequence with slow, measured movement
func create_contemplative_sequence(duration: float = 30.0):
	# Clear existing profiles
	speed_profile.clear()
	height_profile.clear()
	
	# Create a sequence with very gentle speed changes
	var base_speed = movement_speed * 0.7
	
	# Add speed points for gentle undulation
	add_speed_point(0.0, base_speed)
	add_speed_point(0.2, base_speed * 0.8)
	add_speed_point(0.4, base_speed * 1.1)
	add_speed_point(0.6, base_speed * 0.9)
	add_speed_point(0.8, base_speed * 1.2)
	add_speed_point(1.0, base_speed)
	
	# Add subtle height variation
	var base_height = 0.0
	add_height_point(0.0, base_height)
	add_height_point(0.3, base_height + 0.5)
	add_height_point(0.5, base_height + 0.2)
	add_height_point(0.7, base_height + 0.7)
	add_height_point(1.0, base_height)
	
	# Enable breathing for contemplative feel
	enable_breathing(0.03, 0.3)
	
	# Calculate total path length
	var path_length = curve.get_baked_length()
	
	# Adjust movement speed to complete in the specified duration
	var avg_speed = path_length / duration
	movement_speed = avg_speed
	
	# Start movement
	start_movement()

# Create a dynamic sequence with varied movement
func create_dynamic_sequence(duration: float = 20.0):
	# Clear existing profiles
	speed_profile.clear()
	height_profile.clear()
	
	# Create a sequence with dramatic speed changes
	var base_speed = movement_speed
	
	# Add speed points for dynamic movement
	add_speed_point(0.0, base_speed)
	add_speed_point(0.1, base_speed * 2.0)
	add_speed_point(0.3, base_speed * 0.5)
	add_speed_point(0.5, base_speed * 3.0)
	add_speed_point(0.7, base_speed * 1.0)
	add_speed_point(0.9, base_speed * 2.5)
	add_speed_point(1.0, base_speed * 0.7)
	
	# Add dramatic height variation
	var base_height = 0.0
	add_height_point(0.0, base_height)
	add_height_point(0.2, base_height + 3.0)
	add_height_point(0.4, base_height - 1.0)
	add_height_point(0.6, base_height + 4.0)
	add_height_point(0.8, base_height + 0.5)
	add_height_point(1.0, base_height + 2.0)
	
	# Enable micro-shake for dynamic feel
	enable_micro_shake(0.04, 3.0)
	
	# Calculate total path length
	var path_length = curve.get_baked_length()
	
	# Adjust movement speed to complete in the specified duration
	var avg_speed = path_length / duration
	movement_speed = avg_speed
	
	# Start movement
	start_movement()

# Process function for continuous movement
func _process(delta):
	if is_moving:
		# Get current position ratio
		var current_ratio = path_follow.progress_ratio
		
		# Check for points of interest
		_check_points_of_interest(current_ratio)
		
		# Calculate speed at current position
		var current_speed = _get_speed_at_position(current_ratio)
		
		# Apply ease in/out if enabled
		if use_ease_in_out:
			current_speed = _apply_ease_in_out(current_ratio, current_speed)
		
		# Update path follow position
		path_follow.progress += current_speed * delta
		
		# Update height based on height profile
		_update_height_at_current_position()
		
		# Update focus based on focus points
		_update_focus_at_current_position()
		
		# Apply micro-movements
		_apply_micro_movements(delta)
		
		# Handle path completion
		if path_follow.progress_ratio >= 1.0:
			if loop_path:
				path_follow.progress_ratio = 0.0
			else:
				is_moving = false
				emit_signal("path_completed")

# Check if any points of interest have been reached
func _check_points_of_interest(current_ratio: float):
	if not hasattr(self, "points_of_interest"):
		return
		
	for point in self.points_of_interest:
		if not point.triggered and current_ratio >= point.position:
			point.triggered = true
			emit_signal("point_of_interest_reached", point.name)

# Get interpolated speed at the current position
func _get_speed_at_position(position_ratio: float) -> float:
	if speed_profile.size() == 0:
		return movement_speed
	
	# Find the two points that surround the current position
	var prev_point = null
	var next_point = null
	
	for point in speed_profile:
		if point.position <= position_ratio:
			prev_point = point
		else:
			next_point = point
			break
	
	# Handle edge cases
	if prev_point == null:
		return speed_profile[0].speed
	if next_point == null:
		return prev_point.speed
	
	# Interpolate between the two points
	var t = (position_ratio - prev_point.position) / (next_point.position - prev_point.position)
	return lerp(prev_point.speed, next_point.speed, t)

# Apply ease in/out to speed
func _apply_ease_in_out(position_ratio: float, current_speed: float) -> float:
	# Ease in at the beginning
	if position_ratio < ease_in_distance:
		var t = position_ratio / ease_in_distance
		return current_speed * ease(t, 0.5)  # Using 0.5 for cubic ease in/out
	
	# Ease out at the end
	if position_ratio > (1.0 - ease_out_distance):
		var t = (position_ratio - (1.0 - ease_out_distance)) / ease_out_distance
		return current_speed * (1.0 - ease(t, 0.5))  # Using 0.5 for cubic ease in/out
	
	return current_speed

# Ease function (cubic ease in/out)
func ease(t: float, type: float = 0.5) -> float:
	if t < 0.5:
		return 4 * t * t * t
	else:
		return 1 - pow(-2 * t + 2, 3) / 2

# Update camera height based on height profile
func _update_height_at_current_position():
	if height_profile.size() == 0 or not path_follow.get_child_count() > 0:
		return
	
	var camera = path_follow.get_child(0)
	var position_ratio = path_follow.progress_ratio
	
	# Find the two points that surround the current position
	var prev_point = null
	var next_point = null
	
	for point in height_profile:
		if point.position <= position_ratio:
			prev_point = point
		else:
			next_point = point
			break
	
	# Handle edge cases
	if prev_point == null:
		camera.position.y = height_profile[0].height
		return
	if next_point == null:
		camera.position.y = prev_point.height
		return
	
	# Interpolate between the two points
	var t = (position_ratio - prev_point.position) / (next_point.position - prev_point.position)
	camera.position.y = lerp(prev_point.height, next_point.height, t)

# Update camera focus based on focus points
func _update_focus_at_current_position():
	if focus_points.size() == 0 or not path_follow.get_child_count() > 0:
		return
	
	var camera = path_follow.get_child(0)
	var position_ratio = path_follow.progress_ratio
	
	# Find the active focus point
	var active_focus = null
	
	for point in focus_points:
		if position_ratio >= point.position:
			active_focus = point
		else:
			break
	
	# If no focus point is active or the focus hasn't changed, return
	if active_focus == null or (current_focus_target == active_focus.target and current_focus_weight >= 1.0):
		return
	
	# If focus target has changed, start transition
	if current_focus_target != active_focus.target:
		current_focus_target = active_focus.target
		current_focus_weight = 0.0
		emit_signal("focus_changed", current_focus_target)
	
	# Update focus weight
	current_focus_weight = min(1.0, current_focus_weight + focus_transition_speed * get_process_delta_time())
	
	# Look at target with weight
	if current_focus_target and camera is Camera3D:
		var target_transform = camera.global_transform.looking_at(current_focus_target.global_position, UP_VECTOR)
		var target_rotation = target_transform.basis.get_euler()
		
		# Interpolate rotation
		camera.rotation = lerp(camera.rotation, target_rotation, current_focus_weight)

# Apply micro-movements for natural camera feel
func _apply_micro_movements(delta: float):
	if not path_follow.get_child_count() > 0:
		return
	
	var camera = path_follow.get_child(0)
	var micro_offset = Vector3.ZERO
	
	# Apply breathing movement
	if breathing_enabled:
		var breathing = sin(Time.get_ticks_msec() * 0.001 * breathing_frequency) * breathing_amplitude
		micro_offset.y += breathing
	
	# Apply micro-shake
	if micro_shake_enabled:
		var time = Time.get_ticks_msec() * 0.001
		micro_offset.x += noise.get_noise_1d(time * micro_shake_frequency) * micro_shake_amplitude
		micro_offset.z += noise.get_noise_1d(time * micro_shake_frequency + 100) * micro_shake_amplitude
	
	# Apply combined micro-movements
	if breathing_enabled or micro_shake_enabled:
		camera.position += micro_offset

# Custom sort function for position-based arrays
func _sort_by_position(a, b):
	return a.position < b.position

# Check if the object has a specific attribute
func hasattr(obj, attr: String) -> bool:
	return attr in obj
