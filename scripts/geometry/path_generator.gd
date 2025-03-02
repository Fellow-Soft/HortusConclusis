extends Node
class_name PathGenerator

# Path types
enum PathType {
	STONE,
	BRICK,
	GRAVEL,
	DIRT
}

# Random number generator
var rng = RandomNumberGenerator.new()
var seed_value: int = 0

# Path parameters
var path_width: float = 1.0
var path_height: float = 0.1
var path_type: PathType = PathType.STONE
var path_curvature: float = 0.2
var path_roughness: float = 0.1

func _init(p_seed: int = 0):
	seed_value = p_seed if p_seed > 0 else randi()
	rng.seed = seed_value

# Set the path width
func set_path_width(width: float) -> void:
	path_width = width

# Set the path height
func set_path_height(height: float) -> void:
	path_height = height

# Set the path type
func set_path_type(type: PathType) -> void:
	path_type = type

# Set the path curvature
func set_path_curvature(curvature: float) -> void:
	path_curvature = clamp(curvature, 0.0, 1.0)

# Set the path roughness
func set_path_roughness(roughness: float) -> void:
	path_roughness = clamp(roughness, 0.0, 1.0)

# Generate a path between two points
func generate_path(start_point: Vector3, end_point: Vector3, control_points: Array = []) -> Node3D:
	var path_node = Node3D.new()
	path_node.name = "ProceduralPath"
	
	# Create a curve for the path
	var curve = Curve3D.new()
	
	# Add start point
	curve.add_point(start_point)
	
	# Add control points if provided, otherwise generate them
	if control_points.size() > 0:
		for point in control_points:
			curve.add_point(point)
	else:
		# Generate control points based on curvature
		var direction = end_point - start_point
		var distance = direction.length()
		var num_points = int(distance / 5.0) + 1
		
		for i in range(num_points):
			var t = float(i + 1) / float(num_points + 1)
			var point = start_point.lerp(end_point, t)
			
			# Add some random offset perpendicular to the path
			var perp = Vector3(-direction.z, 0, direction.x).normalized()
			var offset = perp * rng.randf_range(-distance * path_curvature, distance * path_curvature)
			point += offset
			
			curve.add_point(point)
	
	# Add end point
	curve.add_point(end_point)
	
	# Create the path mesh
	var path_mesh = _create_path_mesh(curve)
	path_node.add_child(path_mesh)
	
	# Add path details based on type
	match path_type:
		PathType.STONE:
			_add_stone_details(path_node, curve)
		PathType.BRICK:
			_add_brick_details(path_node, curve)
		PathType.GRAVEL:
			_add_gravel_details(path_node, curve)
		PathType.DIRT:
			_add_dirt_details(path_node, curve)
	
	return path_node

# Create the base path mesh
func _create_path_mesh(curve: Curve3D) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "PathMesh"
	
	# Create a path material based on the path type
	var material = _create_path_material()
	
	# Create a surface tool to build the mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	if material:
		st.set_material(material)
	
	# Sample points along the curve
	var length = curve.get_baked_length()
	var steps = int(length / 0.5) + 1  # Sample every 0.5 units
	
	var prev_right = Vector3.ZERO
	
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var offset = t * length
		
		# Get position and direction at this point
		var pos = curve.sample_baked(offset)
		var dir = curve.sample_baked_with_rotation(offset).basis.z.normalized()
		
		# Calculate right vector
		var up = Vector3(0, 1, 0)
		var right = dir.cross(up).normalized()
		
		# Ensure consistent right vector direction
		if i > 0 and right.dot(prev_right) < 0:
			right = -right
		
		prev_right = right
		
		# Calculate vertices for this segment
		var left_pos = pos - right * (path_width / 2.0)
		var right_pos = pos + right * (path_width / 2.0)
		
		# Add some height variation based on roughness
		var height_offset = rng.randf_range(-path_roughness, path_roughness) * path_height
		left_pos.y = path_height / 2.0 + height_offset
		right_pos.y = path_height / 2.0 + height_offset
		
		# Store vertices for triangulation
		if i > 0:
			# Get previous vertices
			var prev_left_vertex = st.get_vertex_array()[st.get_vertex_array().size() - 2]
			var prev_right_vertex = st.get_vertex_array()[st.get_vertex_array().size() - 1]
			
			# Add triangles
			st.add_vertex(prev_left_vertex)
			st.add_vertex(left_pos)
			st.add_vertex(right_pos)
			
			st.add_vertex(prev_left_vertex)
			st.add_vertex(right_pos)
			st.add_vertex(prev_right_vertex)
		
		# Add current vertices
		st.add_vertex(left_pos)
		st.add_vertex(right_pos)
	
	mesh_instance.mesh = st.commit()
	
	# Add a collision shape
	var static_body = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(path_width, path_height, length)
	collision_shape.shape = shape
	
	# Position the collision shape
	var start = curve.get_point_position(0)
	var end = curve.get_point_position(curve.get_point_count() - 1)
	var center = (start + end) / 2.0
	center.y = path_height / 2.0
	collision_shape.position = center
	
	# Rotate the collision shape to align with the path
	var direction = (end - start).normalized()
	var angle = atan2(direction.x, direction.z)
	collision_shape.rotation.y = angle
	
	static_body.add_child(collision_shape)
	mesh_instance.add_child(static_body)
	
	return mesh_instance

