extends Node3D
class_name PlacementSystem

# Signal emitted when an item is placed
signal item_placed(item_type, position, rotation)
# Signal emitted when an item is removed
signal item_removed(item_id)

# Reference to the terrain generator
var terrain_generator: TerrainGenerator

# Dictionary of placeable item types and their properties
var placeable_items = {
	"flower_bed": {
		"model": "res://assets/models/flower_bed.tscn",
		"size": Vector2(2, 2),
		"can_rotate": true,
		"category": "plants"
	},
	"herb_garden": {
		"model": "res://assets/models/herb_garden.tscn",
		"size": Vector2(3, 2),
		"can_rotate": true,
		"category": "plants"
	},
	"stone_path": {
		"model": "res://assets/models/stone_path.tscn",
		"size": Vector2(1, 1),
		"can_rotate": false,
		"category": "paths"
	},
	"bench": {
		"model": "res://assets/models/bench.tscn",
		"size": Vector2(2, 1),
		"can_rotate": true,
		"category": "furniture"
	},
	"fountain": {
		"model": "res://assets/models/fountain.tscn",
		"size": Vector2(3, 3),
		"can_rotate": false,
		"category": "water"
	},
	"statue": {
		"model": "res://assets/models/statue.tscn",
		"size": Vector2(1, 1),
		"can_rotate": true,
		"category": "decoration"
	},
	"tree": {
		"model": "res://assets/models/tree.tscn",
		"size": Vector2(2, 2),
		"can_rotate": false,
		"category": "plants"
	},
	"wall": {
		"model": "res://assets/models/wall.tscn",
		"size": Vector2(3, 1),
		"can_rotate": true,
		"category": "structure"
	},
	"gate": {
		"model": "res://assets/models/gate.tscn",
		"size": Vector2(2, 1),
		"can_rotate": true,
		"category": "structure"
	},
	"torch": {
		"model": "res://assets/models/torch.tscn",
		"size": Vector2(1, 1),
		"can_rotate": true,
		"category": "lighting"
	}
}

# Currently selected item type
var selected_item_type = ""
# Currently selected rotation (in degrees)
var selected_rotation = 0
# Dictionary of placed items
var placed_items = {}
# Next item ID
var next_item_id = 0
# Ghost item (preview of item to be placed)
var ghost_item: Node3D = null
# Grid size
var grid_size = 1.0

# Placement validity
var can_place = false
var placement_position = Vector3.ZERO

func _ready():
	# Initialize the placement system
	pass

func set_terrain_generator(generator: TerrainGenerator):
	terrain_generator = generator

func select_item(item_type: String):
	if item_type in placeable_items:
		selected_item_type = item_type
		update_ghost_item()
		return true
	return false

func rotate_selected_item():
	if selected_item_type != "" and placeable_items[selected_item_type]["can_rotate"]:
		selected_rotation = (selected_rotation + 90) % 360
		if ghost_item:
			ghost_item.rotation.y = deg_to_rad(selected_rotation)
		return true
	return false

func update_ghost_item():
	# Remove existing ghost item if any
	if ghost_item:
		ghost_item.queue_free()
		ghost_item = null
	
	# If no item is selected, return
	if selected_item_type == "":
		return
	
	# Load the model for the selected item
	var item_scene = load(placeable_items[selected_item_type]["model"])
	ghost_item = item_scene.instantiate()
	
	# Set ghost item properties
	ghost_item.rotation.y = deg_to_rad(selected_rotation)
	ghost_item.set_meta("is_ghost", true)
	
	# Add ghost item to the scene
	add_child(ghost_item)
	
	# Make the ghost item semi-transparent
	_set_ghost_transparency(ghost_item, 0.5)

func _set_ghost_transparency(node: Node, alpha: float):
	# Recursively set transparency for all materials in the ghost item
	if node is MeshInstance3D:
		var material = node.get_surface_override_material(0)
		if material:
			var transparent_material = material.duplicate()
			transparent_material.flags_transparent = true
			var color = transparent_material.albedo_color
			transparent_material.albedo_color = Color(color.r, color.g, color.b, alpha)
			node.set_surface_override_material(0, transparent_material)
	
	for child in node.get_children():
		_set_ghost_transparency(child, alpha)

func _process(_delta):
	if ghost_item and terrain_generator:
		update_ghost_position()

func update_ghost_position():
	# Get mouse position in 3D space
	var camera = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		var pos = result.position
		
		# Snap to grid
		var grid_pos = Vector3(
			round(pos.x / grid_size) * grid_size,
			0,
			round(pos.z / grid_size) * grid_size
		)
		
		# Adjust height based on terrain
		if terrain_generator:
			grid_pos.y = terrain_generator.get_height_at_position(grid_pos.x, grid_pos.z)
		
		# Update ghost position
		ghost_item.global_position = grid_pos
		placement_position = grid_pos
		
		# Check if placement is valid
		can_place = check_placement_valid(grid_pos)
		
		# Update ghost appearance based on validity
		if can_place:
			_set_ghost_color(ghost_item, Color(0, 1, 0, 0.5))  # Green for valid
		else:
			_set_ghost_color(ghost_item, Color(1, 0, 0, 0.5))  # Red for invalid

