extends Node
class_name SacredGeometryEnhancedHelpers

# Helper functions for the SacredGeometryEnhanced class
# These functions complete the implementation of the sacred geometry system

# Create a vesica piscis shape
static func create_vesica_shape(radius: float, offset: float) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINE_LOOP)
	
	# Calculate intersection points
	var height = sqrt(radius * radius - (offset/2) * (offset/2))
	var segments = 36
	var half_segments = segments / 2
	
	# Create top half from first circle
	for i in range(half_segments + 1):
		var angle = PI/2 - i * PI / half_segments
		var x = cos(angle) * radius - offset/2
		var z = sin(angle) * radius
		immediate_mesh.surface_add_vertex(Vector3(x, 0, z))
	
	# Create bottom half from second circle
	for i in range(half_segments + 1):
		var angle = PI/2 + i * PI / half_segments
		var x = cos(angle) * radius + offset/2
		var z = sin(angle) * radius
		immediate_mesh.surface_add_vertex(Vector3(x, 0, z))
	
	immediate_mesh.surface_end()
	mesh_instance.mesh = immediate_mesh
	
	return mesh_instance

# Create a torus flow line
static func create_torus_flow_line(major_radius: float, minor_radius: float, segments: int, start_angle: float) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	# Create flow line points
	for i in range(segments + 1):
		var angle = i * 2 * PI / segments
		var toroidal_angle = angle * 3 + start_angle  # Multiple wraps around the torus
		
		var x = (major_radius + minor_radius * cos(toroidal_angle)) * cos(angle)
		var y = minor_radius * sin(toroidal_angle)
		var z = (major_radius + minor_radius * cos(toroidal_angle)) * sin(angle)
		
		immediate_mesh.surface_add_vertex(Vector3(x, y, z))
	
	immediate_mesh.surface_end()
	mesh_instance.mesh = immediate_mesh
	
	return mesh_instance

# Apply material to a pattern
static func apply_material(pattern: Node3D, material_type: int, color: Color, secondary_color: Color, emission_intensity: float):
	if not pattern:
		return
	
	# Apply material to all mesh instances in the pattern
	for child in pattern.get_children():
		if child is MeshInstance3D:
			var material = create_material(material_type, color, secondary_color, emission_intensity)
			child.material_override = material
		
		# Recursively apply to children
		if child.get_child_count() > 0:
			apply_material(child, material_type, color, secondary_color, emission_intensity)

# Create material based on type
static func create_material(material_type: int, color: Color, secondary_color: Color, emission_intensity: float) -> Material:
	var material
	
	match material_type:
		0:  # SIMPLE
			material = StandardMaterial3D.new()
			material.albedo_color = color
			
		1:  # GLOWING
			material = StandardMaterial3D.new()
			material.albedo_color = color
			material.emission_enabled = true
			material.emission = color
			material.emission_energy = emission_intensity
			
		2:  # ETHEREAL
			material = StandardMaterial3D.new()
			material.albedo_color = Color(color.r, color.g, color.b, 0.7)
			material.emission_enabled = true
			material.emission = color
			material.emission_energy = emission_intensity * 0.5
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			
		3:  # GOLDEN
			material = StandardMaterial3D.new()
			material.albedo_color = Color(1.0, 0.8, 0.0)
			material.metallic = 1.0
			material.roughness = 0.1
			material.emission_enabled = true
			material.emission = Color(1.0, 0.8, 0.0)
			material.emission_energy = emission_intensity * 0.3
			
		4:  # CRYSTALLINE
			material = StandardMaterial3D.new()
			material.albedo_color = Color(color.r, color.g, color.b, 0.8)
			material.metallic = 0.5
			material.roughness = 0.0
			material.emission_enabled = true
			material.emission = color
			material.emission_energy = emission_intensity * 0.4
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.refraction_enabled = true
			material.refraction_scale = 0.05
			
		5:  # LIGHT_RAYS
			material = StandardMaterial3D.new()
			material.albedo_color = Color(color.r, color.g, color.b, 0.3)
			material.emission_enabled = true
			material.emission = color
			material.emission_energy = emission_intensity * 1.5
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
			
		6:  # ENERGY_FIELD
			material = StandardMaterial3D.new()
			material.albedo_color = Color(color.r, color.g, color.b, 0.2)
			material.emission_enabled = true
			material.emission = color
			material.emission_energy = emission_intensity * 0.8
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			
		7:  # SACRED_LIGHT
			material = StandardMaterial3D.new()
			material.albedo_color = Color(color.r, color.g, color.b, 0.5)
			material.emission_enabled = true
			material.emission = color
			material.emission_energy = emission_intensity * 1.2
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			
		8:  # COSMIC
			material = StandardMaterial3D.new()
			material.albedo_color = Color(0.1, 0.1, 0.2)
			material.emission_enabled = true
			material.emission = color
			material.emission_energy = emission_intensity
			
		9:  # DIVINE
			material = StandardMaterial3D.new()
			material.albedo_color = Color(color.r, color.g, color.b, 0.6)
			material.emission_enabled = true
			material.emission = color
			material.emission_energy = emission_intensity * 2.0
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	return material

