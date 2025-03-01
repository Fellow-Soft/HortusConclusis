extends Node
class_name MedievalHerbGarden

# Medieval herb garden layout patterns based on historical sources
const GARDEN_LAYOUTS = {
	"monastic": {
		"description": "Traditional monastery physic garden layout",
		"grid_size": Vector2(4, 4),
		"path_width": 1.0,
		"bed_size": Vector2(2.0, 2.0),
		"sections": {
			"medicinal": Vector2i(0, 0),  # Healing herbs
			"culinary": Vector2i(0, 2),   # Kitchen herbs
			"aromatic": Vector2i(2, 0),   # Fragrant herbs
			"sacred": Vector2i(2, 2)      # Symbolic plants
		}
	},
	"knot": {
		"description": "Decorative knot garden with herbs",
		"grid_size": Vector2(3, 3),
		"path_width": 0.8,
		"bed_size": Vector2(2.5, 2.5),
		"pattern": "interlaced",  # Interlaced paths
		"border_herbs": ["lavender", "thyme", "sage"]
	},
	"raised": {
		"description": "Raised bed system for herb cultivation",
		"grid_size": Vector2(2, 4),
		"bed_height": 0.5,
		"bed_size": Vector2(1.8, 1.8),
		"spacing": 0.6,
		"drainage_slope": 0.05
	}
}

# Traditional medieval herb categories and their properties
const HERB_CATEGORIES = {
	"medicinal": {
		"plants": {
			"sage": {
				"latin": "Salvia officinalis",
				"properties": ["healing", "wisdom"],
				"growth_pattern": "herb",
				"placement": "prominent"
			},
			"rosemary": {
				"latin": "Rosmarinus officinalis",
				"properties": ["memory", "loyalty"],
				"growth_pattern": "herb",
				"placement": "border"
			},
			"feverfew": {
				"latin": "Tanacetum parthenium",
				"properties": ["headache", "fever"],
				"growth_pattern": "herb",
				"placement": "central"
			}
		},
		"layout_rules": {
			"spacing": 0.4,
			"companion_plants": true,
			"sun_exposure": "full"
		}
	},
	"culinary": {
		"plants": {
			"thyme": {
				"latin": "Thymus vulgaris",
				"properties": ["cooking", "purification"],
				"growth_pattern": "herb",
				"placement": "border"
			},
			"basil": {
				"latin": "Ocimum basilicum",
				"properties": ["protection", "flavor"],
				"growth_pattern": "herb",
				"placement": "central"
			},
			"mint": {
				"latin": "Mentha spicata",
				"properties": ["refreshment", "virtue"],
				"growth_pattern": "herb",
				"placement": "contained"
			}
		},
		"layout_rules": {
			"spacing": 0.3,
			"companion_plants": true,
			"sun_exposure": "partial"
		}
	},
	"aromatic": {
		"plants": {
			"lavender": {
				"latin": "Lavandula angustifolia",
				"properties": ["peace", "cleansing"],
				"growth_pattern": "herb",
				"placement": "border"
			},
			"chamomile": {
				"latin": "Matricaria chamomilla",
				"properties": ["calming", "patience"],
				"growth_pattern": "herb",
				"placement": "scattered"
			},
			"hyssop": {
				"latin": "Hyssopus officinalis",
				"properties": ["purification", "protection"],
				"growth_pattern": "herb",
				"placement": "central"
			}
		},
		"layout_rules": {
			"spacing": 0.5,
			"companion_plants": true,
			"sun_exposure": "full"
		}
	},
	"sacred": {
		"plants": {
			"mary's_grass": {
				"latin": "Hierochloe odorata",
				"properties": ["blessing", "protection"],
				"growth_pattern": "herb",
				"placement": "central"
			},
			"angelica": {
				"latin": "Angelica archangelica",
				"properties": ["protection", "healing"],
				"growth_pattern": "herb",
				"placement": "cardinal"
			},
			"rue": {
				"latin": "Ruta graveolens",
				"properties": ["virtue", "grace"],
				"growth_pattern": "herb",
				"placement": "corner"
			}
		},
		"layout_rules": {
			"spacing": 0.6,
			"companion_plants": false,
			"sun_exposure": "mixed"
		}
	}
}

# Reference to plant generator
@onready var plant_generator = get_node("/root/PlantGenerator")