func _set_ghost_color(node: Node, color: Color):
	# Recursively set color for all materials in the ghost item
	if node is MeshInstance3D:
		var material = node.get_surface_override_material(0)
		if material:
			var colored_material = material.duplicate()
			colored_material.flags_transparent = true
			colored_material.albedo_color = color
			node.set_surface_override_material(0, colored_material)
	
	for child in node.get_children():
		_set_ghost_color(child, color)

func check_placement_valid(position: Vector3) -> bool:
	# Check if the position is within the terrain bounds
	if not terrain_generator:
		return false
	
	# Get the item size
	var item_size = placeable_items[selected_item_type]["size"]
	
	# Check if the item overlaps with any existing items
	for item_id in placed_items:
		var item = placed_items[item_id]
		var item_pos = item["position"]
		var item_rot = item["rotation"]
		var item_type = item["type"]
		var other_size = placeable_items[item_type]["size"]
		
		# Simple bounding box check (could be improved)
		if _check_overlap(position, item_size, selected_rotation, item_pos, other_size, item_rot):
			return false
	
	return true

func _check_overlap(pos1: Vector3, size1: Vector2, rot1: float, pos2: Vector3, size2: Vector2, rot2: float) -> bool:
	# Simple overlap check (could be improved with actual bounding boxes)
	var distance = pos1.distance_to(pos2)
	var max_size = max(size1.x, size1.y, size2.x, size2.y) * grid_size
	
	# If the distance is less than the maximum size, consider it an overlap
	return distance < max_size

func place_item():
	if selected_item_type == "" or not can_place or not ghost_item:
		return false
	
	# Create a new item instance
	var item_scene = load(placeable_items[selected_item_type]["model"])
	var item_instance = item_scene.instantiate()
	
	# Set item properties
	item_instance.global_position = placement_position
	item_instance.rotation.y = deg_to_rad(selected_rotation)
	
	# Add item to the scene
	add_child(item_instance)
	
	# Store item data
	var item_id = next_item_id
	next_item_id += 1
	
	placed_items[item_id] = {
		"instance": item_instance,
		"type": selected_item_type,
		"position": placement_position,
		"rotation": selected_rotation,
		"id": item_id
	}
	
	# Set metadata for identification
	item_instance.set_meta("item_id", item_id)
	
	# Emit signal
	emit_signal("item_placed", selected_item_type, placement_position, selected_rotation)
	
	return true

func remove_item_at_position(position: Vector3) -> bool:
	# Find the closest item to the given position
	var closest_item_id = -1
	var closest_distance = INF
	
	for item_id in placed_items:
		var item = placed_items[item_id]
		var distance = position.distance_to(item["position"])
		
		if distance < closest_distance:
			closest_distance = distance
			closest_item_id = item_id
	
	# If an item was found and it's close enough, remove it
	if closest_item_id != -1 and closest_distance < grid_size * 2:
		return remove_item(closest_item_id)
	
	return false

func remove_item(item_id: int) -> bool:
	if item_id in placed_items:
		var item = placed_items[item_id]
		
		# Remove the item instance from the scene
		if is_instance_valid(item["instance"]):
			item["instance"].queue_free()
		
		# Remove the item data
		placed_items.erase(item_id)
		
		# Emit signal
		emit_signal("item_removed", item_id)
		
		return true
	
	return false

func clear_all_items():
	# Remove all placed items
	for item_id in placed_items:
		var item = placed_items[item_id]
		if is_instance_valid(item["instance"]):
			item["instance"].queue_free()
	
	# Clear the dictionary
	placed_items.clear()
	next_item_id = 0

func save_garden() -> Dictionary:
	# Create a dictionary to store garden data
	var garden_data = {
		"terrain_seed": terrain_generator.seed_value if terrain_generator else 0,
		"items": []
	}
	
	# Add all placed items to the garden data
	for item_id in placed_items:
		var item = placed_items[item_id]
		garden_data["items"].append({
			"type": item["type"],
			"position": {
				"x": item["position"].x,
				"y": item["position"].y,
				"z": item["position"].z
			},
			"rotation": item["rotation"]
		})
	
	return garden_data

func load_garden(garden_data: Dictionary) -> bool:
	# Clear existing garden
	clear_all_items()
	
	# Set terrain seed if terrain generator exists
	if terrain_generator and "terrain_seed" in garden_data:
		terrain_generator.set_new_seed(garden_data["terrain_seed"])
	
	# Place all items from the garden data
	if "items" in garden_data:
		for item_data in garden_data["items"]:
			# Select the item type
			if not select_item(item_data["type"]):
				continue
			
			# Set the rotation
			selected_rotation = item_data["rotation"]
			
			# Set the position
			placement_position = Vector3(
				item_data["position"]["x"],
				item_data["position"]["y"],
				item_data["position"]["z"]
			)
			
			# Force can_place to true since we're loading a saved garden
			can_place = true
			
			# Place the item
			place_item()
	
	return true
