extends Node
class_name CameraPathIntegration

# Constants
const UP_VECTOR = Vector3(0, 1, 0)

# References to required nodes
var cinematic_controller: Node
var camera_path: CameraPathEnhanced
var camera: Camera3D
var atmosphere_controller: Node

# Time of day parameters
var current_time_of_day: String = "dawn"
var time_of_day_sequences = {
	"dawn": {
		"speed_multiplier": 0.8,
		"height_variation": 1.5,
		"breathing_amplitude": 0.03,
		"breathing_frequency": 0.3,
		"focus_transition_speed": 1.5,
		"micro_shake_enabled": false
	},
	"noon": {
		"speed_multiplier": 1.2,
		"height_variation": 0.7,
		"breathing_amplitude": 0.02,
		"breathing_frequency": 0.4,
		"focus_transition_speed": 2.0,
		"micro_shake_enabled": false
	},
	"dusk": {
		"speed_multiplier": 0.7,
		"height_variation": 1.2,
		"breathing_amplitude": 0.04,
		"breathing_frequency": 0.25,
		"focus_transition_speed": 1.0,
		"micro_shake_enabled": false
	},
	"night": {
		"speed_multiplier": 0.5,
		"height_variation": 2.0,
		"breathing_amplitude": 0.05,
		"breathing_frequency": 0.2,
		"focus_transition_speed": 0.8,
		"micro_shake_enabled": true,
		"micro_shake_amplitude": 0.01,
		"micro_shake_frequency": 1.5
	}
}

# Garden focus points
var garden_focus_points = {}

# Signals
signal sequence_completed(sequence_name)

# Initialize the integration
func initialize(controller: Node, path: CameraPathEnhanced, cam: Camera3D, atmosphere: Node):
	cinematic_controller = controller
	camera_path = path
	camera = cam
	atmosphere_controller = atmosphere
	
	# Connect signals
	if camera_path:
		camera_path.connect("point_of_interest_reached", Callable(self, "_on_point_of_interest_reached"))
		camera_path.connect("path_completed", Callable(self, "_on_path_completed"))
		camera_path.connect("focus_changed", Callable(self, "_on_focus_changed"))
	
	if atmosphere_controller and atmosphere_controller.has_signal("time_changed"):
		atmosphere_controller.connect("time_changed", Callable(self, "_on_time_changed"))

# Create predefined camera sequences for the cinematic experience
func create_cinematic_sequences():
	if not camera_path:
		return
	
	# Find garden elements for focus points
	_find_garden_elements()
	
	# Create sequence points of interest
	_create_sequence_points()
	
	# Set initial camera parameters based on time of day
	_apply_time_of_day_parameters(current_time_of_day)

# Create a dawn sequence - slow, contemplative, with gradual height changes
func create_dawn_sequence(duration: float = 60.0):
	if not camera_path:
		return
	
	# Clear existing profiles
	camera_path.speed_profile.clear()
	camera_path.height_profile.clear()
	camera_path.focus_points.clear()
	
	# Set base speed
	var base_speed = 0.1 * time_of_day_sequences["dawn"].speed_multiplier
	
	# Create gentle speed variations
	camera_path.add_speed_point(0.0, base_speed * 0.7)
	camera_path.add_speed_point(0.2, base_speed * 0.9)
	camera_path.add_speed_point(0.4, base_speed * 0.8)
	camera_path.add_speed_point(0.6, base_speed * 1.1)
	camera_path.add_speed_point(0.8, base_speed * 0.9)
	camera_path.add_speed_point(1.0, base_speed * 0.7)
	
	# Create height variations - dawn has more vertical movement
	var height_var = time_of_day_sequences["dawn"].height_variation
	camera_path.add_height_point(0.0, 0.0)
	camera_path.add_height_point(0.15, height_var * 0.5)
	camera_path.add_height_point(0.3, height_var * 1.0)
	camera_path.add_height_point(0.5, height_var * 0.7)
	camera_path.add_height_point(0.7, height_var * 1.2)
	camera_path.add_height_point(0.85, height_var * 0.8)
	camera_path.add_height_point(1.0, height_var * 0.3)
	
	# Add focus points if garden elements exist
	_add_garden_focus_points_for_sequence("dawn")
	
	# Enable breathing for dawn atmosphere
	camera_path.enable_breathing(
		time_of_day_sequences["dawn"].breathing_amplitude,
		time_of_day_sequences["dawn"].breathing_frequency
	)
	
	# Set focus transition speed
	camera_path.focus_transition_speed = time_of_day_sequences["dawn"].focus_transition_speed
	
	# Disable micro-shake for dawn (calm)
	camera_path.disable_micro_shake()
	
	# Set interpolation
	camera_path.set_interpolation(true, true)
	camera_path.set_ease_distances(0.15, 0.15)
	
	# Calculate path length and adjust speed for duration
	var path_length = camera_path.curve.get_baked_length()
	var avg_speed = path_length / duration
	camera_path.movement_speed = avg_speed
	
	# Start movement
	camera_path.start_movement()

