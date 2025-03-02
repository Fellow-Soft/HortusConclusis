extends Node

# Ambrose Godot Bridge
# This script provides the interface between the Python-based Ambrose agent and the Godot game engine
# Attach this script to a node in your scene to enable Ambrose's presence in the game

# Signals
signal ambrose_message_received(message)
signal ambrose_command_executed(command_name, result)
signal ambrose_voice_started(text)
signal ambrose_voice_ended

# Configuration
@export var python_path: String = "python"  # Path to Python executable
@export var agent_script_path: String = "res://scripts/ai/ambrose_agent.py"  # Path to the Ambrose agent script
@export var use_voice: bool = true  # Whether to use voice for Ambrose
@export var debug_mode: bool = false  # Whether to enable debug mode
@export var auto_start: bool = true  # Whether to start Ambrose automatically

# UI References
@export_node_path var chat_panel_path: NodePath
@export_node_path var chat_input_path: NodePath
@export_node_path var chat_output_path: NodePath
@export_node_path var voice_button_path: NodePath
@export_node_path var ambrose_portrait_path: NodePath

# Private variables
var _ambrose_process = null
var _stdin_thread = null
var _stdout_thread = null
var _is_listening = false
var _conversation_history = []
var _command_queue = []
var _is_speaking = false

# UI nodes
var chat_panel = null
var chat_input = null
var chat_output = null
var voice_button = null
var ambrose_portrait = null

# Called when the node enters the scene tree for the first time
func _ready():
	# Get UI references
	if chat_panel_path:
		chat_panel = get_node(chat_panel_path)
	if chat_input_path:
		chat_input = get_node(chat_input_path)
	if chat_output_path:
		chat_output = get_node(chat_output_path)
	if voice_button_path:
		voice_button = get_node(voice_button_path)
	if ambrose_portrait_path:
		ambrose_portrait = get_node(ambrose_portrait_path)
	
	# Set up UI connections
	if chat_input:
		chat_input.connect("text_submitted", Callable(self, "_on_chat_input_submitted"))
	if voice_button:
		voice_button.connect("pressed", Callable(self, "_on_voice_button_pressed"))
	
	# Auto-start if configured
	if auto_start:
		call_deferred("start_ambrose")

# Start the Ambrose agent process
func start_ambrose():
	if _ambrose_process != null:
		print("Ambrose is already running")
		return
	
	if debug_mode:
		print("Starting Ambrose agent...")
	
	# Convert the resource path to an absolute path
	var script_path = ProjectSettings.globalize_path(agent_script_path)
	
	# Create the process
	_ambrose_process = OS.create_process(python_path, [script_path])
	
	if _ambrose_process == -1:
		push_error("Failed to start Ambrose agent process")
		return
	
	if debug_mode:
		print("Ambrose agent started with PID: ", _ambrose_process)
	
	# Start threads for stdin/stdout communication
	_start_communication_threads()
	
	# Send initial greeting
	send_message("Hello, Ambrose. Please introduce yourself to the player.")

# Stop the Ambrose agent process
func stop_ambrose():
	if _ambrose_process == null:
		return
	
	if debug_mode:
		print("Stopping Ambrose agent...")
	
	# Send exit command to the process
	OS.kill(_ambrose_process)
	_ambrose_process = null
	
	# Clean up threads
	if _stdin_thread:
		_stdin_thread.wait_to_finish()
		_stdin_thread = null
	
	if _stdout_thread:
		_stdout_thread.wait_to_finish()
		_stdout_thread = null
	
	if debug_mode:
		print("Ambrose agent stopped")

# Start threads for communication with the Ambrose process
func _start_communication_threads():
	# Thread for sending messages to Ambrose
	_stdin_thread = Thread.new()
	_stdin_thread.start(Callable(self, "_stdin_thread_function"))
	
	# Thread for receiving messages from Ambrose
	_stdout_thread = Thread.new()
	_stdout_thread.start(Callable(self, "_stdout_thread_function"))

# Thread function for sending messages to Ambrose
func _stdin_thread_function():
	while _ambrose_process != null:
		if not _command_queue.is_empty():
			var command = _command_queue.pop_front()
			# Send the command to the process stdin
			# This is a placeholder - actual implementation would depend on how
			# the Python process is set up to receive commands
			if debug_mode:
				print("Sending command to Ambrose: ", command)
		
		# Sleep to avoid hogging CPU
		OS.delay_msec(100)

