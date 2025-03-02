extends Node3D

# Constants
const GOLDEN_RATIO = 1.618033988749895
const PHI = GOLDEN_RATIO
const TAU = PI * 2.0

# Pattern parameters
var pattern_scale = 1.0
var pattern_rotation = 0.0
var pattern_emission = 1.0
var pattern_color = Color(1, 1, 1, 1)

# Time-based parameters
var current_time = "dawn"
var time_colors = {
    "dawn": Color(1.0, 0.8, 0.6),
    "noon": Color(1.0, 1.0, 0.9),
    "dusk": Color(0.9, 0.6, 0.4),
    "night": Color(0.4, 0.4, 0.8)
}

# Pattern meshes
var vesica_piscis: MeshInstance3D
var flower_of_life: MeshInstance3D
var metatrons_cube: MeshInstance3D
var tree_of_life: MeshInstance3D
var sri_yantra: MeshInstance3D

func _ready():
    # Create pattern meshes
    _create_vesica_piscis()
    _create_flower_of_life()
    _create_metatrons_cube()
    _create_tree_of_life()
    _create_sri_yantra()
    
    # Initialize with dawn colors
    set_time_of_day("dawn")

func _create_vesica_piscis():
    var mesh = ImmediateMesh.new()
    vesica_piscis = MeshInstance3D.new()
    vesica_piscis.mesh = mesh
    add_child(vesica_piscis)
    
    # Create the vesica piscis geometry
    mesh.clear_surfaces()
    mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
    
    var radius = 1.0
    var segments = 32
    var angle_step = TAU / segments
    
    # First circle
    var center1 = Vector3(-radius/2, 0, 0)
    for i in range(segments):
        var angle1 = i * angle_step
        var angle2 = (i + 1) * angle_step
        
        var v1 = center1
        var v2 = center1 + Vector3(cos(angle1), sin(angle1), 0) * radius
        var v3 = center1 + Vector3(cos(angle2), sin(angle2), 0) * radius
        
        mesh.surface_add_vertex(v1)
        mesh.surface_add_vertex(v2)
        mesh.surface_add_vertex(v3)
    
    # Second circle
    var center2 = Vector3(radius/2, 0, 0)
    for i in range(segments):
        var angle1 = i * angle_step
        var angle2 = (i + 1) * angle_step
        
        var v1 = center2
        var v2 = center2 + Vector3(cos(angle1), sin(angle1), 0) * radius
        var v3 = center2 + Vector3(cos(angle2), sin(angle2), 0) * radius
        
        mesh.surface_add_vertex(v1)
        mesh.surface_add_vertex(v2)
        mesh.surface_add_vertex(v3)
    
    mesh.surface_end()

func _create_flower_of_life():
    var mesh = ImmediateMesh.new()
    flower_of_life = MeshInstance3D.new()
    flower_of_life.mesh = mesh
    add_child(flower_of_life)
    
    # Create the Flower of Life geometry
    mesh.clear_surfaces()
    mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
    
    var radius = 0.5
    var segments = 32
    var centers = []
    
    # Calculate circle centers
    for i in range(6):
        var angle = i * TAU / 6
        centers.append(Vector3(cos(angle), sin(angle), 0) * radius)
    
    # Add center circle
    centers.append(Vector3.ZERO)
    
    # Draw circles
    for center in centers:
        _add_circle_to_mesh(mesh, center, radius/2, segments)
    
    mesh.surface_end()

func _create_metatrons_cube():
    var mesh = ImmediateMesh.new()
    metatrons_cube = MeshInstance3D.new()
    metatrons_cube.mesh = mesh
    add_child(metatrons_cube)
    
    # Create Metatron's Cube geometry
    mesh.clear_surfaces()
    mesh.surface_begin(Mesh.PRIMITIVE_LINES)
    
    var points = []
    var radius = 1.0
    
    # Generate the 13 points
    for i in range(12):
        var angle = i * TAU / 12
        points.append(Vector3(cos(angle), sin(angle), 0) * radius)
    points.append(Vector3.ZERO)  # Center point
    
    # Draw lines between points
    for i in range(points.size()):
        for j in range(i + 1, points.size()):
            mesh.surface_add_vertex(points[i])
            mesh.surface_add_vertex(points[j])
    
    mesh.surface_end()

