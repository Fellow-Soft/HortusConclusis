extends Node
class_name HortusConclususCinematicHelpers

# Helper functions for the Hortus Conclusus cinematic demo

# Add mist particles for the introduction stage
static func add_mist_particles(parent: Node3D):
	# Create multiple mist particle systems for a volumetric effect
	for i in range(10):
		var pos = Vector3(randf_range(-20, 20), randf_range(0.5, 3.0), randf_range(-20, 20))
		CinematicEffects.add_materialization_particles(
			parent, 
			pos, 
			Color(0.9, 0.9, 1.0, 0.2)
		)

# Add divine light for the divine manifestation stage
static func add_divine_light(parent: Node3D):
	# Create main divine light from above
	var light = OmniLight3D.new()
	light.light_color = Color(1.0, 0.95, 0.8)
	light.light_energy = 2.0
	light.omni_range = 30.0
	light.global_position = Vector3(0, 15, 0)
	light.shadow_enabled = true
	parent.add_child(light)
	
	# Add subtle pulsing effect to the light
	var light_tween = parent.create_tween()
	light_tween.tween_property(light, "light_energy", 3.0, 2.0)
	light_tween.tween_property(light, "light_energy", 2.0, 2.0)
	light_tween.set_loops(5)
	
	# Add secondary lights for enhanced effect
	for i in range(3):
		var angle = i * (2 * PI / 3)
		var sec_light = OmniLight3D.new()
		sec_light.light_color = Color(1.0, 0.9, 0.7)
		sec_light.light_energy = 1.0
		sec_light.omni_range = 15.0
		sec_light.global_position = Vector3(cos(angle) * 10, 12, sin(angle) * 10)
		parent.add_child(sec_light)
		
		# Create pulsing effect with offset timing
		var sec_tween = parent.create_tween()
		sec_tween.tween_property(sec_light, "light_energy", 1.5, 2.0).set_delay(i * 0.7)
		sec_tween.tween_property(sec_light, "light_energy", 1.0, 2.0)
		sec_tween.set_loops(5)
		
		# Schedule cleanup
		var timer = Timer.new()
		timer.wait_time = 25.0
		timer.one_shot = true
		timer.connect("timeout", Callable(sec_light, "queue_free"))
		parent.add_child(timer)
		timer.start()
	
	# Schedule main light cleanup
	var main_timer = Timer.new()
	main_timer.wait_time = 25.0
	main_timer.one_shot = true
	main_timer.connect("timeout", Callable(light, "queue_free"))
	parent.add_child(main_timer)
	main_timer.start()

# Add final divine light rays for the conclusion stage
static func add_final_light_rays(parent: Node3D):
	# Create a central beam of light
	var central_light = SpotLight3D.new()
	central_light.light_color = Color(1.0, 0.95, 0.8)
	central_light.light_energy = 5.0
	central_light.spot_range = 50.0
	central_light.spot_angle = 20.0
	central_light.global_position = Vector3(0, 30, 0)
	central_light.rotation = Vector3(-PI/2, 0, 0)  # Point downward
	central_light.shadow_enabled = true
	parent.add_child(central_light)
	
	# Create light rays with particle effects
	for i in range(5):
		var angle = i * (2 * PI / 5)
		var ray_pos = Vector3(cos(angle) * 5, 25, sin(angle) * 5)
		
		# Add divine particles for the ray
		CinematicEffects.add_divine_particles(parent, ray_pos, Color(1.0, 0.95, 0.7, 0.8))
		
		# Add a small light at the ray position
		var ray_light = OmniLight3D.new()
		ray_light.light_color = Color(1.0, 0.95, 0.7)
		ray_light.light_energy = 1.0
		ray_light.omni_range = 10.0
		ray_light.global_position = ray_pos
		parent.add_child(ray_light)
		
		# Animate the ray light
		var ray_tween = parent.create_tween()
		ray_tween.tween_property(ray_light, "light_energy", 2.0, 1.0)
		ray_tween.tween_property(ray_light, "light_energy", 1.0, 1.0)
		ray_tween.set_loops(5)
	
	# Fade out the central light at the end
	var fade_tween = parent.create_tween()
	fade_tween.tween_property(central_light, "light_energy", 0.0, 5.0).set_delay(5.0)