# Create a material based on the path type
func _create_path_material() -> Material:
	var material = null
	
	match path_type:
		PathType.STONE:
			material = MedievalShaderCreator.create_stone_material(true)
		PathType.BRICK:
			material = MedievalShaderCreator.create_medieval_material(Color(0.7, 0.3, 0.2), false, 3.0)
		PathType.GRAVEL:
			material = MedievalShaderCreator.create_medieval_material(Color(0.7, 0.7, 0.7), false, 5.0)
		PathType.DIRT:
			material = MedievalShaderCreator.create_medieval_material(Color(0.5, 0.35, 0.2), false, 4.0)
	
	return material

# Add stone details to the path
func _add_stone_details(path_node: Node3D, curve: Curve3D) -> void:
	var details = Node3D.new()
	details.name = "StoneDetails"
	
	var length = curve.get_baked_length()
	var num_stones = int(length / 2.0) + 1
	
	for i in range(num_stones):
		# Random position along the path
		var offset = rng.randf_range(0, length)
		var pos = curve.sample_baked(offset)
		
		# Random offset from center
		var dir = curve.sample_baked_with_rotation(offset).basis.z.normalized()
		var up = Vector3(0, 1, 0)
		var right = dir.cross(up).normalized()
		var side_offset = rng.randf_range(-path_width * 0.4, path_width * 0.4)
		pos += right * side_offset
		
		# Create a stone
		var stone = _create_stone()
		stone.position = pos
		stone.position.y = path_height / 2.0
		stone.rotation.y = rng.randf_range(0, PI * 2)
		stone.scale = Vector3.ONE * rng.randf_range(0.2, 0.4)
		
		details.add_child(stone)
	
	path_node.add_child(details)

# Create a stone mesh
func _create_stone() -> MeshInstance3D:
	var stone = MeshInstance3D.new()
	
	# Create a simple stone mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Create a stone material
	var material = MedievalShaderCreator.create_stone_material(rng.randf() > 0.5)
	st.set_material(material)
	
	# Create a random stone shape
	var vertices = []
	var num_sides = rng.randi_range(5, 8)
	var height = rng.randf_range(0.1, 0.3)
	
	# Create top and bottom vertices
	for i in range(num_sides):
		var angle = 2 * PI * i / num_sides
		var radius = rng.randf_range(0.8, 1.2)
		var x = cos(angle) * radius
		var z = sin(angle) * radius
		
		vertices.append(Vector3(x, 0, z))
		vertices.append(Vector3(x, height, z))
	
	# Create triangles for the sides
	for i in range(num_sides):
		var i2 = (i + 1) % num_sides
		
		# Bottom triangle 1
		st.add_vertex(vertices[i * 2])
		st.add_vertex(vertices[i * 2 + 1])
		st.add_vertex(vertices[i2 * 2 + 1])
		
		# Bottom triangle 2
		st.add_vertex(vertices[i * 2])
		st.add_vertex(vertices[i2 * 2 + 1])
		st.add_vertex(vertices[i2 * 2])
	
	# Create triangles for the top
	var top_center = Vector3(0, height, 0)
	for i in range(num_sides):
		var i2 = (i + 1) % num_sides
		
		st.add_vertex(top_center)
		st.add_vertex(vertices[i * 2 + 1])
		st.add_vertex(vertices[i2 * 2 + 1])
	
	# Create triangles for the bottom
	var bottom_center = Vector3(0, 0, 0)
	for i in range(num_sides):
		var i2 = (i + 1) % num_sides
		
		st.add_vertex(bottom_center)
		st.add_vertex(vertices[i2 * 2])
		st.add_vertex(vertices[i * 2])
	
	stone.mesh = st.commit()
	
	return stone

