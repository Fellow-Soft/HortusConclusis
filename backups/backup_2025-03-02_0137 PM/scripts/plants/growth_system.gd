extends Node
class_name PlantGrowthSystem

# Growth stages based on medieval understanding of plant life cycles
enum GrowthStage {
	SEED,           # Initial planting
	SPROUT,         # First emergence
	JUVENILE,       # Early growth
	MATURE,         # Full growth
	FLOWERING,      # Blooming stage
	FRUITING,       # Bearing fruit/seeds
	DORMANT        # Winter rest
}

# Medieval seasonal influences
enum Season {
	SPRING,  # Growth and renewal
	SUMMER,  # Peak vitality
	AUTUMN,  # Harvest and preparation
	WINTER   # Dormancy and rest
}

# Growth properties for a plant
class PlantGrowth:
	var current_stage: GrowthStage = GrowthStage.SEED
	var growth_progress: float = 0.0  # Progress to next stage (0-1)
	var health: float = 1.0           # Plant health (0-1)
	var age_days: int = 0             # Age in days
	var last_season: Season           # Last season update
	var symbolism: String             # Medieval symbolic meaning
	var uses: Array                   # Traditional uses
	
	# Growth modifiers
	var growth_rate: float = 1.0      # Base growth rate
	var season_modifier: float = 1.0   # Seasonal influence
	var prayer_blessing: bool = false  # Medieval spiritual influence
	
	func _init(initial_symbolism: String = "", initial_uses: Array = []):
		symbolism = initial_symbolism
		uses = initial_uses
		last_season = Season.SPRING

# Signal for growth stage changes
signal plant_stage_changed(plant_id, old_stage, new_stage)
# Signal for seasonal transitions
signal season_changed(old_season, new_season)

# Current season
var current_season: Season = Season.SPRING
# Dictionary of active plants
var plants: Dictionary = {}
# Time scale (1.0 = real time, > 1.0 = accelerated)
@export var time_scale: float = 24.0  # 1 real second = 24 game minutes

# Called when the node enters the scene tree
func _ready():
	# Start the growth cycle
	_start_growth_cycle()

# Initialize a new plant
func add_plant(plant_id: String, symbolism: String = "", uses: Array = []) -> void:
	var plant = PlantGrowth.new(symbolism, uses)
	plants[plant_id] = plant

# Remove a plant
func remove_plant(plant_id: String) -> void:
	if plants.has(plant_id):
		plants.erase(plant_id)

# Update growth for all plants
func _process(delta: float) -> void:
	# Scale time
	var game_time_delta = delta * time_scale
	
	# Update each plant
	for plant_id in plants:
		_update_plant_growth(plant_id, game_time_delta)

# Start the seasonal cycle
func _start_growth_cycle() -> void:
	# Create a timer for seasonal changes
	var season_timer = Timer.new()
	add_child(season_timer)
	season_timer.wait_time = 900.0  # 15 minutes real time per season
	season_timer.connect("timeout", Callable(self, "_on_season_change"))
	season_timer.start()

# Handle seasonal changes
func _on_season_change() -> void:
	var old_season = current_season
	# Advance to next season
	current_season = (current_season + 1) % 4
	
	# Update all plants for the new season
	for plant_id in plants:
		var plant = plants[plant_id]
		plant.last_season = current_season
		_apply_seasonal_effects(plant)
	
	emit_signal("season_changed", old_season, current_season)

# Apply seasonal effects to a plant
func _apply_seasonal_effects(plant: PlantGrowth) -> void:
	match current_season:
		Season.SPRING:
			plant.season_modifier = 1.5  # Enhanced growth
			if plant.current_stage == GrowthStage.DORMANT:
				_advance_growth_stage(plant)  # Wake from dormancy
		
		Season.SUMMER:
			plant.season_modifier = 1.0  # Normal growth
			if plant.current_stage == GrowthStage.MATURE:
				_advance_growth_stage(plant)  # Progress to flowering
		
		Season.AUTUMN:
			plant.season_modifier = 0.5  # Reduced growth
			if plant.current_stage == GrowthStage.FLOWERING:
				_advance_growth_stage(plant)  # Progress to fruiting
		
		Season.WINTER:
			plant.season_modifier = 0.0  # No growth
			plant.current_stage = GrowthStage.DORMANT

