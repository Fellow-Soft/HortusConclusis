extends Node3D
class_name SacredGeometryEnhanced

# Enhanced sacred geometry visualization for the Hortus Conclusus cinematic
# This script creates dynamic, evolving sacred geometry patterns with emission effects

# Constants for pattern parameters
const PATTERN_ROTATION_SPEED = 0.2
const PATTERN_PULSE_SPEED = 0.5
const PATTERN_EMISSION_MIN = 0.5
const PATTERN_EMISSION_MAX = 1.5
const PATTERN_TRANSITION_TIME = 5.0

# Color palettes for different times of day
const COLOR_PALETTES = {
    "dawn": {
        "primary": Color(1.0, 0.9, 0.6, 0.8),    # Golden
        "secondary": Color(0.9, 0.7, 0.5, 0.7),  # Amber
        "accent": Color(0.8, 0.6, 0.9, 0.6)      # Lavender
    },
    "noon": {
        "primary": Color(0.9, 0.95, 1.0, 0.8),   # White-blue
        "secondary": Color(0.7, 0.9, 1.0, 0.7),  # Sky blue
        "accent": Color(1.0, 0.9, 0.5, 0.6)      # Gold
    },
    "dusk": {
        "primary": Color(0.9, 0.6, 0.4, 0.8),    # Orange
        "secondary": Color(0.7, 0.4, 0.6, 0.7),  # Purple
        "accent": Color(1.0, 0.8, 0.3, 0.6)      # Deep gold
    },
    "night": {
        "primary": Color(0.4, 0.5, 0.9, 0.8),    # Deep blue
        "secondary": Color(0.3, 0.3, 0.6, 0.7),  # Indigo
        "accent": Color(0.8, 0.8, 1.0, 0.6)      # Silver
    }
}

# Pattern types
enum PatternType {
    SEED_OF_LIFE,
    FLOWER_OF_LIFE,
    METATRON_CUBE,
    TREE_OF_LIFE,
    VESICA_PISCIS,
    GOLDEN_SPIRAL
}

# Node references
var patterns = {}
var active_pattern: Node3D
var particle_systems = {}

# Animation parameters
var pattern_scale_pulse = 0.0
var pattern_rotation_value = 0.0
var pattern_emission_pulse = 0.0
var current_time_of_day = "dawn"

# Called when the node enters the scene tree
func _ready():
    # Create the sacred geometry patterns
    _create_all_patterns()
    
    # Start with no active pattern
    active_pattern = null

# Process function for continuous updates
func _process(delta: float):
    if active_pattern:
        _update_active_pattern(delta)

# Create all sacred geometry patterns
func _create_all_patterns():
    # Create parent node for all patterns
    var patterns_node = Node3D.new()
    patterns_node.name = "SacredGeometryPatterns"
    add_child(patterns_node)
    
    # Create each pattern type
    patterns[PatternType.SEED_OF_LIFE] = _create_seed_of_life()
    patterns[PatternType.FLOWER_OF_LIFE] = _create_flower_of_life()
    patterns[PatternType.METATRON_CUBE] = _create_metatron_cube()
    patterns[PatternType.TREE_OF_LIFE] = _create_tree_of_life()
    patterns[PatternType.VESICA_PISCIS] = _create_vesica_piscis()
    patterns[PatternType.GOLDEN_SPIRAL] = _create_golden_spiral()
    
    # Add patterns to the scene and hide them initially
    for pattern_type in patterns:
        var pattern = patterns[pattern_type]
        pattern.visible = false
        patterns_node.add_child(pattern)
        
        # Create particle system for each pattern
        _create_pattern_particles(pattern, pattern_type)