# Create a noon sequence - more direct, faster, with less height variation
func create_noon_sequence(duration: float = 45.0):
	if not camera_path:
		return
	
	# Clear existing profiles
	camera_path.speed_profile.clear()
	camera_path.height_profile.clear()
	camera_path.focus_points.clear()
	
	# Set base speed - noon is faster
	var base_speed = 0.15 * time_of_day_sequences["noon"].speed_multiplier
	
	# Create more direct speed variations
	camera_path.add_speed_point(0.0, base_speed * 0.9)
	camera_path.add_speed_point(0.25, base_speed * 1.2)
	camera_path.add_speed_point(0.5, base_speed * 1.0)
	camera_path.add_speed_point(0.75, base_speed * 1.3)
	camera_path.add_speed_point(1.0, base_speed * 0.9)
	
	# Create height variations - noon has less vertical movement
	var height_var = time_of_day_sequences["noon"].height_variation
	camera_path.add_height_point(0.0, height_var * 0.2)
	camera_path.add_height_point(0.3, height_var * 0.5)
	camera_path.add_height_point(0.6, height_var * 0.3)
	camera_path.add_height_point(0.8, height_var * 0.6)
	camera_path.add_height_point(1.0, height_var * 0.4)
	
	# Add focus points if garden elements exist
	_add_garden_focus_points_for_sequence("noon")
	
	# Enable subtle breathing for noon
	camera_path.enable_breathing(
		time_of_day_sequences["noon"].breathing_amplitude,
		time_of_day_sequences["noon"].breathing_frequency
	)
	
	# Set focus transition speed
	camera_path.focus_transition_speed = time_of_day_sequences["noon"].focus_transition_speed
	
	# Disable micro-shake for noon (stable)
	camera_path.disable_micro_shake()
	
	# Set interpolation
	camera_path.set_interpolation(true, true)
	camera_path.set_ease_distances(0.1, 0.1)
	
	# Calculate path length and adjust speed for duration
	var path_length = camera_path.curve.get_baked_length()
	var avg_speed = path_length / duration
	camera_path.movement_speed = avg_speed
	
	# Start movement
	camera_path.start_movement()

# Create a dusk sequence - slower, more dramatic height changes
func create_dusk_sequence(duration: float = 55.0):
	if not camera_path:
		return
	
	# Clear existing profiles
	camera_path.speed_profile.clear()
	camera_path.height_profile.clear()
	camera_path.focus_points.clear()
	
	# Set base speed - dusk is slower
	var base_speed = 0.12 * time_of_day_sequences["dusk"].speed_multiplier
	
	# Create speed variations with more contrast
	camera_path.add_speed_point(0.0, base_speed * 0.8)
	camera_path.add_speed_point(0.2, base_speed * 0.6)
	camera_path.add_speed_point(0.4, base_speed * 1.2)
	camera_path.add_speed_point(0.6, base_speed * 0.7)
	camera_path.add_speed_point(0.8, base_speed * 1.0)
	camera_path.add_speed_point(1.0, base_speed * 0.5)
	
	# Create height variations - dusk has dramatic vertical movement
	var height_var = time_of_day_sequences["dusk"].height_variation
	camera_path.add_height_point(0.0, height_var * 0.3)
	camera_path.add_height_point(0.2, height_var * 1.0)
	camera_path.add_height_point(0.4, height_var * 0.5)
	camera_path.add_height_point(0.6, height_var * 1.2)
	camera_path.add_height_point(0.8, height_var * 0.7)
	camera_path.add_height_point(1.0, height_var * 0.4)
	
	# Add focus points if garden elements exist
	_add_garden_focus_points_for_sequence("dusk")
	
	# Enable more pronounced breathing for dusk
	camera_path.enable_breathing(
		time_of_day_sequences["dusk"].breathing_amplitude,
		time_of_day_sequences["dusk"].breathing_frequency
	)
	
	# Set focus transition speed
	camera_path.focus_transition_speed = time_of_day_sequences["dusk"].focus_transition_speed
	
	# Disable micro-shake for dusk
	camera_path.disable_micro_shake()
	
	# Set interpolation
	camera_path.set_interpolation(true, true)
	camera_path.set_ease_distances(0.12, 0.15)
	
	# Calculate path length and adjust speed for duration
	var path_length = camera_path.curve.get_baked_length()
	var avg_speed = path_length / duration
	camera_path.movement_speed = avg_speed
	
	# Start movement
	camera_path.start_movement()

