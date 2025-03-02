extends Node
class_name MeditationDisplayAdvanced

# Text display parameters
var text_label: Label
var current_text: String = ""
var display_speed: float = 0.05
var current_char_index: int = 0
var is_displaying: bool = false
var is_paused: bool = false

# Animation parameters
var fade_in_duration: float = 2.0
var display_duration: float = 10.0
var fade_out_duration: float = 2.0
var current_animation_state: String = "idle"

# Visual enhancement parameters
var use_calligraphic_styling: bool = true
var use_color_transitions: bool = true
var use_particle_effects: bool = true
var use_text_breathing: bool = true
var use_letter_spacing_variation: bool = true

# Calligraphic styling parameters
var initial_capital_scale: float = 2.0
var flourish_characters: Array = [".", ",", ";", ":", "!", "?"]
var flourish_scale: float = 1.2
var flourish_offset: float = 5.0

# Color transition parameters
var base_color: Color = Color(0.9, 0.8, 0.6, 1.0)  # Parchment-like color
var accent_color: Color = Color(0.7, 0.2, 0.2, 1.0)  # Red ink color
var highlight_color: Color = Color(0.9, 0.7, 0.3, 1.0)  # Gold highlight
var current_color_scheme: String = "dawn"
var color_schemes = {
    "dawn": {
        "base": Color(0.9, 0.8, 0.6, 1.0),
        "accent": Color(0.7, 0.2, 0.2, 1.0),
        "highlight": Color(0.9, 0.7, 0.3, 1.0)
    },
    "noon": {
        "base": Color(1.0, 0.95, 0.8, 1.0),
        "accent": Color(0.3, 0.5, 0.7, 1.0),
        "highlight": Color(0.95, 0.9, 0.5, 1.0)
    },
    "dusk": {
        "base": Color(0.8, 0.7, 0.6, 1.0),
        "accent": Color(0.6, 0.3, 0.5, 1.0),
        "highlight": Color(0.8, 0.6, 0.3, 1.0)
    },
    "night": {
        "base": Color(0.6, 0.6, 0.7, 1.0),
        "accent": Color(0.3, 0.3, 0.6, 1.0),
        "highlight": Color(0.7, 0.7, 0.9, 1.0)
    }
}

# Text breathing parameters
var breathing_amplitude: float = 0.02
var breathing_frequency: float = 0.5
var base_font_size: int = 24
var current_breathing_offset: float = 0.0

# Letter spacing parameters
var base_letter_spacing: float = 0.0
var letter_spacing_variation: float = 2.0

# Particle effect parameters
var particle_emission_rate: float = 0.2
var particle_colors: Array = []
var particle_system: Node

# Timers
var display_timer: Timer
var char_timer: Timer
var breathing_timer: Timer

# Signals
signal display_started
signal display_completed
signal display_paused
signal display_resumed
signal char_displayed(index, character)

# Called when the node enters the scene tree for the first time
func _ready():
    # Initialize timers
    display_timer = Timer.new()
    display_timer.one_shot = true
    display_timer.connect("timeout", Callable(self, "_on_display_timer_timeout"))
    add_child(display_timer)
    
    char_timer = Timer.new()
    char_timer.one_shot = true
    char_timer.connect("timeout", Callable(self, "_on_char_timer_timeout"))
    add_child(char_timer)
    
    breathing_timer = Timer.new()
    breathing_timer.wait_time = 0.05  # Update breathing at 20 Hz
    breathing_timer.connect("timeout", Callable(self, "_on_breathing_timer_timeout"))
    add_child(breathing_timer)
    
    # Initialize particle colors
    _update_particle_colors()
    
    # Start breathing timer if enabled
    if use_text_breathing:
        breathing_timer.start()

# Set the text to be displayed
func set_text(text: String):
    current_text = text
    current_char_index = 0
    
    # Reset label if it exists
    if text_label:
        text_label.text = ""
        
        # Apply base styling
        _apply_base_styling()

# Set the durations for the animations
func set_durations(fade_in: float, display: float, fade_out: float):
    fade_in_duration = fade_in
    display_duration = display
    fade_out_duration = fade_out

# Set the letter reveal speed
func set_letter_reveal_speed(speed: float):
    display_speed = speed

# Start displaying the text
func start_display():
    if not text_label or current_text.is_empty():
        return
    
    # Reset state
    is_displaying = true
    is_paused = false
    current_char_index = 0
    current_animation_state = "fade_in"
    
    # Start fade in
    _fade_in()
    
    # Start character display
    char_timer.wait_time = display_speed
    char_timer.start()
    
    emit_signal("display_started")