# Update pattern colors
static func update_pattern_colors(pattern: Node3D, color: Color, secondary_color: Color, material_type: int, emission_intensity: float):
	if not pattern:
		return
	
	# Update colors for all mesh instances in the pattern
	for child in pattern.get_children():
		if child is MeshInstance3D and child.material_override:
			var material = child.material_override
			
			if material is StandardMaterial3D:
				# Update color based on material type
				match material_type:
					0:  # SIMPLE
						material.albedo_color = color
						
					1:  # GLOWING
						material.albedo_color = color
						material.emission = color
						material.emission_energy = emission_intensity
						
					2:  # ETHEREAL
						material.albedo_color = Color(color.r, color.g, color.b, 0.7)
						material.emission = color
						material.emission_energy = emission_intensity * 0.5
						
					3:  # GOLDEN
						# Golden material keeps its color
						pass
						
					4:  # CRYSTALLINE
						material.albedo_color = Color(color.r, color.g, color.b, 0.8)
						material.emission = color
						material.emission_energy = emission_intensity * 0.4
						
					5:  # LIGHT_RAYS
						material.albedo_color = Color(color.r, color.g, color.b, 0.3)
						material.emission = color
						material.emission_energy = emission_intensity * 1.5
						
					6:  # ENERGY_FIELD
						material.albedo_color = Color(color.r, color.g, color.b, 0.2)
						material.emission = color
						material.emission_energy = emission_intensity * 0.8
						
					7:  # SACRED_LIGHT
						material.albedo_color = Color(color.r, color.g, color.b, 0.5)
						material.emission = color
						material.emission_energy = emission_intensity * 1.2
						
					8:  # COSMIC
						material.emission = color
						material.emission_energy = emission_intensity
						
					9:  # DIVINE
						material.albedo_color = Color(color.r, color.g, color.b, 0.6)
						material.emission = color
						material.emission_energy = emission_intensity * 2.0
		
		# Recursively update children
		if child.get_child_count() > 0:
			update_pattern_colors(child, color, secondary_color, material_type, emission_intensity)

# Start pattern animation
static func start_pattern_animation(pattern: Node3D, animation_type: int, animation_player: AnimationPlayer):
	if not pattern or not animation_player:
		return
	
	# Create animation based on type
	var animation = Animation.new()
	
	match animation_type:
		0:  # ROTATE
			create_rotation_animation(animation, pattern)
			
		1:  # PULSE
			create_pulse_animation(animation, pattern)
			
		2:  # SPIN
			create_spin_animation(animation, pattern)
			
		3:  # UNFOLD
			create_unfold_animation(animation, pattern)
			
		4:  # SHIMMER
			create_shimmer_animation(animation, pattern)
			
		5:  # ORBIT
			create_orbit_animation(animation, pattern)
			
		6:  # BREATHE
			create_breathe_animation(animation, pattern)
			
		7:  # TRANSFORM
			create_transform_animation(animation, pattern)
			
		8:  # ASCEND
			create_ascend_animation(animation, pattern)
			
		9:  # DIVINE_REVEAL
			create_divine_reveal_animation(animation, pattern)
	
	# Add animation to player and play
	var animation_name = "pattern_animation"
	
	if animation_player.has_animation(animation_name):
		animation_player.remove_animation(animation_name)
	
	animation_player.add_animation(animation_name, animation)
	animation_player.play(animation_name)

# Create rotation animation
static func create_rotation_animation(animation: Animation, pattern: Node3D):
	animation.length = 10.0
	animation.loop_mode = Animation.LOOP_LINEAR
	
	# Add rotation track
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, pattern.get_path() + ":rotation:y")
	
	# Add keyframes
	animation.track_insert_key(track_index, 0.0, 0.0)
	animation.track_insert_key(track_index, 10.0, 2 * PI)

# Create pulse animation
static func create_pulse_animation(animation: Animation, pattern: Node3D):
	animation.length = 4.0
	animation.loop_mode = Animation.LOOP_LINEAR
	
	# Add scale track
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, pattern.get_path() + ":scale")
	
	# Add keyframes
	animation.track_insert_key(track_index, 0.0, Vector3.ONE)
	animation.track_insert_key(track_index, 2.0, Vector3.ONE * 1.2)
	animation.track_insert_key(track_index, 4.0, Vector3.ONE)

# Create spin animation
static func create_spin_animation(animation: Animation, pattern: Node3D):
	animation.length = 10.0
	animation.loop_mode = Animation.LOOP_LINEAR
	
	# Add rotation tracks for all axes
	var track_x = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_x, pattern.get_path() + ":rotation:x")
	
	var track_y = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_y, pattern.get_path() + ":rotation:y")
	
	var track_z = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_z, pattern.get_path() + ":rotation:z")
	
	# Add keyframes
	animation.track_insert_key(track_x, 0.0, 0.0)
	animation.track_insert_key(track_x, 10.0, PI)
	
	animation.track_insert_key(track_y, 0.0, 0.0)
	animation.track_insert_key(track_y, 10.0, 2 * PI)
	
	animation.track_insert_key(track_z, 0.0, 0.0)
	animation.track_insert_key(track_z, 10.0, PI / 2)