# Thread function for receiving messages from Ambrose
func _stdout_thread_function():
	while _ambrose_process != null:
		# Read from the process stdout
		# This is a placeholder - actual implementation would depend on how
		# the Python process is set up to send messages
		
		# For now, we'll simulate receiving messages
		OS.delay_msec(1000)  # Sleep to avoid hogging CPU

# Send a message to Ambrose
func send_message(message: String):
	if _ambrose_process == null:
		push_error("Ambrose agent is not running")
		return
	
	# Add to command queue
	_command_queue.append(message)
	
	# Add to conversation history
	_conversation_history.append({"role": "user", "content": message})
	
	# Update UI
	if chat_output:
		chat_output.text += "\nYou: " + message
		chat_output.scroll_vertical = chat_output.get_line_count()
	
	if chat_input:
		chat_input.text = ""

# Handle received message from Ambrose
func _handle_received_message(message: String):
	# Add to conversation history
	_conversation_history.append({"role": "assistant", "content": message})
	
	# Update UI
	if chat_output:
		chat_output.text += "\nAmbrose: " + message
		chat_output.scroll_vertical = chat_output.get_line_count()
	
	# Emit signal
	emit_signal("ambrose_message_received", message)
	
	# Speak the message if voice is enabled
	if use_voice and not _is_speaking:
		speak_text(message)

# Speak text using text-to-speech
func speak_text(text: String, voice_id: String = "medieval_male"):
	if _is_speaking:
		return
	
	_is_speaking = true
	emit_signal("ambrose_voice_started", text)
	
	# Animate portrait if available
	if ambrose_portrait:
		ambrose_portrait.play("speaking")
	
	# In a real implementation, this would call the TTS system
	# For now, we'll just simulate speaking with a timer
	var speak_timer = Timer.new()
	add_child(speak_timer)
	speak_timer.wait_time = 2.0  # Simulate speaking time
	speak_timer.one_shot = true
	speak_timer.connect("timeout", Callable(self, "_on_speak_finished"))
	speak_timer.start()

# Called when speaking finishes
func _on_speak_finished():
	_is_speaking = false
	emit_signal("ambrose_voice_ended")
	
	# Reset portrait animation if available
	if ambrose_portrait:
		ambrose_portrait.play("idle")
	
	# Remove the timer
	var timer = get_child(get_child_count() - 1)
	timer.queue_free()

# Execute a command in the game
func execute_command(command_name: String, args: Dictionary = {}):
	if debug_mode:
		print("Executing command: ", command_name, " with args: ", args)
	
	var result = null
	
	# Handle different commands
	match command_name:
		"show_meditation":
			var section = args.get("section", null)
			result = _show_meditation(section)
		
		"create_plant":
			var plant_type = args.get("plant_type", "generic")
			var location = args.get("location", Vector3(0, 0, 0))
			var properties = args.get("properties", {})
			result = _create_plant(plant_type, location, properties)
		
		"generate_texture":
			var texture_type = args.get("texture_type", "generic")
			var variation = args.get("variation", "default")
			result = _generate_texture(texture_type, variation)
		
		"modify_garden":
			var element_type = args.get("element_type", "")
			var element_id = args.get("element_id", "")
			var properties = args.get("properties", {})
			result = _modify_garden(element_type, element_id, properties)
		
		_:
			result = {"success": false, "message": "Unknown command: " + command_name}
	
	# Emit signal with result
	emit_signal("ambrose_command_executed", command_name, result)
	
	return result

# Show meditation
func _show_meditation(section = null):
	# Find the meditation display node
	var meditation_display = get_tree().get_nodes_in_group("meditation_display")
	if meditation_display.size() > 0:
		if section:
			meditation_display[0].show_meditation_section(section)
		else:
			meditation_display[0].show_meditation()
		return {"success": true, "message": "Showing meditation" + (" section: " + section if section else "")}
	else:
		return {"success": false, "message": "Meditation display not found"}

# References to required systems
@onready var placement_system = get_tree().get_nodes_in_group("placement_system")[0]
@onready var growth_system = get_tree().get_nodes_in_group("growth_system")[0]
@onready var plant_generator = get_tree().get_nodes_in_group("plant_generator")[0]