# Update the active pattern animation
func _update_active_pattern(delta: float):
    # Update rotation
    pattern_rotation_value += delta * PATTERN_ROTATION_SPEED
    active_pattern.rotation.y = pattern_rotation_value
    
    # Update scale pulsing
    pattern_scale_pulse += delta * PATTERN_PULSE_SPEED
    var scale_factor = 1.0 + sin(pattern_scale_pulse) * 0.1
    active_pattern.scale = Vector3.ONE * scale_factor
    
    # Update emission pulsing
    pattern_emission_pulse += delta * PATTERN_PULSE_SPEED * 0.7
    var emission_factor = PATTERN_EMISSION_MIN + (sin(pattern_emission_pulse) * 0.5 + 0.5) * (PATTERN_EMISSION_MAX - PATTERN_EMISSION_MIN)
    
    # Update material emission for all child meshes
    for child in active_pattern.get_children():
        if child is MeshInstance3D:
            var material = child.get_surface_override_material(0)
            if material and material is StandardMaterial3D:
                material.emission_energy = emission_factor
    
    # Update particle systems
    if active_pattern in particle_systems:
        var particles = particle_systems[active_pattern]
        if particles and particles.has("main"):
            var main_particles = particles["main"]
            if main_particles and is_instance_valid(main_particles):
                # Adjust particle emission rate based on pulse
                var emission_rate = 20 + int(sin(pattern_emission_pulse) * 10)
                if main_particles.amount != emission_rate:
                    main_particles.amount = emission_rate

# Create Seed of Life pattern
func _create_seed_of_life() -> Node3D:
    var pattern = Node3D.new()
    pattern.name = "SeedOfLife"
    
    var radius = 1.0
    var segments = 36
    var color = COLOR_PALETTES[current_time_of_day]["primary"]
    
    # Create center circle
    var center_circle = _create_circle_mesh(radius, segments, color)
    pattern.add_child(center_circle)
    
    # Create six surrounding circles
    for i in range(6):
        var angle = i * PI / 3
        var pos = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
        var circle = _create_circle_mesh(radius, segments, color)
        circle.position = pos
        pattern.add_child(circle)
    
    return pattern

# Create Flower of Life pattern
func _create_flower_of_life() -> Node3D:
    var pattern = Node3D.new()
    pattern.name = "FlowerOfLife"
    
    var radius = 0.5
    var segments = 36
    var color = COLOR_PALETTES[current_time_of_day]["primary"]
    
    # Create center circle
    var center_circle = _create_circle_mesh(radius, segments, color)
    pattern.add_child(center_circle)
    
    # Create first ring of 6 circles
    for i in range(6):
        var angle = i * PI / 3
        var pos = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
        var circle = _create_circle_mesh(radius, segments, color)
        circle.position = pos
        pattern.add_child(circle)
    
    # Create second ring of 12 circles
    var color2 = COLOR_PALETTES[current_time_of_day]["secondary"]
    for i in range(12):
        var angle = i * PI / 6
        var pos = Vector3(cos(angle) * radius * 2, 0, sin(angle) * radius * 2)
        var circle = _create_circle_mesh(radius, segments, color2)
        circle.position = pos
        pattern.add_child(circle)
    
    return pattern

# Create Metatron's Cube pattern
func _create_metatron_cube() -> Node3D:
    var pattern = Node3D.new()
    pattern.name = "MetatronCube"
    
    var radius = 0.2
    var color = COLOR_PALETTES[current_time_of_day]["primary"]
    var line_color = COLOR_PALETTES[current_time_of_day]["secondary"]
    
    # Create 13 vertices (spheres)
    var vertices = []
    var positions = []
    
    # Center vertex
    var center = _create_sphere_mesh(radius, color)
    pattern.add_child(center)
    vertices.append(center)
    positions.append(Vector3.ZERO)
    
    # First ring of 6 vertices
    for i in range(6):
        var angle = i * PI / 3
        var pos = Vector3(cos(angle) * 1.0, 0, sin(angle) * 1.0)
        var vertex = _create_sphere_mesh(radius, color)
        vertex.position = pos
        pattern.add_child(vertex)
        vertices.append(vertex)
        positions.append(pos)
    
    # Second ring of 6 vertices
    var color2 = COLOR_PALETTES[current_time_of_day]["accent"]
    for i in range(6):
        var angle = i * PI / 3 + PI / 6
        var pos = Vector3(cos(angle) * 2.0, 0, sin(angle) * 2.0)
        var vertex = _create_sphere_mesh(radius, color2)
        vertex.position = pos
        pattern.add_child(vertex)
        vertices.append(vertex)
        positions.append(pos)
    
    # Create lines connecting vertices
    for i in range(positions.size()):
        for j in range(i + 1, positions.size()):
            var line = _create_line_mesh(positions[i], positions[j], line_color)
            pattern.add_child(line)
    
    return pattern