func _create_tree_of_life():
    var mesh = ImmediateMesh.new()
    tree_of_life = MeshInstance3D.new()
    tree_of_life.mesh = mesh
    add_child(tree_of_life)
    
    # Create Tree of Life geometry
    mesh.clear_surfaces()
    mesh.surface_begin(Mesh.PRIMITIVE_LINES)
    
    var points = []
    var radius = 1.0
    
    # Define the 10 Sephirot positions
    points.append(Vector3(0, radius, 0))  # Keter
    points.append(Vector3(-radius/2, radius/2, 0))  # Chokmah
    points.append(Vector3(radius/2, radius/2, 0))  # Binah
    points.append(Vector3(-radius/2, 0, 0))  # Chesed
    points.append(Vector3(radius/2, 0, 0))  # Geburah
    points.append(Vector3(0, 0, 0))  # Tiferet
    points.append(Vector3(-radius/2, -radius/2, 0))  # Netzach
    points.append(Vector3(radius/2, -radius/2, 0))  # Hod
    points.append(Vector3(0, -radius/2, 0))  # Yesod
    points.append(Vector3(0, -radius, 0))  # Malkuth
    
    # Draw lines between points
    for i in range(points.size()):
        for j in range(i + 1, points.size()):
            mesh.surface_add_vertex(points[i])
            mesh.surface_add_vertex(points[j])
    
    mesh.surface_end()

func _create_sri_yantra():
    var mesh = ImmediateMesh.new()
    sri_yantra = MeshInstance3D.new()
    sri_yantra.mesh = mesh
    add_child(sri_yantra)
    
    # Create Sri Yantra geometry
    mesh.clear_surfaces()
    mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
    
    var radius = 1.0
    var triangles = 9
    var angle_step = TAU / triangles
    
    for i in range(triangles):
        var angle = i * angle_step
        var next_angle = (i + 1) * angle_step
        
        var v1 = Vector3.ZERO
        var v2 = Vector3(cos(angle), sin(angle), 0) * radius
        var v3 = Vector3(cos(next_angle), sin(next_angle), 0) * radius
        
        mesh.surface_add_vertex(v1)
        mesh.surface_add_vertex(v2)
        mesh.surface_add_vertex(v3)
    
    mesh.surface_end()

func _add_circle_to_mesh(mesh: ImmediateMesh, center: Vector3, radius: float, segments: int):
    var angle_step = TAU / segments
    
    for i in range(segments):
        var angle1 = i * angle_step
        var angle2 = (i + 1) * angle_step
        
        var v1 = center
        var v2 = center + Vector3(cos(angle1), sin(angle1), 0) * radius
        var v3 = center + Vector3(cos(angle2), sin(angle2), 0) * radius
        
        mesh.surface_add_vertex(v1)
        mesh.surface_add_vertex(v2)
        mesh.surface_add_vertex(v3)

func set_time_of_day(time: String):
    current_time = time
    if time in time_colors:
        pattern_color = time_colors[time]
        _update_materials()

func _update_materials():
    var material = StandardMaterial3D.new()
    material.albedo_color = pattern_color
    material.emission_enabled = true
    material.emission = pattern_color
    material.emission_energy = pattern_emission
    
    if vesica_piscis:
        vesica_piscis.material_override = material
    if flower_of_life:
        flower_of_life.material_override = material
    if metatrons_cube:
        metatrons_cube.material_override = material
    if tree_of_life:
        tree_of_life.material_override = material
    if sri_yantra:
        sri_yantra.material_override = material

func _process(delta):
    pattern_rotation += delta * 0.1
    pattern_scale = 1.0 + sin(Time.get_ticks_msec() * 0.001) * 0.1
    
    rotation.y = pattern_rotation
    scale = Vector3.ONE * pattern_scale
