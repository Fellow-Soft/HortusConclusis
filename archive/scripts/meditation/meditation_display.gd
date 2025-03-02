extends Node

# Meditation Display Script
# Displays the meditation text in-game as an interactive element
# Attach this script to a Node in your scene

@onready var meditation_panel = $MeditationPanel
@onready var meditation_text = $MeditationPanel/ScrollContainer/MeditationText
@onready var next_button = $MeditationPanel/NextButton
@onready var close_button = $MeditationPanel/CloseButton
@onready var background = $MeditationPanel/Background
@onready var title_label = $MeditationPanel/TitleLabel

# Meditation text sections
var meditation_sections = []
var current_section = 0
var meditation_visible = false

# Appearance settings
var scroll_speed = 50  # Text scroll speed
var background_color = Color(0.1, 0.1, 0.1, 0.85)  # Dark, semi-transparent background
var text_color = Color(0.9, 0.9, 0.8)  # Slightly off-white, parchment-like
var title_color = Color(0.8, 0.7, 0.5)  # Gold-like color for titles

func _ready():
	# Hide the meditation panel initially
	if meditation_panel:
		meditation_panel.visible = false
	
	# Load the meditation text from file
	load_meditation_text()
	
	# Connect button signals
	if next_button:
		next_button.connect("pressed", Callable(self, "_on_next_button_pressed"))
	
	if close_button:
		close_button.connect("pressed", Callable(self, "_on_close_button_pressed"))
	
	# Set up appearance
	setup_appearance()

func load_meditation_text():
	# Load the meditation text from the markdown file
	var file = FileAccess.open("res://MEDITATION.md", FileAccess.READ)
	if file:
		var current_title = ""
		var current_content = ""
		var in_section = false
		
		while not file.eof_reached():
			var line = file.get_line()
			
			# Check for section headers (## in markdown)
			if line.begins_with("## "):
				# If we were already in a section, save it before starting a new one
				if in_section:
					meditation_sections.append({
						"title": current_title,
						"content": current_content
					})
				
				# Start a new section
				current_title = line.substr(3).strip_edges()
				current_content = ""
				in_section = true
			
			# Skip other headers or separators
			elif line.begins_with("#") or line.begins_with("---") or line.begins_with("*"):
				continue
			
			# Add content lines to the current section
			elif in_section:
				# Add the line to the current content
				current_content += line + "\n"
		
		# Add the last section
		if in_section:
			meditation_sections.append({
				"title": current_title,
				"content": current_content
			})
		
		file.close()
	else:
		# If file can't be loaded, add a default message
		meditation_sections.append({
			"title": "The Garden Awaits",
			"content": "The meditation text could not be loaded.\nPerhaps the garden is not yet ready for contemplation."
		})

func setup_appearance():
	if background:
		background.color = background_color
	
	if meditation_text:
		meditation_text.add_theme_color_override("default_color", text_color)
		meditation_text.add_theme_font_size_override("normal_font_size", 18)
	
	if title_label:
		title_label.add_theme_color_override("font_color", title_color)
		title_label.add_theme_font_size_override("font_size", 24)

func show_meditation():
	if meditation_panel and meditation_sections.size() > 0:
		meditation_panel.visible = true
		meditation_visible = true
		display_current_section()

func hide_meditation():
	if meditation_panel:
		meditation_panel.visible = false
		meditation_visible = false

func display_current_section():
	if current_section < meditation_sections.size():
		var section = meditation_sections[current_section]
		
		if title_label:
			title_label.text = section.title
		
		if meditation_text:
			meditation_text.text = section.content
		
		# Update next button text based on whether this is the last section
		if next_button:
			if current_section < meditation_sections.size() - 1:
				next_button.text = "Next"
			else:
				next_button.text = "Finish"

func _on_next_button_pressed():
	if current_section < meditation_sections.size() - 1:
		# Move to the next section
		current_section += 1
		display_current_section()
	else:
		# This was the last section, close the meditation
		hide_meditation()
		current_section = 0  # Reset for next time

func _on_close_button_pressed():
	hide_meditation()
	current_section = 0  # Reset for next time

func _input(event):
	# Toggle meditation display with the M key
	if event is InputEventKey and event.pressed and event.keycode == KEY_M:
		if meditation_visible:
			hide_meditation()
		else:
			show_meditation()
	
	# Also allow space or enter to advance to the next section
	if meditation_visible and event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_on_next_button_pressed()

# Call this function from other scripts to show the meditation
func trigger_meditation():
	show_meditation()