# Create Tree of Life pattern
func _create_tree_of_life() -> Node3D:
    var pattern = Node3D.new()
    pattern.name = "TreeOfLife"
    
    var radius = 0.3
    var color = COLOR_PALETTES[current_time_of_day]["primary"]
    var line_color = COLOR_PALETTES[current_time_of_day]["secondary"]
    
    # Create 10 sephirot (spheres)
    var sephirot_positions = [
        Vector3(0, 0, -2),    # Keter
        Vector3(-1, 0, -1),   # Chokmah
        Vector3(1, 0, -1),    # Binah
        Vector3(-1, 0, 0),    # Chesed
        Vector3(1, 0, 0),     # Geburah
        Vector3(0, 0, 0),     # Tiferet
        Vector3(-1, 0, 1),    # Netzach
        Vector3(1, 0, 1),     # Hod
        Vector3(0, 0, 1),     # Yesod
        Vector3(0, 0, 2)      # Malkuth
    ]
    
    var sephirot_colors = [
        COLOR_PALETTES[current_time_of_day]["accent"],     # Keter
        COLOR_PALETTES[current_time_of_day]["primary"],    # Chokmah
        COLOR_PALETTES[current_time_of_day]["primary"],    # Binah
        COLOR_PALETTES[current_time_of_day]["secondary"],  # Chesed
        COLOR_PALETTES[current_time_of_day]["secondary"],  # Geburah
        COLOR_PALETTES[current_time_of_day]["accent"],     # Tiferet
        COLOR_PALETTES[current_time_of_day]["secondary"],  # Netzach
        COLOR_PALETTES[current_time_of_day]["secondary"],  # Hod
        COLOR_PALETTES[current_time_of_day]["primary"],    # Yesod
        COLOR_PALETTES[current_time_of_day]["accent"]      # Malkuth
    ]
    
    var sephirot = []
    for i in range(sephirot_positions.size()):
        var sphere = _create_sphere_mesh(radius, sephirot_colors[i])
        sphere.position = sephirot_positions[i]
        pattern.add_child(sphere)
        sephirot.append(sphere)
    
    # Create lines connecting sephirot (paths)
    var paths = [
        [0, 1], [0, 2], [1, 2], [1, 3], [2, 4], [3, 4],
        [3, 5], [4, 5], [5, 6], [5, 7], [6, 7], [6, 8],
        [7, 8], [8, 9], [1, 5], [2, 5], [3, 6], [4, 7],
        [5, 8], [0, 5], [1, 6], [2, 7]
    ]
    
    for path in paths:
        var line = _create_line_mesh(
            sephirot_positions[path[0]],
            sephirot_positions[path[1]],
            line_color
        )
        pattern.add_child(line)
    
    return pattern

# Create Vesica Piscis pattern
func _create_vesica_piscis() -> Node3D:
    var pattern = Node3D.new()
    pattern.name = "VesicaPiscis"
    
    var radius = 1.0
    var segments = 36
    var color = COLOR_PALETTES[current_time_of_day]["primary"]
    var color2 = COLOR_PALETTES[current_time_of_day]["secondary"]
    
    # Create two overlapping circles
    var circle1 = _create_circle_mesh(radius, segments, color)
    circle1.position = Vector3(-radius/2, 0, 0)
    pattern.add_child(circle1)
    
    var circle2 = _create_circle_mesh(radius, segments, color2)
    circle2.position = Vector3(radius/2, 0, 0)
    pattern.add_child(circle2)
    
    # Create the vesica piscis shape in the middle
    var vesica = _create_vesica_piscis_mesh(radius, segments, COLOR_PALETTES[current_time_of_day]["accent"])
    pattern.add_child(vesica)
    
    return pattern

