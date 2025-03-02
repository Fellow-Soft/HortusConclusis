extends Node
class_name LSystem

# L-System parameters
var axiom: String = "F"
var rules = {}
var angle: float = 25.0
var iterations: int = 3
var step_size: float = 0.5
var randomness: float = 0.1
var thickness_scale: float = 0.9
var branch_probability: float = 0.3

# Result of the L-System generation
var result: String = ""

# Random number generator for consistent results
var rng = RandomNumberGenerator.new()
var seed_value: int = 0

func _init(p_seed: int = 0):
	seed_value = p_seed if p_seed > 0 else randi()
	rng.seed = seed_value

# Set the axiom (starting string)
func set_axiom(p_axiom: String) -> void:
	axiom = p_axiom

# Add a rule to the L-System
func add_rule(predecessor: String, successor: String) -> void:
	rules[predecessor] = successor

# Set the angle for rotations (in degrees)
func set_angle(p_angle: float) -> void:
	angle = p_angle

# Set the number of iterations
func set_iterations(p_iterations: int) -> void:
	iterations = p_iterations

# Set the step size for forward movement
func set_step_size(p_step_size: float) -> void:
	step_size = p_step_size

# Set the randomness factor (0.0 to 1.0)
func set_randomness(p_randomness: float) -> void:
	randomness = clamp(p_randomness, 0.0, 1.0)

# Set the thickness scaling factor for branches
func set_thickness_scale(p_thickness_scale: float) -> void:
	thickness_scale = p_thickness_scale

# Set the probability of branching
func set_branch_probability(p_probability: float) -> void:
	branch_probability = clamp(p_probability, 0.0, 1.0)

# Generate the L-System string
func generate() -> String:
	result = axiom
	
	for i in range(iterations):
		var new_result = ""
		for j in range(result.length()):
			var c = result[j]
			if c in rules:
				# Apply rule with some randomness
				if rng.randf() < branch_probability or not _is_branch_symbol(c):
					new_result += _apply_rule_with_randomness(c)
				else:
					new_result += c
			else:
				new_result += c
		result = new_result
	
	return result

# Check if a symbol represents a branch
func _is_branch_symbol(symbol: String) -> bool:
	return symbol == "+" or symbol == "-" or symbol == "[" or symbol == "]"

# Apply a rule with some randomness
func _apply_rule_with_randomness(symbol: String) -> String:
	var rule = rules[symbol]
	
	if randomness <= 0.0:
		return rule
	
	var modified_rule = ""
	for i in range(rule.length()):
		var c = rule[i]
		
		# Add randomness to angles
		if c == "+" or c == "-":
			if rng.randf() < randomness:
				var angle_mod = rng.randf_range(-15, 15)
				if angle_mod > 0:
					modified_rule += "+"
				else:
					modified_rule += "-"
			else:
				modified_rule += c
		# Add randomness to step size
		elif c == "F":
			if rng.randf() < randomness:
				var length_mod = rng.randf_range(0.8, 1.2)
				if length_mod > 1.0:
					modified_rule += "FF"
				else:
					modified_rule += "F"
			else:
				modified_rule += c
		else:
			modified_rule += c
	
	return modified_rule

