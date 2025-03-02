extends Node3D

# References to garden nodes
@onready var monastic_garden = $MonasticGarden
@onready var knot_garden = $KnotGarden
@onready var raised_garden = $RaisedGarden

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize each garden with its respective layout
	monastic_garden.create_herb_garden("monastic", Vector3.ZERO)
	knot_garden.create_herb_garden("knot", Vector3.ZERO)
	raised_garden.create_herb_garden("raised", Vector3.ZERO)
	
	# Connect signals for interaction
	_connect_signals()
	
	# Add tooltips to show plant information
	_setup_tooltips()

# Connect necessary signals
func _connect_signals():
	# Example: Connect to time of day changes to update lighting
	if has_node("/root/TimeSystem"):
		get_node("/root/TimeSystem").connect("time_changed", Callable(self, "_on_time_changed"))

# Setup tooltips for plants
func _setup_tooltips():
	for garden in [monastic_garden, knot_garden, raised_garden]:
		var herbs = garden.get_node_or_null("Herbs")
		if herbs:
			for herb in herbs.get_children():
				_add_herb_tooltip(herb)

# Add tooltip to an herb
func _add_herb_tooltip(herb: Node3D):
	# Get herb data from the garden system
	var herb_name = herb.name.to_lower()
	var tooltip_text = ""
	
	# Find herb category and data
	for category in monastic_garden.HERB_CATEGORIES:
		var plants = monastic_garden.HERB_CATEGORIES[category]["plants"]
		if plants.has(herb_name):
			var data = plants[herb_name]
			tooltip_text = "%s\n%s\n%s" % [
				herb_name.capitalize(),
				data["latin"],
				", ".join(data["properties"])
			]
			break
	
	if tooltip_text.is_empty():
		return
	
	# Create tooltip
	var tooltip = Label.new()
	tooltip.text = tooltip_text
	tooltip.visible = false
	tooltip.add_theme_font_size_override("font_size", 14)
	tooltip.add_theme_stylebox_override("normal", _create_tooltip_style())
	
	# Add to UI layer
	$UI.add_child(tooltip)
	
	# Store reference to update position
	herb.set_meta("tooltip", tooltip)

# Create tooltip style
func _create_tooltip_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style

# Update tooltips based on camera position
func _process(_delta):
	var camera = get_node("Camera3D")
	if not camera:
		return
	
	for garden in [monastic_garden, knot_garden, raised_garden]:
		var herbs = garden.get_node_or_null("Herbs")
		if herbs:
			for herb in herbs.get_children():
				_update_herb_tooltip(herb, camera)

# Update individual herb tooltip
func _update_herb_tooltip(herb: Node3D, camera: Camera3D):
	var tooltip = herb.get_meta("tooltip", null)
	if not tooltip:
		return
	
	# Get screen position of herb
	var herb_pos = herb.global_position
	var screen_pos = camera.unproject_position(herb_pos)
	
	# Check if herb is in front of camera
	var is_in_front = camera.is_position_in_frustum(herb_pos)
	
	# Update tooltip visibility and position
	if is_in_front:
		tooltip.visible = true
		tooltip.position = Vector2(screen_pos.x, screen_pos.y) - Vector2(tooltip.size.x/2, tooltip.size.y + 30)
	else:
		tooltip.visible = false

# Handle time of day changes
func _on_time_changed(hour: float):
	# Update lighting based on time of day
	var light = get_node("DirectionalLight3D")
	if not light:
		return
	
	# Adjust light angle and color based on time
	var angle = (hour - 6) * PI / 12  # Rotate from east to west
	light.rotation.x = -cos(angle)
	light.rotation.z = sin(angle)
	
	# Adjust light color and intensity
	var intensity = 1.0
	var color = Color(1, 0.95, 0.9)
	
	if hour < 6 or hour > 18:  # Night
		intensity = 0.2
		color = Color(0.6, 0.6, 1.0)
	elif hour < 8 or hour > 16:  # Dawn/Dusk
		intensity = 0.6
		color = Color(1.0, 0.8, 0.6)
	
	light.light_energy = intensity
	light.light_color = color
