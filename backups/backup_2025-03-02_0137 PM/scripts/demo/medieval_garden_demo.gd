extends Node3D

# Medieval Garden Demo
# This script demonstrates the medieval textures and shaders
# for the Hortus Conclusus project
# Now with Ambrose integration for interactive chat

# References to the scene nodes
@onready var camera = $Camera3D
@onready var garden_elements = $GardenElements
@onready var info_label = $CanvasLayer/InfoLabel
@onready var texture_info = $CanvasLayer/TextureInfo
@onready var ambrose_interface = $CanvasLayer/MedievalAmbroseInterface
@onready var background_music = $BackgroundMusic

# Music tracks for different times of day
const MUSIC_TRACKS = {
    "morning": "res://assets/music/medieval_morning.wav",
    "midday": "res://assets/music/medieval_midday.wav",
    "afternoon": "res://assets/music/medieval_afternoon.wav",
    "evening": "res://assets/music/medieval_evening.wav",
    "night": "res://assets/music/medieval_night.wav"
}

# Time periods for different tracks (in hours, 24-hour format)
const TIME_PERIODS = {
    "morning": [6, 11],    # 6:00 AM - 11:59 AM
    "midday": [12, 14],    # 12:00 PM - 2:59 PM
    "afternoon": [15, 17], # 3:00 PM - 5:59 PM
    "evening": [18, 21],   # 6:00 PM - 9:59 PM
    "night": [22, 5]       # 10:00 PM - 5:59 AM
}

# Texture and shader paths
const TEXTURE_BASE_PATH = "assets/textures/medieval_garden_pack/"
const INTEGRATED_PACKS_PATH = "assets/textures/integrated_packs/"

# Camera movement parameters
var camera_target_position = Vector3(0, 5, 10)
var camera_target_rotation = Vector3(-20, 0, 0)
var camera_speed = 2.0
var rotation_speed = 1.0

# Current display state
var current_category = "garden_elements"
var current_texture_index = 0
var categories = ["garden_elements", "ornamental", "symbolic", "materials"]
var textures_by_category = {}
var shader_types = ["illuminated", "weathered", "garden", "stone_wall", "wood", "fabric", "parchment"]
var current_shader_index = 0

# Ambrose integration
var ambrose_bridge = null
var ambrose_ready = false

func _ready():
	# Initialize the scene
	setup_scene()
	
	# Load available textures
	load_available_textures()
	
	# Generate a complete garden layout
	generate_garden_layout()
	
	# Set up info text
	info_label.text = "Medieval Garden Demo\n"
	info_label.text += "Press Space to cycle through textures\n"
	info_label.text += "Press Tab to cycle through categories\n"
	info_label.text += "Press S to cycle through shaders\n"
	info_label.text += "Use WASD to move camera\n"
	info_label.text += "Use Q/E to rotate camera\n"
	info_label.text += "Press C to chat with Ambrose"
	
	# Set up Ambrose interface
	setup_ambrose()
	
	# Start background music based on time of day
	update_background_music()
	
	# Set up timer to check time of day periodically
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 60  # Check every minute
	timer.connect("timeout", Callable(self, "update_background_music"))
	timer.start()

func get_current_time_period() -> String:
	"""Get the current time period based on the system time"""
	var current_time = Time.get_datetime_dict_from_system()
	var hour = current_time["hour"]
	
	for period in TIME_PERIODS:
		var start_hour = TIME_PERIODS[period][0]
		var end_hour = TIME_PERIODS[period][1]
		
		if end_hour < start_hour:  # Period crosses midnight
			if hour >= start_hour or hour <= end_hour:
				return period
		else:  # Normal period
			if hour >= start_hour and hour <= end_hour:
				return period
	
	return "morning"  # Default to morning if no match found

func update_background_music():
	"""Update the background music based on the current time of day"""
	var current_period = get_current_time_period()
	var music_path = MUSIC_TRACKS[current_period]
	
	# Load and play the appropriate music track
	if background_music:
		var stream = load(music_path)
		if stream and (not background_music.playing or background_music.stream != stream):
			background_music.stream = stream
			background_music.play()