# Create a 3D mesh from the L-System
func create_mesh(material: Material = null) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var st = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	if material:
		st.set_material(material)
	
	var position_stack = []
	var direction_stack = []
	var thickness_stack = []
	
	var position = Vector3.ZERO
	var direction = Vector3(0, 1, 0)
	var thickness = 0.1
	
	# Create a basis for the branch
	var up = Vector3(0, 1, 0)
	var right = direction.cross(up).normalized()
	if right.length_squared() < 0.01:
		right = Vector3(1, 0, 0)
	var forward = right.cross(up).normalized()
	
	for i in range(result.length()):
		var c = result[i]
		
		match c:
			"F":  # Move forward and draw
				var new_position = position + direction * step_size
				_create_branch_segment(st, position, new_position, thickness, right, forward)
				position = new_position
			"+":  # Turn right
				var rot = Quaternion(up, deg_to_rad(angle))
				direction = rot * direction
				right = rot * right
				forward = right.cross(up).normalized()
			"-":  # Turn left
				var rot = Quaternion(up, deg_to_rad(-angle))
				direction = rot * direction
				right = rot * right
				forward = right.cross(up).normalized()
			"&":  # Pitch down
				var rot = Quaternion(right, deg_to_rad(angle))
				direction = rot * direction
				up = rot * up
				forward = right.cross(up).normalized()
			"^":  # Pitch up
				var rot = Quaternion(right, deg_to_rad(-angle))
				direction = rot * direction
				up = rot * up
				forward = right.cross(up).normalized()
			"<":  # Roll left
				var rot = Quaternion(direction, deg_to_rad(angle))
				up = rot * up
				right = rot * right
				forward = right.cross(up).normalized()
			">":  # Roll right
				var rot = Quaternion(direction, deg_to_rad(-angle))
				up = rot * up
				right = rot * right
				forward = right.cross(up).normalized()
			"|":  # Turn around
				direction = -direction
				right = -right
				forward = -forward
			"[":  # Push state
				position_stack.push_back(position)
				direction_stack.push_back([direction, up, right, forward])
				thickness_stack.push_back(thickness)
				thickness *= thickness_scale
			"]":  # Pop state
				position = position_stack.pop_back()
				var dirs = direction_stack.pop_back()
				direction = dirs[0]
				up = dirs[1]
				right = dirs[2]
				forward = dirs[3]
				thickness = thickness_stack.pop_back()
	
	mesh_instance.mesh = st.commit()
	
	return mesh_instance

# Create a branch segment between two points
func _create_branch_segment(st: SurfaceTool, start: Vector3, end: Vector3, thickness: float, right: Vector3, forward: Vector3) -> void:
	var segments = 6  # Number of sides for the branch cylinder
	
	# Create vertices for the start of the segment
	var start_vertices = []
	for i in range(segments):
		var angle = 2 * PI * i / segments
		var offset = right * cos(angle) * thickness + forward * sin(angle) * thickness
		start_vertices.append(start + offset)
	
	# Create vertices for the end of the segment
	var end_vertices = []
	for i in range(segments):
		var angle = 2 * PI * i / segments
		var offset = right * cos(angle) * thickness + forward * sin(angle) * thickness
		end_vertices.append(end + offset)
	
	# Create triangles for the cylinder
	for i in range(segments):
		var i2 = (i + 1) % segments
		
		# First triangle
		st.add_vertex(start_vertices[i])
		st.add_vertex(end_vertices[i])
		st.add_vertex(end_vertices[i2])
		
		# Second triangle
		st.add_vertex(start_vertices[i])
		st.add_vertex(end_vertices[i2])
		st.add_vertex(start_vertices[i2])
	
	# Create cap at the start
	var start_center = start
	for i in range(segments):
		var i2 = (i + 1) % segments
		st.add_vertex(start_center)
		st.add_vertex(start_vertices[i])
		st.add_vertex(start_vertices[i2])
	
	# Create cap at the end
	var end_center = end
	for i in range(segments):
		var i2 = (i + 1) % segments
		st.add_vertex(end_center)
		st.add_vertex(end_vertices[i2])
		st.add_vertex(end_vertices[i])
	

