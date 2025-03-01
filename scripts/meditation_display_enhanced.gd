extends Control
class_name MeditationDisplayEnhanced

# Enhanced meditation display for the Hortus Conclusus cinematic demo
# This script provides more sophisticated text animations and visual effects

# Text animation types
enum AnimationType {
	FADE,           # Simple fade in/out
	TYPEWRITER,     # Character-by-character reveal
	WORD_BY_WORD,   # Word-by-word reveal
	SCROLL,         # Scrolling text
	WAVE,           # Wave effect on text
	BREATHE,        # Text that pulses like breathing
	GLOW,           # Glowing text effect
	SHIMMER,        # Shimmering text effect
	SACRED,         # Sacred geometry-inspired text reveal
	MEDIEVAL        # Medieval manuscript-inspired reveal
}

# Text style presets
enum TextStyle {
	SIMPLE,         # Clean, simple text
	PARCHMENT,      # Parchment-like appearance
	ILLUMINATED,    # Illuminated manuscript style
	SACRED_TEXT,    # Sacred text style
	MYSTICAL,       # Mystical, ethereal style
	MONASTIC,       # Monastic, austere style
	NATURE,         # Nature-inspired style
	CELESTIAL       # Celestial, cosmic style
}

# UI components
@onready var text_label = $TextLabel
@onready var background_panel = $BackgroundPanel
@onready var glow_effect = $GlowEffect
@onready var particle_effect = $ParticleEffect
@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer

# Display parameters
var current_text: String = ""
var current_lines: Array = []
var current_animation_type: AnimationType = AnimationType.TYPEWRITER
var current_style: TextStyle = TextStyle.PARCHMENT
var fade_in_duration: float = 2.0
var display_duration: float = 20.0
var fade_out_duration: float = 2.0
var letter_reveal_speed: float = 0.08
var word_reveal_speed: float = 0.3
var line_reveal_speed: float = 1.0
var glow_intensity: float = 1.5
var glow_color: Color = Color(1.0, 0.9, 0.7, 0.8)
var glow_pulse_speed: float = 0.3
var background_color: Color = Color(0.1, 0.1, 0.15, 0.7)
var font_color: Color = Color(0.95, 0.9, 0.8)
var font_size: int = 24
var font_shadow_enabled: bool = true
var font_shadow_color: Color = Color(0.0, 0.0, 0.0, 0.5)
var font_shadow_offset: Vector2 = Vector2(2, 2)
var current_char_index: int = 0
var current_word_index: int = 0
var current_line_index: int = 0
var is_displaying: bool = false
var is_paused: bool = false
var words: Array = []
var display_complete: bool = false
var time_of_day: String = "dawn"
var sacred_geometry_enabled: bool = false
var sacred_geometry_node: Node2D

# Signals
signal display_started
signal display_completed
signal text_fully_revealed
signal animation_step_completed

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize UI components if not already set
	if not text_label:
		text_label = Label.new()
		text_label.name = "TextLabel"
		text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		add_child(text_label)
	
	if not background_panel:
		background_panel = Panel.new()
		background_panel.name = "BackgroundPanel"
		background_panel.show_behind_parent = true
		add_child(background_panel)
		move_child(background_panel, 0)
	
	if not glow_effect:
		glow_effect = ColorRect.new()
		glow_effect.name = "GlowEffect"
		glow_effect.show_behind_parent = true
		glow_effect.color = Color(1.0, 0.9, 0.7, 0.0)  # Start with transparent
		add_child(glow_effect)
		move_child(glow_effect, 1)
	
	if not animation_player:
		animation_player = AnimationPlayer.new()
		animation_player.name = "AnimationPlayer"
		add_child(animation_player)
	
	if not timer:
		timer = Timer.new()
		timer.name = "Timer"
		timer.one_shot = true
		add_child(timer)
	
	# Connect signals
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	
	# Set up initial style
	_apply_style(current_style)
	
	# Create sacred geometry node
	_create_sacred_geometry()
	
	# Hide initially
	modulate.a = 0.0

# Set the text to display
func set_text(text: String):
	current_text = text
	current_lines = text.split("\n")
	words = []
	
	# Split text into words for word-by-word animation
	for line in current_lines:
		words.append_array(line.split(" "))

# Set the animation type
func set_animation_type(type: AnimationType):
	current_animation_type = type

# Set the text style
func set_style(style: TextStyle):
	current_style = style
	_apply_style(style)

# Set display durations
func set_durations(fade_in: float, display: float, fade_out: float):
	fade_in_duration = fade_in
	display_duration = display
	fade_out_duration = fade_out