# Create a night sequence - slowest, most dramatic, with micro-shake
func create_night_sequence(duration: float = 70.0):
	if not camera_path:
		return
	
	# Clear existing profiles
	camera_path.speed_profile.clear()
	camera_path.height_profile.clear()
	camera_path.focus_points.clear()
	
	# Set base speed - night is slowest
	var base_speed = 0.08 * time_of_day_sequences["night"].speed_multiplier
	
	# Create speed variations with long pauses
	camera_path.add_speed_point(0.0, base_speed * 0.6)
	camera_path.add_speed_point(0.15, base_speed * 0.3)
	camera_path.add_speed_point(0.3, base_speed * 0.8)
	camera_path.add_speed_point(0.5, base_speed * 0.4)
	camera_path.add_speed_point(0.7, base_speed * 0.9)
	camera_path.add_speed_point(0.85, base_speed * 0.3)
	camera_path.add_speed_point(1.0, base_speed * 0.5)
	
	# Create height variations - night has most dramatic vertical movement
	var height_var = time_of_day_sequences["night"].height_variation
	camera_path.add_height_point(0.0, height_var * 0.2)
	camera_path.add_height_point(0.15, height_var * 1.0)
	camera_path.add_height_point(0.3, height_var * 0.5)
	camera_path.add_height_point(0.45, height_var * 1.5)
	camera_path.add_height_point(0.6, height_var * 0.3)
	camera_path.add_height_point(0.75, height_var * 1.2)
	camera_path.add_height_point(0.9, height_var * 0.8)
	camera_path.add_height_point(1.0, height_var * 0.4)
	
	# Add focus points if garden elements exist
	_add_garden_focus_points_for_sequence("night")
	
	# Enable pronounced breathing for night
	camera_path.enable_breathing(
		time_of_day_sequences["night"].breathing_amplitude,
		time_of_day_sequences["night"].breathing_frequency
	)
	
	# Set focus transition speed
	camera_path.focus_transition_speed = time_of_day_sequences["night"].focus_transition_speed
	
	# Enable subtle micro-shake for night (mysterious)
	if time_of_day_sequences["night"].micro_shake_enabled:
		camera_path.enable_micro_shake(
			time_of_day_sequences["night"].micro_shake_amplitude,
			time_of_day_sequences["night"].micro_shake_frequency
		)
	
	# Set interpolation
	camera_path.set_interpolation(true, true)
	camera_path.set_ease_distances(0.2, 0.2)
	
	# Calculate path length and adjust speed for duration
	var path_length = camera_path.curve.get_baked_length()
	var avg_speed = path_length / duration
	camera_path.movement_speed = avg_speed
	
	# Start movement
	camera_path.start_movement()

# Create a sequence that focuses on sacred geometry
func create_sacred_geometry_sequence(sacred_geometry_node: Node3D, duration: float = 30.0):
	if not camera_path or not sacred_geometry_node:
		return
	
	# Clear existing profiles
	camera_path.speed_profile.clear()
	camera_path.height_profile.clear()
	camera_path.focus_points.clear()
	
	# Set base speed
	var base_speed = 0.05
	
	# Create speed variations for contemplative viewing
	camera_path.add_speed_point(0.0, base_speed * 0.5)
	camera_path.add_speed_point(0.2, base_speed * 0.3)
	camera_path.add_speed_point(0.4, base_speed * 0.7)
	camera_path.add_speed_point(0.6, base_speed * 0.4)
	camera_path.add_speed_point(0.8, base_speed * 0.6)
	camera_path.add_speed_point(1.0, base_speed * 0.3)
	
	# Create height variations to view from different angles
	camera_path.add_height_point(0.0, 1.0)
	camera_path.add_height_point(0.25, 2.5)
	camera_path.add_height_point(0.5, 0.5)
	camera_path.add_height_point(0.75, 3.0)
	camera_path.add_height_point(1.0, 1.5)
	
	# Add focus points on the sacred geometry
	camera_path.add_focus_point(0.0, sacred_geometry_node, 2.0)
	camera_path.add_focus_point(1.0, sacred_geometry_node, 2.0)
	
	# Enable subtle breathing
	camera_path.enable_breathing(0.02, 0.2)
	
	# Set focus transition speed
	camera_path.focus_transition_speed = 1.0
	
	# Disable micro-shake for clarity
	camera_path.disable_micro_shake()
	
	# Set interpolation
	camera_path.set_interpolation(true, true)
	camera_path.set_ease_distances(0.15, 0.15)
	
	# Calculate path length and adjust speed for duration
	var path_length = camera_path.curve.get_baked_length()
	var avg_speed = path_length / duration
	camera_path.movement_speed = avg_speed
	
	# Start movement
	camera_path.start_movement()