# Medieval plant patterns based on sacred geometry and symbolism
const MEDIEVAL_PATTERNS = {
	"rose": {  # Five-petaled rose pattern (symbol of Mary)
		"axiom": "F",
		"rules": {
			"F": "F[++F][--F][+F][-F][F]"  # Five-fold symmetry
		},
		"angle": 72.0,  # 360/5 for pentagonal symmetry
		"iterations": 4,
		"step_size": 0.3,
		"thickness_scale": 0.8,
		"colors": {
			"stem": Color(0.2, 0.4, 0.1),
			"flower": Color(0.8, 0.2, 0.2)
		}
	},
	"lily": {  # Trinity-based lily pattern
		"axiom": "F",
		"rules": {
			"F": "FF-[-F+F+F]+[+F-F-F]"  # Three-fold symmetry
		},
		"angle": 120.0,  # 360/3 for trinity symbolism
		"iterations": 3,
		"step_size": 0.4,
		"thickness_scale": 0.7,
		"colors": {
			"stem": Color(0.3, 0.5, 0.1),
			"flower": Color(1.0, 1.0, 1.0)
		}
	},
	"herb": {  # Medicinal herb pattern
		"axiom": "X",
		"rules": {
			"X": "F[+X]F[-X]+X",
			"F": "FF"
		},
		"angle": 60.0,  # Hexagonal symmetry for healing herbs
		"iterations": 4,
		"step_size": 0.25,
		"thickness_scale": 0.6,
		"colors": {
			"stem": Color(0.2, 0.3, 0.1),
			"leaf": Color(0.3, 0.5, 0.2)
		}
	},
	"tree": {  # Sacred tree pattern
		"axiom": "X",
		"rules": {
			"X": "F[+X][-X]FX",
			"F": "FF"
		},
		"angle": 45.0,  # Eight-fold symmetry for cosmic order
		"iterations": 5,
		"step_size": 0.5,
		"thickness_scale": 0.75,
		"colors": {
			"trunk": Color(0.3, 0.2, 0.1),
			"leaves": Color(0.2, 0.4, 0.1)
		}
	},
	"vine": {  # Climbing vine pattern
		"axiom": "F",
		"rules": {
			"F": "F[+F]F[-F][&F]"  # Spiral growth
		},
		"angle": 45.0,
		"iterations": 4,
		"step_size": 0.3,
		"thickness_scale": 0.7,
		"colors": {
			"stem": Color(0.4, 0.5, 0.2),
			"leaf": Color(0.3, 0.6, 0.2)
		}
	}
}

# Create a medieval plant using the L-System
static func create_medieval_plant(plant_type: String, seed_value: int = 0) -> Node3D:
	var plant = Node3D.new()
	plant.name = "Medieval" + plant_type.capitalize()
	
	var pattern = MEDIEVAL_PATTERNS.get(plant_type, MEDIEVAL_PATTERNS["herb"])
	
	var l_system = LSystem.new(seed_value)
	l_system.set_axiom(pattern["axiom"])
	for key in pattern["rules"]:
		l_system.add_rule(key, pattern["rules"][key])
	l_system.set_angle(pattern["angle"])
	l_system.set_iterations(pattern["iterations"])
	l_system.set_step_size(pattern["step_size"])
	l_system.set_thickness_scale(pattern["thickness_scale"])
	l_system.set_randomness(0.1)  # Slight variation for natural look
	
	l_system.generate()
	
	# Create materials with medieval colors
	var stem_material = StandardMaterial3D.new()
	stem_material.albedo_color = pattern["colors"].values()[0]
	stem_material.roughness = 0.9
	stem_material.metallic = 0.0
	
	var flower_material = StandardMaterial3D.new()
	flower_material.albedo_color = pattern["colors"].values()[1]
	flower_material.roughness = 0.7
	flower_material.metallic = 0.0
	
	# Create base structure
	var structure_mesh = l_system.create_mesh(stem_material)
	structure_mesh.name = "Structure"
	plant.add_child(structure_mesh)
	
	# Add decorative elements based on plant type
	match plant_type:
		"rose":
			_add_rose_petals(plant, flower_material, seed_value)
		"lily":
			_add_lily_petals(plant, flower_material, seed_value)
		"herb":
			_add_herb_leaves(plant, flower_material, seed_value)
		"tree":
			_add_sacred_leaves(plant, flower_material, seed_value)
		"vine":
			_add_vine_leaves(plant, flower_material, seed_value)
	
	return plant

# Add rose petals in a five-fold pattern
static func _add_rose_petals(plant: Node3D, material: Material, seed_value: int) -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	var petal_positions = _get_endpoint_positions(plant)
	for pos in petal_positions:
		var petals = Node3D.new()
		petals.position = pos
		
		# Create five petals in a sacred pentagonal arrangement
		for i in range(5):
			var petal = _create_petal(material)
			var angle = i * TAU / 5
			petal.rotation = Vector3(
				PI/4,
				angle,
				0
			)
			petal.scale = Vector3.ONE * rng.randf_range(0.2, 0.3)
			petals.add_child(petal)
		
		plant.add_child(petals)

