extends Path3D
class_name CameraPath

# Reference to the path follow node
@onready var path_follow = $PathFollow3D

# Camera movement parameters
var movement_speed: float = 0.1
var is_moving: bool = false
var loop_path: bool = true

# Called when the node enters the scene tree for the first time
func _ready():
	# Ensure path follow is at the start
	path_follow.progress_ratio = 0.0

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

# Process function for continuous movement
func _process(delta):
	if is_moving:
		# Update path follow position
		path_follow.progress += movement_speed * delta
		
		# Handle looping
		if loop_path and path_follow.progress_ratio >= 1.0:
			path_follow.progress_ratio = 0.0
