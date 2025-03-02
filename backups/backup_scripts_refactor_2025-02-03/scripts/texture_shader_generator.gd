extends Node
class_name TextureShaderGenerator

# This script serves as a bridge between the Python texture generator and the Godot shader pack
# It provides functions to generate textures using the Python script and apply shaders to materials

# Paths
const PYTHON_SCRIPT_PATH = "res://scripts/texture_generator.py"
const TEXTURE_BASE_PATH = "res://assets/textures/medieval_pack_1"

# Signal for progress updates
signal generation_progress(step, total_steps, description)

# Generate all textures using the Python script
func generate_all_textures() -> bool:
	print("Starting texture generation process...")
	
	# Check if Python is available
	var output = []
	var exit_code = OS.execute("python", ["--version"], output)
	
	if exit_code != 0:
		push_error("Python is not available. Please install Python to generate textures.")
		return false
	
	print("Python detected. Generating textures...")
	
	# Run the texture generator script
	var script_path = ProjectSettings.globalize_path(PYTHON_SCRIPT_PATH)
	exit_code = OS.execute("python", [script_path], output)
	
	if exit_code != 0:
		push_error("Failed to run texture generator script: " + str(output))
		return false
	
	print("Textures generated successfully!")
	print(output)
	return true

# Apply shaders to materials based on texture types
func apply_shaders_to_materials() -> Dictionary:
	print("Applying shaders to materials...")
	
	var materials = {}
	
	# Ground materials
	emit_signal("generation_progress", 1, 5, "Creating ground materials...")
	materials["ground"] = _create_ground_materials()
	
	# Plant materials
	emit_signal("generation_progress", 2, 5, "Creating plant materials...")
	materials["plants"] = _create_plant_materials()
	
	# Structure materials
	emit_signal("generation_progress", 3, 5, "Creating structure materials...")
	materials["structures"] = _create_structure_materials()
	
	# Decorative materials
	emit_signal("generation_progress", 4, 5, "Creating decorative materials...")
	materials["decorative"] = _create_decorative_materials()
	
	# Water materials
	emit_signal("generation_progress", 5, 5, "Creating water materials...")
	materials["water"] = _create_water_material()
	
	print("All materials created successfully!")
	return materials

# Create ground materials with appropriate shaders
func _create_ground_materials() -> Dictionary:
	var materials = {}
	
	# Soil materials
	materials["soil_rich"] = _create_material_from_texture("ground/soil_rich.png", "ground", Color(0.4, 0.3, 0.2))
	materials["soil_dry"] = _create_material_from_texture("ground/soil_dry.png", "ground", Color(0.5, 0.4, 0.3))
	materials["soil_clay"] = _create_material_from_texture("ground/soil_clay.png", "ground", Color(0.6, 0.4, 0.3))
	
	# Grass materials
	materials["grass_common"] = _create_material_from_texture("ground/grass_common.png", "ground", Color(0.3, 0.5, 0.2))
	materials["grass_lush"] = _create_material_from_texture("ground/grass_lush.png", "ground", Color(0.2, 0.5, 0.1))
	materials["grass_dry"] = _create_material_from_texture("ground/grass_dry.png", "ground", Color(0.5, 0.5, 0.3))
	
	# Stone materials
	materials["stone_cobble"] = _create_material_from_texture("ground/stone_cobble.png", "stone_wall", Color(0.7, 0.7, 0.7))
	materials["stone_flag"] = _create_material_from_texture("ground/stone_flag.png", "stone_wall", Color(0.75, 0.75, 0.7))
	materials["stone_rough"] = _create_material_from_texture("ground/stone_rough.png", "stone_wall", Color(0.6, 0.6, 0.6))
	
	# Brick materials
	materials["brick_red"] = _create_material_from_texture("ground/brick_red.png", "stone_wall", Color(0.7, 0.3, 0.2))
	materials["brick_clay"] = _create_material_from_texture("ground/brick_clay.png", "stone_wall", Color(0.8, 0.6, 0.4))
	
	return materials

# Create plant materials with appropriate shaders
func _create_plant_materials() -> Dictionary:
	var materials = {}
	
	# Flower materials
	materials["flower_red"] = _create_material_from_texture("plants/flower_red.png", "illuminated", Color(0.8, 0.2, 0.2))
	materials["flower_blue"] = _create_material_from_texture("plants/flower_blue.png", "illuminated", Color(0.2, 0.4, 0.8))
	materials["flower_yellow"] = _create_material_from_texture("plants/flower_yellow.png", "illuminated", Color(0.9, 0.8, 0.2))
	materials["flower_purple"] = _create_material_from_texture("plants/flower_purple.png", "illuminated", Color(0.6, 0.3, 0.7))
	
	# Leaf materials
	materials["leaf_green"] = _create_material_from_texture("plants/leaf_green.png", "illuminated", Color(0.3, 0.6, 0.3))
	materials["leaf_autumn"] = _create_material_from_texture("plants/leaf_autumn.png", "illuminated", Color(0.8, 0.4, 0.2))
	materials["leaf_dry"] = _create_material_from_texture("plants/leaf_dry.png", "weathered", Color(0.6, 0.5, 0.3))
	
	return materials

