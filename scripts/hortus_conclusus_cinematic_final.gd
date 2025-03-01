extends Node3D
class_name HortusConclususCinematic

# Import helper functions
const Helpers = preload("res://scripts/hortus_conclusus_cinematic_helpers.gd")
const Connections = preload("res://scripts/hortus_conclusus_cinematic_connections.gd")

# References to key nodes
@onready var camera_path = $CameraPath
@onready var path_follow = $CameraPath/PathFollow3D
@onready var camera = $CameraPath/PathFollow3D/Camera3D
@onready var animation_player = $AnimationPlayer
@onready var atmosphere_controller = $AtmosphereController
@onready var meditation_display = $MeditationDisplay
@onready var fade_overlay = $UI/FadeOverlay
@onready var timer = $Timer
@onready var shader_controller = $ShaderController
@onready var audio_player = $AudioStreamPlayer
@onready var title_label = $UI/Title
@onready var meditation_label = $UI/Meditation
@onready var world_environment = $WorldEnvironment

# Garden elements
@onready var monastic_garden = $GardenElements/MonasticGarden
@onready var knot_garden = $GardenElements/KnotGarden
@onready var raised_garden = $GardenElements/RaisedGarden

# Constants
const UP_VECTOR = Vector3(0, 1, 0)

[Previous content remains the same until _update_camera_focus function...]

# Update camera focus
func _update_camera_focus():
    if not camera or not camera_focus_point:
        return
    
    # Gradually rotate camera to look at focus point
    var target_rotation = camera.global_transform.looking_at(camera_focus_point, UpVectorHandler.get_up_vector()).basis.get_euler()
    var current_rotation = camera.rotation
    
    # Smoothly interpolate rotation
    camera.rotation = current_rotation.lerp(target_rotation, 0.02)

# Get up vector (used by camera system)
func get_up_vector() -> Vector3:
    return UpVectorHandler.get_up_vector()

# This function is called by other scripts that need the up vector
func up() -> Vector3:
    return UpVectorHandler.up()

[Rest of the file remains the same...]