# Add brick details to the path
func _add_brick_details(path_node: Node3D, curve: Curve3D) -> void:
	var details = Node3D.new()
	details.name = "BrickDetails"
	
	var length = curve.get_baked_length()
	var brick_length = 0.4
	var brick_spacing = 0.05
	var rows = 3
	
	var offset = 0.0
	while offset < length:
		var pos = curve.sample_baked(offset)
		var dir = curve.sample_baked_with_rotation(offset).basis.z.normalized()
		var up = Vector3(0, 1, 0)
		var right = dir.cross(up).normalized()
		
		for row in range(rows):
			var row_offset = (row - (rows - 1) / 2.0) * (brick_length + brick_spacing)
			var brick_pos = pos + right * row_offset
			
			# Alternate brick pattern
			if int(offset / (brick_length + brick_spacing)) % 2 == 1:
				if row == 0 or row == rows - 1:
					continue
			
			# Create a brick
			var brick = _create_brick()
			brick.position = brick_pos
			brick.position.y = path_height / 2.0
			
			# Align brick with path direction
			var angle = atan2(dir.x, dir.z)
			brick.rotation.y = angle
			
			details.add_child(brick)
		
		offset += brick_length + brick_spacing
	
	path_node.add_child(details)

# Create a brick mesh
func _create_brick() -> MeshInstance3D:
	var brick = MeshInstance3D.new()
	
	# Create a brick mesh
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.4, 0.1, 0.2)
	
	# Create a brick material
	var material = MedievalShaderCreator.create_medieval_material(
		Color(rng.randf_range(0.6, 0.8), rng.randf_range(0.2, 0.4), rng.randf_range(0.1, 0.3)),
		false,
		2.0
	)
	
	mesh.material = material
	brick.mesh = mesh
	
	return brick

# Add gravel details to the path
func _add_gravel_details(path_node: Node3D, curve: Curve3D) -> void:
	var details = Node3D.new()
	details.name = "GravelDetails"
	
	var length = curve.get_baked_length()
	var num_pebbles = int(length * path_width * 5)
	
	for i in range(num_pebbles):
		# Random position along the path
		var offset = rng.randf_range(0, length)
		var pos = curve.sample_baked(offset)
		
		# Random offset from center
		var dir = curve.sample_baked_with_rotation(offset).basis.z.normalized()
		var up = Vector3(0, 1, 0)
		var right = dir.cross(up).normalized()
		var side_offset = rng.randf_range(-path_width * 0.45, path_width * 0.45)
		pos += right * side_offset
		
		# Create a pebble
		var pebble = _create_pebble()
		pebble.position = pos
		pebble.position.y = path_height / 2.0 + 0.02
		pebble.rotation = Vector3(
			rng.randf_range(0, PI),
			rng.randf_range(0, PI * 2),
			rng.randf_range(0, PI)
		)
		pebble.scale = Vector3.ONE * rng.randf_range(0.05, 0.1)
		
		details.add_child(pebble)
	
	path_node.add_child(details)

# Create a pebble mesh
func _create_pebble() -> MeshInstance3D:
	var pebble = MeshInstance3D.new()
	
	# Create a simple pebble mesh
	var mesh = SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	
	# Slightly squash the pebble
	pebble.scale.y = rng.randf_range(0.5, 0.8)
	
	# Create a pebble material
	var gray_value = rng.randf_range(0.5, 0.8)
	var material = MedievalShaderCreator.create_medieval_material(
		Color(gray_value, gray_value, gray_value),
		false,
		3.0
	)
	
	mesh.material = material
	pebble.mesh = mesh
	
	return pebble