# Add lily petals in a trinity pattern
static func _add_lily_petals(plant: Node3D, material: Material, seed_value: int) -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	var petal_positions = _get_endpoint_positions(plant)
	for pos in petal_positions:
		var petals = Node3D.new()
		petals.position = pos
		
		# Create three petals representing the Trinity
		for i in range(3):
			var petal = _create_petal(material)
			var angle = i * TAU / 3
			petal.rotation = Vector3(
				PI/3,
				angle,
				0
			)
			petal.scale = Vector3.ONE * rng.randf_range(0.3, 0.4)
			petals.add_child(petal)
		
		plant.add_child(petals)

# Add herb leaves in a medicinal pattern
static func _add_herb_leaves(plant: Node3D, material: Material, seed_value: int) -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	var leaf_positions = _get_endpoint_positions(plant)
	for pos in leaf_positions:
		var leaves = Node3D.new()
		leaves.position = pos
		
		# Create leaves in pairs (common in medicinal herbs)
		for i in range(2):
			var leaf = _create_leaf(material)
			var angle = i * PI
			leaf.rotation = Vector3(
				PI/6,
				angle,
				0
			)
			leaf.scale = Vector3.ONE * rng.randf_range(0.15, 0.25)
			leaves.add_child(leaf)
		
		plant.add_child(leaves)

# Add sacred tree leaves in an eight-fold pattern
static func _add_sacred_leaves(plant: Node3D, material: Material, seed_value: int) -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	var leaf_positions = _get_endpoint_positions(plant)
	for pos in leaf_positions:
		var leaves = Node3D.new()
		leaves.position = pos
		
		# Create eight leaves representing cosmic order
		for i in range(8):
			var leaf = _create_leaf(material)
			var angle = i * TAU / 8
			leaf.rotation = Vector3(
				PI/4,
				angle,
				0
			)
			leaf.scale = Vector3.ONE * rng.randf_range(0.2, 0.3)
			leaves.add_child(leaf)
		
		plant.add_child(leaves)

# Add vine leaves in a spiral pattern
static func _add_vine_leaves(plant: Node3D, material: Material, seed_value: int) -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	var leaf_positions = _get_endpoint_positions(plant)
	for pos in leaf_positions:
		var leaf = _create_leaf(material)
		leaf.position = pos
		leaf.rotation = Vector3(
			rng.randf_range(0, TAU),
			rng.randf_range(0, TAU),
			0
		)
		leaf.scale = Vector3.ONE * rng.randf_range(0.2, 0.3)
		plant.add_child(leaf)

# Helper function to get endpoint positions from the plant structure
static func _get_endpoint_positions(plant: Node3D) -> Array:
	var positions = []
	var structure = plant.get_node("Structure")
	if structure and structure is MeshInstance3D:
		var mesh = structure.mesh
		var vertices = mesh.get_faces()
		for i in range(0, vertices.size(), 3):
			positions.append(vertices[i])
	return positions

# Create a petal mesh
static func _create_petal(material: Material) -> MeshInstance3D:
	var petal = MeshInstance3D.new()
	var st = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	
	# Create a more organic petal shape
	var points = []
	var num_points = 8
	for i in range(num_points):
		var t = float(i) / (num_points - 1)
		var width = sin(t * PI) * 0.3
		var point = Vector3(width, t * 0.5, 0)
		points.append(point)
	
	# Create triangles
	for i in range(num_points - 1):
		st.add_vertex(Vector3.ZERO)
		st.add_vertex(points[i])
		st.add_vertex(points[i + 1])
	
	petal.mesh = st.commit()
	return petal

# Create a leaf mesh
static func _create_leaf(material: Material) -> MeshInstance3D:
	var leaf = MeshInstance3D.new()
	var st = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	
	# Create a more detailed leaf shape
	var points = []
	var num_points = 10
	for i in range(num_points):
		var t = float(i) / (num_points - 1)
		var width = sin(t * PI) * 0.2
		var point = Vector3(width, t * 0.4, 0)
		points.append(point)
	
	# Create triangles with a center vein
	for i in range(num_points - 1):
		st.add_vertex(Vector3(0, points[i].y, 0))
		st.add_vertex(points[i])
		st.add_vertex(points[i + 1])
		
		st.add_vertex(Vector3(0, points[i].y, 0))
		st.add_vertex(points[i + 1])
		st.add_vertex(Vector3(0, points[i + 1].y, 0))
	
	leaf.mesh = st.commit()
	return leaf
