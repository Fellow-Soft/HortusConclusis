extends Node
class_name TerrainGenerator

# Constants for terrain generation
const TERRAIN_SIZE = Vector2(50, 50)  # Size of the terrain in tiles
const TILE_SIZE = 1.0  # Size of each tile in world units

# Exported variables for customization
@export var terrace_height: float = 0.5
@export var terrace_step: float = 3.0
@export var soil_type: String = "grass"  # "grass", "soil", "stone"
# Erosion parameters
@export var erosion_rate: float = 0.01
@export var deposition_rate: float = 0.01
@export var erosion_iterations: int = 10

# Noise parameters for terrain height
var noise = FastNoiseLite.new()
var seed_value = 0

# Terrain data
var height_map = []
var soil_map = [] # 2D array to store soil types per tile
var water_map = [] # 2D array to store water levels

func _init():
	# Initialize the noise generator
	randomize()
	seed_value = randi()
	noise.seed = seed_value
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_octaves = 4
	noise.frequency = 0.1
	
	# Initialize water map
	water_map = []
	for x in range(TERRAIN_SIZE.x):
		var row = []
		for z in range(TERRAIN_SIZE.y):
			row.append(0.0) # No initial water
		water_map.append(row)

func generate_terrain():
	print("Generating terrain...")
	
	# Initialize height and soil maps
	height_map = []
	soil_map = []
	for x in range(TERRAIN_SIZE.x):
		var height_row = []
		var soil_row = []
		for z in range(TERRAIN_SIZE.y):
			height_row.append(0.0)
			soil_row.append("grass") # Default soil type
		height_map.append(height_row)
		soil_map.append(soil_row)
	
	# Generate height and soil values
	for x in range(TERRAIN_SIZE.x):
		for z in range(TERRAIN_SIZE.y):
			var nx = float(x) / TERRAIN_SIZE.x - 0.5
			var nz = float(z) / TERRAIN_SIZE.y - 0.5
			
			# Generate base terrain (relatively flat for a garden)
			var raw_height = noise.get_noise_2d(nx * 10, nz * 10) * 0.5 + 0.5
			
			# Apply terracing directly during height generation
			var stepped_height = floor(raw_height / terrace_height) * terrace_height
			
			# Add small variation within each terrace level
			var terrace_variation = noise.get_noise_2d(nx * 20, nz * 20) * 0.1
			var height = stepped_height + terrace_variation
			
			# Scale height to be subtle
			height = height * 0.2
			
			# Ensure minimum height is 0
			height = max(0.0, height)
			
			# Determine soil type based on height and noise
			var soil_noise = noise.get_noise_2d(nx * 5, nz * 5)
			if height > 0.15:
				soil_map[x][z] = "stone"
			elif soil_noise > 0.2:
				soil_map[x][z] = "soil"
			else:
				soil_map[x][z] = "grass"
			
			# Store height value
			height_map[x][z] = height
	
	_simulate_erosion() # Apply erosion after generating initial terrain
	return height_map

func create_mesh_instance():
	# Create a MeshInstance3D for the terrain
	var mesh_instance = MeshInstance3D.new()
	var mesh = create_terrain_mesh()
	mesh_instance.mesh = mesh
	
	# Create material based on soil type
	var material = create_terrain_material()
	mesh_instance.material_override = material
	
	return mesh_instance

func _simulate_erosion():
	print("Simulating erosion...")
	
	for _i in range(erosion_iterations):
		for x in range(1, TERRAIN_SIZE.x - 1):
			for z in range(1, TERRAIN_SIZE.y - 1):
				# Calculate height difference with neighbors
				var height_diff = 0.0
				height_diff += height_map[x][z] - height_map[x+1][z]
				height_diff += height_map[x][z] - height_map[x-1][z]
				height_diff += height_map[x][z] - height_map[x][z+1]
				height_diff += height_map[x][z] - height_map[x][z-1]
				height_diff /= 4.0
				
				# Apply erosion and deposition
				height_map[x][z] -= height_diff * erosion_rate
				
				# Deposition to lower neighbors (simplified)
				var deposition = height_diff * deposition_rate / 4.0
				height_map[x+1][z] += deposition
				height_map[x-1][z] += deposition
				height_map[x][z+1] += deposition
				height_map[x][z-1] += deposition