# Add dirt details to the path
func _add_dirt_details(path_node: Node3D, curve: Curve3D) -> void:
	var details = Node3D.new()
	details.name = "DirtDetails"
	
	var length = curve.get_baked_length()
	var num_details = int(length / 3.0) + 1
	
	for i in range(num_details):
		# Random position along the path
		var offset = rng.randf_range(0, length)
		var pos = curve.sample_baked(offset)
		
		# Random offset from center
		var dir = curve.sample_baked_with_rotation(offset).basis.z.normalized()
		var up = Vector3(0, 1, 0)
		var right = dir.cross(up).normalized()
		var side_offset = rng.randf_range(-path_width * 0.4, path_width * 0.4)
		pos += right * side_offset
		
		# Randomly choose between a small stone or a grass tuft
		if rng.randf() > 0.7:
			# Create a small stone
			var stone = _create_stone()
			stone.position = pos
			stone.position.y = path_height / 2.0
			stone.rotation.y = rng.randf_range(0, PI * 2)
			stone.scale = Vector3.ONE * rng.randf_range(0.05, 0.15)
			
			details.add_child(stone)
		else:
			# Create a grass tuft
			var grass = _create_grass_tuft()
			grass.position = pos
			grass.position.y = path_height / 2.0
			grass.rotation.y = rng.randf_range(0, PI * 2)
			
			details.add_child(grass)
	
	path_node.add_child(details)

# Create a grass tuft
func _create_grass_tuft() -> MeshInstance3D:
	var grass = MeshInstance3D.new()
	
	# Create a simple grass mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Create a grass material
	var material = MedievalShaderCreator.create_plant_material(
		rng.randf_range(0.25, 0.35),  # Hue
		rng.randf_range(0.5, 0.7),    # Saturation
		rng.randf_range(0.3, 0.5)     # Value
	)
	st.set_material(material)
	
	# Create grass blades
	var num_blades = rng.randi_range(3, 6)
	var height = rng.randf_range(0.1, 0.2)
	
	for i in range(num_blades):
		var angle = 2 * PI * i / num_blades
		var radius = rng.randf_range(0.02, 0.05)
		var blade_height = height * rng.randf_range(0.8, 1.2)
		
		var base_pos = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		var tip_pos = Vector3(
			base_pos.x + rng.randf_range(-0.05, 0.05),
			blade_height,
			base_pos.z + rng.randf_range(-0.05, 0.05)
		)
		
		var mid_pos1 = base_pos.lerp(tip_pos, 0.3) + Vector3(
			rng.randf_range(-0.02, 0.02),
			0,
			rng.randf_range(-0.02, 0.02)
		)
		
		var mid_pos2 = base_pos.lerp(tip_pos, 0.7) + Vector3(
			rng.randf_range(-0.02, 0.02),
			0,
			rng.randf_range(-0.02, 0.02)
		)
		
		# Create a blade as a thin triangle
		st.add_vertex(base_pos)
		st.add_vertex(mid_pos1)
		st.add_vertex(tip_pos)
		
		st.add_vertex(mid_pos1)
		st.add_vertex(mid_pos2)
		st.add_vertex(tip_pos)
	
	
	grass.mesh = st.commit()
	
	return grass

# Generate a circular path
static func generate_circular_path(center: Vector3, radius: float, segments: int = 16, path_type: PathType = PathType.STONE) -> Node3D:
	var path_gen = PathGenerator.new()
	path_gen.set_path_type(path_type)
	
	var control_points = []
	
	for i in range(segments):
		var angle = 2 * PI * i / segments
		var x = center.x + cos(angle) * radius
		var z = center.z + sin(angle) * radius
		control_points.append(Vector3(x, center.y, z))
	
	# Close the circle by adding the first point again
	control_points.append(control_points[0])
	
	return path_gen.generate_path(control_points[0], control_points[segments], control_points.slice(1, segments))

# Generate a straight path
static func generate_straight_path(start: Vector3, end: Vector3, path_type: PathType = PathType.STONE) -> Node3D:
	var path_gen = PathGenerator.new()
	path_gen.set_path_type(path_type)
	return path_gen.generate_path(start, end)

# Generate a curved path
static func generate_curved_path(start: Vector3, end: Vector3, curve_amount: float = 0.5, path_type: PathType = PathType.STONE) -> Node3D:
	var path_gen = PathGenerator.new()
	path_gen.set_path_type(path_type)
	path_gen.set_path_curvature(curve_amount)
	return path_gen.generate_path(start, end)
