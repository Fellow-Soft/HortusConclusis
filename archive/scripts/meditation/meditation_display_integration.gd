extends Node
class_name MeditationDisplayIntegration

# Constants
const MeditationDisplayAdvanced = preload("res://scripts/meditation_display_advanced.gd")

# References to required nodes
var cinematic_controller: Node
var meditation_display: MeditationDisplayAdvanced
var atmosphere_controller: Node

# Time of day parameters
var current_time_of_day: String = "dawn"
var time_of_day_parameters = {
    "dawn": {
        "breathing_amplitude": 0.02,
        "breathing_frequency": 0.3,
        "letter_spacing_variation": 1.5,
        "display_speed": 0.05,
        "particle_emission_rate": 0.15
    },
    "noon": {
        "breathing_amplitude": 0.01,
        "breathing_frequency": 0.4,
        "letter_spacing_variation": 1.0,
        "display_speed": 0.04,
        "particle_emission_rate": 0.1
    },
    "dusk": {
        "breathing_amplitude": 0.03,
        "breathing_frequency": 0.25,
        "letter_spacing_variation": 2.0,
        "display_speed": 0.06,
        "particle_emission_rate": 0.2
    },
    "night": {
        "breathing_amplitude": 0.04,
        "breathing_frequency": 0.2,
        "letter_spacing_variation": 2.5,
        "display_speed": 0.07,
        "particle_emission_rate": 0.25
    }
}

# Meditation texts for different times of day
var meditation_texts = {}

# Signals
signal meditation_started(time_of_day)
signal meditation_completed(time_of_day)

# Initialize the integration
func initialize(controller: Node, label: Label, atmosphere: Node):
    cinematic_controller = controller
    atmosphere_controller = atmosphere
    
    # Create enhanced meditation display
    meditation_display = MeditationDisplayAdvanced.new()
    add_child(meditation_display)
    
    # Connect to the label
    meditation_display.text_label = label
    
    # Configure meditation display
    _configure_meditation_display()
    
    # Connect signals
    if meditation_display:
        meditation_display.connect("display_started", Callable(self, "_on_meditation_display_started"))
        meditation_display.connect("display_completed", Callable(self, "_on_meditation_display_completed"))
    
    if atmosphere_controller and atmosphere_controller.has_signal("time_changed"):
        atmosphere_controller.connect("time_changed", Callable(self, "_on_time_changed"))
    
    # Load meditation texts
    _load_meditation_texts()

# Configure the meditation display with default settings
func _configure_meditation_display():
    if not meditation_display:
        return
    
    # Set default durations
    meditation_display.set_durations(2.0, 10.0, 2.0)
    
    # Set default letter reveal speed
    meditation_display.set_letter_reveal_speed(0.05)
    
    # Enable features
    meditation_display.set_calligraphic_styling(true)
    meditation_display.set_color_transitions(true)
    meditation_display.set_text_breathing(true)
    meditation_display.set_letter_spacing_variation(true)
    meditation_display.set_particle_effects(true)
    
    # Set initial color scheme
    meditation_display.set_color_scheme(current_time_of_day)
    
    # Apply time-of-day specific parameters
    _apply_time_of_day_parameters(current_time_of_day)

# Load meditation texts from the cinematic controller
func _load_meditation_texts():
    if not cinematic_controller:
        return
    
    # Try to get meditation texts from the controller
    if cinematic_controller.has_method("get_meditation_texts"):
        meditation_texts = cinematic_controller.get_meditation_texts()
    elif "MEDITATIONS" in cinematic_controller:
        meditation_texts = cinematic_controller.MEDITATIONS
    else:
        # Fallback meditation texts
        meditation_texts = {
            "dawn": [
                "As morning light filters through the mist,",
                "Sacred patterns emerge from darkness,",
                "The garden awakens to divine geometry,",
                "Each plant a symbol of celestial order."
            ],
            "noon": [
                "In the fullness of day, the garden reveals its wisdom,",
                "Herbs arranged in patterns of the Trinity,",
                "Roses in five-fold symmetry honoring the Virgin,",
                "The cosmic order made manifest in living form."
            ],
            "dusk": [
                "As shadows lengthen across the garden paths,",
                "The day's work completed in sacred harmony,",
                "Plants return their essence to the fading light,",
                "Preparing for night's contemplative silence."
            ],
            "night": [
                "Under starlight, the garden dreams of eternity,",
                "Divine patterns continue their silent growth,",
                "In darkness, the soul finds its deepest truths,",
                "As above in the heavens, so below in the garden."
            ]
        }