# Create a sequence that showcases the entire garden
func create_garden_overview_sequence(duration: float = 40.0):
	if not camera_path:
		return
	
	# Clear existing profiles
	camera_path.speed_profile.clear()
	camera_path.height_profile.clear()
	camera_path.focus_points.clear()
	
	# Set base speed
	var base_speed = 0.15
	
	# Create speed variations
	camera_path.add_speed_point(0.0, base_speed * 0.8)
	camera_path.add_speed_point(0.2, base_speed * 1.2)
	camera_path.add_speed_point(0.4, base_speed * 0.9)
	camera_path.add_speed_point(0.6, base_speed * 1.3)
	camera_path.add_speed_point(0.8, base_speed * 0.7)
	camera_path.add_speed_point(1.0, base_speed * 1.0)
	
	# Create height variations - higher for overview
	camera_path.add_height_point(0.0, 5.0)
	camera_path.add_height_point(0.2, 8.0)
	camera_path.add_height_point(0.4, 6.0)
	camera_path.add_height_point(0.6, 10.0)
	camera_path.add_height_point(0.8, 7.0)
	camera_path.add_height_point(1.0, 9.0)
	
	# Add focus points on garden elements
	_add_garden_focus_points_for_sequence("overview")
	
	# Enable subtle breathing
	camera_path.enable_breathing(0.03, 0.3)
	
	# Set focus transition speed
	camera_path.focus_transition_speed = 1.5
	
	# Disable micro-shake for clarity
	camera_path.disable_micro_shake()
	
	# Set interpolation
	camera_path.set_interpolation(true, true)
	camera_path.set_ease_distances(0.1, 0.1)
	
	# Calculate path length and adjust speed for duration
	var path_length = camera_path.curve.get_baked_length()
	var avg_speed = path_length / duration
	camera_path.movement_speed = avg_speed
	
	# Start movement
	camera_path.start_movement()

# Create a dramatic reveal sequence
func create_dramatic_reveal(target_node: Node3D, duration: float = 15.0):
	if not camera_path or not target_node:
		return
	
	# Use the built-in dramatic reveal sequence
	camera_path.create_dramatic_reveal_sequence(0.9, duration)
	
	# Add focus point on the target
	camera_path.focus_points.clear()
	camera_path.add_focus_point(0.5, target_node, 2.0)
	camera_path.add_focus_point(0.9, target_node, 1.0)
	
	# Start movement
	camera_path.start_movement()

# Find garden elements for focus points
func _find_garden_elements():
	if not cinematic_controller:
		return
	
	# Clear existing focus points
	garden_focus_points.clear()
	
	# Find garden elements node
	var garden_elements = cinematic_controller.get_node_or_null("GardenElements")
	if not garden_elements:
		return
	
	# Find specific garden types
	var monastic_garden = garden_elements.get_node_or_null("MonasticGarden")
	var knot_garden = garden_elements.get_node_or_null("KnotGarden")
	var raised_garden = garden_elements.get_node_or_null("RaisedGarden")
	var herb_garden = garden_elements.get_node_or_null("HerbGarden")
	var fountain = garden_elements.get_node_or_null("Fountain")
	
	# Store found elements
	if monastic_garden:
		garden_focus_points["monastic"] = monastic_garden
	if knot_garden:
		garden_focus_points["knot"] = knot_garden
	if raised_garden:
		garden_focus_points["raised"] = raised_garden
	if herb_garden:
		garden_focus_points["herb"] = herb_garden
	if fountain:
		garden_focus_points["fountain"] = fountain
	
	# Find sacred geometry patterns
	var sacred_patterns = cinematic_controller.get_node_or_null("SacredGeometryPatterns")
	if sacred_patterns and sacred_patterns.get_child_count() > 0:
		for i in range(sacred_patterns.get_child_count()):
			var pattern = sacred_patterns.get_child(i)
			garden_focus_points["sacred_" + str(i)] = pattern