# Set letter reveal speed for typewriter effect
func set_letter_reveal_speed(speed: float):
	letter_reveal_speed = speed

# Set word reveal speed for word-by-word effect
func set_word_reveal_speed(speed: float):
	word_reveal_speed = speed

# Set line reveal speed for scrolling effect
func set_line_reveal_speed(speed: float):
	line_reveal_speed = speed

# Set glow parameters
func set_glow_parameters(intensity: float, pulse_speed: float, alpha: float):
	glow_intensity = intensity
	glow_pulse_speed = pulse_speed
	glow_color.a = alpha

# Set font color
func set_font_color(color: Color):
	font_color = color
	if text_label:
		text_label.add_theme_color_override("font_color", color)

# Set background color
func set_background_color(color: Color):
	background_color = color
	if background_panel:
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = color
		style_box.corner_radius_top_left = 10
		style_box.corner_radius_top_right = 10
		style_box.corner_radius_bottom_left = 10
		style_box.corner_radius_bottom_right = 10
		background_panel.add_theme_stylebox_override("panel", style_box)

# Set font size
func set_font_size(size: int):
	font_size = size
	if text_label:
		text_label.add_theme_font_size_override("font_size", size)

# Enable or disable sacred geometry background
func set_sacred_geometry(enabled: bool):
	sacred_geometry_enabled = enabled
	if sacred_geometry_node:
		sacred_geometry_node.visible = enabled

# Set time of day to adjust appearance
func set_time_of_day(time: String):
	time_of_day = time
	
	# Adjust colors based on time of day
	match time:
		"dawn":
			glow_color = Color(1.0, 0.8, 0.6, 0.8)
			font_color = Color(0.95, 0.9, 0.8)
		"noon":
			glow_color = Color(1.0, 0.95, 0.9, 0.8)
			font_color = Color(0.2, 0.2, 0.2)
		"dusk":
			glow_color = Color(0.9, 0.7, 0.5, 0.8)
			font_color = Color(0.95, 0.9, 0.8)
		"night":
			glow_color = Color(0.6, 0.7, 0.9, 0.8)
			font_color = Color(0.9, 0.95, 1.0)
	
	set_font_color(font_color)
	set_glow_parameters(glow_intensity, glow_pulse_speed, glow_color.a)

# Start displaying the text
func start_display():
	if current_text.is_empty():
		return
	
	# Reset state
	current_char_index = 0
	current_word_index = 0
	current_line_index = 0
	display_complete = false
	is_displaying = true
	
	# Show the control
	visible = true
	
	# Start with fade in
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_in_duration)
	tween.tween_callback(Callable(self, "_start_text_animation"))
	
	emit_signal("display_started")

# Restart the display with the current text
func restart_display():
	# If currently displaying, stop first
	if is_displaying:
		_stop_display()
	
	# Start display again
	start_display()

# Pause the display
func pause_display():
	is_paused = true
	
	if timer.is_stopped() == false:
		timer.paused = true
	
	if animation_player.is_playing():
		animation_player.pause()

# Resume the display
func resume_display():
	is_paused = false
	
	if timer.is_stopped() == false:
		timer.paused = false
	
	if animation_player.is_playing():
		animation_player.play()

# Stop the display
func _stop_display():
	is_displaying = false
	is_paused = false
	
	if timer.is_stopped() == false:
		timer.stop()
	
	if animation_player.is_playing():
		animation_player.stop()

# Complete the display immediately
func complete_display():
	_stop_display()
	
	# Show full text
	if text_label:
		text_label.text = current_text
	
	# Start fade out after display duration
	timer.wait_time = display_duration
	timer.start()

# Process function for continuous effects
func _process(delta):
	if not is_displaying or is_paused:
		return
	
	# Update glow effect
	_update_glow_effect(delta)
	
	# Update sacred geometry if enabled
	if sacred_geometry_enabled and sacred_geometry_node:
		_update_sacred_geometry(delta)

# Start the text animation based on selected type
func _start_text_animation():
	match current_animation_type:
		AnimationType.FADE:
			_animate_text_fade()
		AnimationType.TYPEWRITER:
			_animate_text_typewriter()
		AnimationType.WORD_BY_WORD:
			_animate_text_word_by_word()
		AnimationType.SCROLL:
			_animate_text_scroll()
		AnimationType.WAVE:
			_animate_text_wave()
		AnimationType.BREATHE:
			_animate_text_breathe()
		AnimationType.GLOW:
			_animate_text_glow()
		AnimationType.SHIMMER:
			_animate_text_shimmer()
		AnimationType.SACRED:
			_animate_text_sacred()
		AnimationType.MEDIEVAL:
			_animate_text_medieval()

