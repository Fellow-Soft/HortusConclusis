extends Control

# References to nodes
@onready var logo = $Logo
@onready var animation_player = $AnimationPlayer
@onready var background_music = $BackgroundMusic

# Path to the main scene
const MAIN_SCENE_PATH = "res://scenes/medieval_garden_demo.tscn"

# Called when the node enters the scene tree for the first time
func _ready():
	# Start the fade-in animation
	animation_player.play("splash_sequence")
	
	# Play background music
	if background_music and background_music.stream:
		background_music.play()

# Called when the animation finishes
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "splash_sequence":
		# Keep the music playing by removing it from the scene tree
		# and making it a singleton that persists across scene changes
		var music_player = $BackgroundMusic
		if music_player:
			remove_child(music_player)
			get_tree().root.add_child(music_player)
			music_player.name = "PersistentMusicPlayer"
		
		# Load the main scene
		get_tree().change_scene_to_file(MAIN_SCENE_PATH)