# Restart the display from the beginning
func restart_display():
    # Stop any current display
    stop_display()
    
    # Reset and start again
    current_char_index = 0
    if text_label:
        text_label.text = ""
    
    start_display()

# Stop the display
func stop_display():
    is_displaying = false
    is_paused = false
    
    # Stop timers
    if char_timer:
        char_timer.stop()
    if display_timer:
        display_timer.stop()

# Pause the display
func pause_display():
    if is_displaying and not is_paused:
        is_paused = true
        
        # Stop character timer
        if char_timer:
            char_timer.stop()
        
        emit_signal("display_paused")

# Resume the display
func resume_display():
    if is_displaying and is_paused:
        is_paused = false
        
        # Restart character timer
        if char_timer:
            char_timer.wait_time = display_speed
            char_timer.start()
        
        emit_signal("display_resumed")

# Fade in the text label
func fade_in():
    _fade_in()

# Fade out the text label
func fade_out():
    _fade_out()

# Set the color scheme based on time of day
func set_color_scheme(time_of_day: String):
    if time_of_day in color_schemes:
        current_color_scheme = time_of_day
        
        # Update colors
        base_color = color_schemes[time_of_day].base
        accent_color = color_schemes[time_of_day].accent
        highlight_color = color_schemes[time_of_day].highlight
        
        # Update particle colors
        _update_particle_colors()
        
        # Apply to current text if already displaying
        if text_label and not text_label.text.is_empty():
            _apply_color_styling()

# Enable or disable calligraphic styling
func set_calligraphic_styling(enabled: bool):
    use_calligraphic_styling = enabled
    
    # Apply to current text if already displaying
    if text_label and not text_label.text.is_empty() and use_calligraphic_styling:
        _apply_calligraphic_styling()

# Enable or disable color transitions
func set_color_transitions(enabled: bool):
    use_color_transitions = enabled
    
    # Apply to current text if already displaying
    if text_label and not text_label.text.is_empty() and use_color_transitions:
        _apply_color_styling()

# Enable or disable particle effects
func set_particle_effects(enabled: bool):
    use_particle_effects = enabled
    
    # Create or remove particle system
    if use_particle_effects:
        _create_particle_system()
    elif particle_system:
        particle_system.queue_free()
        particle_system = null

# Enable or disable text breathing
func set_text_breathing(enabled: bool):
    use_text_breathing = enabled
    
    if use_text_breathing:
        if breathing_timer:
            breathing_timer.start()
    else:
        if breathing_timer:
            breathing_timer.stop()
        
        # Reset font size
        if text_label:
            text_label.add_theme_font_size_override("font_size", base_font_size)

# Enable or disable letter spacing variation
func set_letter_spacing_variation(enabled: bool):
    use_letter_spacing_variation = enabled
    
    # Apply to current text if already displaying
    if text_label and not text_label.text.is_empty() and use_letter_spacing_variation:
        _apply_letter_spacing()
    elif text_label:
        # Reset letter spacing
        text_label.add_theme_constant_override("letter_spacing", base_letter_spacing)

# Private methods

# Apply base styling to the label
func _apply_base_styling():
    if not text_label:
        return
    
    # Set base font size
    text_label.add_theme_font_size_override("font_size", base_font_size)
    
    # Set base letter spacing
    text_label.add_theme_constant_override("letter_spacing", base_letter_spacing)
    
    # Set base color
    text_label.add_theme_color_override("font_color", base_color)

# Apply calligraphic styling to the text
func _apply_calligraphic_styling():
    if not text_label or not use_calligraphic_styling:
        return
    
    # This would require custom rendering or RichTextLabel
    # For now, we'll just apply some basic styling with BBCode if possible
    if text_label is RichTextLabel:
        var styled_text = "[center]"
        
        # Apply initial capital styling
        if current_text.length() > 0:
            styled_text += "[font_size=" + str(int(base_font_size * initial_capital_scale)) + "]"
            styled_text += current_text[0]
            styled_text += "[/font_size]"
            
            # Rest of the text
            if current_text.length() > 1:
                styled_text += current_text.substr(1)
        
        styled_text += "[/center]"
        text_label.text = styled_text

