extends Control
class_name CinematicMeditationDisplay

# Meditation text display for cinematic scenes
# Provides a flowing, ethereal display of meditation text that changes with time of day

# UI Components
@onready var meditation_text = $MeditationText if has_node("MeditationText") else null
@onready var background_panel = $BackgroundPanel if has_node("BackgroundPanel") else null
@onready var glow_effect = $GlowEffect if has_node("GlowEffect") else null

# Animation parameters
var fade_in_duration: float = 3.0
var display_duration: float = 15.0
var fade_out_duration: float = 3.0
var letter_reveal_speed: float = 0.05
var glow_pulse_speed: float = 2.0
var glow_intensity_min: float = 0.5
var glow_intensity_max: float = 1.0

# State tracking
var current_text: String = ""
var target_text: String = ""
var is_displaying: bool = false
var display_timer: float = 0.0
var letter_timer: float = 0.0
var revealed_letters: int = 0
var display_state: String = "idle"  # idle, fade_in, revealing, display, fade_out

# Medieval font settings
var font_color: Color = Color(0.9, 0.85, 0.7)  # Parchment-like color
var font_shadow_color: Color = Color(0.1, 0.1, 0.1, 0.5)
var background_color: Color = Color(0.1, 0.1, 0.1, 0.7)  # Dark, semi-transparent

# Called when the node enters the scene tree for the first time
func _ready():
	# Set up the visual appearance
	_setup_appearance()
	
	# Initialize in hidden state
	if meditation_text:
		meditation_text.visible = false
		meditation_text.text = ""
	
	if background_panel:
		background_panel.visible = false
	
	if glow_effect:
		glow_effect.visible = false

# Set up the visual appearance
func _setup_appearance():
	if meditation_text:
		meditation_text.add_theme_color_override("default_color", font_color)
		meditation_text.add_theme_font_size_override("normal_font_size", 20)
		
		# Add shadow effect
		meditation_text.add_theme_constant_override("shadow_offset_x", 2)
		meditation_text.add_theme_constant_override("shadow_offset_y", 2)
		meditation_text.add_theme_color_override("font_shadow_color", font_shadow_color)
	
	if background_panel:
		background_panel.color = background_color

# Process function for animations
func _process(delta):
	match display_state:
		"idle":
			# Do nothing in idle state
			pass
			
		"fade_in":
			# Fade in the background and text container
			display_timer += delta
			var progress = min(display_timer / fade_in_duration, 1.0)
			
			if background_panel:
				background_panel.color.a = background_color.a * progress
			
			if display_timer >= fade_in_duration:
				display_timer = 0.0
				display_state = "revealing"
				
				if meditation_text:
					meditation_text.visible = true
					meditation_text.text = ""
		
		"revealing":
			# Gradually reveal the text letter by letter
			letter_timer += delta
			
			if letter_timer >= letter_reveal_speed:
				letter_timer -= letter_reveal_speed
				revealed_letters += 1
				
				if meditation_text and revealed_letters <= target_text.length():
					meditation_text.text = target_text.substr(0, revealed_letters)
				
				# Check if all letters are revealed
				if revealed_letters >= target_text.length():
					display_timer = 0.0
					display_state = "display"
		
		"display":
			# Display the full text for the specified duration
			display_timer += delta
			
			# Pulse the glow effect
			if glow_effect:
				var pulse = (sin(display_timer * glow_pulse_speed) + 1.0) / 2.0
				var intensity = lerp(glow_intensity_min, glow_intensity_max, pulse)
				glow_effect.modulate.a = intensity
			
			# Check if display time is complete
			if display_timer >= display_duration:
				display_timer = 0.0
				display_state = "fade_out"
		
		"fade_out":
			# Fade out the text and background
			display_timer += delta
			var progress = min(display_timer / fade_out_duration, 1.0)
			
			if background_panel:
				background_panel.color.a = background_color.a * (1.0 - progress)
			
			if meditation_text:
				meditation_text.modulate.a = 1.0 - progress
			
			if glow_effect:
				glow_effect.modulate.a = (1.0 - progress) * glow_intensity_min
			
			# Check if fade out is complete
			if display_timer >= fade_out_duration:
				display_timer = 0.0
				display_state = "idle"
				
				# Hide all elements
				if meditation_text:
					meditation_text.visible = false
				
				if background_panel:
					background_panel.visible = false
				
				if glow_effect:
					glow_effect.visible = false
				
				# Signal that display is complete
				emit_signal("display_completed")

# Set the text to display
func set_text(text: String):
	target_text = text
	revealed_letters = 0

# Start displaying the meditation text
func start_display():
	# Reset state
	display_timer = 0.0
	letter_timer = 0.0
	revealed_letters = 0
	display_state = "fade_in"
	
	# Show elements
	if background_panel:
		background_panel.visible = true
		background_panel.color.a = 0.0
	
	if glow_effect:
		glow_effect.visible = true
		glow_effect.modulate.a = 0.0
	
	if meditation_text:
		meditation_text.modulate.a = 1.0
		meditation_text.text = ""
	
	is_displaying = true

# Stop displaying the meditation text
func stop_display():
	display_state = "fade_out"

# Restart the display with the current text
func restart_display():
	stop_display()
	await get_tree().create_timer(fade_out_duration).timeout
	start_display()

# Set the display durations
func set_durations(fade_in: float, display: float, fade_out: float):
	fade_in_duration = fade_in
	display_duration = display
	fade_out_duration = fade_out

# Set the letter reveal speed
func set_letter_reveal_speed(speed: float):
	letter_reveal_speed = speed

# Set the glow pulse parameters
func set_glow_parameters(speed: float, min_intensity: float, max_intensity: float):
	glow_pulse_speed = speed
	glow_intensity_min = min_intensity
	glow_intensity_max = max_intensity

# Set the font color
func set_font_color(color: Color):
	font_color = color
	if meditation_text:
		meditation_text.add_theme_color_override("default_color", font_color)

# Set the background color
func set_background_color(color: Color):
	background_color = color
	if background_panel:
		background_panel.color = background_color

# Check if currently displaying
func is_currently_displaying() -> bool:
	return display_state != "idle"

# Signal emitted when display is completed
signal display_completed