# Create Golden Spiral pattern
func _create_golden_spiral() -> Node3D:
    var pattern = Node3D.new()
    pattern.name = "GoldenSpiral"
    
    var color = COLOR_PALETTES[current_time_of_day]["primary"]
    var color2 = COLOR_PALETTES[current_time_of_day]["secondary"]
    
    # Create the golden spiral using Fibonacci squares
    var fib = [1, 1, 2, 3, 5, 8, 13, 21]
    var pos = Vector3.ZERO
    var total_size = 0
    
    for i in range(fib.size() - 1):
        var size = fib[i] * 0.2  # Scale down to reasonable size
        total_size += size
        
        # Create square
        var square = _create_square_mesh(size, color if i % 2 == 0 else color2)
        
        # Position each square
        if i == 0:
            square.position = Vector3(size/2, 0, size/2)
        elif i == 1:
            square.position = Vector3(fib[0] * 0.2 + size/2, 0, fib[0] * 0.2 - size/2)
        elif i == 2:
            square.position = Vector3(fib[0] * 0.2 - size/2, 0, fib[0] * 0.2 + fib[1] * 0.2 - size/2)
        elif i == 3:
            square.position = Vector3(fib[0] * 0.2 - fib[2] * 0.2 - size/2, 0, fib[0] * 0.2 + fib[1] * 0.2 - size/2)
        elif i == 4:
            square.position = Vector3(fib[0] * 0.2 - fib[2] * 0.2 - size/2, 0, fib[0] * 0.2 + fib[1] * 0.2 - fib[3] * 0.2 - size/2)
        elif i == 5:
            square.position = Vector3(fib[0] * 0.2 - fib[2] * 0.2 + fib[4] * 0.2 - size/2, 0, fib[0] * 0.2 + fib[1] * 0.2 - fib[3] * 0.2 - size/2)
        elif i == 6:
            square.position = Vector3(fib[0] * 0.2 - fib[2] * 0.2 + fib[4] * 0.2 - size/2, 0, fib[0] * 0.2 + fib[1] * 0.2 - fib[3] * 0.2 + fib[5] * 0.2 - size/2)
        
        pattern.add_child(square)
    
    # Create the spiral curve
    var spiral = _create_golden_spiral_curve(total_size, COLOR_PALETTES[current_time_of_day]["accent"])
    pattern.add_child(spiral)
    
    return pattern

# Create a circle mesh for sacred geometry patterns
func _create_circle_mesh(radius: float, segments: int, color: Color) -> MeshInstance3D:
    var mesh_instance = MeshInstance3D.new()
    var surface_tool = SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLE_FAN)
    
    # Center vertex
    surface_tool.set_color(color)
    surface_tool.add_vertex(Vector3.ZERO)
    
    # Perimeter vertices
    for i in range(segments + 1):
        var angle = i * 2 * PI / segments
        var vertex = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
        surface_tool.add_vertex(vertex)
    
    mesh_instance.mesh = surface_tool.commit()
    
    # Create material with emission
    var material = StandardMaterial3D.new()
    material.albedo_color = color
    material.emission_enabled = true
    material.emission = color
    material.emission_energy = 1.0
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    mesh_instance.set_surface_override_material(0, material)
    
    return mesh_instance

# Create a line mesh for sacred geometry patterns
func _create_line_mesh(start: Vector3, end: Vector3, color: Color) -> MeshInstance3D:
    var mesh_instance = MeshInstance3D.new()
    var immediate_mesh = ImmediateMesh.new()
    
    immediate_mesh.clear_surfaces()
    immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
    immediate_mesh.surface_add_vertex(start)
    immediate_mesh.surface_add_vertex(end)
    immediate_mesh.surface_end()
    
    mesh_instance.mesh = immediate_mesh
    
    # Create material with emission
    var material = StandardMaterial3D.new()
    material.albedo_color = color
    material.emission_enabled = true
    material.emission = color
    material.emission_energy = 1.0
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    mesh_instance.set_surface_override_material(0, material)
    
    return mesh_instance

# Create a sphere mesh for sacred geometry patterns
func _create_sphere_mesh(radius: float, color: Color) -> MeshInstance3D:
    var mesh_instance = MeshInstance3D.new()
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = radius
    sphere_mesh.height = radius * 2
    mesh_instance.mesh = sphere_mesh
    
    # Create material with emission
    var material = StandardMaterial3D.new()
    material.albedo_color = color
    material.emission_enabled = true
    material.emission = color
    material.emission_energy = 1.0
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    mesh_instance.set_surface_override_material(0, material)
    
    return mesh_instance

