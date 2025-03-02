extends Node3D

# Audio resources
var medieval_music: AudioStream

# Node references
var title_label: RichTextLabel
var subtitle_label: RichTextLabel
var fade_overlay: ColorRect
var parchment_texture: TextureRect
var border_container: Control
var audio_player: AudioStreamPlayer
var timer: Timer
var border_elements = []

# Title screen parameters
var title_fade_in_duration = 3.0
var title_display_duration = 6.0
var title_fade_out_duration = 2.0
var subtitle_delay = 2.0
var letter_delay = 0.12
var title_text = "Hortus Conclusus"
var subtitle_text = "The Enclosed Garden"
var cinematic_scene = "res://scenes/hortus_conclusus_cinematic.tscn"
var main_scene = "res://scenes/medieval_garden_demo.tscn"

# Border flourishes
var num_flourishes = 8
var flourish_scale_min = 0.5
var flourish_scale_max = 1.2
var flourish_rotation_min = -0.5
var flourish_rotation_max = 0.5

# Shader parameters
var parchment_age = 0.7  # 0.0 to 1.0
var glow_intensity = 0.4 # 0.0 to 1.0
var color_variation = 0.3 # 0.0 to 1.0

# Transition manager
var transition_manager: Node

func _ready():
    # Initialize random number generator
    randomize()
    
    # Get references to UI elements
    title_label = $UI/TitleLabel
    subtitle_label = $UI/SubtitleLabel
    fade_overlay = $UI/FadeOverlay
    parchment_texture = $UI/ParchmentTexture
    border_container = $UI/BorderContainer
    audio_player = $AudioStreamPlayer
    timer = $Timer
    
    # Create and add border elements
    _create_borders()
    
    # Load audio resource
    if ResourceLoader.exists("res://assets/music/medieval_evening.wav"):
        medieval_music = load("res://assets/music/medieval_evening.wav")
    elif ResourceLoader.exists("res://assets/music/medieval_background.wav"):
        medieval_music = load("res://assets/music/medieval_background.wav")
    
    # Create and set up transition manager
    transition_manager = Node.new()
    transition_manager.name = "TransitionManager"
    transition_manager.set_script(load("res://scripts/cinematic_transition.gd"))
    add_child(transition_manager)
    transition_manager.initialize(fade_overlay, audio_player, "title_screen_cinematic")
    
    # Set up audio
    if medieval_music and audio_player:
        audio_player.stream = medieval_music
        audio_player.volume_db = -6.0
        audio_player.play()
    
    # Start the title sequence after a short delay
    timer.wait_time = 1.0
    timer.connect("timeout", Callable(self, "_start_title_sequence"))
    timer.start()
    
    # Check if we should use the complete experience flow
    var arguments = OS.get_cmdline_args()
    for arg in arguments:
        if arg == "--complete-experience":
            print("Complete experience mode enabled")
            # Set cinematic_scene to go to the full cinematic rather than the game
            cinematic_scene = "res://scenes/hortus_conclusus_cinematic.tscn"
            main_scene = "res://scenes/medieval_garden_demo.tscn"  # Next scene after cinematic

func _create_borders():
    # Add decorative corner flourishes and border elements
    var positions = [
        Vector2(100, 100),   # Top left
        Vector2(924, 100),   # Top right
        Vector2(100, 500),   # Bottom left
        Vector2(924, 500),   # Bottom right
        Vector2(512, 80),    # Top center
        Vector2(512, 520),   # Bottom center
        Vector2(80, 300),    # Left center
        Vector2(944, 300)    # Right center
    ]
    
    for i in range(min(num_flourishes, positions.size())):
        var flourish = ColorRect.new()
        flourish.name = "Flourish" + str(i)
        flourish.size = Vector2(60, 60)
        flourish.color = Color(0.7, 0.5, 0.2, 0.0)  # Start transparent
        flourish.position = positions[i] - flourish.size / 2
        
        # Apply random scale and rotation
        var scale_factor = randf_range(flourish_scale_min, flourish_scale_max)
        flourish.scale = Vector2(scale_factor, scale_factor)
        flourish.rotation = randf_range(flourish_rotation_min, flourish_rotation_max)
        
        border_container.add_child(flourish)
        border_elements.append(flourish)