func setup_scene():
	# Set up the environment
	var environment = get_viewport().world_3d.environment
	if environment:
		environment.ambient_light_color = Color(0.5, 0.5, 0.4)
		environment.ambient_light_energy = 0.5
		environment.fog_enabled = true
		environment.fog_density = 0.01
		# Fix for Godot 4 - fog_color needs to be set differently
		if "fog_color" in environment:
			environment.fog_color = Color(0.7, 0.7, 0.6)
		else:
			# For Godot 4, we might need to use a different property
			environment.set("fog_color", Color(0.7, 0.7, 0.6))
	
	# Set up directional light for medieval sun
	var directional_light = DirectionalLight3D.new()
	directional_light.light_color = Color(1.0, 0.95, 0.8)  # Warm sunlight
	directional_light.light_energy = 1.2
	directional_light.shadow_enabled = true
	directional_light.rotation_degrees = Vector3(-45, -30, 0)
	add_child(directional_light)
	
	# Set up ground plane
	var ground_plane = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(50, 50)
	ground_plane.mesh = plane_mesh
	
	# Apply a basic ground material
	var ground_material = StandardMaterial3D.new()
	ground_material.albedo_color = Color(0.3, 0.4, 0.2)  # Green grass
	ground_plane.material_override = ground_material
	
	add_child(ground_plane)
	
	# Create garden elements node if it doesn't exist
	if not garden_elements:
		garden_elements = Node3D.new()
		garden_elements.name = "GardenElements"
		add_child(garden_elements)