# Create a square mesh for golden spiral
func _create_square_mesh(size: float, color: Color) -> MeshInstance3D:
    var mesh_instance = MeshInstance3D.new()
    var surface_tool = SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_LINE_LOOP)
    
    # Create square outline
    surface_tool.set_color(color)
    surface_tool.add_vertex(Vector3(-size/2, 0, -size/2))
    surface_tool.add_vertex(Vector3(size/2, 0, -size/2))
    surface_tool.add_vertex(Vector3(size/2, 0, size/2))
    surface_tool.add_vertex(Vector3(-size/2, 0, size/2))
    
    mesh_instance.mesh = surface_tool.commit()
    
    # Create material with emission
    var material = StandardMaterial3D.new()
    material.albedo_color = color
    material.emission_enabled = true
    material.emission = color
    material.emission_energy = 1.0
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    mesh_instance.set_surface_override_material(0, material)
    
    return mesh_instance

# Create a vesica piscis mesh
func _create_vesica_piscis_mesh(radius: float, segments: int, color: Color) -> MeshInstance3D:
    var mesh_instance = MeshInstance3D.new()
    var surface_tool = SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLE_FAN)
    
    # Center vertex
    surface_tool.set_color(color)
    surface_tool.add_vertex(Vector3.ZERO)
    
    # Create the vesica piscis shape
    for i in range(segments / 2 + 1):
        var angle = i * 2 * PI / segments + PI/2
        var vertex = Vector3(cos(angle) * radius, 0, sin(angle) * radius) + Vector3(-radius/2, 0, 0)
        surface_tool.add_vertex(vertex)
    
    for i in range(segments / 2 + 1):
        var angle = i * 2 * PI / segments - PI/2
        var vertex = Vector3(cos(angle) * radius, 0, sin(angle) * radius) + Vector3(radius/2, 0, 0)
        surface_tool.add_vertex(vertex)
    
    mesh_instance.mesh = surface_tool.commit()
    
    # Create material with emission
    var material = StandardMaterial3D.new()
    material.albedo_color = color
    material.emission_enabled = true
    material.emission = color
    material.emission_energy = 1.0
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    mesh_instance.set_surface_override_material(0, material)
    
    return mesh_instance

# Create a golden spiral curve
func _create_golden_spiral_curve(size: float, color: Color) -> MeshInstance3D:
    var mesh_instance = MeshInstance3D.new()
    var immediate_mesh = ImmediateMesh.new()
    
    immediate_mesh.clear_surfaces()
    immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
    
    # Create the golden spiral using parametric equation
    var a = 0.1
    var b = 0.1
    var max_theta = 8 * PI
    var steps = 100
    
    for i in range(steps + 1):
        var theta = i * max_theta / steps
        var r = a * exp(b * theta)
        var x = r * cos(theta)
        var z = r * sin(theta)
        immediate_mesh.surface_add_vertex(Vector3(x, 0, z))
    
    immediate_mesh.surface_end()
    
    mesh_instance.mesh = immediate_mesh
    
    # Create material with emission
    var material = StandardMaterial3D.new()
    material.albedo_color = color
    material.emission_enabled = true
    material.emission = color
    material.emission_energy = 1.0
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    mesh_instance.set_surface_override_material(0, material)
    
    return mesh_instance

