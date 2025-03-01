extends Node

# This script helps set up the enhanced cinematic scene
# It should be run once to convert the standard cinematic scene to use the enhanced components

# Constants
const HortusConclususCinematicEnhanced = preload("res://scripts/hortus_conclusus_cinematic_enhanced.gd")
const CameraPathEnhanced = preload("res://scripts/camera_path_enhanced.gd")

# Called when the node enters the scene tree for the first time
func _ready():
	print("Setting up enhanced cinematic scene...")
	
	# Find the original cinematic scene
	var original_scene = get_tree().current_scene
	if not original_scene or not original_scene is Node3D:
		print("Error: Current scene is not a Node3D scene")
		return
	
	# Find the original cinematic controller
	var original_controller = _find_cinematic_controller(original_scene)
	if not original_controller:
		print("Error: Could not find cinematic controller in the scene")
		return
	
	print("Found original cinematic controller: " + original_controller.name)
	
	# Create a new enhanced cinematic controller
	var enhanced_controller = HortusConclususCinematicEnhanced.new()
	enhanced_controller.name = original_controller.name + "Enhanced"
	
	# Copy transform and other properties
	enhanced_controller.global_transform = original_controller.global_transform
	
	# Add the enhanced controller to the scene
	original_scene.add_child(enhanced_controller)
	
	# Copy child nodes from original to enhanced controller
	_copy_children(original_controller, enhanced_controller)
	
	# Find and enhance the camera path
	_enhance_camera_path(enhanced_controller)
	
	# Save the enhanced scene
	_save_enhanced_scene(original_scene)
	
	print("Enhanced cinematic scene setup complete!")
	print("You can now use the enhanced cinematic controller: " + enhanced_controller.name)
	print("The original controller has been kept for reference.")
	print("To use the enhanced controller in the scene, you should:")
	print("1. Open the scene in the Godot editor")
	print("2. Hide or remove the original controller")
	print("3. Make sure the enhanced controller is active")

# Find the cinematic controller in the scene
func _find_cinematic_controller(scene: Node) -> Node:
	# Try to find by class name
	for child in scene.get_children():
		if child.get_class() == "HortusConclususCinematic" or child.name.begins_with("HortusConclususCinematic"):
			return child
	
	# Try to find by script
	for child in scene.get_children():
		if child.get_script() and child.get_script().resource_path.ends_with("hortus_conclusus_cinematic.gd"):
			return child
	
	# Try to find by name
	for child in scene.get_children():
		if child.name == "CinematicController":
			return child
	
	# Not found
	return null

# Copy children from one node to another
func _copy_children(source: Node, target: Node):
	for child in source.get_children():
		# Skip nodes that will be handled specially
		if child is Path3D and child.name == "CameraPath":
			continue
		
		# Duplicate the child
		var duplicate = child.duplicate()
		target.add_child(duplicate)
		
		print("Copied child: " + child.name)

# Enhance the camera path
func _enhance_camera_path(controller: Node):
	# Find the original camera path
	var original_path = controller.get_node_or_null("CameraPath")
	if not original_path or not original_path is Path3D:
		print("Warning: Could not find camera path in the controller")
		return
	
	print("Found original camera path: " + original_path.name)
	
	# Create a new enhanced camera path
	var enhanced_path = CameraPathEnhanced.new()
	enhanced_path.name = "CameraPathEnhanced"
	
	# Copy properties from original path
	enhanced_path.curve = original_path.curve
	enhanced_path.global_transform = original_path.global_transform
	
	# Add the enhanced path to the controller
	controller.add_child(enhanced_path)
	
	# Copy path follow and camera from original path
	var path_follow = original_path.get_node_or_null("PathFollow3D")
	if path_follow:
		var duplicate_follow = path_follow.duplicate()
		enhanced_path.add_child(duplicate_follow)
		print("Copied path follow to enhanced path")
	
	print("Enhanced camera path setup complete")

# Save the enhanced scene
func _save_enhanced_scene(scene: Node):
	# This function would save the modified scene, but it's not possible
	# to save scenes programmatically in Godot without editor access
	print("Note: The scene cannot be saved programmatically.")
	print("You will need to save the scene manually in the Godot editor.")
	print("Alternatively, you can create a new scene with the enhanced controller.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Exit after one frame
	get_tree().quit()
