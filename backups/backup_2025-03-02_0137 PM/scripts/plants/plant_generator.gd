extends Node
class_name PlantGenerator

# References to required systems
@onready var l_system = LSystem.new()
@onready var growth_system = get_node("/root/GrowthSystem")

# Medieval plant patterns (moved to L-System)
var patterns = {}

func _ready():
    # Get patterns from L-System
    patterns = LSystem.MEDIEVAL_PATTERNS

# Generate a plant model based on type, growth stage, and season
func generate_plant(plant_type: String, growth_stage: int, season: int) -> Node3D:
    var pattern = patterns.get(plant_type, patterns["herb"])  # Default to herb if type not found
    
    # Create the plant using L-System's medieval plant generator
    var plant = LSystem.create_medieval_plant(plant_type)
    
    # Apply growth stage modifications
    _apply_growth_stage(plant, growth_stage)
    
    # Apply seasonal effects through shader
    _apply_seasonal_effects(plant, season)
    
    # Add divine effects for special stages
    if growth_stage in [PlantGrowthSystem.GrowthStage.FLOWERING, PlantGrowthSystem.GrowthStage.FRUITING]:
        _add_divine_effects(plant)
    
    return plant

# Apply growth stage modifications
func _apply_growth_stage(plant: Node3D, stage: int) -> void:
    var structure = plant.get_node("Structure")
    if not structure:
        return
    
    # Get the material
    var material = structure.get_surface_override_material(0)
    if not material:
        return
    
    # Modify scale based on growth stage
    match stage:
        PlantGrowthSystem.GrowthStage.SEED:
            plant.scale = Vector3.ONE * 0.2
        PlantGrowthSystem.GrowthStage.SPROUT:
            plant.scale = Vector3.ONE * 0.4
        PlantGrowthSystem.GrowthStage.JUVENILE:
            plant.scale = Vector3.ONE * 0.7
        PlantGrowthSystem.GrowthStage.MATURE:
            plant.scale = Vector3.ONE
        PlantGrowthSystem.GrowthStage.FLOWERING:
            plant.scale = Vector3.ONE * 1.1
            material.set_shader_parameter("is_sacred", true)
            material.set_shader_parameter("divine_light_intensity", 0.7)
        PlantGrowthSystem.GrowthStage.FRUITING:
            plant.scale = Vector3.ONE * 1.2
            material.set_shader_parameter("is_sacred", true)
            material.set_shader_parameter("divine_light_intensity", 0.5)
        PlantGrowthSystem.GrowthStage.DORMANT:
            plant.scale = Vector3.ONE * 0.8

# Apply seasonal effects through shader
func _apply_seasonal_effects(plant: Node3D, season: int) -> void:
    var structure = plant.get_node("Structure")
    if not structure:
        return
    
    # Get the material
    var material = structure.get_surface_override_material(0)
    if not material:
        return
    
    # Apply seasonal modifications through shader parameters
    match season:
        PlantGrowthSystem.Season.SPRING:
            material.set_shader_parameter("weathering_amount", 0.1)
            material.set_shader_parameter("moss_growth", 0.3)
            material.set_shader_parameter("time_of_day", 10.0)  # Morning light
        
        PlantGrowthSystem.Season.SUMMER:
            material.set_shader_parameter("weathering_amount", 0.2)
            material.set_shader_parameter("moss_growth", 0.4)
            material.set_shader_parameter("time_of_day", 12.0)  # Noon light
        
        PlantGrowthSystem.Season.AUTUMN:
            material.set_shader_parameter("weathering_amount", 0.4)
            material.set_shader_parameter("moss_growth", 0.2)
            material.set_shader_parameter("time_of_day", 16.0)  # Afternoon light
        
        PlantGrowthSystem.Season.WINTER:
            material.set_shader_parameter("weathering_amount", 0.6)
            material.set_shader_parameter("moss_growth", 0.1)
            material.set_shader_parameter("time_of_day", 8.0)  # Winter morning

# Add divine effects
func _add_divine_effects(plant: Node3D) -> void:
    var structure = plant.get_node("Structure")
    if not structure:
        return
    
    # Get or create the material
    var material = structure.get_surface_override_material(0)
    if not material:
        material = StandardMaterial3D.new()
        structure.set_surface_override_material(0, material)
    
    # Add divine glow effect
    material.set_shader_parameter("is_sacred", true)
    material.set_shader_parameter("divine_light_intensity", 0.6)
    material.set_shader_parameter("divine_light_color", Color(1.0, 0.95, 0.7, 1.0))
    
    # Add particle effects for divine manifestation
    var particles = GPUParticles3D.new()
    var particle_material = ParticleProcessMaterial.new()
    
    particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
    particle_material.emission_sphere_radius = 0.5
    particle_material.gravity = Vector3.UP * 0.1
    particle_material.color = Color(1.0, 1.0, 0.8, 0.5)
    
    particles.process_material = particle_material
    particles.amount = 20
    particles.lifetime = 2.0
    
    plant.add_child(particles)