# Animate text with simple fade
func _animate_text_fade():
	if text_label:
		text_label.text = current_text
		text_label.modulate.a = 0.0
		
		var tween = create_tween()
		tween.tween_property(text_label, "modulate:a", 1.0, fade_in_duration)
		tween.tween_callback(Callable(self, "_on_text_fully_revealed"))

# Animate text with typewriter effect
func _animate_text_typewriter():
	if text_label:
		text_label.text = ""
		current_char_index = 0
		
		# Start revealing characters one by one
		timer.wait_time = letter_reveal_speed
		timer.start()

# Animate text with word-by-word effect
func _animate_text_word_by_word():
	if text_label:
		text_label.text = ""
		current_word_index = 0
		
		# Start revealing words one by one
		timer.wait_time = word_reveal_speed
		timer.start()

# Animate text with scrolling effect
func _animate_text_scroll():
	if text_label:
		text_label.text = ""
		current_line_index = 0
		
		# Start revealing lines one by one
		timer.wait_time = line_reveal_speed
		timer.start()

# Animate text with wave effect
func _animate_text_wave():
	if text_label:
		text_label.text = current_text
		
		# Create wave animation
		var animation = Animation.new()
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_index, ".:custom_effects/wave_offset")
		animation.length = 2.0
		
		# Add wave keyframes
		for i in range(21):
			var time = i * 0.1
			var value = sin(time * PI) * 5.0
			animation.track_insert_key(track_index, time, value)
		
		animation.loop_mode = Animation.LOOP_LINEAR
		
		# Add animation to player
		animation_player.add_animation("wave", animation)
		animation_player.play("wave")
		
		# Signal that text is fully revealed
		_on_text_fully_revealed()

# Animate text with breathing effect
func _animate_text_breathe():
	if text_label:
		text_label.text = current_text
		
		# Create breathing animation
		var animation = Animation.new()
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_index, ".:scale")
		animation.length = 4.0
		
		# Add breathing keyframes
		animation.track_insert_key(track_index, 0.0, Vector2(1.0, 1.0))
		animation.track_insert_key(track_index, 2.0, Vector2(1.05, 1.05))
		animation.track_insert_key(track_index, 4.0, Vector2(1.0, 1.0))
		
		animation.loop_mode = Animation.LOOP_LINEAR
		
		# Add animation to player
		animation_player.add_animation("breathe", animation)
		animation_player.play("breathe")
		
		# Signal that text is fully revealed
		_on_text_fully_revealed()

# Animate text with glow effect
func _animate_text_glow():
	if text_label:
		text_label.text = current_text
		
		# Create glow animation
		var animation = Animation.new()
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_index, ".:custom_effects/glow_intensity")
		animation.length = 3.0
		
		# Add glow keyframes
		animation.track_insert_key(track_index, 0.0, 0.5)
		animation.track_insert_key(track_index, 1.5, 1.5)
		animation.track_insert_key(track_index, 3.0, 0.5)
		
		animation.loop_mode = Animation.LOOP_LINEAR
		
		# Add animation to player
		animation_player.add_animation("glow", animation)
		animation_player.play("glow")
		
		# Signal that text is fully revealed
		_on_text_fully_revealed()

# Animate text with shimmer effect
func _animate_text_shimmer():
	if text_label:
		text_label.text = current_text
		
		# Create shimmer animation
		var animation = Animation.new()
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_index, ".:custom_effects/shimmer_progress")
		animation.length = 3.0
		
		# Add shimmer keyframes
		animation.track_insert_key(track_index, 0.0, 0.0)
		animation.track_insert_key(track_index, 3.0, 1.0)
		
		animation.loop_mode = Animation.LOOP_LINEAR
		
		# Add animation to player
		animation_player.add_animation("shimmer", animation)
		animation_player.play("shimmer")
		
		# Signal that text is fully revealed
		_on_text_fully_revealed()

# Animate text with sacred geometry-inspired reveal
func _animate_text_sacred():
	if text_label:
		text_label.text = current_text
		text_label.modulate.a = 0.0
		
		# Enable sacred geometry
		set_sacred_geometry(true)
		
		# Create sacred reveal animation
		var tween = create_tween()
		tween.tween_property(text_label, "modulate:a", 1.0, fade_in_duration * 2)
		tween.tween_callback(Callable(self, "_on_text_fully_revealed"))

