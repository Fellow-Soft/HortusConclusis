extends Node
class_name MedievalShaderCreator

# This class provides backward compatibility with the original medieval shader system
# while also integrating with the new MedievalShaderPack for more advanced capabilities

# Create a medieval-style shader that mimics illuminated manuscript aesthetics
static func create_medieval_material(base_color: Color, gold_accent: bool = false, texture_scale: float = 1.0) -> ShaderMaterial:
	# Use the new shader pack if available
	if ClassDB.class_exists("MedievalShaderPack"):
		var material = MedievalShaderPack.create_medieval_shader_material("illuminated", base_color)
		var intensity = 0.7 if gold_accent else 0.0
		material.set_shader_parameter("gold_accent_intensity", intensity)
		material.set_shader_parameter("use_gold_leaf", gold_accent)
		return material
	
	# Fall back to the original implementation if the new system isn't available
	var material = ShaderMaterial.new()
	material.shader = _create_medieval_shader()
	
	# Set shader parameters
	material.set_shader_parameter("base_color", base_color)
	material.set_shader_parameter("gold_accent", gold_accent)
	material.set_shader_parameter("texture_scale", texture_scale)
	material.set_shader_parameter("parchment_texture", _create_parchment_texture())
	material.set_shader_parameter("noise_texture", _create_noise_texture())
	
	return material

# Create the shader code
static func _create_medieval_shader() -> Shader:
	var shader = Shader.new()
	
	shader.code = """
	shader_type spatial;
	
	// Parameters
	uniform vec4 base_color : source_color = vec4(0.8, 0.7, 0.5, 1.0);
	uniform bool gold_accent = false;
	uniform float texture_scale = 1.0;
	uniform sampler2D parchment_texture;
	uniform sampler2D noise_texture;
	
	// Constants
	const float OUTLINE_THICKNESS = 0.02;
	const float GOLD_INTENSITY = 0.8;
	const float PARCHMENT_INTENSITY = 0.3;
	const float BRUSH_STROKE_INTENSITY = 0.15;
	
	void fragment() {
		// Sample textures
		vec2 scaled_uv = UV * texture_scale;
		vec4 parchment = texture(parchment_texture, scaled_uv);
		vec4 noise = texture(noise_texture, scaled_uv * 2.0);
		
		// Calculate rim effect for outline
		float rim = 1.0 - dot(NORMAL, VIEW);
		float outline = smoothstep(0.5, 0.8, rim);
		
		// Base color with parchment texture
		vec3 color = mix(base_color.rgb, parchment.rgb, PARCHMENT_INTENSITY);
		
		// Add brush stroke effect
		float brush_noise = noise.r * 2.0 - 1.0;
		color = mix(color, color * (1.0 + brush_noise * 0.2), BRUSH_STROKE_INTENSITY);
		
		// Add gold accent if enabled
		if (gold_accent) {
			// Create gold color based on view angle for a metallic effect
			vec3 gold_color = mix(vec3(0.8, 0.7, 0.2), vec3(1.0, 0.9, 0.1), pow(rim, 2.0));
			
			// Apply gold to highlights
			float gold_mask = smoothstep(0.4, 0.6, noise.g);
			color = mix(color, gold_color, gold_mask * GOLD_INTENSITY);
		}
		
		// Apply outline
		color = mix(color, vec3(0.0, 0.0, 0.0), outline * OUTLINE_THICKNESS);
		
		// Output
		ALBEDO = color;
		
		// Metallic and roughness
		if (gold_accent) {
			METALLIC = 0.8;
			ROUGHNESS = 0.2;
		} else {
			METALLIC = 0.0;
			ROUGHNESS = 0.9;
		}
		
		// Add some subtle specular
		SPECULAR = 0.1;
	}
	"""
	
	return shader