# Update growth for a single plant
func _update_plant_growth(plant_id: String, delta: float) -> void:
	var plant = plants[plant_id]
	
	# Skip if dormant
	if plant.current_stage == GrowthStage.DORMANT:
		return
	
	# Calculate growth increment
	var growth_increment = delta * plant.growth_rate * plant.season_modifier
	if plant.prayer_blessing:
		growth_increment *= 1.2  # Blessing bonus
	
	# Update growth progress
	plant.growth_progress += growth_increment
	plant.age_days += delta / 86400.0  # Convert seconds to days
	
	# Check for stage advancement
	if plant.growth_progress >= 1.0:
		plant.growth_progress = 0.0
		_advance_growth_stage(plant)

# Advance to the next growth stage
func _advance_growth_stage(plant: PlantGrowth) -> void:
	var old_stage = plant.current_stage
	
	# Determine next stage
	match plant.current_stage:
		GrowthStage.SEED:
			plant.current_stage = GrowthStage.SPROUT
		GrowthStage.SPROUT:
			plant.current_stage = GrowthStage.JUVENILE
		GrowthStage.JUVENILE:
			plant.current_stage = GrowthStage.MATURE
		GrowthStage.MATURE:
			plant.current_stage = GrowthStage.FLOWERING
		GrowthStage.FLOWERING:
			plant.current_stage = GrowthStage.FRUITING
		GrowthStage.FRUITING:
			# Stay in fruiting until winter
			if current_season == Season.WINTER:
				plant.current_stage = GrowthStage.DORMANT
	
	# Emit signal for stage change
	for plant_id in plants:
		if plants[plant_id] == plant:
			emit_signal("plant_stage_changed", plant_id, old_stage, plant.current_stage)
			break

# Apply a prayer blessing to a plant
func bless_plant(plant_id: String) -> void:
	if plants.has(plant_id):
		plants[plant_id].prayer_blessing = true

# Get the current growth stage description
func get_stage_description(plant_id: String) -> String:
	if not plants.has(plant_id):
		return "Plant not found"
	
	var plant = plants[plant_id]
	match plant.current_stage:
		GrowthStage.SEED:
			return "A seed sleeping in the earth, holding the promise of God's creation"
		GrowthStage.SPROUT:
			return "A tender shoot reaching toward heaven's light"
		GrowthStage.JUVENILE:
			return "A young plant growing in wisdom and strength"
		GrowthStage.MATURE:
			return "A plant in its full vigor, demonstrating the glory of creation"
		GrowthStage.FLOWERING:
			return "Blessed with flowers, showing the beauty of paradise"
		GrowthStage.FRUITING:
			return "Bearing fruit, fulfilling its divine purpose"
		GrowthStage.DORMANT:
			return "Resting in winter's embrace, awaiting spring's renewal"
		_:
			return "Unknown stage"

# Get plant health description
func get_health_description(plant_id: String) -> String:
	if not plants.has(plant_id):
		return "Plant not found"
	
	var plant = plants[plant_id]
	if plant.health > 0.8:
		return "Thriving by God's grace"
	elif plant.health > 0.6:
		return "Growing steadily"
	elif plant.health > 0.4:
		return "In need of care and attention"
	elif plant.health > 0.2:
		return "Struggling to maintain vigor"
	else:
		return "Close to returning to the earth"

# Get current season description
func get_season_description() -> String:
	match current_season:
		Season.SPRING:
			return "Spring - When God renews the garden"
		Season.SUMMER:
			return "Summer - The time of full growth and vigor"
		Season.AUTUMN:
			return "Autumn - The season of harvest and preparation"
		Season.WINTER:
			return "Winter - A time of rest and contemplation"
		_:
			return "Unknown season"