# Animate text with medieval manuscript-inspired reveal
func _animate_text_medieval():
	if text_label:
		text_label.text = ""
		current_line_index = 0
		
		# Start revealing lines with decorative elements
		timer.wait_time = line_reveal_speed * 2
		timer.start()

# Update the typewriter animation
func _update_typewriter_animation():
	if current_char_index < current_text.length():
		text_label.text += current_text[current_char_index]
		current_char_index += 1
		
		# Continue with next character
		timer.wait_time = letter_reveal_speed
		timer.start()
	else:
		# Text fully revealed
		_on_text_fully_revealed()

# Update the word-by-word animation
func _update_word_by_word_animation():
	if current_word_index < words.size():
		if current_word_index > 0:
			text_label.text += " "
		text_label.text += words[current_word_index]
		current_word_index += 1
		
		# Continue with next word
		timer.wait_time = word_reveal_speed
		timer.start()
	else:
		# Text fully revealed
		_on_text_fully_revealed()

# Update the scroll animation
func _update_scroll_animation():
	if current_line_index < current_lines.size():
		if current_line_index > 0:
			text_label.text += "\n"
		text_label.text += current_lines[current_line_index]
		current_line_index += 1
		
		# Continue with next line
		timer.wait_time = line_reveal_speed
		timer.start()
	else:
		# Text fully revealed
		_on_text_fully_revealed()

# Update the medieval animation
func _update_medieval_animation():
	if current_line_index < current_lines.size():
		if current_line_index > 0:
			text_label.text += "\n"
		
		# Add decorative element at start of line
		if current_line_index == 0:
			text_label.text += "✧ "
		
		text_label.text += current_lines[current_line_index]
		
		# Add decorative element at end of line
		if current_line_index == current_lines.size() - 1:
			text_label.text += " ✧"
		
		current_line_index += 1
		
		# Continue with next line
		timer.wait_time = line_reveal_speed * 1.5
		timer.start()
	else:
		# Text fully revealed
		_on_text_fully_revealed()

# Update glow effect
func _update_glow_effect(delta):
	if not glow_effect:
		return
	
	# Pulse the glow
	var pulse = (sin(Time.get_ticks_msec() * 0.001 * glow_pulse_speed) + 1.0) / 2.0
	var intensity = glow_intensity * 0.5 + glow_intensity * 0.5 * pulse
	
	# Update glow color
	glow_effect.color = glow_color
	glow_effect.color.a = glow_color.a * pulse

# Update sacred geometry animation
func _update_sacred_geometry(delta):
	if not sacred_geometry_node:
		return
	
	# Rotate the sacred geometry
	sacred_geometry_node.rotation += delta * 0.1
	
	# Pulse the scale
	var pulse = (sin(Time.get_ticks_msec() * 0.0005) + 1.0) / 2.0
	sacred_geometry_node.scale = Vector2.ONE * (0.9 + pulse * 0.2)

# Create sacred geometry node
func _create_sacred_geometry():
	sacred_geometry_node = Node2D.new()
	sacred_geometry_node.name = "SacredGeometry"
	add_child(sacred_geometry_node)
	move_child(sacred_geometry_node, 0)
	
	# Create flower of life pattern
	_create_flower_of_life()
	
	# Hide initially
	sacred_geometry_node.visible = false

# Create flower of life pattern
func _create_flower_of_life():
	var center = Vector2(size.x / 2, size.y / 2)
	var radius = min(size.x, size.y) * 0.4
	
	# Create circles in Flower of Life pattern
	var positions = []
	
	# Center circle
	positions.append(Vector2.ZERO)
	
	# First ring (6 circles)
	for i in range(6):
		var angle = i * PI / 3
		positions.append(Vector2(cos(angle) * radius, sin(angle) * radius))
	
	# Create circles
	for pos in positions:
		var circle = _create_circle(radius, Color(1.0, 0.9, 0.7, 0.1))
		circle.position = center + pos
		sacred_geometry_node.add_child(circle)

# Create a circle for sacred geometry
func _create_circle(radius: float, color: Color) -> Node2D:
	var circle = Node2D.new()
	
	# Draw circle in _draw
	circle.draw = func():
		var center = Vector2.ZERO
		circle.draw_circle(center, radius, color)
	
	return circle