# Create a plant in the garden using procedural generation
func _create_plant(plant_type: String, location: Vector3, properties: Dictionary = {}):
	if not (placement_system and growth_system and plant_generator):
		return {
			"success": false,
			"message": "Required systems not found"
		}
	
	# Generate a unique ID for the plant
	var plant_id = "plant_" + str(Time.get_unix_time_from_system())
	
	# Initialize plant in growth system
	growth_system.add_plant(
		plant_id,
		properties.get("symbolism", ""),
		properties.get("uses", [])
	)
	
	# Generate initial plant model
	var plant_model = plant_generator.generate_plant(
		plant_type,
		PlantGrowthSystem.GrowthStage.SEED,  # Start as seed
		growth_system.current_season
	)
	
	# Add divine particle effect for planting
	var particles = GPUParticles3D.new()
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 1.0
	material.gravity = Vector3.UP * 0.5
	material.color = Color(1.0, 1.0, 0.8, 0.3)
	particles.process_material = material
	particles.amount = 30
	particles.lifetime = 3.0
	particles.one_shot = true
	plant_model.add_child(particles)
	
	# Position the plant
	plant_model.global_position = location
	plant_model.set_meta("plant_id", plant_id)
	
	# Set rotation if specified
	if "rotation" in properties:
		plant_model.rotation.y = deg_to_rad(properties["rotation"])
	
	# Add to scene
	add_child(plant_model)
	
	# Connect signals for growth stage changes
	growth_system.connect("plant_stage_changed",
		Callable(self, "_on_plant_stage_changed").bind(plant_model))
	
	return {
		"success": true,
		"message": "Created " + plant_type + " through divine inspiration",
		"plant_id": plant_id
	}

# Handle plant growth stage changes
func _on_plant_stage_changed(plant_id: String, old_stage: int, new_stage: int, plant_model: Node3D):
	if plant_model.get_meta("plant_id") != plant_id:
		return
	
	# Generate new model for this growth stage
	var new_model = plant_generator.generate_plant(
		plant_model.name,  # Use current plant type
		new_stage,
		growth_system.current_season
	)
	
	# Transfer position and rotation
	new_model.global_position = plant_model.global_position
	new_model.rotation = plant_model.rotation
	new_model.set_meta("plant_id", plant_id)
	
	# Replace old model
	var parent = plant_model.get_parent()
	parent.add_child(new_model)
	plant_model.queue_free()
	
	# Add divine effect for growth transition
	if new_stage in [PlantGrowthSystem.GrowthStage.FLOWERING, PlantGrowthSystem.GrowthStage.FRUITING]:
		var particles = GPUParticles3D.new()
		var material = ParticleProcessMaterial.new()
		material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		material.emission_sphere_radius = 0.5
		material.gravity = Vector3.UP * 0.2
		material.color = Color(1.0, 1.0, 0.8, 0.4)
		particles.process_material = material
		particles.amount = 20
		particles.lifetime = 2.0
		particles.one_shot = true
		new_model.add_child(particles)

# Generate a texture
func _generate_texture(texture_type: String, variation: String = "default"):
	# This would call the texture generator
	# For now, return a placeholder result
	return {
		"success": true,
		"texture_path": "res://assets/textures/medieval_garden_pack/" + texture_type + "/" + variation + ".png",
		"message": "Generated " + variation + " " + texture_type + " texture"
	}

# Modify an aspect of the garden
func _modify_garden(element_type: String, element_id: String, properties: Dictionary = {}):
	# This would call the garden modification system
	# For now, return a placeholder result
	return {
		"success": true,
		"message": "Modified " + element_type + " " + element_id
	}

# UI event handlers
func _on_chat_input_submitted(text: String):
	if text.strip_edges() != "":
		send_message(text)

func _on_voice_button_pressed():
	if _is_listening:
		# Stop listening
		_is_listening = false
		if voice_button:
			voice_button.text = "Speak to Ambrose"
	else:
		# Start listening
		_is_listening = true
		if voice_button:
			voice_button.text = "Listening..."
		
		# In a real implementation, this would start the speech recognition
		# For now, we'll just simulate it with a timer
		var listen_timer = Timer.new()
		add_child(listen_timer)
		listen_timer.wait_time = 3.0  # Simulate listening time
		listen_timer.one_shot = true
		listen_timer.connect("timeout", Callable(self, "_on_listen_finished"))
		listen_timer.start()

# Called when listening finishes
func _on_listen_finished():
	_is_listening = false
	if voice_button:
		voice_button.text = "Speak to Ambrose"
	
	# Remove the timer
	var timer = get_child(get_child_count() - 1)
	timer.queue_free()
	
	# Simulate recognized speech
	var simulated_text = "Tell me about medieval gardens"
	send_message(simulated_text)

# Called when the node is about to be removed from the scene
func _exit_tree():
	stop_ambrose()
