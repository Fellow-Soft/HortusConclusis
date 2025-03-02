extends Control

# Medieval Ambrose Interface
# This script provides a stylized medieval chat interface for Ambrose in the garden demo

# Signals
signal message_sent(text)
signal toggle_chat_requested
signal voice_requested

# Configuration
@export var auto_open: bool = false
@export var show_toggle_button: bool = true
@export var initial_message: String = "Greetings, traveler. I am Ambrose, the keeper of this sacred garden. How may I assist thee on thy journey through this hortus conclusus?"

# UI References
@onready var chat_panel = $ChatPanel
@onready var chat_output = $ChatPanel/OutputContainer/ChatOutput
@onready var chat_input = $ChatPanel/InputContainer/ChatInput
@onready var voice_button = $ChatPanel/InputContainer/VoiceButton
@onready var toggle_button = $ToggleButton
@onready var ambrose_portrait = $PortraitContainer/AmbrosePortrait
@onready var status_label = $ChatPanel/StatusLabel

# Private variables
var _is_open: bool = false
var _is_speaking: bool = false
var _conversation_history = []

# Called when the node enters the scene tree for the first time
func _ready():
	# Set up UI connections
	chat_input.connect("text_submitted", Callable(self, "_on_chat_input_submitted"))
	voice_button.connect("pressed", Callable(self, "_on_voice_button_pressed"))
	
	if toggle_button and show_toggle_button:
		toggle_button.connect("pressed", Callable(self, "_on_toggle_button_pressed"))
		toggle_button.visible = true
	else:
		toggle_button.visible = false
	
	# Initialize chat state
	if auto_open:
		_is_open = true
	else:
		_is_open = false
	
	# Update UI based on initial state
	_update_chat_visibility()
	
	# Add initial message if provided
	if initial_message != "":
		add_message("Ambrose", initial_message)

# Add a message to the chat
func add_message(sender: String, message: String):
	# Add to conversation history
	_conversation_history.append({"sender": sender, "message": message})
	
	# Format the message with medieval styling
	var formatted_message = ""
	
	if sender == "Ambrose":
		formatted_message = "[color=#5c3c1d][b]Ambrose:[/b][/color] [i]" + message + "[/i]"
	else:
		formatted_message = "[color=#1d3c5c][b]Thee:[/b][/color] " + message
	
	# Add to chat output
	chat_output.append_text("\n\n" + formatted_message)
	
	# Scroll to bottom
	chat_output.scroll_to_line(chat_output.get_line_count())
	
	# If Ambrose is speaking, animate the portrait
	if sender == "Ambrose":
		_speak(message)

# Send a message from the player
func send_message(text: String):
	if text.strip_edges() == "":
		return
	
	# Add to chat
	add_message("Player", text)
	
	# Clear input
	chat_input.text = ""
	
	# Show status
	status_label.text = "Ambrose is pondering thy words..."
	status_label.visible = true
	
	# Emit signal for processing
	emit_signal("message_sent", text)

# Set Ambrose's response
func set_response(text: String):
	# Hide status
	status_label.visible = false
	
	# Add response to chat
	add_message("Ambrose", text)

# Toggle the chat panel visibility
func toggle_chat():
	_is_open = !_is_open
	_update_chat_visibility()

# Show the chat panel
func show_chat():
	_is_open = true
	_update_chat_visibility()

# Hide the chat panel
func hide_chat():
	_is_open = false
	_update_chat_visibility()

# Update the chat panel visibility based on state
func _update_chat_visibility():
	if chat_panel:
		chat_panel.visible = _is_open
	
	if toggle_button:
		if _is_open:
			toggle_button.text = "Close Scroll"
		else:
			toggle_button.text = "Speak with Ambrose"

# Simulate Ambrose speaking
func _speak(text: String):
	if _is_speaking:
		return
	
	_is_speaking = true
	
	# Animate portrait if available
	if ambrose_portrait:
		ambrose_portrait.play("speaking")
	
	# Calculate speaking time based on text length
	var speak_time = min(max(2.0, text.length() * 0.05), 10.0)
	
	# Create a timer for speaking duration
	var speak_timer = Timer.new()
	add_child(speak_timer)
	speak_timer.wait_time = speak_time
	speak_timer.one_shot = true
	speak_timer.connect("timeout", Callable(self, "_on_speak_finished"))
	speak_timer.start()

# Called when speaking finishes
func _on_speak_finished():
	_is_speaking = false
	
	# Reset portrait animation if available
	if ambrose_portrait:
		ambrose_portrait.play("idle")
	
	# Remove the timer
	var timer = get_child(get_child_count() - 1)
	timer.queue_free()

# UI event handlers
func _on_chat_input_submitted(text: String):
	send_message(text)

func _on_voice_button_pressed():
	emit_signal("voice_requested")

func _on_toggle_button_pressed():
	toggle_chat()