# Apply text style
func _apply_style(style: TextStyle):
	match style:
		TextStyle.SIMPLE:
			set_font_color(Color(1.0, 1.0, 1.0))
			set_background_color(Color(0.1, 0.1, 0.1, 0.7))
			set_glow_parameters(0.0, 0.0, 0.0)
			font_shadow_enabled = false
		
		TextStyle.PARCHMENT:
			set_font_color(Color(0.3, 0.2, 0.1))
			set_background_color(Color(0.9, 0.85, 0.7, 0.9))
			set_glow_parameters(0.0, 0.0, 0.0)
			font_shadow_enabled = false
		
		TextStyle.ILLUMINATED:
			set_font_color(Color(0.1, 0.1, 0.3))
			set_background_color(Color(0.95, 0.95, 0.9, 0.9))
			set_glow_parameters(1.0, 0.2, 0.3)
			glow_color = Color(0.8, 0.6, 0.2, 0.3)
			font_shadow_enabled = false
		
		TextStyle.SACRED_TEXT:
			set_font_color(Color(0.9, 0.8, 0.2))
			set_background_color(Color(0.2, 0.2, 0.3, 0.8))
			set_glow_parameters(2.0, 0.3, 0.5)
			glow_color = Color(1.0, 0.9, 0.5, 0.5)
			font_shadow_enabled = true
			font_shadow_color = Color(0.5, 0.3, 0.0, 0.5)
		
		TextStyle.MYSTICAL:
			set_font_color(Color(0.8, 0.9, 1.0))
			set_background_color(Color(0.1, 0.1, 0.2, 0.7))
			set_glow_parameters(1.5, 0.4, 0.4)
			glow_color = Color(0.5, 0.7, 1.0, 0.4)
			font_shadow_enabled = true
			font_shadow_color = Color(0.0, 0.2, 0.5, 0.5)
		
		TextStyle.MONASTIC:
			set_font_color(Color(0.2, 0.2, 0.2))
			set_background_color(Color(0.9, 0.9, 0.85, 0.9))
			set_glow_parameters(0.0, 0.0, 0.0)
			font_shadow_enabled = false
		
		TextStyle.NATURE:
			set_font_color(Color(0.2, 0.4, 0.2))
			set_background_color(Color(0.8, 0.9, 0.8, 0.8))
			set_glow_parameters(0.5, 0.2, 0.2)
			glow_color = Color(0.7, 0.9, 0.7, 0.2)
			font_shadow_enabled = true
			font_shadow_color = Color(0.1, 0.2, 0.1, 0.3)
		
		TextStyle.CELESTIAL:
			set_font_color(Color(0.9, 0.95, 1.0))
			set_background_color(Color(0.1, 0.15, 0.3, 0.7))
			set_glow_parameters(2.0, 0.5, 0.5)
			glow_color = Color(0.7, 0.8, 1.0, 0.5)
			font_shadow_enabled = true
			font_shadow_color = Color(0.2, 0.3, 0.5, 0.5)
	
	# Apply shadow if enabled
	if font_shadow_enabled and text_label:
		text_label.add_theme_color_override("font_shadow_color", font_shadow_color)
		text_label.add_theme_constant_override("shadow_offset_x", font_shadow_offset.x)
		text_label.add_theme_constant_override("shadow_offset_y", font_shadow_offset.y)
	elif text_label:
		text_label.add_theme_constant_override("shadow_offset_x", 0)
		text_label.add_theme_constant_override("shadow_offset_y", 0)

# Timer timeout handler
func _on_timer_timeout():
	if not is_displaying:
		# Display duration finished, start fade out
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, fade_out_duration)
		tween.tween_callback(Callable(self, "_on_display_completed"))
		return
	
	# Continue with animation based on type
	match current_animation_type:
		AnimationType.TYPEWRITER:
			_update_typewriter_animation()
		AnimationType.WORD_BY_WORD:
			_update_word_by_word_animation()
		AnimationType.SCROLL:
			_update_scroll_animation()
		AnimationType.MEDIEVAL:
			_update_medieval_animation()

# Text fully revealed handler
func _on_text_fully_revealed():
	emit_signal("text_fully_revealed")
	
	# Start display duration timer
	timer.wait_time = display_duration
	timer.start()

# Display completed handler
func _on_display_completed():
	_stop_display()
	visible = false
	display_complete = true
	emit_signal("display_completed")

# Get current display progress (0.0 to 1.0)
func get_display_progress() -> float:
	if not is_displaying:
		return display_complete ? 1.0 : 0.0
	
	match current_animation_type:
		AnimationType.TYPEWRITER:
			return float(current_char_index) / current_text.length()
		AnimationType.WORD_BY_WORD:
			return float(current_word_index) / words.size()
		AnimationType.SCROLL, AnimationType.MEDIEVAL:
			return float(current_line_index) / current_lines.size()
		_:
			return 1.0