func _start_title_sequence():
    # Fade out black overlay first
    var initial_fade = create_tween()
    initial_fade.tween_property(fade_overlay, "color:a", 0.0, 2.0)
    initial_fade.tween_callback(Callable(self, "_animate_borders"))

func _animate_borders():
    # Fade in and animate border elements
    for i in range(border_elements.size()):
        var delay = i * 0.2
        var flourish = border_elements[i]
        
        var tween = create_tween().set_parallel(true)
        tween.tween_property(flourish, "color:a", 1.0, 1.0).set_delay(delay)
        
        # Gentle rotation animation
        var current_rotation = flourish.rotation
        tween.tween_property(flourish, "rotation", current_rotation + 0.05, 2.0).set_delay(delay)
        tween.tween_property(flourish, "rotation", current_rotation - 0.05, 2.0).set_delay(delay + 2.0)
    
    # Sequence to next step after all borders appear
    var sequence_tween = create_tween()
    sequence_tween.tween_interval(border_elements.size() * 0.2 + 1.0)
    sequence_tween.tween_callback(Callable(self, "_show_title"))

func _show_title():
    # First show the empty RichTextLabel container
    var title_tween = create_tween()
    title_tween.tween_property(title_label, "modulate:a", 1.0, 0.5)
    title_tween.tween_callback(Callable(self, "_animate_title_letters"))

func _animate_title_letters():
    # Animate each letter of the title with colored first letter
    var colored_title = "[center][color=#8B0000]" + title_text.substr(0, 1) + "[/color]" + title_text.substr(1) + "[/center]"
    
    for i in range(colored_title.length()):
        # Skip BBCode tags without pausing for them
        if colored_title[i] == '[':
            var tag_end = colored_title.find(']', i)
            if tag_end != -1:
                title_label.text += colored_title.substr(i, tag_end - i + 1)
                i = tag_end
                continue
                
        title_label.text += colored_title[i]
        await get_tree().create_timer(letter_delay).timeout
    
    # After title is complete, show subtitle
    var subtitle_tween = create_tween()
    subtitle_tween.tween_interval(subtitle_delay)
    subtitle_tween.tween_property(subtitle_label, "modulate:a", 1.0, 0.5)
    subtitle_tween.tween_callback(Callable(self, "_animate_subtitle_letters"))

func _animate_subtitle_letters():
    # Animate each letter of the subtitle
    var colored_subtitle = "[center][color=#4B5320]" + subtitle_text + "[/color][/center]"
    
    for i in range(colored_subtitle.length()):
        # Skip BBCode tags without pausing for them
        if colored_subtitle[i] == '[':
            var tag_end = colored_subtitle.find(']', i)
            if tag_end != -1:
                subtitle_label.text += colored_subtitle.substr(i, tag_end - i + 1)
                i = tag_end
                continue
                
        subtitle_label.text += colored_subtitle[i]
        await get_tree().create_timer(letter_delay * 1.2).timeout
    
    # After subtitle is complete, wait before fade out
    var display_tween = create_tween()
    display_tween.tween_interval(title_display_duration)
    display_tween.tween_callback(Callable(self, "_fade_out_titles"))

func _fade_out_titles():
    # Fade out title and subtitle together
    var title_fade_out = create_tween()
    title_fade_out.tween_property(title_label, "modulate:a", 0.0, title_fade_out_duration)
    
    var subtitle_fade_out = create_tween()
    subtitle_fade_out.tween_property(subtitle_label, "modulate:a", 0.0, title_fade_out_duration)
    
    # Fade out border elements
    for flourish in border_elements:
        var tween = create_tween()
        tween.tween_property(flourish, "color:a", 0.0, title_fade_out_duration)
    
    # After elements fade out, transition to black
    var sequence_tween = create_tween()
    sequence_tween.tween_interval(title_fade_out_duration)
    sequence_tween.tween_callback(Callable(self, "_fade_to_cinematic"))

func _fade_to_cinematic():
    # Fade to black and load the cinematic demo scene
    var final_fade = create_tween()
    final_fade.tween_property(fade_overlay, "color:a", 1.0, 2.0)
    final_fade.tween_callback(Callable(self, "_change_to_cinematic"))


func _change_to_cinematic():
    # Use the transition manager to handle the scene change
    transition_manager.transition_to_cinematic(cinematic_scene)

# Process function removed as we don't need particle movement
