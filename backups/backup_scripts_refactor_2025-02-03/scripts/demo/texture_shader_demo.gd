extends Node

# This script demonstrates how to use the texture and shader generators
# Attach it to a node in your scene to generate textures and apply shaders

# References to the generators
var texture_generator: TextureShaderGenerator

# UI elements for progress display
var progress_label: Label
var progress_bar: ProgressBar

# Flag to track if generation is in progress
var is_generating = false

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize the texture generator
	texture_generator = TextureShaderGenerator.new()
	add_child(texture_generator)
	
	# Connect signals
	texture_generator.generation_progress.connect(_on_generation_progress)
	
	# Create UI elements for progress display
	_create_ui()
	
	print("Texture and Shader Demo ready. Press G to generate textures and shaders.")

# Create UI elements for progress display
func _create_ui():
	# Create a CanvasLayer for UI
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	
	# Create a VBoxContainer for layout
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	vbox.offset_left = -300
	vbox.offset_top = 20
	vbox.offset_right = -20
	canvas_layer.add_child(vbox)
	
	# Create a title label
	var title_label = Label.new()
	title_label.text = "Medieval Texture & Shader Generator"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)
	
	# Create a progress label
	progress_label = Label.new()
	progress_label.text = "Press G to generate textures and shaders"
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(progress_label)
	
	# Create a progress bar
	progress_bar = ProgressBar.new()
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = 0
	progress_bar.custom_minimum_size = Vector2(280, 20)
	vbox.add_child(progress_bar)
	
	# Create a help label
	var help_label = Label.new()
	help_label.text = "Controls:\nG - Generate textures\nS - Apply shaders\nD - Demo materials on objects"
	help_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	vbox.add_child(help_label)

# Handle input for demo controls
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_G and not is_generating:
			# Generate textures
			_generate_textures()
		elif event.keycode == KEY_S and not is_generating:
			# Apply shaders
			_apply_shaders()
		elif event.keycode == KEY_D and not is_generating:
			# Demo materials on objects
			_demo_materials()

# Generate textures using the Python script
func _generate_textures():
	is_generating = true
	progress_label.text = "Generating textures..."
	progress_bar.value = 0
	
	# Run the texture generation in a thread to avoid freezing the UI
	var thread = Thread.new()
	thread.start(Callable(self, "_thread_generate_textures"))

# Thread function for texture generation
func _thread_generate_textures():
	var success = texture_generator.generate_all_textures()
	
	# Update UI from main thread
	call_deferred("_on_texture_generation_complete", success)

# Called when texture generation is complete
func _on_texture_generation_complete(success: bool):
	is_generating = false
	
	if success:
		progress_label.text = "Textures generated successfully!"
		progress_bar.value = 100
	else:
		progress_label.text = "Texture generation failed. Check console for details."
		progress_bar.value = 0

# Apply shaders to materials
func _apply_shaders():
	is_generating = true
	progress_label.text = "Applying shaders to materials..."
	progress_bar.value = 0
	
	# Apply shaders in a thread to avoid freezing the UI
	var thread = Thread.new()
	thread.start(Callable(self, "_thread_apply_shaders"))

# Thread function for shader application
func _thread_apply_shaders():
	var materials = texture_generator.apply_shaders_to_materials()
	
	# Update UI from main thread
	call_deferred("_on_shader_application_complete", materials)

# Called when shader application is complete
func _on_shader_application_complete(materials: Dictionary):
	is_generating = false
	
	if materials.size() > 0:
		progress_label.text = "Shaders applied successfully!"
		progress_bar.value = 100
		
		# Store the materials for later use
		var resource = Resource.new()
		resource.set_meta("materials", materials)
		ResourceSaver.save(resource, "res://assets/materials/medieval_materials.tres")
	else:
		progress_label.text = "Shader application failed. Check console for details."
		progress_bar.value = 0

# Demo materials on objects in the scene
func _demo_materials():
	progress_label.text = "Creating demo objects..."
	
	# Create a demo scene with various objects
	var demo_scene = Node3D.new()
	demo_scene.name = "MaterialDemo"
	get_tree().get_root().add_child(demo_scene)
	
	# Create a camera
	var camera = Camera3D.new()
	camera.transform.origin = Vector3(0, 2, 5)
	camera.look_at(Vector3(0, 0, 0))
	demo_scene.add_child(camera)
	
	# Create a directional light
	var light = DirectionalLight3D.new()
	light.transform.origin = Vector3(2, 4, 2)
	light.look_at(Vector3(0, 0, 0))
	demo_scene.add_child(light)
	
	# Create a ground plane
	var ground = MeshInstance3D.new()
	ground.mesh = PlaneMesh.new()
	ground.mesh.size = Vector2(10, 10)
	ground.transform.origin = Vector3(0, -1, 0)
	demo_scene.add_child(ground)
	
	# Create various objects to showcase materials
	_create_demo_objects(demo_scene)
	
	progress_label.text = "Demo objects created. Press ESC to return to main scene."

# Create demo objects with different materials
func _create_demo_objects(parent: Node3D):
	# Load the materials
	var resource = ResourceLoader.load("res://assets/materials/medieval_materials.tres")
	var materials
	
	if resource and resource.has_meta("materials"):
		materials = resource.get_meta("materials")
	else:
		# Create a basic material set if the saved materials don't exist
		materials = TextureShaderGenerator.create_medieval_material_set()
	
	# Create a grid of objects
	var spacing = 1.5
	var grid_size = 3
	var index = 0
	
	for z in range(grid_size):
		for x in range(grid_size):
			var object_type = index % 5
			var mesh_instance = MeshInstance3D.new()
			
			# Position in grid
			mesh_instance.transform.origin = Vector3(
				(x - grid_size/2) * spacing,
				0,
				(z - grid_size/2) * spacing
			)
			
			# Create different mesh types
			match object_type:
				0: # Cube
					mesh_instance.mesh = BoxMesh.new()
				1: # Sphere
					mesh_instance.mesh = SphereMesh.new()
				2: # Cylinder
					mesh_instance.mesh = CylinderMesh.new()
				3: # Torus
					mesh_instance.mesh = TorusMesh.new()
				4: # Prism
					mesh_instance.mesh = PrismMesh.new()
			
			# Apply a material based on position
			var material_index = (x + z) % materials.size()
			var material_key = materials.keys()[material_index]
			mesh_instance.material_override = materials[material_key]
			
			# Add to scene
			parent.add_child(mesh_instance)
			
			# Create a label for the material name
			var label_3d = Label3D.new()
			label_3d.text = material_key
			label_3d.transform.origin = Vector3(0, 0.8, 0)
			mesh_instance.add_child(label_3d)
			
			index += 1

# Progress update callback
func _on_generation_progress(step: int, total_steps: int, description: String):
	progress_label.text = description
	progress_bar.value = (float(step) / total_steps) * 100