# Create a complete herb garden based on layout type
func create_herb_garden(layout_type: String, position: Vector3) -> Node3D:
	var garden = Node3D.new()
	garden.name = "MedievalHerbGarden"
	garden.position = position
	
	var layout = GARDEN_LAYOUTS[layout_type]
	
	# Create the base structure
	_create_garden_structure(garden, layout)
	
	# Plant herbs according to layout
	_plant_herbs(garden, layout)
	
	# Add paths and borders
	_create_paths_and_borders(garden, layout)
	
	# Add decorative elements
	_add_decorative_elements(garden, layout)
	
	return garden

# Create the basic garden structure
func _create_garden_structure(garden: Node3D, layout: Dictionary) -> void:
	var structure = Node3D.new()
	structure.name = "GardenStructure"
	
	# Create raised beds if specified
	if layout.has("bed_height"):
		for x in range(layout.grid_size.x):
			for y in range(layout.grid_size.y):
				var bed = _create_raised_bed(
					Vector3(
						x * (layout.bed_size.x + layout.spacing),
						0,
						y * (layout.bed_size.y + layout.spacing)
					),
					layout.bed_size,
					layout.bed_height
				)
				structure.add_child(bed)
	
	garden.add_child(structure)

# Plant herbs according to layout rules
func _plant_herbs(garden: Node3D, layout: Dictionary) -> void:
	var herbs = Node3D.new()
	herbs.name = "Herbs"
	
	# Plant according to sections
	if layout.has("sections"):
		for section_type in layout.sections:
			var pos = layout.sections[section_type]
			var category = HERB_CATEGORIES[section_type]
			
			for plant_name in category.plants:
				var plant_data = category.plants[plant_name]
				var plant = plant_generator.create_medieval_plant(
					"herb",  # Use herb L-system pattern
					randi()  # Random seed for variation
				)
				
				# Position within section according to placement rule
				var plant_pos = _get_plant_position(
					pos,
					plant_data.placement,
					layout.bed_size,
					category.layout_rules.spacing
				)
				
				plant.position = plant_pos
				herbs.add_child(plant)
	
	garden.add_child(herbs)

# Create paths and borders
func _create_paths_and_borders(garden: Node3D, layout: Dictionary) -> void:
	var paths = Node3D.new()
	paths.name = "Paths"
	
	# Create main paths
	var path_mesh = _create_path_mesh(layout.path_width)
	
	for x in range(layout.grid_size.x + 1):
		var path = MeshInstance3D.new()
		path.mesh = path_mesh
		path.position = Vector3(
			x * layout.bed_size.x - layout.path_width/2,
			0,
			layout.grid_size.y * layout.bed_size.y / 2
		)
		path.scale.z = layout.grid_size.y * layout.bed_size.y
		paths.add_child(path)
	
	for y in range(layout.grid_size.y + 1):
		var path = MeshInstance3D.new()
		path.mesh = path_mesh
		path.rotation.y = PI/2
		path.position = Vector3(
			layout.grid_size.x * layout.bed_size.x / 2,
			0,
			y * layout.bed_size.y - layout.path_width/2
		)
		path.scale.z = layout.grid_size.x * layout.bed_size.x
		paths.add_child(path)
	
	garden.add_child(paths)

# Add decorative elements
func _add_decorative_elements(garden: Node3D, layout: Dictionary) -> void:
	var decorations = Node3D.new()
	decorations.name = "Decorations"
	
	# Add sundial at center if monastic layout
	if layout.has("description") and "monastic" in layout.description.to_lower():
		var sundial = _create_sundial()
		sundial.position = Vector3(
			layout.grid_size.x * layout.bed_size.x / 2,
			0,
			layout.grid_size.y * layout.bed_size.y / 2
		)
		decorations.add_child(sundial)
	
	# Add corner markers
	for x in [0, layout.grid_size.x]:
		for y in [0, layout.grid_size.y]:
			var marker = _create_corner_marker()
			marker.position = Vector3(
				x * layout.bed_size.x,
				0,
				y * layout.bed_size.y
			)
			decorations.add_child(marker)
	
	garden.add_child(decorations)