# Create structure materials with appropriate shaders
func _create_structure_materials() -> Dictionary:
	var materials = {}
	
	# Wood materials
	materials["wood_oak"] = _create_material_from_texture("structures/wood_oak.png", "wood", Color(0.6, 0.4, 0.2))
	materials["wood_dark"] = _create_material_from_texture("structures/wood_dark.png", "wood", Color(0.4, 0.3, 0.2))
	materials["wood_light"] = _create_material_from_texture("structures/wood_light.png", "wood", Color(0.7, 0.5, 0.3))
	
	# Thatch material
	materials["thatch"] = _create_material_from_texture("structures/thatch.png", "weathered", Color(0.7, 0.6, 0.3))
	
	return materials

# Create decorative materials with appropriate shaders
func _create_decorative_materials() -> Dictionary:
	var materials = {}
	
	# Parchment materials
	materials["parchment"] = _create_material_from_texture("decorative/parchment.png", "parchment", Color(0.9, 0.85, 0.7))
	materials["parchment_bordered"] = _create_material_from_texture("decorative/parchment_bordered.png", "parchment", Color(0.9, 0.85, 0.7))
	
	# Create a stained glass material (no texture needed)
	materials["stained_glass"] = MedievalShaderPack.create_medieval_shader_material("stained_glass")
	
	# Create a fabric material
	var fabric_material = MedievalShaderPack.create_medieval_shader_material("fabric", Color(0.5, 0.2, 0.2))
	fabric_material.set_shader_parameter("pattern_intensity", 0.7)
	materials["fabric_red"] = fabric_material
	
	# Create a gold-threaded fabric material
	var gold_fabric_material = MedievalShaderPack.create_medieval_shader_material("fabric", Color(0.3, 0.1, 0.5))
	gold_fabric_material.set_shader_parameter("pattern_intensity", 0.8)
	gold_fabric_material.set_shader_parameter("use_gold_thread", true)
	materials["fabric_royal"] = gold_fabric_material
	
	return materials

# Create water material with appropriate shader
func _create_water_material() -> ShaderMaterial:
	return MedievalShaderPack.create_medieval_shader_material("water")

# Create a material from a texture with the specified shader type
func _create_material_from_texture(texture_path: String, shader_type: String, base_color: Color = Color(1, 1, 1)) -> ShaderMaterial:
	var material = MedievalShaderPack.create_medieval_shader_material(shader_type, base_color)
	
	# Load the texture if it exists
	var full_path = TEXTURE_BASE_PATH + "/" + texture_path
	if ResourceLoader.exists(full_path):
		var texture = load(full_path)
		
		# Set the texture parameter based on shader type
		match shader_type:
			"illuminated":
				material.set_shader_parameter("main_texture", texture)
			"weathered":
				material.set_shader_parameter("main_texture", texture)
			"parchment":
				material.set_shader_parameter("parchment_texture", texture)
			"stone_wall":
				material.set_shader_parameter("stone_texture", texture)
			"wood":
				material.set_shader_parameter("wood_texture", texture)
			"fabric":
				material.set_shader_parameter("fabric_texture", texture)
			"ground":
				material.set_shader_parameter("soil_texture", texture)
	
	return material

# Generate a single texture and return the path
func generate_single_texture(texture_type: String, variation: String = "") -> String:
	print("Generating single texture: " + texture_type + (", variation: " + variation if variation else ""))
	
	# Prepare the command arguments
	var args = [ProjectSettings.globalize_path(PYTHON_SCRIPT_PATH), "--single", texture_type]
	if variation:
		args.append("--variation")
		args.append(variation)
	
	# Run the Python script
	var output = []
	var exit_code = OS.execute("python", args, output)
	
	if exit_code != 0:
		push_error("Failed to generate texture: " + str(output))
		return ""
	
	# Parse the output to get the generated texture path
	var texture_path = ""
	for line in output:
		if line.begins_with("TEXTURE_PATH:"):
			texture_path = line.split("TEXTURE_PATH:")[1].strip_edges()
	
	print("Generated texture at: " + texture_path)
	return texture_path

# Apply a shader to a MeshInstance3D
func apply_shader_to_mesh(mesh_instance: MeshInstance3D, material_key: String, materials_dict: Dictionary) -> void:
	var category = material_key.split("/")[0]
	var name = material_key.split("/")[1]
	
	if category in materials_dict and name in materials_dict[category]:
		mesh_instance.material_override = materials_dict[category][name]
	else:
		push_warning("Material not found: " + material_key)

# Create a complete medieval material set for a new object
static func create_medieval_material_set() -> Dictionary:
	var materials = {}
	
	# Create basic materials with medieval shaders
	materials["stone"] = MedievalShaderPack.create_medieval_shader_material("stone_wall", Color(0.7, 0.7, 0.7))
	materials["wood"] = MedievalShaderPack.create_medieval_shader_material("wood", Color(0.6, 0.4, 0.2))
	materials["fabric"] = MedievalShaderPack.create_medieval_shader_material("fabric", Color(0.5, 0.2, 0.2))
	materials["parchment"] = MedievalShaderPack.create_medieval_shader_material("parchment", Color(0.9, 0.85, 0.7))
	materials["gold"] = MedievalShaderPack.create_medieval_shader_material("illuminated", Color(0.9, 0.8, 0.2))
	materials["water"] = MedievalShaderPack.create_medieval_shader_material("water")
	
	# Set gold accent for the gold material
	materials["gold"].set_shader_parameter("use_gold_leaf", true)
	materials["gold"].set_shader_parameter("gold_accent_intensity", 1.0)
	
	return materials