func load_available_textures():
	# Initialize categories
	for category in categories:
		textures_by_category[category] = []
	
	# Load textures from the medieval garden pack
	var dir = DirAccess.open(TEXTURE_BASE_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir() and file_name in categories:
				# Load textures from this category
				var category_dir = DirAccess.open(TEXTURE_BASE_PATH + file_name)
				if category_dir:
					category_dir.list_dir_begin()
					var texture_file = category_dir.get_next()
					
					while texture_file != "":
						if not category_dir.current_is_dir() and texture_file.ends_with(".png"):
							textures_by_category[file_name].append(texture_file)
						texture_file = category_dir.get_next()
					
					category_dir.list_dir_end()
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	# Debug output
	for category in categories:
		print("Category: ", category, " - ", textures_by_category[category].size(), " textures")

func generate_garden_layout():
	# Clear previous garden elements
	for child in garden_elements.get_children():
		child.queue_free()
	
	# Create a garden layout with various elements
	var rng = RandomNumberGenerator.new()
	rng.seed = 12345  # Use a fixed seed for consistent results
	
	print("Generating garden layout...")
	
	# Create a central fountain
	if "ornamental" in textures_by_category and textures_by_category["ornamental"].size() > 0:
		var fountain_index = 0
		for i in range(textures_by_category["ornamental"].size()):
			if "fountain" in textures_by_category["ornamental"][i]:
				fountain_index = i
				break
		
		if fountain_index < textures_by_category["ornamental"].size():
			var fountain = create_display_object("ornamental", textures_by_category["ornamental"][fountain_index])
			fountain.position = Vector3(0, 0.5, 0)
			fountain.scale = Vector3(2, 2, 2)
			apply_shader_to_object(fountain, "illuminated")
			garden_elements.add_child(fountain)
			print("Added central fountain")
		else:
			# Create a default fountain if no fountain texture is found
			var default_fountain = MeshInstance3D.new()
			var cylinder = CylinderMesh.new()
			cylinder.top_radius = 2.0
			cylinder.bottom_radius = 2.5
			cylinder.height = 1.0
			default_fountain.mesh = cylinder
			default_fountain.position = Vector3(0, 0.5, 0)
			
			var fountain_material = StandardMaterial3D.new()
			fountain_material.albedo_color = Color(0.7, 0.7, 0.8)
			default_fountain.material_override = fountain_material
			
			garden_elements.add_child(default_fountain)
			print("Added default fountain")
	
	# Create garden beds in a circular pattern around the fountain
	if "garden_elements" in textures_by_category and textures_by_category["garden_elements"].size() > 0:
		var num_beds = 8
		var radius = 8.0
		
		for i in range(num_beds):
			var angle = 2 * PI * i / num_beds
			var pos_x = radius * cos(angle)
			var pos_z = radius * sin(angle)
			
			var bed_index = rng.randi() % textures_by_category["garden_elements"].size()
			var garden_bed = create_display_object("garden_elements", textures_by_category["garden_elements"][bed_index])
			garden_bed.position = Vector3(pos_x, 0.01, pos_z)
			garden_bed.rotation_degrees.y = rad_to_deg(angle) + 90
			garden_bed.scale = Vector3(2, 1, 2)
			apply_shader_to_object(garden_bed, "garden")
			garden_elements.add_child(garden_bed)
		
		print("Added garden beds")
	else:
		# Create default garden beds if no textures are found
		var num_beds = 8
		var radius = 8.0
		
		for i in range(num_beds):
			var angle = 2 * PI * i / num_beds
			var pos_x = radius * cos(angle)
			var pos_z = radius * sin(angle)
			
			var garden_bed = MeshInstance3D.new()
			var plane = PlaneMesh.new()
			plane.size = Vector2(5, 5)
			garden_bed.mesh = plane
			garden_bed.position = Vector3(pos_x, 0.01, pos_z)
			garden_bed.rotation_degrees.x = -90
			garden_bed.rotation_degrees.y = rad_to_deg(angle) + 90
			garden_bed.scale = Vector3(2, 1, 2)
			
			var bed_material = StandardMaterial3D.new()
			bed_material.albedo_color = Color(0.3, 0.5, 0.2)
			garden_bed.material_override = bed_material
			
			garden_elements.add_child(garden_bed)
		
		print("Added default garden beds")
	
	# Create stone paths connecting the garden beds
	if "garden_elements" in textures_by_category:
		var path_index = 0
		for i in range(textures_by_category["garden_elements"].size()):
			if "path" in textures_by_category["garden_elements"][i]:
				path_index = i
				break
		
		# Create a cross-shaped path
		var path_width = 1.5
		var path_length = 20.0
		
		# Horizontal path
		var h_path = create_display_object("garden_elements", textures_by_category["garden_elements"][path_index])
		h_path.position = Vector3(0, 0.005, 0)
		h_path.scale = Vector3(path_length / 5.0, 1, path_width / 5.0)
		apply_shader_to_object(h_path, "stone_wall")
		garden_elements.add_child(h_path)
		
		# Vertical path
		var v_path = create_display_object("garden_elements", textures_by_category["garden_elements"][path_index])
		v_path.position = Vector3(0, 0.005, 0)
		v_path.rotation_degrees.y = 90
		v_path.scale = Vector3(path_length / 5.0, 1, path_width / 5.0)
		apply_shader_to_object(v_path, "stone_wall")
		garden_elements.add_child(v_path)
	
	# Add symbolic elements at the corners
	if "symbolic" in textures_by_category and textures_by_category["symbolic"].size() > 0:
		var corner_positions = [
			Vector3(10, 0, 10),
			Vector3(-10, 0, 10),
			Vector3(10, 0, -10),
			Vector3(-10, 0, -10)
		]
		
		for i in range(min(corner_positions.size(), textures_by_category["symbolic"].size())):
			var symbol = create_display_object("symbolic", textures_by_category["symbolic"][i])
			symbol.position = corner_positions[i]
			symbol.rotation_degrees.x = -90  # Make it stand upright
			apply_shader_to_object(symbol, "illuminated")
			garden_elements.add_child(symbol)
	
	# Add walls around the garden
	if "materials" in textures_by_category and textures_by_category["materials"].size() > 0:
		var wall_index = 0
		for i in range(textures_by_category["materials"].size()):
			if "wall" in textures_by_category["materials"][i]:
				wall_index = i
				break
		
		var wall_positions = [
			[Vector3(0, 2, 15), Vector3(0, 0, 0), Vector3(30, 4, 1)],  # North wall
			[Vector3(0, 2, -15), Vector3(0, 0, 0), Vector3(30, 4, 1)],  # South wall
			[Vector3(15, 2, 0), Vector3(0, 90, 0), Vector3(30, 4, 1)],  # East wall
			[Vector3(-15, 2, 0), Vector3(0, 90, 0), Vector3(30, 4, 1)]   # West wall
		]
		
		for wall_data in wall_positions:
			var wall = create_display_object("materials", textures_by_category["materials"][wall_index])
			wall.position = wall_data[0]
			wall.rotation_degrees = wall_data[1]
			wall.scale = wall_data[2]
			apply_shader_to_object(wall, "weathered")
			garden_elements.add_child(wall)
	
	# Update the texture info display
	texture_info.text = "Category: garden_elements\n"
	texture_info.text += "Texture: herb_bed.png\n"
	texture_info.text += "Shader: illuminated"

func update_display():
	# Clear previous display
	for child in garden_elements.get_children():
		child.queue_free()
	
	# Get current texture
	var textures = textures_by_category[current_category]
	
	if textures.size() == 0:
		texture_info.text = "No textures found in category: " + current_category
		return
	
	current_texture_index = current_texture_index % textures.size()
	var texture_name = textures[current_texture_index]
	
	# Update info text
	texture_info.text = "Category: " + current_category + "\n"
	texture_info.text += "Texture: " + texture_name + "\n"
	texture_info.text += "Shader: " + shader_types[current_shader_index]
	
	# Generate a complete garden layout with the selected texture
	generate_garden_layout()

func create_display_object(category, texture_name):
	var object = MeshInstance3D.new()
	
	# Choose appropriate mesh based on category
	var mesh
	
	if category == "garden_elements":
		# Use a plane for garden elements
		mesh = PlaneMesh.new()
		mesh.size = Vector2(5, 5)
		object.rotation_degrees.x = -90  # Lay flat
		object.position.y = 0.01  # Slightly above ground
	
	elif category == "ornamental":
		# Use a more complex shape for ornamental elements
		if "fountain" in texture_name:
			# Fountain-like cylinder
			mesh = CylinderMesh.new()
			mesh.top_radius = 2.0
			mesh.bottom_radius = 2.5
			mesh.height = 1.0
			object.position.y = 0.5  # Half height
		else:
			# Generic ornamental object
			mesh = PrismMesh.new()
			mesh.size = Vector3(3, 3, 1)
			object.position.y = 0.5
	
	elif category == "symbolic":
		# Use a vertical plane for symbolic elements
		mesh = PlaneMesh.new()
		mesh.size = Vector2(4, 4)
		object.position.y = 2.0  # Raise up
	
	elif category == "materials":
		# Use a cube for materials
		mesh = BoxMesh.new()
		mesh.size = Vector3(4, 4, 4)
		object.position.y = 2.0  # Half height
	
	else:
		# Default to a plane
		mesh = PlaneMesh.new()
		mesh.size = Vector2(5, 5)
		object.position.y = 0.01
	
	object.mesh = mesh
	
	# Load and apply the texture
	var texture_path = TEXTURE_BASE_PATH + category + "/" + texture_name
	print("Loading texture: ", texture_path)
	var texture = load(texture_path)
	
	if texture:
		var material = StandardMaterial3D.new()
		material.albedo_texture = texture
		object.material_override = material
		print("Texture loaded successfully")
	else:
		# Create a default material if texture loading fails
		var default_material = StandardMaterial3D.new()
		
		if category == "garden_elements":
			default_material.albedo_color = Color(0.3, 0.5, 0.2)  # Green
		elif category == "ornamental":
			default_material.albedo_color = Color(0.7, 0.7, 0.8)  # Light gray
		elif category == "symbolic":
			default_material.albedo_color = Color(0.8, 0.7, 0.2)  # Gold
		elif category == "materials":
			default_material.albedo_color = Color(0.5, 0.5, 0.5)  # Gray
		else:
			default_material.albedo_color = Color(1, 1, 1)  # White
		
		object.material_override = default_material
		print("Failed to load texture, using default material")
	
	return object

func apply_shader_to_object(object, shader_type):
	# Check if the object has a material with an albedo texture
	if object.material_override and object.material_override is StandardMaterial3D and object.material_override.albedo_texture:
		# Check if we have an integrated texture pack for this object
		var base_name = object.material_override.albedo_texture.resource_path.get_file().get_basename()
		var category = object.material_override.albedo_texture.resource_path.get_base_dir().get_file()
		
		var integrated_path = INTEGRATED_PACKS_PATH + category + "_" + base_name
		var resource_path = integrated_path + "/" + category + "_" + base_name + ".tres"
		
		var shader_material
		
		# Try to load the pre-made shader resource
		if ResourceLoader.exists(resource_path):
			shader_material = load(resource_path)
			print("Loaded shader resource: ", resource_path)
		else:
			# Create a new shader material
			shader_material = ShaderMaterial.new()
			
			# Get the appropriate shader from MedievalShaderPack
			var shader_script = load("scripts/shaders/medieval_shader_pack.gd")
			if shader_script:
				var base_color = Color(1, 1, 1, 1)  # Default white
				shader_material = shader_script.create_medieval_shader_material(shader_type, base_color)
				
				# Set the albedo texture
				shader_material.set_shader_parameter("albedo_texture", object.material_override.albedo_texture)
				print("Created new shader material with type: ", shader_type)
		
		# Apply the shader material
		if shader_material:
			object.material_override = shader_material
	else:
		# Create a basic shader material for objects without textures
		var shader = load("scripts/shaders/medieval_shader_pack.gdshader")
		if shader:
			var shader_material = ShaderMaterial.new()
			shader_material.shader = shader
			
			# Set base color from the object's material if available
			var base_color = Color(1, 1, 1, 1)
			if object.material_override and object.material_override is StandardMaterial3D:
				base_color = object.material_override.albedo_color
			
			shader_material.set_shader_parameter("base_color", base_color)
			
			# Apply the shader material
			object.material_override = shader_material
			print("Applied basic shader to object without texture")

func _process(delta):
	# Handle camera movement
	handle_camera_movement(delta)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			# Cycle through textures
			current_texture_index += 1
			update_display()
		
		elif event.keycode == KEY_TAB:
			# Cycle through categories
			var category_index = categories.find(current_category)
			category_index = (category_index + 1) % categories.size()
			current_category = categories[category_index]
			current_texture_index = 0
			update_display()
		
		elif event.keycode == KEY_S:
			# Cycle through shaders
			current_shader_index = (current_shader_index + 1) % shader_types.size()
			update_display()
		
		elif event.keycode == KEY_C:
			# Toggle Ambrose chat interface
			if ambrose_interface:
				ambrose_interface.toggle_chat()

# Set up Ambrose integration
func setup_ambrose():
	if ambrose_interface:
		# Connect signals
		ambrose_interface.connect("message_sent", Callable(self, "_on_ambrose_message_sent"))
		ambrose_interface.connect("voice_requested", Callable(self, "_on_ambrose_voice_requested"))
		
		# Create Ambrose bridge
		ambrose_bridge = Node.new()
		ambrose_bridge.set_script(load("res://scripts/ai/ambrose_godot_bridge.gd"))
		add_child(ambrose_bridge)
		
		# Configure bridge
		ambrose_bridge.debug_mode = true
		ambrose_bridge.auto_start = true
		
		# Connect bridge signals
		ambrose_bridge.connect("ambrose_message_received", Callable(self, "_on_ambrose_response_received"))
		ambrose_bridge.connect("ambrose_command_executed", Callable(self, "_on_ambrose_command_executed"))
		
		print("Ambrose integration set up")
		
		# Start Ambrose after a short delay
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = 2.0
		timer.one_shot = true
		timer.connect("timeout", Callable(self, "_start_ambrose"))
		timer.start()

# Start Ambrose agent
func _start_ambrose():
	if ambrose_bridge:
		ambrose_bridge.start_ambrose()
		ambrose_ready = true
		print("Ambrose agent started")

# Handle message sent to Ambrose
func _on_ambrose_message_sent(message: String):
	print("Message sent to Ambrose: " + message)
	
	if ambrose_bridge and ambrose_ready:
		# Forward message to Ambrose bridge
		ambrose_bridge.send_message(message)
	else:
		# Simulate response if Ambrose is not ready
		var simulated_response = "Forgive me, but I am still gathering my thoughts. Please try again in a moment."
		_on_ambrose_response_received(simulated_response)

# Handle response from Ambrose
func _on_ambrose_response_received(message: String):
	print("Response from Ambrose: " + message)
	
	if ambrose_interface:
		ambrose_interface.set_response(message)

# Handle voice request
func _on_ambrose_voice_requested():
	print("Voice requested")
	
	if ambrose_bridge and ambrose_ready:
		# TODO: Implement voice recognition
		var simulated_text = "Tell me about this garden"
		ambrose_interface.send_message(simulated_text)
	else:
		var simulated_response = "Voice recognition is not available at the moment."
		_on_ambrose_response_received(simulated_response)

# Handle command execution
func _on_ambrose_command_executed(command_name: String, result):
	print("Command executed: " + command_name)
	print("Result: " + str(result))
	
	# Handle specific commands
	match command_name:
		"generate_texture":
			# Refresh the display
			load_available_textures()
			update_display()
		
		"create_plant":
			# Refresh the garden
			generate_garden_layout()
		
		"modify_garden":
			# Refresh the garden
			generate_garden_layout()

func handle_camera_movement(delta):
	# WASD movement
	var movement = Vector3.ZERO
	
	if Input.is_key_pressed(KEY_W):
		movement.z -= 1
	if Input.is_key_pressed(KEY_S):
		movement.z += 1
	if Input.is_key_pressed(KEY_A):
		movement.x -= 1
	if Input.is_key_pressed(KEY_D):
		movement.x += 1
	
	# Apply movement relative to camera orientation
	if movement != Vector3.ZERO:
		movement = movement.normalized() * camera_speed * delta
		camera.global_translate(movement)
	
	# Q/E rotation
	var rotation_change = 0
	
	if Input.is_key_pressed(KEY_Q):
		rotation_change -= 1
	if Input.is_key_pressed(KEY_E):
		rotation_change += 1
	
	if rotation_change != 0:
		camera.rotate_y(rotation_change * rotation_speed * delta)

func _on_generate_button_pressed():
	# Show a message that we're generating textures
	texture_info.text = "Generating medieval textures...\nThis may take a moment."
	
	# We need to defer the execution to allow the UI to update
	await get_tree().process_frame
	
	# Run the texture generation script
	var output = []
	var exit_code = OS.execute("python", ["scripts/medieval_texture_generator.py"], output, true)
	
	if exit_code == 0:
		texture_info.text = "Textures generated successfully!\nReloading textures..."
		await get_tree().process_frame
		
		# Reload available textures
		load_available_textures()
		update_display()
	else:
		texture_info.text = "Error generating textures.\nSee console for details."
		print("Error executing medieval_texture_generator.py:")
		for line in output:
			print(line)

func _on_integrate_button_pressed():
	# Show a message that we're integrating textures with shaders
	texture_info.text = "Integrating textures with shaders...\nThis may take a moment."
	
	# We need to defer the execution to allow the UI to update
	await get_tree().process_frame
	
	# Run the texture-shader integration script
	var output = []
	var exit_code = OS.execute("python", ["scripts/medieval_texture_shader_integrator.py", "--all"], output, true)
	
	if exit_code == 0:
		texture_info.text = "Textures integrated successfully!\nReloading display..."
		await get_tree().process_frame
		
		# Update the display to use the integrated textures
		update_display()
	else:
		texture_info.text = "Error integrating textures.\nSee console for details."
		print("Error executing medieval_texture_shader_integrator.py:")
		for line in output:
			print(line)