# Create particle systems for a pattern
func _create_pattern_particles(pattern: Node3D, pattern_type: int) -> void:
    # Create main particle system
    var main_particles = GPUParticles3D.new()
    main_particles.name = "PatternParticles"
    main_particles.amount = 30
    main_particles.lifetime = 3.0
    main_particles.explosiveness = 0.0
    main_particles.randomness = 0.5
    main_particles.fixed_fps = 30
    main_particles.visibility_aabb = AABB(Vector3(-5, -5, -5), Vector3(10, 10, 10))
    
    # Create particle material
    var material = ParticleProcessMaterial.new()
    material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
    material.emission_sphere_radius = 2.0
    material.direction = Vector3(0, 1, 0)
    material.spread = 180.0
    material.gravity = Vector3(0, 0.05, 0)
    material.initial_velocity_min = 0.1
    material.initial_velocity_max = 0.3
    material.angular_velocity_min = -0.2
    material.angular_velocity_max = 0.2
    material.scale_min = 0.05
    material.scale_max = 0.1
    
    # Set color based on pattern type
    var color = COLOR_PALETTES[current_time_of_day]["primary"]
    if pattern_type == PatternType.FLOWER_OF_LIFE or pattern_type == PatternType.TREE_OF_LIFE:
        color = COLOR_PALETTES[current_time_of_day]["accent"]
    elif pattern_type == PatternType.METATRON_CUBE or pattern_type == PatternType.GOLDEN_SPIRAL:
        color = COLOR_PALETTES[current_time_of_day]["secondary"]
    
    material.color = color
    
    # Create color gradient for fading
    var gradient = Gradient.new()
    gradient.add_point(0.0, Color(color.r, color.g, color.b, 0.0))
    gradient.add_point(0.2, Color(color.r, color.g, color.b, color.a))
    gradient.add_point(0.8, Color(color.r, color.g, color.b, color.a))
    gradient.add_point(1.0, Color(color.r, color.g, color.b, 0.0))
    
    var gradient_texture = GradientTexture1D.new()
    gradient_texture.gradient = gradient
    material.color_ramp = gradient_texture
    
    # Set up mesh for particles
    var mesh = QuadMesh.new()
    mesh.size = Vector2(1, 1)
    
    # Assign material and mesh to particles
    main_particles.process_material = material
    main_particles.draw_pass_1 = mesh
    
    # Add to pattern
    pattern.add_child(main_particles)
    
    # Store reference to particle systems
    particle_systems[pattern] = {
        "main": main_particles
    }
    
    # Initially not emitting
    main_particles.emitting = false

# Public method to activate a pattern
func activate_pattern(pattern_type: int) -> void:
    # Hide current active pattern if any
    if active_pattern:
        active_pattern.visible = false
        
        # Stop particle emission
        if active_pattern in particle_systems:
            var particles = particle_systems[active_pattern]
            if particles and particles.has("main"):
                particles["main"].emitting = false
    
    # Set new active pattern
    if pattern_type in patterns:
        active_pattern = patterns[pattern_type]
        active_pattern.visible = true
        active_pattern.scale = Vector3.ONE
        
        # Reset animation values
        pattern_scale_pulse = 0.0
        pattern_rotation_value = 0.0
        pattern_emission_pulse = 0.0
        
        # Start particle emission
        if active_pattern in particle_systems:
            var particles = particle_systems[active_pattern]
            if particles and particles.has("main"):
                particles["main"].emitting = true
    else:
        active_pattern = null

# Public method to transition between patterns
func transition_to_pattern(pattern_type: int) -> void:
    if not active_pattern or not (pattern_type in patterns):
        activate_pattern(pattern_type)
        return
    
    var new_pattern = patterns[pattern_type]
    var old_pattern = active_pattern
    
    # Start transition
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_IN_OUT)
    
    # Fade out old pattern
    old_pattern.visible = true
    tween.tween_property(old_pattern, "scale", Vector3.ONE * 0.5, PATTERN_TRANSITION_TIME / 2)
    
    # Update materials for fade out
    for child in old_pattern.get_children():
        if child is MeshInstance3D:
            var material = child.get_surface_override_material(0)
            if material and material is StandardMaterial3D:
                tween.parallel().tween_property(material, "emission_energy", 0.0, PATTERN_TRANSITION_TIME / 2)
                tween.parallel().tween_property(material, "albedo_color:a", 0.0, PATTERN_TRANSITION_TIME / 2)
    
    # Prepare new pattern
    new_pattern.visible = true
    new_pattern.scale = Vector3.ONE * 0.5
    
    # Set initial transparency for new pattern
    for child in new_pattern.get_children():
        if child is MeshInstance3D:
            var material = child.get_surface_override_material(0)
            if material and material is Standar