# Add nature sounds for the garden exploration stage
static func add_nature_sounds(parent: Node3D):
	# Create audio player for nature sounds
	var nature_player = AudioStreamPlayer.new()
	nature_player.name = "NatureSoundPlayer"
	nature_player.volume_db = -15.0
	parent.add_child(nature_player)
	
	# Schedule random bird sounds
	var bird_timer = Timer.new()
	bird_timer.wait_time = 5.0
	bird_timer.connect("timeout", Callable(parent, "_play_random_bird_sound").bind(nature_player))
	parent.add_child(bird_timer)
	bird_timer.start()
	
	return nature_player

# Play a random bird sound
static func play_random_bird_sound(parent: Node3D, player: AudioStreamPlayer):
	# In a real implementation, you would have actual bird sound files
	# For this example, we'll just adjust the volume to simulate a bird sound
	var current_volume = player.volume_db
	
	var tween = parent.create_tween()
	tween.tween_property(player, "volume_db", current_volume + 5.0, 0.2)
	tween.tween_property(player, "volume_db", current_volume, 0.3)

# Highlight each garden type with subtle effects
static func highlight_garden_types(parent: Node3D, monastic_garden: Node3D, knot_garden: Node3D, raised_garden: Node3D):
	# Add subtle particle effects to each garden type
	if monastic_garden:
		CinematicEffects.add_growth_particles(parent, monastic_garden)
		
		# Schedule a highlight effect
		var monastic_timer = Timer.new()
		monastic_timer.wait_time = 5.0
		monastic_timer.one_shot = true
		monastic_timer.connect("timeout", Callable(parent, "_highlight_garden").bind(monastic_garden))
		parent.add_child(monastic_timer)
		monastic_timer.start()
	
	if knot_garden:
		CinematicEffects.add_flowering_particles(parent, knot_garden)
		
		# Schedule a highlight effect with delay
		var knot_timer = Timer.new()
		knot_timer.wait_time = 15.0
		knot_timer.one_shot = true
		knot_timer.connect("timeout", Callable(parent, "_highlight_garden").bind(knot_garden))
		parent.add_child(knot_timer)
		knot_timer.start()
	
	if raised_garden:
		CinematicEffects.add_divine_particles(parent, raised_garden)
		
		# Schedule a highlight effect with longer delay
		var raised_timer = Timer.new()
		raised_timer.wait_time = 25.0
		raised_timer.one_shot = true
		raised_timer.connect("timeout", Callable(parent, "_highlight_garden").bind(raised_garden))
		parent.add_child(raised_timer)
		raised_timer.start()

# Highlight a specific garden with a subtle glow effect
static func highlight_garden(parent: Node3D, garden: Node3D):
	# Create a temporary light to highlight the garden
	var highlight_light = OmniLight3D.new()
	highlight_light.light_color = Color(0.9, 0.8, 0.6)
	highlight_light.light_energy = 0.0
	highlight_light.omni_range = 10.0
	highlight_light.global_position = garden.global_position + Vector3(0, 2, 0)
	parent.add_child(highlight_light)
	
	# Animate the highlight
	var tween = parent.create_tween()
	tween.tween_property(highlight_light, "light_energy", 1.5, 1.0)
	tween.tween_property(highlight_light, "light_energy", 0.0, 2.0)
	tween.tween_callback(Callable(highlight_light, "queue_free"))

# Setup day-night effects for the day-night transition stage
static func setup_day_night_effects(parent: Node3D, atmosphere_controller):
	# Connect to time change signal to update effects
	if atmosphere_controller.is_connected("time_changed", Callable(parent, "_on_time_changed")):
		atmosphere_controller.disconnect("time_changed", Callable(parent, "_on_time_changed"))
	
	# Add time-specific effects
	var dawn_timer = Timer.new()
	dawn_timer.wait_time = 30.0
	dawn_timer.one_shot = true
	dawn_timer.connect("timeout", Callable(parent, "_add_dawn_effects"))
	parent.add_child(dawn_timer)
	dawn_timer.start()
	
	var noon_timer = Timer.new()
	noon_timer.wait_time = 60.0
	noon_timer.one_shot = true
	noon_timer.connect("timeout", Callable(parent, "_add_noon_effects"))
	parent.add_child(noon_timer)
	noon_timer.start()
	
	var dusk_timer = Timer.new()
	dusk_timer.wait_time = 90.0
	dusk_timer.one_shot = true
	dusk_timer.connect("timeout", Callable(parent, "_add_dusk_effects"))
	parent.add_child(dusk_timer)
	dusk_timer.start()