# Create a procedural parchment texture
static func _create_parchment_texture() -> Texture2D:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.9, 0.85, 0.7, 1.0))
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 12345
	
	# Add noise to create parchment texture
	for y in range(256):
		for x in range(256):
			var noise_val = rng.randf_range(0.85, 1.0)
			var color = Color(
				0.9 * noise_val, 
				0.85 * noise_val, 
				0.7 * noise_val, 
				1.0
			)
			img.set_pixel(x, y, color)
	
	# Add some darker spots randomly
	for i in range(100):
		var x = rng.randi_range(0, 255)
		var y = rng.randi_range(0, 255)
		var radius = rng.randi_range(1, 5)
		var darkness = rng.randf_range(0.7, 0.9)
		
		for dx in range(-radius, radius + 1):
			for dy in range(-radius, radius + 1):
				var dist = sqrt(dx * dx + dy * dy)
				if dist <= radius and x + dx >= 0 and x + dx < 256 and y + dy >= 0 and y + dy < 256:
					var current_color = img.get_pixel(x + dx, y + dy)
					var factor = 1.0 - (dist / radius) * (1.0 - darkness)
					var new_color = Color(
						current_color.r * factor,
						current_color.g * factor,
						current_color.b * factor,
						1.0
					)
					img.set_pixel(x + dx, y + dy, new_color)
	
	var texture = ImageTexture.create_from_image(img)
	return texture

# Create a procedural noise texture
static func _create_noise_texture() -> Texture2D:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.5, 0.5, 0.5, 1.0))
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 67890
	
	# Generate noise
	for y in range(256):
		for x in range(256):
			var noise1 = rng.randf()
			var noise2 = rng.randf()
			var color = Color(noise1, noise2, rng.randf(), 1.0)
			img.set_pixel(x, y, color)
	
	var texture = ImageTexture.create_from_image(img)
	return texture

# Create a medieval-style material for plants
static func create_plant_material(hue: float = 0.3, saturation: float = 0.6, value: float = 0.7) -> ShaderMaterial:
	var base_color = Color.from_hsv(hue, saturation, value)
	
	# Use the new shader pack if available
	if ClassDB.class_exists("MedievalShaderPack"):
		var material = MedievalShaderPack.create_medieval_shader_material("illuminated", base_color)
		material.set_shader_parameter("illumination_intensity", 0.3)
		return material
	
	return create_medieval_material(base_color, false, 2.0)

# Create a medieval-style material for stone
static func create_stone_material(light_stone: bool = false) -> ShaderMaterial:
	var base_color
	if light_stone:
		base_color = Color(0.8, 0.8, 0.75)
	else:
		base_color = Color(0.5, 0.5, 0.5)
	
	# Use the new shader pack if available
	if ClassDB.class_exists("MedievalShaderPack"):
		var material = MedievalShaderPack.create_medieval_shader_material("stone_wall", base_color)
		material.set_shader_parameter("moss_amount", 0.2)
		return material
	
	return create_medieval_material(base_color, false, 3.0)

# Create a medieval-style material for wood
static func create_wood_material(dark_wood: bool = false) -> ShaderMaterial:
	var base_color
	if dark_wood:
		base_color = Color(0.3, 0.2, 0.1)
	else:
		base_color = Color(0.6, 0.4, 0.2)
	
	# Use the new shader pack if available
	if ClassDB.class_exists("MedievalShaderPack"):
		var material = MedievalShaderPack.create_medieval_shader_material("wood", base_color)
		material.set_shader_parameter("grain_contrast", 0.6)
		material.set_shader_parameter("weathering_amount", 0.3)
		return material
	
	return create_medieval_material(base_color, false, 2.0)

# Create a medieval-style material for water
static func create_water_material() -> ShaderMaterial:
	# Use the new shader pack if available
	if ClassDB.class_exists("MedievalShaderPack"):
		var material = MedievalShaderPack.create_medieval_shader_material("water")
		material.set_shader_parameter("time_scale", 0.5)
		material.set_shader_parameter("ripple_strength", 0.2)
		return material
	
	# Fall back to the original implementation
	var material = ShaderMaterial.new()
	material.shader = _create_water_shader()
	
	# Set shader parameters
	material.set_shader_parameter("water_color", Color(0.1, 0.3, 0.5, 0.8))
	material.set_shader_parameter("ripple_speed", 0.5)
	material.set_shader_parameter("ripple_strength", 0.02)
	material.set_shader_parameter("noise_texture", _create_noise_texture())
	
	return material