# Create unfold animation
static func create_unfold_animation(animation: Animation, pattern: Node3D):
	animation.length = 5.0
	animation.loop_mode = Animation.LOOP_NONE
	
	# Add scale track
	var track_scale = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_scale, pattern.get_path() + ":scale")
	
	# Add rotation track
	var track_rot = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_rot, pattern.get_path() + ":rotation:y")
	
	# Add keyframes
	animation.track_insert_key(track_scale, 0.0, Vector3.ONE * 0.1)
	animation.track_insert_key(track_scale, 5.0, Vector3.ONE)
	
	animation.track_insert_key(track_rot, 0.0, 0.0)
	animation.track_insert_key(track_rot, 5.0, 2 * PI)

# Create shimmer animation
static func create_shimmer_animation(animation: Animation, pattern: Node3D):
	animation.length = 3.0
	animation.loop_mode = Animation.LOOP_LINEAR
	
	# Add custom property track for emission energy
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, pattern.get_path() + ":custom_emission_energy")
	
	# Add keyframes
	animation.track_insert_key(track_index, 0.0, 0.5)
	animation.track_insert_key(track_index, 1.5, 1.5)
	animation.track_insert_key(track_index, 3.0, 0.5)

# Create orbit animation
static func create_orbit_animation(animation: Animation, pattern: Node3D):
	animation.length = 20.0
	animation.loop_mode = Animation.LOOP_LINEAR
	
	# Add position track
	var track_pos = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_pos, pattern.get_path() + ":position")
	
	# Add rotation track
	var track_rot = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_rot, pattern.get_path() + ":rotation:y")
	
	# Add keyframes for circular orbit
	for i in range(5):
		var t = i * 5.0
		var angle = i * 2 * PI / 4
		var pos = Vector3(cos(angle) * 2, sin(angle) * 0.5 + 10, sin(angle) * 2)
		
		animation.track_insert_key(track_pos, t, pos)
		animation.track_insert_key(track_rot, t, angle)

# Create breathe animation
static func create_breathe_animation(animation: Animation, pattern: Node3D):
	animation.length = 8.0
	animation.loop_mode = Animation.LOOP_LINEAR
	
	# Add scale track
	var track_scale = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_scale, pattern.get_path() + ":scale")
	
	# Add position track for slight up/down movement
	var track_pos = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_pos, pattern.get_path() + ":position:y")
	
	# Get initial position
	var initial_y = pattern.position.y
	
	# Add keyframes
	animation.track_insert_key(track_scale, 0.0, Vector3.ONE * 0.95)
	animation.track_insert_key(track_scale, 4.0, Vector3.ONE * 1.05)
	animation.track_insert_key(track_scale, 8.0, Vector3.ONE * 0.95)
	
	animation.track_insert_key(track_pos, 0.0, initial_y)
	animation.track_insert_key(track_pos, 4.0, initial_y + 0.2)
	animation.track_insert_key(track_pos, 8.0, initial_y)

# Create transform animation
static func create_transform_animation(animation: Animation, pattern: Node3D):
	animation.length = 10.0
	animation.loop_mode = Animation.LOOP_LINEAR
	
	# Add rotation tracks
	var track_x = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_x, pattern.get_path() + ":rotation:x")
	
	var track_y = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_y, pattern.get_path() + ":rotation:y")
	
	var track_z = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_z, pattern.get_path() + ":rotation:z")
	
	# Add scale track
	var track_scale = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_scale, pattern.get_path() + ":scale")
	
	# Add keyframes
	animation.track_insert_key(track_x, 0.0, 0.0)
	animation.track_insert_key(track_x, 5.0, PI)
	animation.track_insert_key(track_x, 10.0, 0.0)
	
	animation.track_insert_key(track_y, 0.0, 0.0)
	animation.track_insert_key(track_y, 5.0, PI)
	animation.track_insert_key(track_y, 10.0, 2 * PI)
	
	animation.track_insert_key(track_z, 0.0, 0.0)
	animation.track_insert_key(track_z, 5.0, PI / 2)
	animation.track_insert_key(track_z, 10.0, 0.0)
	
	animation.track_insert_key(track_scale, 0.0, Vector3.ONE)
	animation.track_insert_key(track_scale, 2.5, Vector3.ONE * 0.5)
	animation.track_insert_key(track_scale, 5.0, Vector3.ONE * 1.5)
	animation.track_insert_key(track_scale, 7.5, Vector3.ONE * 0.5)
	animation.track_insert_key(track_scale, 10.0, Vector3.ONE)

# Create ascend animation
static func create_ascend_animation(animation: Animation, pattern: Node3D):
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
static func create_divine_reveal_animation(animation: Animation, pattern: Node3D):
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
static func update_pattern_animation(pattern: Node3D, delta: float, animation_type: int, 
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
static func update_pattern_emission(pattern: Node3D, base_intensity: float, pulse_speed: float):
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
static func on_animation_finished(animation_name: String, pattern: Node3D):
	# Handle animation completion
	if animation_name == "pattern_animation":
		# For non-looping animations, we might want to do something here
		pass