# Helper function to create a raised bed
func _create_raised_bed(position: Vector3, size: Vector2, height: float) -> MeshInstance3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Create bed geometry
	var points = [
		Vector3(-size.x/2, 0, -size.y/2),
		Vector3(size.x/2, 0, -size.y/2),
		Vector3(size.x/2, 0, size.y/2),
		Vector3(-size.x/2, 0, size.y/2),
		Vector3(-size.x/2, height, -size.y/2),
		Vector3(size.x/2, height, -size.y/2),
		Vector3(size.x/2, height, size.y/2),
		Vector3(-size.x/2, height, size.y/2)
	]
	
	# Add vertices for all faces
	_add_quad(st, points[0], points[1], points[2], points[3])  # Bottom
	_add_quad(st, points[4], points[7], points[6], points[5])  # Top
	_add_quad(st, points[0], points[4], points[5], points[1])  # Front
	_add_quad(st, points[1], points[5], points[6], points[2])  # Right
	_add_quad(st, points[2], points[6], points[7], points[3])  # Back
	_add_quad(st, points[3], points[7], points[4], points[0])  # Left
	
	var bed = MeshInstance3D.new()
	bed.mesh = st.commit()
	bed.position = position
	
	return bed

# Helper function to add a quad to a SurfaceTool
func _add_quad(st: SurfaceTool, p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3) -> void:
	var normal = (p2 - p1).cross(p3 - p1).normalized()
	st.set_normal(normal)
	
	st.add_vertex(p1)
	st.add_vertex(p2)
	st.add_vertex(p3)
	
	st.add_vertex(p1)
	st.add_vertex(p3)
	st.add_vertex(p4)

# Helper function to create path mesh
func _create_path_mesh(width: float) -> Mesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var points = [
		Vector3(-width/2, 0, -0.5),
		Vector3(width/2, 0, -0.5),
		Vector3(width/2, 0, 0.5),
		Vector3(-width/2, 0, 0.5)
	]
	
	_add_quad(st, points[0], points[1], points[2], points[3])
	
	return st.commit()

# Helper function to create a sundial
func _create_sundial() -> Node3D:
	var sundial = Node3D.new()
	sundial.name = "Sundial"
	
	# Create base
	var base = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.3
	cylinder.bottom_radius = 0.4
	cylinder.height = 0.1
	base.mesh = cylinder
	sundial.add_child(base)
	
	# Create gnomon (the vertical pointer)
	var gnomon = MeshInstance3D.new()
	var prism = PrismMesh.new()
	prism.size = Vector3(0.05, 0.3, 0.05)
	gnomon.mesh = prism
	gnomon.position.y = 0.1
	gnomon.rotation.x = deg_to_rad(45)  # Angle for latitude
	sundial.add_child(gnomon)
	
	return sundial

# Helper function to create a corner marker
func _create_corner_marker() -> Node3D:
	var marker = Node3D.new()
	marker.name = "CornerMarker"
	
	var post = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.05
	cylinder.bottom_radius = 0.05
	cylinder.height = 0.6
	post.mesh = cylinder
	post.position.y = 0.3
	marker.add_child(post)
	
	return marker

# Helper function to get plant position based on placement rule
func _get_plant_position(section_pos: Vector2i, placement: String, bed_size: Vector2, spacing: float) -> Vector3:
	var base_pos = Vector3(
		section_pos.x * bed_size.x,
		0,
		section_pos.y * bed_size.y
	)
	
	match placement:
		"central":
			return base_pos + Vector3(bed_size.x/2, 0, bed_size.y/2)
		"border":
			var offset = Vector3(
				randf_range(spacing, bed_size.x - spacing),
				0,
				randf_range(spacing, spacing * 2)
			)
			return base_pos + offset
		"corner":
			return base_pos + Vector3(spacing, 0, spacing)
		"cardinal":
			var cardinal_points = [
				Vector3(bed_size.x/2, 0, spacing),
				Vector3(bed_size.x - spacing, 0, bed_size.y/2),
				Vector3(bed_size.x/2, 0, bed_size.y - spacing),
				Vector3(spacing, 0, bed_size.y/2)
			]
			return base_pos + cardinal_points[randi() % 4]
		"scattered":
			return base_pos + Vector3(
				randf_range(spacing, bed_size.x - spacing),
				0,
				randf_range(spacing, bed_size.y - spacing)
			)
		_:  # Default to center
			return base_pos + Vector3(bed_size.x/2, 0, bed_size.y/2)
