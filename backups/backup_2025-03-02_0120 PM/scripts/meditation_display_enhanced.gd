extends Control

# Display parameters
var text_speed = 0.05
var display_duration = 10.0
var fade_duration = 2.0

# Node references
var text_label: RichTextLabel
var background_panel: ColorRect
var glow_effect: ColorRect

# State tracking
var current_text = ""
var display_timer = 0.0
var is_displaying = false
var is_fading = false
var fade_timer = 0.0
var fade_direction = 1  # 1 for fade in, -1 for fade out

# Signals
signal display_completed
signal fade_completed

func _ready():
    # Get node references
    background_panel = $BackgroundPanel
    glow_effect = $GlowEffect
    text_label = $MeditationText
    
    # Initialize properties
    if text_label:
        text_label.text = ""
        text_label.visible_ratio = 0
    
    if background_panel:
        background_panel.modulate.a = 0
    
    if glow_effect:
        glow_effect.modulate.a = 0

func set_text(new_text: String):
    current_text = new_text
    if text_label:
        text_label.text = current_text
        text_label.visible_ratio = 0

func start_display():
    if text_label:
        text_label.visible_ratio = 0
        is_displaying = true
        display_timer = 0.0
        fade_in()

func restart_display():
    display_timer = 0.0
    if text_label:
        text_label.visible_ratio = 0
    start_display()

func fade_in():
    is_fading = true
    fade_direction = 1
    fade_timer = 0.0

func fade_out():
    is_fading = true
    fade_direction = -1
    fade_timer = 0.0

func _process(delta):
    if is_displaying:
        display_timer += delta
        
        if text_label:
            # Calculate visible ratio based on text speed
            var target_ratio = display_timer / text_speed
            text_label.visible_ratio = min(1.0, target_ratio)
            
            # Check if display is complete
            if text_label.visible_ratio >= 1.0:
                is_displaying = false
                emit_signal("display_completed")
    
    if is_fading:
        fade_timer += delta
        var alpha = fade_timer / fade_duration if fade_direction > 0 else 1.0 - (fade_timer / fade_duration)
        alpha = clamp(alpha, 0.0, 1.0)
        
        if background_panel:
            background_panel.modulate.a = alpha * 0.7  # Semi-transparent background
        
        if glow_effect:
            glow_effect.modulate.a = alpha * 0.1  # Subtle glow
        
        if text_label:
            text_label.modulate.a = alpha
        
        if fade_timer >= fade_duration:
            is_fading = false
            emit_signal("fade_completed")

func set_colors(text_color: Color, background_color: Color, glow_color: Color):
    if text_label:
        text_label.add_theme_color_override("default_color", text_color)
    
    if background_panel:
        background_panel.color = background_color
    
    if glow_effect:
        glow_effect.color = glow_color

func get_display_progress() -> float:
    return text_label.visible_ratio if text_label else 0.0

func is_complete() -> bool:
    return not is_displaying and not is_fading

func _on_timer_timeout():
    fade_out()
