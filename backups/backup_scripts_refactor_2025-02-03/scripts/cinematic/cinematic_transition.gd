extends Node

# This script handles the smooth transition between the title screen and cinematic demo

var fade_duration = 2.0
var transition_delay = 1.0

# Signal to notify when transition is complete
signal transition_complete

# Reference to overlay for fading
var fade_overlay: ColorRect
var audio_player: AudioStreamPlayer
var current_scene: String

# Initialize with reference to fade overlay and audio player
func initialize(overlay: ColorRect, audio: AudioStreamPlayer, scene_name: String):
    fade_overlay = overlay
    audio_player = audio
    current_scene = scene_name
    
    # Ensure the overlay is ready for transitions
    if fade_overlay:
        fade_overlay.color = Color(0, 0, 0, 0)  # Start transparent

# Transition from title to cinematic with fade effect
func transition_to_cinematic(target_scene: String):
    print("Transitioning from " + current_scene + " to " + target_scene)
    
    # Fade out visuals
    var visual_tween = create_tween()
    visual_tween.tween_property(fade_overlay, "color:a", 1.0, fade_duration)
    
    # Fade out audio if it exists
    if audio_player and audio_player.playing:
        var audio_tween = create_tween()
        audio_tween.tween_property(audio_player, "volume_db", -80.0, fade_duration)
    
    # Wait for fade to complete, then change scene
    await get_tree().create_timer(fade_duration + transition_delay).timeout
    
    # Change to the target scene
    var error = get_tree().change_scene_to_file(target_scene)
    if error != OK:
        print("Error changing scene: " + str(error))
    
    # Emit signal that transition is complete
    transition_complete.emit()

# Handle cinematic to game transition
func transition_to_game(target_scene: String):
    print("Transitioning from cinematic to game: " + target_scene)
    
    # Similar fade effect
    var visual_tween = create_tween()
    visual_tween.tween_property(fade_overlay, "color:a", 1.0, fade_duration)
    
    # Fade out audio if it exists
    if audio_player and audio_player.playing:
        var audio_tween = create_tween()
        audio_tween.tween_property(audio_player, "volume_db", -80.0, fade_duration)
    
    # Wait for fade to complete, then change scene
    await get_tree().create_timer(fade_duration + transition_delay).timeout
    
    # Change to the target scene
    var error = get_tree().change_scene_to_file(target_scene)
    if error != OK:
        print("Error changing scene: " + str(error))
    
    # Emit signal that transition is complete
    transition_complete.emit()

# Fade in from black (for use after scene change)
func fade_in():
    # Reset overlay to black
    if fade_overlay:
        fade_overlay.color = Color(0, 0, 0, 1)
        
        # Create fade-in tween
        var tween = create_tween()
        tween.tween_property(fade_overlay, "color:a", 0.0, fade_duration)
        
        # If audio player exists, fade in audio as well
        if audio_player:
            audio_player.volume_db = -80.0
            var audio_tween = create_tween()
            audio_tween.tween_property(audio_player, "volume_db", 0.0, fade_duration)