# Add dawn-specific effects
static func add_dawn_effects(parent: Node3D):
	# Add mist particles for dawn
	for i in range(3):
		var pos = Vector3(randf_range(-15, 15), 0.5, randf_range(-15, 15))
		CinematicEffects.add_materialization_particles(parent, pos, Color(1.0, 0.8, 0.6, 0.3))

# Add noon-specific effects
static func add_noon_effects(parent: Node3D):
	# Add divine light for noon
	var light = OmniLight3D.new()
	light.light_color = Color(1.0, 0.95, 0.8)
	light.light_energy = 1.0
	light.omni_range = 20.0
	light.global_position = Vector3(0, 15, 0)
	parent.add_child(light)
	
	# Animate light
	var tween = parent.create_tween()
	tween.tween_property(light, "light_energy", 0.0, 20.0)
	tween.tween_callback(Callable(light, "queue_free"))

# Add dusk-specific effects
static func add_dusk_effects(parent: Node3D):
	# Add golden particles for dusk
	for i in range(5):
		var pos = Vector3(randf_range(-15, 15), randf_range(1, 5), randf_range(-15, 15))
		CinematicEffects.add_materialization_particles(parent, pos, Color(1.0, 0.8, 0.4, 0.5))

# Handle time of day changes
static func on_time_changed(parent: Node3D, time_of_day, meditation_display, meditations):
	# Update meditation text based on time of day
	var meditation_text = ""
	
	match time_of_day:
		"dawn":
			meditation_text = meditations["dawn"].join("\n")
		"noon":
			meditation_text = meditations["noon"].join("\n")
		"dusk":
			meditation_text = meditations["dusk"].join("\n")
		"night":
			meditation_text = meditations["night"].join("\n")
	
	if meditation_text != "" and meditation_display:
		meditation_display.set_text(meditation_text)
		meditation_display.restart_display()
	
	# Update shader parameters for all materials
	update_shader_parameters(parent, time_of_day)

# Update shader parameters based on time of day
static func update_shader_parameters(parent: Node3D, time_of_day: String):
	# Get all materials in the scene
	var materials = get_all_materials(parent)
	
	# Update shader parameters for each material
	for material in materials:
		if material.has_method("set_shader_parameter"):
			match time_of_day:
				"dawn":
					material.set_shader_parameter("time_of_day", 6.0)
					material.set_shader_parameter("weathering_amount", 0.3)
					material.set_shader_parameter("moss_growth", 0.4)
					material.set_shader_parameter("manuscript_rim", 0.2) # Subtle illumination
					material.set_shader_parameter("divine_light_intensity", 0.3)
				"noon":
					material.set_shader_parameter("time_of_day", 12.0)
					material.set_shader_parameter("weathering_amount", 0.2)
					material.set_shader_parameter("moss_growth", 0.3)
					material.set_shader_parameter("manuscript_rim", 0.1)
					material.set_shader_parameter("divine_light_intensity", 0.1)
				"dusk":
					material.set_shader_parameter("time_of_day", 18.0)
					material.set_shader_parameter("weathering_amount", 0.4)
					material.set_shader_parameter("moss_growth", 0.5)
					material.set_shader_parameter("manuscript_rim", 0.3) # Golden hour effect
					material.set_shader_parameter("divine_light_intensity", 0.4)
				"night":
					material.set_shader_parameter("time_of_day", 0.0)
					material.set_shader_parameter("weathering_amount", 0.5)
					material.set_shader_parameter("moss_growth", 0.2)
					material.set_shader_parameter("is_sacred", true)
					material.set_shader_parameter("manuscript_rim", 0.5) # Strong illumination
					material.set_shader_parameter("divine_light_intensity", 0.6)

# Get all materials in the scene
static func get_all_materials(node: Node) -> Array:
	var materials = []
	
	# Recursively find all mesh instances
	var mesh_instances = find_all_mesh_instances(node)
	
	# Extract materials
	for mesh_instance in mesh_instances:
		var material = mesh_instance.get_surface_override_material(0)
		if material and not materials.has(material):
			materials.append(material)
	
	return materials

# Recursively find all mesh instances
static func find_all_mesh_instances(node: Node) -> Array:
	var result = []
	
	if node is MeshInstance3D:
		result.append(node)
	
	for child in node.get_children():
		result.append_array(find_all_mesh_instances(child))
	
	return result

# Fade in the scene
static func fade_in(parent: Node3D, fade_overlay: ColorRect):
	var tween = parent.create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, 3.0)

# Fade out the scene
static func fade_out(parent: Node3D, fade_overlay: ColorRect):
	var tween = parent.create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 3.0)
