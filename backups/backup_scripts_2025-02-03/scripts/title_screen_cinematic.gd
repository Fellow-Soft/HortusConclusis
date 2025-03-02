extends Node3D

# Audio resources
var medieval_music: AudioStream

# Node references
var title_label: Label
var subtitle_label: Label
var fade_overlay: ColorRect
var audio_player: AudioStreamPlayer
var timer: Timer

# Title screen parameters
var title_fade_in_duration = 2.0
var title_display_duration = 5.0
var title_fade_out_duration = 2.0
var subtitle_delay = 1.5
var title_text = "Hortus Conclusus"
var subtitle_text = "The Enclosed Garden"
var next_scene = "res://scenes/medieval_garden_demo.tscn"

func _ready():
    # Initialize random number generator
    randomize()
    
    # Load audio resource
    if ResourceLoader.exists("res://assets/music/medieval_evening.wav"):
        medieval_music = load("res://assets/music/medieval_evening.wav")
    elif ResourceLoader.exists("res://assets/music/medieval_background.wav"):
        medieval_music = load("res://assets/music/medieval_background.wav")
    
    # Set up the UI elements
    _setup_ui()
    
    # Get references to nodes
    audio_player = $AudioStreamPlayer
    timer = $Timer
    
    # Start black screen
    fade_overlay.color = Color(0, 0, 0, 1)
    
    # Set up audio
    if medieval_music and audio_player:
        audio_player.stream = medieval_music
        audio_player.volume_db = -6.0
        audio_player.play()
    
    # Start the title sequence after a short delay
    timer.wait_time = 1.0
    timer.one_shot = true
    timer.connect("timeout", Callable(self, "_start_title_sequence"))
    timer.start()

func _setup_ui():
    # Create UI node
    var ui = Control.new()
    ui.name = "UI"
    ui.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(ui)
    
    # Create title label
    title_label = Label.new()
    title_label.name = "TitleLabel"
    title_label.text = title_text
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title_label.add_theme_font_size_override("font_size", 42)
    title_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
    title_label.position = Vector2(0, 200)
    title_label.size = Vector2(800, 100)
    title_label.modulate.a = 0
    ui.add_child(title_label)
    
    # Create subtitle label
    subtitle_label = Label.new()
    subtitle_label.name = "SubtitleLabel"
    subtitle_label.text = subtitle_text
    subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    subtitle_label.add_theme_font_size_override("font_size", 28)
    subtitle_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
    subtitle_label.position = Vector2(0, 250)
    subtitle_label.size = Vector2(800, 100)
    subtitle_label.modulate.a = 0
    ui.add_child(subtitle_label)
    
    # Create fade overlay
    fade_overlay = ColorRect.new()
    fade_overlay.name = "FadeOverlay"
    fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    fade_overlay.color = Color(0, 0, 0, 1)
    ui.add_child(fade_overlay)
    
    # Create AudioStreamPlayer
    audio_player = AudioStreamPlayer.new()
    audio_player.name = "AudioStreamPlayer"
    add_child(audio_player)
    
    # Create timer
    timer = Timer.new()
    timer.name = "Timer"
    add_child(timer)

func _start_title_sequence():
    # Fade out black overlay first
    var initial_fade = create_tween()
    initial_fade.tween_property(fade_overlay, "color:a", 0.0, 2.0)
    initial_fade.tween_callback(Callable(self, "_show_title"))

func _show_title():
    # Fade in title
    var title_tween = create_tween()
    title_tween.tween_property(title_label, "modulate:a", 1.0, title_fade_in_duration)
    title_tween.tween_callback(Callable(self, "_show_subtitle"))
    
func _show_subtitle():
    # Fade in subtitle after a short delay
    var subtitle_tween = create_tween()
    subtitle_tween.tween_interval(subtitle_delay)
    subtitle_tween.tween_property(subtitle_label, "modulate:a", 1.0, title_fade_in_duration)
    subtitle_tween.tween_interval(title_display_duration)
    subtitle_tween.tween_callback(Callable(self, "_fade_out_titles"))

func _fade_out_titles():
    # Fade out title and subtitle together
    var title_fade_out = create_tween()
    title_fade_out.tween_property(title_label, "modulate:a", 0.0, title_fade_out_duration)
    
    var subtitle_fade_out = create_tween()
    subtitle_fade_out.tween_property(subtitle_label, "modulate:a", 0.0, title_fade_out_duration)
    subtitle_fade_out.tween_callback(Callable(self, "_fade_to_main_scene"))

func _fade_to_main_scene():
    # Fade to black and load the main scene
    var final_fade = create_tween()
    final_fade.tween_property(fade_overlay, "color:a", 1.0, 2.0)
    final_fade.tween_callback(Callable(self, "_change_scene"))

func _change_scene():
    # Transition to main scene
    get_tree().change_scene_to_file(next_scene)