# Apply color styling to the text
func _apply_color_styling():
    if not text_label or not use_color_transitions:
        return
    
    # For now, just set the base color
    text_label.add_theme_color_override("font_color", base_color)
    
    # This would require custom rendering or RichTextLabel for more advanced styling
    if text_label is RichTextLabel:
        var styled_text = "[center]"
        
        # Apply color styling
        for i in range(current_text.length()):
            var char = current_text[i]
            
            # Initial capital in highlight color
            if i == 0:
                styled_text += "[color=#" + highlight_color.to_html(false) + "]"
                styled_text += char
                styled_text += "[/color]"
            # Punctuation in accent color
            elif flourish_characters.has(char):
                styled_text += "[color=#" + accent_color.to_html(false) + "]"
                styled_text += char
                styled_text += "[/color]"
            # Regular character
            else:
                styled_text += char
        
        styled_text += "[/center]"
        text_label.text = styled_text

# Apply letter spacing variation
func _apply_letter_spacing():
    if not text_label or not use_letter_spacing_variation:
        return
    
    # For now, just set a random letter spacing
    var spacing = base_letter_spacing + randf_range(-letter_spacing_variation, letter_spacing_variation)
    text_label.add_theme_constant_override("letter_spacing", spacing)

# Create particle system for text effects
func _create_particle_system():
    # This would require a custom particle system
    # For now, we'll just create a placeholder
    if particle_system:
        particle_system.queue_free()
    
    particle_system = Node2D.new()
    particle_system.name = "TextParticles"
    add_child(particle_system)
    
    # In a real implementation, we would create CPUParticles2D or GPUParticles2D
    # and configure them to emit particles around the text

# Update particle colors based on current color scheme
func _update_particle_colors():
    particle_colors.clear()
    
    # Add colors from current scheme
    particle_colors.append(base_color)
    particle_colors.append(accent_color)
    particle_colors.append(highlight_color)

# Fade in the text label
func _fade_in():
    if not text_label:
        return
    
    # Set initial alpha
    text_label.modulate.a = 0.0
    
    # Create tween for fade in
    var tween = create_tween()
    tween.tween_property(text_label, "modulate:a", 1.0, fade_in_duration)
    
    # Set animation state
    current_animation_state = "fade_in"

# Fade out the text label
func _fade_out():
    if not text_label:
        return
    
    # Create tween for fade out
    var tween = create_tween()
    tween.tween_property(text_label, "modulate:a", 0.0, fade_out_duration)
    tween.tween_callback(Callable(self, "_on_fade_out_completed"))
    
    # Set animation state
    current_animation_state = "fade_out"

# Display the next character
func _display_next_char():
    if not text_label or not is_displaying or is_paused:
        return
    
    if current_char_index < current_text.length():
        # Get the next character
        var next_char = current_text[current_char_index]
        
        # Add it to the label
        text_label.text += next_char
        
        # Apply styling if needed
        if use_calligraphic_styling:
            _apply_calligraphic_styling()
        
        if use_color_transitions:
            _apply_color_styling()
        
        if use_letter_spacing_variation:
            _apply_letter_spacing()
        
        # Emit particle if needed
        if use_particle_effects and particle_system and randf() < particle_emission_rate:
            _emit_particle_at_char(current_char_index)
        
        # Signal that a character was displayed
        emit_signal("char_displayed", current_char_index, next_char)
        
        # Increment index
        current_char_index += 1
        
        # Schedule next character
        if current_char_index < current_text.length():
            char_timer.wait_time = display_speed
            char_timer.start()
        else:
            # All characters displayed, start display duration
            current_animation_state = "display"
            display_timer.wait_time = display_duration
            display_timer.start()
    else:
        # All characters displayed, start display duration
        current_animation_state = "display"
        display_timer.wait_time = display_duration
        display_timer.start()

# Emit a particle at a specific character position
func _emit_particle_at_char(char_index: int):
    # This would require calculating the position of the character
    # For now, we'll just emit a particle at a random position near the label
    if not particle_system or not text_label:
        return
    
    # In a real implementation, we would calculate the position of the character
    # and emit a particle at that position

# Update text breathing effect
func _update_text_breathing():
    if not text_label or not use_text_breathing:
        return
    
    # Calculate breathing offset
    current_breathing_offset = sin(Time.get_ticks_msec() * 0.001 * breathing_frequency) * breathing_amplitude
    
    # Apply to font size
    var new_size = base_font_size * (1.0 + current_breathing_offset)
    text_label.add_theme_font_size_override("font_size", int(new_size))

# Timer callbacks

func _on_char_timer_timeout():
    _display_next_char()

func _on_display_timer_timeout():
    # Display duration completed, start fade out
    _fade_out()

func _on_breathing_timer_timeout():
    _update_text_breathing()

func _on_fade_out_completed():
    # Fade out completed, reset state
    is_displaying = false
    current_animation_state = "idle"
    
    # Signal that display is completed
    emit_signal("display_completed")
