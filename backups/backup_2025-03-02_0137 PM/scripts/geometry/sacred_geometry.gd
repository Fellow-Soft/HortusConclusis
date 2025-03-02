# Create ascend animation
func create_ascend_animation(animation: Animation, pattern: Node3D):
	animation.length = 15.0
	animation.loop_mode = Animation.LOOP_NONE
	
	# Add position track
	var track_pos = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_pos, pattern.get_path() + ":position:y")
	
	# Add scale track
	var track_scale = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_scale, pattern.get_path() + ":scale")
	
	# Add rotation track
	var track_rot = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_rot, pattern.get_path() + ":rotation:y")
	
	# Get initial position
	var initial_y = pattern.position.y
	
	# Add keyframes
	animation.track_insert_key(track_pos, 0.0, initial_y)
	animation.track_insert_key(track_pos, 15.0, initial_y + 10.0)
	
	animation.track_insert_key(track_scale, 0.0, Vector3.ONE)
	animation.track_insert_key(track_scale, 7.5, Vector3.ONE * 1.5)
	animation.track_insert_key(track_scale, 15.0, Vector3.ONE * 0.5)
	
	animation.track_insert_key(track_rot, 0.0, 0.0)
	animation.track_insert_key(track_rot, 15.0, 2 * PI)

# Create divine reveal animation
func create_divine_reveal_animation(animation: Animation, pattern: Node3D):
	animation.length = 20.0
	animation.loop_mode = Animation.LOOP_NONE
	
	# Add position track
	var track_pos = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_pos, pattern.get_path() + ":position:y")
	
	# Add scale track
	var track_scale = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_scale, pattern.get_path() + ":scale")
	
	# Add rotation track
	var track_rot = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_rot, pattern.get_path() + ":rotation:y")
	
	# Add custom property track for emission energy
	var track_emission = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_emission, pattern.get_path() + ":custom_emission_energy")
	
	# Get initial position
	var initial_y = pattern.position.y
	
	# Add keyframes
	animation.track_insert_key(track_pos, 0.0, initial_y - 5.0)
	animation.track_insert_key(track_pos, 10.0, initial_y)
	animation.track_insert_key(track_pos, 20.0, initial_y + 2.0)
	
	animation.track_insert_key(track_scale, 0.0, Vector3.ONE * 0.1)
	animation.track_insert_key(track_scale, 10.0, Vector3.ONE)
	animation.track_insert_key(track_scale, 15.0, Vector3.ONE * 1.2)
	animation.track_insert_key(track_scale, 20.0, Vector3.ONE)
	
	animation.track_insert_key(track_rot, 0.0, 0.0)
	animation.track_insert_key(track_rot, 20.0, PI * 4)
	
	animation.track_insert_key(track_emission, 0.0, 0.5)
	animation.track_insert_key(track_emission, 10.0, 1.0)
	animation.track_insert_key(track_emission, 15.0, 2.0)
	animation.track_insert_key(track_emission, 20.0, 1.5)

# Update pattern animation in process
func update_pattern_animation(pattern: Node3D, delta: float, animation_type: int, 
							pattern_rotation_speed: float, pattern_pulse_speed: float, 
							pattern_pulse_amplitude: float, pattern_emission_intensity: float):
	if not pattern:
		return
	
	# Update based on animation type
	match animation_type:
		0:  # ROTATE
			pattern.rotate_y(pattern_rotation_speed * delta)
			
		1:  # PULSE
			var pulse = (sin(Time.get_ticks_msec() * 0.001 * pattern_pulse_speed) + 1.0) / 2.0
			var scale_factor = 1.0 + pulse * pattern_pulse_amplitude
			pattern.scale = Vector3.ONE * scale_factor
			
		2:  # SPIN
			pattern.rotate_x(pattern_rotation_speed * 0.3 * delta)
			pattern.rotate_y(pattern_rotation_speed * delta)
			pattern.rotate_z(pattern_rotation_speed * 0.2 * delta)
			
		3:  # UNFOLD
			# Handled by animation player
			pass
			
		4:  # SHIMMER
			update_pattern_emission(pattern, pattern_emission_intensity, pattern_pulse_speed)
			
		5:  # ORBIT
			# Handled by animation player
			pass
			
		6:  # BREATHE
			var breath = (sin(Time.get_ticks_msec() * 0.0005) + 1.0) / 2.0
			var scale_factor = 0.95 + breath * 0.1
			pattern.scale = Vector3.ONE * scale_factor
			pattern.position.y += sin(Time.get_ticks_msec() * 0.0005) * 0.01
			
		7:  # TRANSFORM
			# Handled by animation player
			pass
			
		8:  # ASCEND
			# Handled by animation player
			pass
			
		9:  # DIVINE_REVEAL
			# Handled by animation player
			pass

# Update pattern emission intensity
func update_pattern_emission(pattern: Node3D, base_intensity: float, pulse_speed: float):
	if not pattern:
		return
	
	# Calculate pulsing emission intensity
	var pulse = (sin(Time.get_ticks_msec() * 0.001 * pulse_speed) + 1.0) / 2.0
	var intensity = base_intensity * (0.5 + pulse * 0.5)
	
	# Update emission for all mesh instances
	for child in pattern.get_children():
		if child is MeshInstance3D and child.material_override:
			var material = child.material_override
			
			if material is StandardMaterial3D and material.emission_enabled:
				material.emission_energy = intensity
		
		# Recursively update children
		if child.get_child_count() > 0:
			update_pattern_emission(child, base_intensity, pulse_speed)

# Animation finished callback
func on_animation_finished(animation_name: String, pattern: Node3D):
	# Handle animation completion
	if animation_name == "pattern_animation":
		# For non-looping animations, we might want to do something here
		pass
