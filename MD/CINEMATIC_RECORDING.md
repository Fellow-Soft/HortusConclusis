# Hortus Conclusus Cinematic Recording

This document explains how to record the Hortus Conclusus cinematic experience as a sequence of PNG images that can be converted to a video.

## Prerequisites

- Godot Engine 4.3 or later installed
- Sufficient disk space for image sequence recording (approximately 1GB for a 2-minute recording)
- The Hortus Conclusus project with all enhancements implemented
- (Optional) Video editing software or FFmpeg for converting image sequences to video

## Recording Process

### Automatic Recording (Recommended)

1. Navigate to the HortusConclusis directory
2. Run the `record_cinematic_simple.bat` script by double-clicking it
3. Follow the on-screen instructions
4. The recording will automatically start and run for approximately 2 minutes
5. When complete, a dialog will appear showing the location of the saved PNG image sequence

### Manual Recording

If you prefer to manually control the recording process:

1. Open the Godot Engine
2. Load the HortusConclusis project
3. Open the scene `scenes/hortus_conclusus_cinematic_recording.tscn`
4. Run the scene
5. The recording will automatically start and run for approximately 2 minutes
6. When complete, a dialog will appear showing the location of the saved PNG image sequence

## Finding the Recorded Images

The PNG image sequence is saved in your Godot user data directory:

- Windows: `%APPDATA%\Godot\app_userdata\Hortus Conclusis\screenshots\`
- macOS: `~/Library/Application Support/Godot/app_userdata/Hortus Conclusis/screenshots/`
- Linux: `~/.local/share/godot/app_userdata/Hortus Conclusis/screenshots/`

## Recording Settings

The default recording settings are:

- Resolution: Same as the game window (1280x720)
- Frame rate: 30 FPS
- Duration: 120 seconds (2 minutes)
- Format: PNG image sequence (frame_000000.png, frame_000001.png, etc.)

### Customizing Recording Settings

To customize the recording settings, edit the `scripts/cinematic_recorder.gd` file:

```gdscript
# Configuration
var output_path = "user://cinematic_recording.png"  # Base filename for screenshots
var recording_fps = 30
var recording_duration = 120 # seconds
var recording_quality = 0.8 # 0.0 to 1.0 (only affects compression if used)
```

## Converting Image Sequence to Video

After recording, you'll need to convert the PNG image sequence to a video file. Here are several methods:

### Using FFmpeg (Command Line)

1. Install [FFmpeg](https://ffmpeg.org/download.html) if you don't have it already
2. Navigate to the screenshots directory in a command prompt or terminal
3. Run the following command:

```
ffmpeg -framerate 30 -i frame_%06d.png -c:v libx264 -pix_fmt yuv420p cinematic.mp4
```

This will create a high-quality MP4 video file from your image sequence.

### Using Video Editing Software

You can also import the image sequence into video editing software:

- **Adobe Premiere Pro**: File > Import > navigate to the first image > check "Image Sequence"
- **DaVinci Resolve**: Media page > Add > navigate to the first image > check "Image Sequence"
- **Windows Video Editor**: Import the images and arrange them on the timeline
- **iMovie**: File > Import > navigate to the screenshots folder > select all images

## Troubleshooting

### Recording Fails

If the recording fails to start or complete:

1. Check that Godot has permission to write to your user data directory
2. Ensure you have sufficient disk space (at least 1GB free)
3. Check the Godot console for error messages

### Performance Issues During Recording

If you experience performance issues during recording:

1. Close other applications to free up system resources
2. Reduce the recording resolution by adjusting your game window size
3. Disable some visual effects in the cinematic scene
4. Try recording on a more powerful computer

### Missing VideoStreamWriter Class

The original recording system used the `VideoStreamWriter` class, which may not be available in all Godot versions or builds. The current system uses PNG screenshots instead, which is more compatible across different Godot versions.

## Technical Details

The recording functionality captures frames from the viewport at regular intervals and saves them as PNG files. The process is managed by the `CinematicRecorder` node in the recording scene.

The recording captures:

- All visual elements including particle effects, lighting, and UI
- The full day-night cycle with all time-of-day transitions
- All meditation text displays

Note that audio is not captured in the image sequence. If you need audio, you'll need to add it separately in your video editing software.

## Using the Recorded Video

The final video can be:

- Shared on social media or video platforms
- Used in presentations or demonstrations
- Included in documentation or tutorials
- Edited further with video editing software

## Credits

When sharing the recorded video, please include attribution to the Hortus Conclusus project and its creators.