# Apply time-of-day specific parameters to the meditation display
func _apply_time_of_day_parameters(time_of_day: String):
    if not meditation_display or not time_of_day in time_of_day_parameters:
        return
    
    var params = time_of_day_parameters[time_of_day]
    
    # Apply breathing parameters
    meditation_display.breathing_amplitude = params.breathing_amplitude
    meditation_display.breathing_frequency = params.breathing_frequency
    
    # Apply letter spacing variation
    meditation_display.letter_spacing_variation = params.letter_spacing_variation
    
    # Apply display speed
    meditation_display.set_letter_reveal_speed(params.display_speed)
    
    # Apply particle emission rate
    meditation_display.particle_emission_rate = params.particle_emission_rate
    
    # Apply color scheme
    meditation_display.set_color_scheme(time_of_day)

# Display meditation text for a specific time of day
func display_meditation(time_of_day: String):
    if not meditation_display or not time_of_day in meditation_texts:
        return
    
    # Update current time of day
    current_time_of_day = time_of_day
    
    # Apply time-of-day specific parameters
    _apply_time_of_day_parameters(time_of_day)
    
    # Set and display the text
    var text = meditation_texts[time_of_day].join("\n")
    meditation_display.set_text(text)
    meditation_display.start_display()

# Restart the current meditation
func restart_meditation():
    if not meditation_display:
        return
    
    meditation_display.restart_display()

# Stop the current meditation
func stop_meditation():
    if not meditation_display:
        return
    
    meditation_display.stop_display()

# Fade out the meditation text
func fade_out_meditation():
    if not meditation_display:
        return
    
    meditation_display.fade_out()

# Set the durations for the meditation display
func set_durations(fade_in: float, display: float, fade_out: float):
    if not meditation_display:
        return
    
    meditation_display.set_durations(fade_in, display, fade_out)

# Customize time-of-day parameters
func customize_time_of_day_parameters(time_of_day: String, parameters: Dictionary):
    if not time_of_day in time_of_day_parameters:
        time_of_day_parameters[time_of_day] = {}
    
    # Update parameters
    for key in parameters:
        time_of_day_parameters[time_of_day][key] = parameters[key]
    
    # Apply if this is the current time of day
    if time_of_day == current_time_of_day:
        _apply_time_of_day_parameters(time_of_day)

# Create a dawn meditation sequence
func create_dawn_meditation_sequence():
    if not meditation_display:
        return
    
    # Configure for dawn
    current_time_of_day = "dawn"
    _apply_time_of_day_parameters("dawn")
    
    # Set durations for dawn (longer fade in, medium display)
    meditation_display.set_durations(3.0, 12.0, 2.0)
    
    # Display the meditation
    display_meditation("dawn")

# Create a noon meditation sequence
func create_noon_meditation_sequence():
    if not meditation_display:
        return
    
    # Configure for noon
    current_time_of_day = "noon"
    _apply_time_of_day_parameters("noon")
    
    # Set durations for noon (quick fade in, longer display)
    meditation_display.set_durations(1.5, 15.0, 2.0)
    
    # Display the meditation
    display_meditation("noon")

# Create a dusk meditation sequence
func create_dusk_meditation_sequence():
    if not meditation_display:
        return
    
    # Configure for dusk
    current_time_of_day = "dusk"
    _apply_time_of_day_parameters("dusk")
    
    # Set durations for dusk (medium fade in, medium display)
    meditation_display.set_durations(2.5, 12.0, 3.0)
    
    # Display the meditation
    display_meditation("dusk")

# Create a night meditation sequence
func create_night_meditation_sequence():
    if not meditation_display:
        return
    
    # Configure for night
    current_time_of_day = "night"
    _apply_time_of_day_parameters("night")
    
    # Set durations for night (slow fade in, long display)
    meditation_display.set_durations(4.0, 18.0, 3.0)
    
    # Display the meditation
    display_meditation("night")

# Signal handlers
func _on_meditation_display_started():
    emit_signal("meditation_started", current_time_of_day)

func _on_meditation_display_completed():
    emit_signal("meditation_completed", current_time_of_day)

func _on_time_changed(time: String):
    # Update meditation display when time of day changes
    current_time_of_day = time
    _apply_time_of_day_parameters(time)
    
    # Display the meditation for the new time of day
    display_meditation(time)
