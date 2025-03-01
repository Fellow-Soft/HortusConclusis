extends Node
class_name HortusConclususCinematicConnections

# This file contains the connection functions for the HortusConclususCinematic class
# These functions connect the main cinematic script to the helper functions

# Add mist particles for the introduction stage
static func add_mist_particles(parent: Node3D):
	HortusConclususCinematicHelpers.add_mist_particles(parent)

# Add divine light for the divine manifestation stage
static func add_divine_light(parent: Node3D):
	HortusConclususCinematicHelpers.add_divine_light(parent)

# Add final divine light rays for the conclusion stage
static func add_final_light_rays(parent: Node3D):
	HortusConclususCinematicHelpers.add_final_light_rays(parent)

# Add nature sounds for the garden exploration stage
static func add_nature_sounds(parent: Node3D) -> AudioStreamPlayer:
	return HortusConclususCinematicHelpers.add_nature_sounds(parent)

# Play a random bird sound
static func play_random_bird_sound(parent: Node3D, player: AudioStreamPlayer):
	HortusConclususCinematicHelpers.play_random_bird_sound(parent, player)

# Highlight each garden type with subtle effects
static func highlight_garden_types(parent: Node3D, monastic_garden: Node3D, knot_garden: Node3D, raised_garden: Node3D):
	HortusConclususCinematicHelpers.highlight_garden_types(parent, monastic_garden, knot_garden, raised_garden)

# Highlight a specific garden with a subtle glow effect
static func highlight_garden(parent: Node3D, garden: Node3D):
	HortusConclususCinematicHelpers.highlight_garden(parent, garden)

# Setup day-night effects for the day-night transition stage
static func setup_day_night_effects(parent: Node3D, atmosphere_controller):
	HortusConclususCinematicHelpers.setup_day_night_effects(parent, atmosphere_controller)

# Add dawn-specific effects
static func add_dawn_effects(parent: Node3D):
	HortusConclususCinematicHelpers.add_dawn_effects(parent)

# Add noon-specific effects
static func add_noon_effects(parent: Node3D):
	HortusConclususCinematicHelpers.add_noon_effects(parent)

# Add dusk-specific effects
static func add_dusk_effects(parent: Node3D):
	HortusConclususCinematicHelpers.add_dusk_effects(parent)

# Handle time of day changes
static func on_time_changed(parent: Node3D, time_of_day, meditation_display, meditations):
	HortusConclususCinematicHelpers.on_time_changed(parent, time_of_day, meditation_display, meditations)

# Update shader parameters based on time of day
static func update_shader_parameters(parent: Node3D, time_of_day: String):
	HortusConclususCinematicHelpers.update_shader_parameters(parent, time_of_day)

# Fade in the scene
static func fade_in(parent: Node3D, fade_overlay: ColorRect):
	HortusConclususCinematicHelpers.fade_in(parent, fade_overlay)

# Fade out the scene
static func fade_out(parent: Node3D, fade_overlay: ColorRect):
	HortusConclususCinematicHelpers.fade_out(parent, fade_overlay)

# Activate sacred geometry patterns in sequence
static func activate_sacred_patterns_sequence(parent: Node3D, sacred_geometry_patterns: Array):
	# Show patterns one by one in sequence with proper timing
	for i in range(sacred_geometry_patterns.size()):
		var pattern = sacred_geometry_patterns[i]
		pattern.visible = true
		pattern.scale = Vector3.ZERO
		
		# Create tween for scale and rotation with staggered timing
		var tween = parent.create_tween()
		tween.tween_property(pattern, "scale", Vector3.ONE * 3, 2.0).set_delay(i * 8.0)
		
		# Add rotation animation
		var rotation_tween = parent.create_tween()
		rotation_tween.tween_property(pattern, "rotation:y", PI * 2, 20.0).set_delay(i * 8.0)
		rotation_tween.set_loops()
		
		# Schedule next pattern to become active
		if i < sacred_geometry_patterns.size() - 1:
			var timer = Timer.new()
			timer.wait_time = (i + 1) * 8.0
			timer.one_shot = true
			timer.connect("timeout", Callable(parent, "_activate_next_pattern").bind(i + 1))
			parent.add_child(timer)
			timer.start()

# Update sacred patterns animation
static func update_sacred_patterns(parent: Node3D, active_sacred_pattern: Node3D, delta: float, pattern_rotation_speed: float, pattern_scale_pulse: float, pattern_emission_intensity: float):
	if active_sacred_pattern:
		# Rotate pattern
		active_sacred_pattern.rotate_y(pattern_rotation_speed * delta)
		
		# Pulse scale
		var new_pulse = pattern_scale_pulse + delta * 0.5
		var pulse_scale = 1.0 + sin(new_pulse) * 0.1
		active_sacred_pattern.scale = Vector3.ONE * 3 * pulse_scale
		
		# Update emission intensity
		var new_emission = 0.5 + sin(new_pulse * 2) * 0.3
		update_pattern_emission(active_sacred_pattern, new_emission)
		
		return new_pulse, new_emission
	
	return pattern_scale_pulse, pattern_emission_intensity

# Update pattern emission intensity
static func update_pattern_emission(pattern: Node3D, intensity: float):
	for child in pattern.get_children():
		if child is MeshInstance3D and child.material_override:
			var material = child.material_override
			if material is StandardMaterial3D and material.emission_enabled:
				material.emission_energy = intensity

# Signal handlers for the cinematic demo

# Handle timer timeout
static func on_timer_timeout(parent: Node3D, current_materialization_stage: int, materialization_stages_size: int):
	if current_materialization_stage < materialization_stages_size:
		parent.call("_materialize_next_stage")
	else:
		# All stages complete, move to next sequence
		parent.call("_update_sequence_stage")

# Handle meditation display completion
static func on_meditation_completed(parent: Node3D):
	# Schedule next meditation or effect
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.connect("timeout", Callable(parent, "_update_meditation"))
	parent.add_child(timer)
	timer.start()

# Update meditation text
static func update_meditation(parent: Node3D, meditation_display, current_meditation: String, meditations: Dictionary):
	# Cycle through meditation texts
	var meditation_keys = meditations.keys()
	var current_index = meditation_keys.find(current_meditation)
	var next_index = (current_index + 1) % meditation_keys.size()
	var next_meditation = meditation_keys[next_index]
	
	# Set new meditation text
	meditation_display.set_text(meditations[next_meditation].join("\n"))
	meditation_display.restart_display()
	
	return next_meditation
