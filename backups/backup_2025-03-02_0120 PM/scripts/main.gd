extends Node3D

# References to our core systems
var terrain_generator: TerrainGenerator
var placement_system: PlacementSystem
var camera_system: CameraSystem
var atmosphere_controller: AtmosphereController

# UI elements
var ui_container: Control
var build_ui: Control
var explore_ui: Control
var item_buttons = {}
var mode_switch_button: Button
var save_button: Button
var load_button: Button

# Item categories for UI organization
var item_categories = {
	"plants": "Plants",
	"paths": "Paths",
	"furniture": "Furniture",
	"water": "Water Features",
	"decoration": "Decorations",
	"structure": "Structures",
	"lighting": "Lighting"
}

# Current garden file path
var current_garden_path = "user://garden.json"

func _ready():
	# Initialize the terrain generator
	terrain_generator = TerrainGenerator.new()
	add_child(terrain_generator)
	terrain_generator.generate_terrain()
	
	# Create the terrain mesh
	var terrain_mesh = terrain_generator.create_mesh_instance()
	
	# Apply medieval shader to terrain
	var terrain_material = MedievalShaderCreator.create_medieval_material(
		Color(0.4, 0.5, 0.3),  # Green-brown base color
		false,                 # No gold accent
		5.0                    # Texture scale
	)
	terrain_mesh.material_override = terrain_material
	
	add_child(terrain_mesh)
	
	# Add a collision shape for the terrain
	var static_body = StaticBody3D.new()
	add_child(static_body)
	
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(
		terrain_generator.TERRAIN_SIZE.x * terrain_generator.TILE_SIZE,
		1.0,
		terrain_generator.TERRAIN_SIZE.y * terrain_generator.TILE_SIZE
	)
	collision_shape.shape = shape
	collision_shape.position = Vector3(0, -0.5, 0)  # Position slightly below the terrain
	static_body.add_child(collision_shape)
	
	# Initialize the placement system
	placement_system = PlacementSystem.new()
	add_child(placement_system)
	placement_system.set_terrain_generator(terrain_generator)
	
	# Initialize the camera system
	camera_system = CameraSystem.new()
	add_child(camera_system)
	camera_system.set_terrain_generator(terrain_generator)
	
	# Initialize the atmosphere controller
	atmosphere_controller = AtmosphereController.new()
	add_child(atmosphere_controller)
	
	# Set initial atmosphere to golden hour (for medieval aesthetic)
	atmosphere_controller.set_golden_hour()
	
	# Connect signals
	camera_system.mode_changed.connect(_on_camera_mode_changed)
	placement_system.item_placed.connect(_on_item_placed)
	placement_system.item_removed.connect(_on_item_removed)
	atmosphere_controller.time_changed.connect(_on_time_changed)
	atmosphere_controller.weather_changed.connect(_on_weather_changed)
	
	# Generate procedural elements
	_generate_procedural_elements()
	
	# Setup UI
	_setup_ui()
	
	# Set initial state
	_on_camera_mode_changed(camera_system.current_mode)

func _setup_lighting():
	# Create a directional light for the sun
	var directional_light = DirectionalLight3D.new()
	directional_light.shadow_enabled = true
	directional_light.light_color = Color(1.0, 0.95, 0.8)  # Warm sunlight
	directional_light.light_energy = 1.2
	
	# Position the light
	directional_light.rotation = Vector3(deg_to_rad(-45), deg_to_rad(45), 0)
	add_child(directional_light)
	
	# Add environment for sky and ambient light
	var world_environment = WorldEnvironment.new()
	var environment = Environment.new()
	
	# Sky settings
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.sky.sky_material = ProceduralSkyMaterial.new()
	
	# Ambient light settings
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_color = Color(0.6, 0.7, 0.9)
	environment.ambient_light_energy = 0.5
	
	# Fog settings for atmosphere
	environment.fog_enabled = true
	environment.fog_density = 0.001
	environment.fog_aerial_perspective = 0.5
	environment.fog_sky_affect = 0.5
	
	world_environment.environment = environment
	add_child(world_environment)