# Create sequence points of interest
func _create_sequence_points():
	if not camera_path:
		return
	
	# Add points of interest that will trigger signals
	camera_path.add_point_of_interest(0.25, "first_quarter")
	camera_path.add_point_of_interest(0.5, "halfway")
	camera_path.add_point_of_interest(0.75, "third_quarter")
	camera_path.add_point_of_interest(0.95, "approaching_end")

# Add garden focus points for a specific sequence
func _add_garden_focus_points_for_sequence(sequence_name: String):
	if not camera_path or garden_focus_points.size() == 0:
		return
	
	match sequence_name:
		"dawn":
			# Dawn focuses on herb garden and monastic garden
			if "herb" in garden_focus_points:
				camera_path.add_focus_point(0.2, garden_focus_points["herb"], 3.0)
			if "monastic" in garden_focus_points:
				camera_path.add_focus_point(0.6, garden_focus_points["monastic"], 3.0)
			if "sacred_0" in garden_focus_points:
				camera_path.add_focus_point(0.9, garden_focus_points["sacred_0"], 2.0)
		
		"noon":
			# Noon focuses on knot garden and fountain
			if "knot" in garden_focus_points:
				camera_path.add_focus_point(0.3, garden_focus_points["knot"], 2.0)
			if "fountain" in garden_focus_points:
				camera_path.add_focus_point(0.7, garden_focus_points["fountain"], 2.0)
			if "sacred_1" in garden_focus_points:
				camera_path.add_focus_point(0.9, garden_focus_points["sacred_1"], 2.0)
		
		"dusk":
			# Dusk focuses on raised garden and monastic garden
			if "raised" in garden_focus_points:
				camera_path.add_focus_point(0.25, garden_focus_points["raised"], 3.0)
			if "monastic" in garden_focus_points:
				camera_path.add_focus_point(0.6, garden_focus_points["monastic"], 3.0)
			if "sacred_2" in garden_focus_points:
				camera_path.add_focus_point(0.85, garden_focus_points["sacred_2"], 2.5)
		
		"night":
			# Night focuses on fountain and herb garden
			if "fountain" in garden_focus_points:
				camera_path.add_focus_point(0.2, garden_focus_points["fountain"], 4.0)
			if "herb" in garden_focus_points:
				camera_path.add_focus_point(0.5, garden_focus_points["herb"], 4.0)
			if "sacred_3" in garden_focus_points:
				camera_path.add_focus_point(0.8, garden_focus_points["sacred_3"], 3.0)
		
		"overview":
			# Overview focuses on all gardens in sequence
			var focus_points = ["monastic", "knot", "raised", "herb", "fountain"]
			var position = 0.1
			
			for point in focus_points:
				if point in garden_focus_points:
					camera_path.add_focus_point(position, garden_focus_points[point], 2.0)
					position += 0.2

# Apply time of day specific camera parameters
func _apply_time_of_day_parameters(time_of_day: String):
	if not camera_path or not time_of_day in time_of_day_sequences:
		return
	
	var params = time_of_day_sequences[time_of_day]
	
	# Apply breathing parameters
	camera_path.enable_breathing(
		params.breathing_amplitude,
		params.breathing_frequency
	)
	
	# Apply focus transition speed
	camera_path.focus_transition_speed = params.focus_transition_speed
	
	# Apply micro-shake if enabled
	if "micro_shake_enabled" in params and params.micro_shake_enabled:
		camera_path.enable_micro_shake(
			params.micro_shake_amplitude,
			params.micro_shake_frequency
		)
	else:
		camera_path.disable_micro_shake()

# Signal handlers
func _on_point_of_interest_reached(point_name: String):
	# Forward the signal to any listeners
	emit_signal("sequence_completed", point_name)
	
	# Adjust camera parameters at specific points if needed
	match point_name:
		"halfway":
			# Increase height variation at halfway point
			if camera_path and camera_path.height_profile.size() > 0:
				for i in range(camera_path.height_profile.size()):
					camera_path.height_profile[i].height *= 1.2
		
		"approaching_end":
			# Slow down as we approach the end
			if camera_path:
				camera_path.movement_speed *= 0.7

func _on_path_completed():
	# Forward the signal to any listeners
	emit_signal("sequence_completed", "path_completed")

func _on_focus_changed(target: Node3D):
	# Could implement special effects when focus changes
	pass

func _on_time_changed(time: String):
	# Update camera parameters when time of day changes
	current_time_of_day = time
	_apply_time_of_day_parameters(time)
	
	# Create a new sequence based on time of day
	match time:
		"dawn":
			create_dawn_sequence()
		"noon":
			create_noon_sequence()
		"dusk":
			create_dusk_sequence()
		"night":
			create_night_sequence()