func create_terrain_material(type = null):
	var material = StandardMaterial3D.new()
	var material_type = type if type != null else soil_type
	
	match material_type:
		"grass":
			material.albedo_color = Color(0.3, 0.5, 0.2)  # Green for grass
		"soil":
			material.albedo_color = Color(0.4, 0.3, 0.2)  # Brown for soil
		"stone":
			material.albedo_color = Color(0.5, 0.5, 0.5)  # Gray for stone
		_:
			material.albedo_color = Color(0.3, 0.5, 0.2)  # Default to grass
	return material

func create_terrain_mesh():
	# Create a new PlaneMesh for the terrain
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(TERRAIN_SIZE.x, TERRAIN_SIZE.y) * TILE_SIZE
	plane_mesh.subdivide_width = int(TERRAIN_SIZE.x) - 1
	plane_mesh.subdivide_depth = int(TERRAIN_SIZE.y) - 1
	
	# Create a new ArrayMesh
	var array_mesh = ArrayMesh.new()
	
	# Define materials for each soil type
	var materials = {
		"grass": create_terrain_material("grass"),
		"soil": create_terrain_material("soil"),
		"stone": create_terrain_material("stone")
	}
	
	# Generate surfaces per material
	for soil in materials.keys():
		var surface_tool = SurfaceTool.new()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface_tool.set_uv(Vector2(0, 0))
		surface_tool.set_normal(Vector3(0, 1, 0))
		
		# Generate mesh data and materials per tile
		for x in range(TERRAIN_SIZE.x - 1):
			for z in range(TERRAIN_SIZE.y - 1):
				if soil_map[x][z] == soil: # Only add vertices for this soil type
					# Get tile vertices and height
					var v1 = Vector3(x * TILE_SIZE - TERRAIN_SIZE.x * TILE_SIZE / 2, height_map[x][z], z * TILE_SIZE - TERRAIN_SIZE.y * TILE_SIZE / 2)
					var v2 = Vector3((x + 1) * TILE_SIZE - TERRAIN_SIZE.x * TILE_SIZE / 2, height_map[x+1][z], z * TILE_SIZE - TERRAIN_SIZE.y * TILE_SIZE / 2)
					var v3 = Vector3((x + 1) * TILE_SIZE - TERRAIN_SIZE.x * TILE_SIZE / 2, height_map[x+1][z+1], (z + 1) * TILE_SIZE - TERRAIN_SIZE.y * TILE_SIZE / 2)
					var v4 = Vector3(x * TILE_SIZE - TERRAIN_SIZE.x * TILE_SIZE / 2, height_map[x][z+1], (z + 1) * TILE_SIZE - TERRAIN_SIZE.y * TILE_SIZE / 2)
					
					# Create tile mesh
					surface_tool.add_vertex(v1)
					surface_tool.add_vertex(v2)
					surface_tool.add_vertex(v3)
					surface_tool.add_vertex(v4)
					
					# Create triangles
					surface_tool.add_index(0)
					surface_tool.add_index(1)
					surface_tool.add_index(2)
					surface_tool.add_index(0)
					surface_tool.add_index(2)
					surface_tool.add_index(3)
		
		# Commit surface to mesh with material
		array_mesh.add_surface_from_tool(surface_tool, materials[soil], "")
	
	return array_mesh

# Function to get height at a specific world position
func get_height_at_position(world_x: float, world_z: float) -> float:
	var grid_x = int((world_x / TILE_SIZE + TERRAIN_SIZE.x / 2.0))
	var grid_z = int((world_z / TILE_SIZE + TERRAIN_SIZE.y / 2.0))
	
	# Ensure we're within bounds
	grid_x = clamp(grid_x, 0, TERRAIN_SIZE.x - 1)
	grid_z = clamp(grid_z, 0, TERRAIN_SIZE.y - 1)
	
	return height_map[grid_x][grid_z]

# Function to set a new seed and regenerate the terrain
func set_new_seed(new_seed = null):
	if new_seed == null:
		randomize()
		seed_value = randi()
	else:
		seed_value = new_seed
	
	noise.seed = seed_value
	return generate_terrain()

func _process(delta):
	# Simulate erosion over time
	_simulate_erosion_over_time(delta)

func _simulate_erosion_over_time(delta):
	# Erosion simulation timer (adjust interval as needed)
	var erosion_interval = 0.5 # seconds

	if fmod(Time.get_ticks_msec() / 1000.0, erosion_interval) < delta:
		_simulate_erosion()