func _setup_ui():
	# Create UI container
	ui_container = Control.new()
	ui_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(ui_container)
	
	# Create build mode UI
	build_ui = Control.new()
	build_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_container.add_child(build_ui)
	
	# Create explore mode UI
	explore_ui = Control.new()
	explore_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_container.add_child(explore_ui)
	
	# Create item selection panel
	var item_panel = Panel.new()
	item_panel.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	item_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_panel.custom_minimum_size = Vector2(200, 0)
	build_ui.add_child(item_panel)
	
	var item_scroll = ScrollContainer.new()
	item_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	item_panel.add_child(item_scroll)
	
	var item_vbox = VBoxContainer.new()
	item_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	item_scroll.add_child(item_vbox)
	
	# Add category headers and item buttons
	for category_id in item_categories:
		var category_label = Label.new()
		category_label.text = item_categories[category_id]
		category_label.add_theme_font_size_override("font_size", 18)
		item_vbox.add_child(category_label)
		
		var category_items = _get_items_in_category(category_id)
		for item_id in category_items:
			var item_button = Button.new()
			item_button.text = _format_item_name(item_id)
			item_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			item_button.pressed.connect(_on_item_button_pressed.bind(item_id))
			item_vbox.add_child(item_button)
			item_buttons[item_id] = item_button
		
		# Add spacer after each category
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 10)
		item_vbox.add_child(spacer)
	
	# Create tool panel (top right)
	var tool_panel = Panel.new()
	tool_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	tool_panel.custom_minimum_size = Vector2(200, 100)
	build_ui.add_child(tool_panel)
	
	var tool_vbox = VBoxContainer.new()
	tool_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	tool_vbox.custom_minimum_size = Vector2(200, 0)
	tool_panel.add_child(tool_vbox)
	
	# Add tool buttons
	mode_switch_button = Button.new()
	mode_switch_button.text = "Switch to Explore Mode"
	mode_switch_button.pressed.connect(_on_mode_switch_button_pressed)
	tool_vbox.add_child(mode_switch_button)
	
	var rotate_button = Button.new()
	rotate_button.text = "Rotate Item (R)"
	rotate_button.pressed.connect(_on_rotate_button_pressed)
	tool_vbox.add_child(rotate_button)
	
	var remove_button = Button.new()
	remove_button.text = "Remove Item (Delete)"
	remove_button.pressed.connect(_on_remove_button_pressed)
	tool_vbox.add_child(remove_button)
	
	save_button = Button.new()
	save_button.text = "Save Garden"
	save_button.pressed.connect(_on_save_button_pressed)
	tool_vbox.add_child(save_button)
	
	load_button = Button.new()
	load_button.text = "Load Garden"
	load_button.pressed.connect(_on_load_button_pressed)
	tool_vbox.add_child(load_button)
	
	# Create help text for explore mode
	var help_label = Label.new()
	help_label.text = "Press TAB to return to Build Mode\nWASD to move, Mouse to look"
	help_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	help_label.position = Vector2(0, 20)
	explore_ui.add_child(help_label)

func _get_items_in_category(category_id: String) -> Array:
	var items = []
	for item_id in placement_system.placeable_items:
		if placement_system.placeable_items[item_id]["category"] == category_id:
			items.append(item_id)
	return items

func _format_item_name(item_id: String) -> String:
	# Convert snake_case to Title Case
	var words = item_id.split("_")
	for i in range(words.size()):
		words[i] = words[i].capitalize()
	return " ".join(words)

func _on_item_button_pressed(item_id: String):
	placement_system.select_item(item_id)

func _on_rotate_button_pressed():
	placement_system.rotate_selected_item()

func _on_remove_button_pressed():
	# Get mouse position in 3D space
	var camera = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		placement_system.remove_item_at_position(result.position)

func _on_mode_switch_button_pressed():
	camera_system.switch_mode()

func _on_camera_mode_changed(mode):
	if mode == CameraSystem.CameraMode.BUILD:
		build_ui.visible = true
		explore_ui.visible = false
		mode_switch_button.text = "Switch to Explore Mode"
	else:
		build_ui.visible = false
		explore_ui.visible = true
		mode_switch_button.text = "Switch to Build Mode"

func _on_item_placed(item_type, position, rotation):
	print("Item placed: ", item_type, " at ", position, " with rotation ", rotation)

func _on_item_removed(item_id):
	print("Item removed: ", item_id)

func _on_save_button_pressed():
	var garden_data = placement_system.save_garden()
	var file = FileAccess.open(current_garden_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(garden_data))
		file.close()
		print("Garden saved to: ", current_garden_path)
	else:
		print("Failed to save garden")