# Create a water shader
static func _create_water_shader() -> Shader:
	var shader = Shader.new()
	
	shader.code = """
	shader_type spatial;
	
	// Parameters
	uniform vec4 water_color : source_color = vec4(0.1, 0.3, 0.5, 0.8);
	uniform float ripple_speed = 0.5;
	uniform float ripple_strength = 0.02;
	uniform sampler2D noise_texture;
	
	void vertex() {
		// Add gentle ripple effect
		vec2 scaled_uv = UV * 3.0;
		float time = TIME * ripple_speed;
		
		// Sample noise for ripple
		float noise1 = texture(noise_texture, scaled_uv + vec2(time * 0.1, time * 0.2)).r;
		float noise2 = texture(noise_texture, scaled_uv * 1.5 - vec2(time * 0.15, time * 0.1)).g;
		
		// Apply ripple to vertex
		VERTEX.y += (noise1 - 0.5) * ripple_strength;
		VERTEX.y += (noise2 - 0.5) * ripple_strength * 0.5;
	}
	
	void fragment() {
		// Sample noise for water texture
		vec2 scaled_uv = UV * 2.0;
		float time = TIME * ripple_speed;
		
		vec2 ripple_uv = scaled_uv + vec2(sin(time * 0.1), cos(time * 0.2)) * 0.1;
		float noise = texture(noise_texture, ripple_uv).b;
		
		// Create water color with ripple effect
		vec3 shallow = water_color.rgb * 1.2;
		vec3 deep = water_color.rgb * 0.8;
		vec3 color = mix(deep, shallow, noise);
		
		// Add highlight
		float highlight = pow(noise, 8.0) * 0.5;
		color += vec3(highlight);
		
		// Output
		ALBEDO = color;
		ALPHA = water_color.a;
		
		// Water properties
		METALLIC = 0.1;
		ROUGHNESS = 0.2;
		SPECULAR = 0.5;
	}
	"""
	
	return shader

# Create a medieval-style material for gold/metal
static func create_gold_material() -> ShaderMaterial:
	var base_color = Color(0.9, 0.8, 0.4)
	
	# Use the new shader pack if available
	if ClassDB.class_exists("MedievalShaderPack"):
		var material = MedievalShaderPack.create_medieval_shader_material("illuminated", base_color)
		material.set_shader_parameter("gold_accent_intensity", 1.0)
		material.set_shader_parameter("use_gold_leaf", true)
		return material
	
	return create_medieval_material(base_color, true, 1.0)

# Create a medieval-style material for fabric/cloth
static func create_fabric_material(hue: float = 0.0, saturation: float = 0.8, value: float = 0.7) -> ShaderMaterial:
	var base_color = Color.from_hsv(hue, saturation, value)
	
	# Use the new shader pack if available
	if ClassDB.class_exists("MedievalShaderPack"):
		var material = MedievalShaderPack.create_medieval_shader_material("fabric", base_color)
		material.set_shader_parameter("pattern_intensity", 0.7)
		
		# Use gold thread for royal fabrics (purple/red hues)
		if (hue >= 0.7 and hue <= 0.9) or (hue >= 0.0 and hue <= 0.05):
			material.set_shader_parameter("use_gold_thread", true)
		
		return material
	
	var material = create_medieval_material(base_color, false, 4.0)
	return material

# Create a medieval-style material for parchment
static func create_parchment_material(aged: bool = false) -> ShaderMaterial:
	var base_color = Color(0.9, 0.85, 0.7)
	
	# Use the new shader pack if available
	if ClassDB.class_exists("MedievalShaderPack"):
		var material = MedievalShaderPack.create_medieval_shader_material("parchment", base_color)
		var age_amount = 0.7 if aged else 0.2
		material.set_shader_parameter("age_amount", age_amount)
		return material
	
	return create_medieval_material(base_color, false, 1.0)

# Create a medieval-style material for stained glass
static func create_stained_glass_material(hue: float = 0.6) -> ShaderMaterial:
	# Use the new shader pack if available
	if ClassDB.class_exists("MedievalShaderPack"):
		var material = MedievalShaderPack.create_medieval_shader_material("stained_glass")
		
		# Set glass color based on hue
		var glass_color = Color.from_hsv(hue, 0.8, 0.8, 0.7)
		material.set_shader_parameter("glass_color", glass_color)
		
		return material
	
	# Fall back to a simple transparent colored material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.from_hsv(hue, 0.8, 0.8, 0.7)
	material.metallic = 0.1
	material.roughness = 0.1
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	return material
