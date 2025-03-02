extends Node

# Configuration
var output_path = "user://cinematic_recording.png"  # Changed to PNG for screenshot sequence
var recording_fps = 30
var recording_duration = 120 # seconds
var recording_quality = 0.8 # 0.0 to 1.0

# Recording state
var is_recording = false
var frames_recorded = 0
var max_frames = recording_fps * recording_duration
var frame_count = 0

# Called when the node enters the scene tree for the first time
func _ready():
    # Print debug information
    print("Cinematic Recorder: Initializing...")
    print("Output directory: user://screenshots/")
    print("User data directory: " + OS.get_user_data_dir())
    
    # Create screenshots directory if it doesn't exist
    var dir = DirAccess.open("user://")
    if not dir.dir_exists("screenshots"):
        dir.make_dir("screenshots")
    
    # Wait a moment before starting recording to ensure scene is fully loaded
    await get_tree().create_timer(1.0).timeout
    start_recording()

# Start recording the cinematic
func start_recording():
    print("Cinematic Recorder: Starting recording...")
    
    # Start recording
    is_recording = true
    frames_recorded = 0
    frame_count = 0
    
    print("Cinematic Recorder: Recording started. Screenshots will be saved to: user://screenshots/")
    print("Cinematic Recorder: Full path: " + OS.get_user_data_dir() + "/screenshots/")

# Process function to capture frames
func _process(delta):
    if is_recording:
        # Only capture frames at the specified FPS
        frame_count += 1
        if frame_count >= Engine.get_frames_per_second() / recording_fps:
            frame_count = 0
            
            # Capture the current frame
            var img = get_viewport().get_texture().get_image()
            
            # Save the frame as a PNG file
            var frame_path = "user://screenshots/frame_" + str(frames_recorded).pad_zeros(6) + ".png"
            img.save_png(frame_path)
            
            frames_recorded += 1
            
            # Print progress every second
            if frames_recorded % recording_fps == 0:
                var seconds_recorded = frames_recorded / recording_fps
                print("Cinematic Recorder: Recording progress: " + str(seconds_recorded) + " / " + str(recording_duration) + " seconds")
            
            # Check if we've recorded enough frames
            if frames_recorded >= max_frames:
                stop_recording()

# Stop recording and save the video
func stop_recording():
    if is_recording:
        is_recording = false
        
        print("Cinematic Recorder: Recording completed.")
        print("Cinematic Recorder: " + str(frames_recorded) + " frames saved to: user://screenshots/")
        
        # Convert the user:// path to an absolute path for easier access
        var absolute_path = OS.get_user_data_dir() + "/screenshots/"
        print("Cinematic Recorder: Absolute path: " + absolute_path)
        
        # Notify the user
        _show_completion_dialog(absolute_path)

# Show a dialog when recording is complete
func _show_completion_dialog(path):
    var dialog = AcceptDialog.new()
    dialog.title = "Recording Complete"
    dialog.dialog_text = "Cinematic recording saved as image sequence to:\n" + path + "\n\nUse a video editor to convert these images to a video."
    add_child(dialog)
    dialog.popup_centered()