func _on_load_button_pressed():
	var file = FileAccess.open(current_garden_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			var garden_data = json.data
			placement_system.load_garden(garden_data)
			print("Garden loaded from: ", current_garden_path)
		else:
			print("JSON Parse Error: ", json.get_error_message())
	else:
		print("Failed to load garden")

# Generate procedural elements for the garden
func _generate_procedural_elements():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Create a container for procedural elements
	var procedural_elements = Node3D.new()
	procedural_elements.name = "ProceduralElements"
	add_child(procedural_elements)
	
	# Generate trees
	var num_trees = 10
	for i in range(num_trees):
		var tree = LSystem.create_tree(rng.randi())
		
		# Position the tree randomly on the terrain
		var x = rng.randf_range(-20, 20)
		var z = rng.randf_range(-20, 20)
		var y = terrain_generator.get_height_at_position(x, z)
		
		tree.position = Vector3(x, y, z)
		tree.scale = Vector3.ONE * rng.randf_range(0.8, 1.5)
		tree.rotation.y = rng.randf_range(0, PI * 2)
		
		procedural_elements.add_child(tree)
	
	# Generate bushes
	var num_bushes = 15
	for i in range(num_bushes):
		var bush = LSystem.create_bush(rng.randi())
		
		# Position the bush randomly on the terrain
		var x = rng.randf_range(-20, 20)
		var z = rng.randf_range(-20, 20)
		var y = terrain_generator.get_height_at_position(x, z)
		
		bush.position = Vector3(x, y, z)
		bush.scale = Vector3.ONE * rng.randf_range(0.5, 1.0)
		bush.rotation.y = rng.randf_range(0, PI * 2)
		
		procedural_elements.add_child(bush)
	
	# Generate flowers
	var num_flowers = 30
	for i in range(num_flowers):
		var flower = LSystem.create_flower(rng.randi())
		
		# Position the flower randomly on the terrain
		var x = rng.randf_range(-20, 20)
		var z = rng.randf_range(-20, 20)
		var y = terrain_generator.get_height_at_position(x, z)
		
		flower.position = Vector3(x, y, z)
		flower.scale = Vector3.ONE * rng.randf_range(0.3, 0.7)
		flower.rotation.y = rng.randf_range(0, PI * 2)
		
		procedural_elements.add_child(flower)
	
	# Generate paths
	var path_container = Node3D.new()
	path_container.name = "Paths"
	procedural_elements.add_child(path_container)
	
	# Create a circular path in the center
	var center_path = PathGenerator.generate_circular_path(
		Vector3(0, 0, 0),  # Center
		10.0,              # Radius
		16,                # Segments
		PathGenerator.PathType.STONE  # Path type
	)
	path_container.add_child(center_path)
	
	# Create some radial paths
	var num_radial_paths = 4
	for i in range(num_radial_paths):
		var angle = i * (2 * PI / num_radial_paths)
		var inner_point = Vector3(cos(angle) * 10, 0, sin(angle) * 10)
		var outer_point = Vector3(cos(angle) * 20, 0, sin(angle) * 20)
		
		var path_type
		match i % 4:
			0: path_type = PathGenerator.PathType.STONE
			1: path_type = PathGenerator.PathType.BRICK
			2: path_type = PathGenerator.PathType.GRAVEL
			3: path_type = PathGenerator.PathType.DIRT
		
		var radial_path = PathGenerator.generate_straight_path(
			inner_point,
			outer_point,
			path_type
		)
		path_container.add_child(radial_path)

# Handle time of day changes
func _on_time_changed(time_of_day):
	print("Time changed to: ", atmosphere_controller.get_time_of_day_string())
	
	# Update UI or other elements based on time of day
	if time_of_day == AtmosphereController.TimeOfDay.NIGHT or time_of_day == AtmosphereController.TimeOfDay.MIDNIGHT:
		# Add torches or other lighting if it's night
		pass

# Handle weather changes
func _on_weather_changed(weather_type):
	print("Weather changed to: ", atmosphere_controller.get_weather_string())
	
	# Update UI or other elements based on weather
	if weather_type == AtmosphereController.WeatherType.HEAVY_RAIN or weather_type == AtmosphereController.WeatherType.STORMY:
		# Maybe add some shelter or effects
		pass

func _input(event):
	# Handle keyboard shortcuts
	if event is InputEventKey and event.pressed:
		# Tab key to switch modes
		if event.keycode == KEY_TAB:
			camera_system.switch_mode()
		
		# R key to rotate selected item
		if event.keycode == KEY_R and camera_system.current_mode == CameraSystem.CameraMode.BUILD:
			placement_system.rotate_selected_item()
		
		# Delete key to remove item
		if event.keycode == KEY_DELETE and camera_system.current_mode == CameraSystem.CameraMode.BUILD:
			_on_remove_button_pressed()
		
		# Left mouse button to place item
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if camera_system.current_mode == CameraSystem.CameraMode.BUILD and placement_system.can_place:
				placement_system.place_item()
		
		# Weather and time controls
		if event.keycode == KEY_1:
			# Change to golden hour
			atmosphere_controller.set_golden_hour()
		elif event.keycode == KEY_2:
			# Change to noon
			atmosphere_controller.set_medieval_noon()
		elif event.keycode == KEY_3:
			# Change to night
			atmosphere_controller.set_time_progress(0.9)  # 90% through the day
		elif event.keycode == KEY_4:
			# Change to dawn
			atmosphere_controller.set_time_progress(0.3)  # 30% through the day
		elif event.keycode == KEY_5:
			# Toggle day cycle
			atmosphere_controller.set_day_cycle_enabled(not atmosphere_controller.day_cycle_enabled)
		elif event.keycode == KEY_6:
			# Random weather
			atmosphere_controller.random_weather_change()
