import os
import sys
import json
import time
import threading
import requests
from typing import Dict, List, Any, Optional, Callable

# Add the project root to the path so we can import our modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

# Import configuration
from scripts.ai.config import (
    CLAUDE_API_KEY, 
    CLAUDE_API_URL, 
    CLAUDE_MODEL,
    USE_VOICE,
    VOICE_ID,
    DEBUG_MODE,
    CUSTOM_INSTRUCTION_PATH
)

# Import Godot integration
try:
    import godot_bridge
except ImportError:
    print("Warning: godot_bridge module not found. Running in standalone mode.")
    godot_bridge = None

# Import voice system
from scripts.interaction.voice_system import VoiceSystem

# Import command executor
from scripts.interaction.command_executor import CommandExecutor

class AmbroseAgent:
    """
    Ambrose Agent - The Gardener of Hortus Conclusus
    
    This agent integrates Claude 3.7 to provide an interactive gardener character
    that can converse with the player and execute commands within the game.
    """
    
    def __init__(self, 
                 api_key: Optional[str] = None, 
                 use_voice: bool = USE_VOICE,
                 debug: bool = DEBUG_MODE,
                 voice_id: str = VOICE_ID):
        """Initialize the Ambrose Agent"""
        self.api_key = api_key or CLAUDE_API_KEY
        self.debug = debug
        self.conversation_history = []
        self.system_prompt = self._load_system_prompt()
        
        # Initialize the command executor
        self.executor = CommandExecutor(debug=debug)
        
        # Initialize voice system if enabled
        self.voice_system = VoiceSystem(voice_id=voice_id, debug=debug) if use_voice else None
        
        # Register available commands
        self._register_commands()
        
        if self.debug:
            print("Ambrose Agent initialized")
            print(f"Using model: {CLAUDE_MODEL}")
            print(f"API key configured: {'Yes' if self.api_key else 'No'}")
            print(f"Voice system enabled: {use_voice}")
    
    def _load_system_prompt(self) -> str:
        """Load the system prompt from the Gardener's Codex"""
        try:
            # Determine the path to the custom instruction file
            custom_instruction_path = os.path.join(
                os.path.dirname(os.path.dirname(os.path.dirname(__file__))), 
                "CUSTOM_INSTRUCTION.md"
            )
            
            # Load the custom instruction as the system prompt
            with open(custom_instruction_path, "r") as f:
                system_prompt = f.read()
            
            # Add additional context for in-game interaction
            system_prompt += "\n\n# In-Game Context\n\n"
            system_prompt += "You are Ambrose, the Gardener of Hortus Conclusus, manifested within the garden itself. "
            system_prompt += "You can interact with the player through conversation and can execute commands to modify the garden. "
            system_prompt += "Always stay in character as Ambrose, speaking with the wisdom and perspective of a medieval gardener "
            system_prompt += "while still being able to understand and execute modern commands. "
            system_prompt += "When the player asks you to create or modify something in the garden, identify the appropriate command "
            system_prompt += "and execute it using the command_execute function."
            
            if self.debug:
                print(f"Loaded system prompt from {custom_instruction_path}")
            
            return system_prompt
        except Exception as e:
            print(f"Error loading system prompt: {e}")
            return "You are Ambrose, the Gardener of Hortus Conclusus."
    
    def _register_commands(self):
        """Register available commands that Ambrose can execute"""
        # Register texture generation commands
        self.executor.register_command(
            "generate_texture", 
            self._generate_texture,
            "Generate a new texture for the garden",
            ["texture_type", "variation"]
        )
        
        # Register plant creation commands
        self.executor.register_command(
            "create_plant", 
            self._create_plant,
            "Create a new plant in the garden",
            ["plant_type", "location", "properties"]
        )
        
        # Register garden modification commands
        self.executor.register_command(
            "modify_garden", 
            self._modify_garden,
            "Modify an aspect of the garden",
            ["element_type", "element_id", "properties"]
        )
        
        # Register meditation commands
        self.executor.register_command(
            "show_meditation", 
            self._show_meditation,
            "Display a meditation about the garden",
            ["section"]
        )
    
    def _generate_texture(self, texture_type: str, variation: str = "default") -> Dict[str, Any]:
        """Generate a new texture using the texture generator"""
        if self.debug:
            print(f"Generating texture: {texture_type}, variation: {variation}")
        
        # This would call the actual texture generator
        # For now, return a placeholder response
        return {
            "success": True,
            "texture_path": f"res://assets/textures/medieval_garden_pack/{texture_type}/{variation}.png",
            "message": f"Generated {variation} {texture_type} texture"
        }
    
    def _create_plant(self, plant_type: str, location: Dict[str, float], properties: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new plant in the garden with medieval-appropriate properties"""
        if self.debug:
            print(f"Creating plant: {plant_type} at {location}")
        
        # Convert location dict to Vector3 format expected by Godot
        godot_location = Vector3(
            location.get("x", 0),
            location.get("y", 0),
            location.get("z", 0)
        )
        
        # Add medieval-appropriate properties based on plant type
        medieval_properties = {
            "rotation": properties.get("rotation", 0),  # Default rotation
            "symbolism": self._get_plant_symbolism(plant_type),
            "uses": self._get_plant_uses(plant_type),
            "season": properties.get("season", "summer")  # Default to summer
        }
        
        # Merge with any provided properties
        medieval_properties.update(properties)
        
        if godot_bridge:
            # Use the Godot bridge to create the plant
            result = godot_bridge.call_method(
                "execute_command",
                "create_plant",
                {
                    "plant_type": plant_type,
                    "location": godot_location,
                    "properties": medieval_properties
                }
            )
            return result
        else:
            return {
                "success": False,
                "message": "Godot bridge not available"
            }
    
    def _get_plant_symbolism(self, plant_type: str) -> str:
        """Get medieval symbolism for a plant type"""
        symbolism = {
            "rose": "Love and the Virgin Mary",
            "lily": "Purity and the Holy Trinity",
            "herb": "Healing and God's providence",
            "tree": "Life and growth",
            "flowers": "Beauty of Paradise",
            "herbs": "God's healing grace"
        }
        return symbolism.get(plant_type.lower(), "Divine creation")
    
    def _get_plant_uses(self, plant_type: str) -> List[str]:
        """Get medieval uses for a plant type"""
        uses = {
            "rose": ["Medicine", "Perfume", "Decoration"],
            "lily": ["Sacred decoration", "Medicine"],
            "herb": ["Medicine", "Cooking", "Ritual"],
            "tree": ["Shade", "Fruit", "Contemplation"],
            "flowers": ["Decoration", "Medicine"],
            "herbs": ["Medicine", "Cooking", "Ritual"]
        }
        return uses.get(plant_type.lower(), ["General use"])
    
    def _modify_garden(self, element_type: str, element_id: str, properties: Dict[str, Any]) -> Dict[str, Any]:
        """Modify an aspect of the garden"""
        if self.debug:
            print(f"Modifying {element_type} {element_id} with {properties}")
        
        # This would call the garden modification system
        # For now, return a placeholder response
        return {
            "success": True,
            "message": f"Modified {element_type} {element_id}"
        }
    
    def _show_meditation(self, section: Optional[str] = None) -> Dict[str, Any]:
        """Display a meditation about the garden"""
        if self.debug:
            print(f"Showing meditation section: {section}")
        
        # This would trigger the meditation display in-game
        if godot_bridge:
            godot_bridge.call_method("show_meditation", section)
        
        return {
            "success": True,
            "message": f"Showing meditation{f' section: {section}' if section else ''}"
        }
    
    def send_message(self, message: str) -> str:
        """Send a message to Claude and get a response"""
        if not self.api_key:
            return "API key not configured. Please check the config.py file."
        
        if self.debug:
            print(f"Sending message to Claude: {message}")
        
        # Add the user message to the conversation history
        self.conversation_history.append({"role": "user", "content": message})
        
        # Prepare the API request
        headers = {
            "anthropic-version": "2023-06-01",
            "content-type": "application/json",
            "x-api-key": self.api_key
        }
        
        data = {
            "model": CLAUDE_MODEL,
            "messages": [
                {
                    "role": "user",
                    "content": message
                }
            ],
            "system": self.system_prompt,
            "max_tokens": 3200
        }
        
        try:
            if self.debug:
                print(f"Making API request to {CLAUDE_API_URL}")
                print(f"Headers: {headers}")
                print(f"Data: {json.dumps(data, indent=2)}")
            
            response = requests.post(CLAUDE_API_URL, headers=headers, json=data)
            
            if self.debug:
                print(f"Response status code: {response.status_code}")
                print(f"Response headers: {response.headers}")
                print(f"Response text: {response.text[:500]}...")  # Print first 500 chars
            
            response.raise_for_status()
            
            response_data = response.json()
            
            if self.debug:
                print(f"Received response: {json.dumps(response_data, indent=2)}")
            
            assistant_message = response_data["content"][0]["text"]
            
            # Add the assistant message to the conversation history
            self.conversation_history.append({"role": "assistant", "content": assistant_message})
            
            # Check if the response contains a command to execute
            command_result = self._extract_and_execute_command(assistant_message)
            if command_result:
                # Append the command result to the response
                assistant_message += f"\n\n[Command executed: {command_result['message']}]"
            
            return assistant_message
        
        except Exception as e:
            error_message = f"Error communicating with Claude API: {str(e)}"
            print(error_message)
            if self.debug:
                import traceback
                traceback.print_exc()
            return error_message
    
    def _extract_and_execute_command(self, message: str) -> Optional[Dict[str, Any]]:
        """Extract and execute a command from the assistant's message with medieval context"""
        message = message.lower()
        
        # Plant creation patterns
        plant_patterns = {
            "plant": ["plant", "sow", "grow", "cultivate"],
            "flower": ["flower", "bloom", "rose", "lily"],
            "herb": ["herb", "medicinal", "healing plant"],
            "tree": ["tree", "sapling", "arbor"]
        }
        
        # Location patterns
        location_terms = ["near", "by", "at", "in", "next to"]
        
        # Extract plant type and location
        if any(verb in message for verbs in plant_patterns.values() for verb in verbs):
            # Determine plant type
            plant_type = "generic_plant"
            for type_key, patterns in plant_patterns.items():
                if any(pattern in message for pattern in patterns):
                    plant_type = type_key
                    break
            
            # Extract location context
            location = {"x": 0, "y": 0, "z": 0}  # Default center position
            for term in location_terms:
                if term in message:
                    # Simple positional logic - could be enhanced with more sophisticated parsing
                    if "center" in message:
                        location = {"x": 0, "y": 0, "z": 0}
                    elif "north" in message:
                        location = {"x": 0, "y": 0, "z": -5}
                    elif "south" in message:
                        location = {"x": 0, "y": 0, "z": 5}
                    elif "east" in message:
                        location = {"x": 5, "y": 0, "z": 0}
                    elif "west" in message:
                        location = {"x": -5, "y": 0, "z": 0}
                    break
            
            # Extract additional properties
            properties = {}
            
            # Season context
            seasons = ["spring", "summer", "autumn", "winter"]
            for season in seasons:
                if season in message:
                    properties["season"] = season
                    break
            
            # Rotation context
            if "facing" in message:
                if "north" in message:
                    properties["rotation"] = 0
                elif "east" in message:
                    properties["rotation"] = 90
                elif "south" in message:
                    properties["rotation"] = 180
                elif "west" in message:
                    properties["rotation"] = 270
            
            # Execute the create_plant command with medieval context
            return self.executor.execute_command(
                "create_plant",
                plant_type,
                location,
                properties
            )
        
        # Texture generation patterns
        elif any(word in message for word in ["texture", "pattern", "design"]):
            texture_type = "generic"
            for type_name in ["stone", "wood", "fabric", "ground", "wall"]:
                if type_name in message:
                    texture_type = type_name
                    break
            
            # Extract variation from medieval context
            variation = "default"
            if "weathered" in message:
                variation = "weathered"
            elif "ornate" in message:
                variation = "ornate"
            elif "simple" in message:
                variation = "simple"
            
            return self.executor.execute_command(
                "generate_texture",
                texture_type,
                variation
            )
        
        # Meditation patterns
        elif any(word in message for word in ["meditate", "contemplate", "reflect", "ponder"]):
            # Extract specific meditation focus
            section = None
            if "nature" in message:
                section = "nature"
            elif "divine" in message or "god" in message:
                section = "divine"
            elif "labor" in message or "work" in message:
                section = "labor"
            
            return self.executor.execute_command("show_meditation", section)
        
        return None
    
    def process_voice_input(self) -> str:
        """Process voice input from the player"""
        if not self.voice_system:
            return "Voice system not initialized"
        
        try:
            # Start listening for voice input
            print("Listening for voice input...")
            text = self.voice_system.listen()
            
            if text:
                print(f"Recognized: {text}")
                
                # Process the text input
                response = self.send_message(text)
                
                # Speak the response
                self.voice_system.speak(response)
                
                return response
            else:
                return "Could not recognize speech"
        
        except Exception as e:
            error_message = f"Error processing voice input: {str(e)}"
            print(error_message)
            return error_message
    
    def run_interactive(self):
        """Run an interactive command-line session with Ambrose"""
        print("Ambrose, the Gardener of Hortus Conclusus")
        print("Type 'exit' to quit, 'voice' to use voice input")
        
        while True:
            user_input = input("\nYou: ")
            
            if user_input.lower() == "exit":
                print("Farewell from the garden.")
                break
            
            elif user_input.lower() == "voice":
                response = self.process_voice_input()
            
            else:
                response = self.send_message(user_input)
            
            print(f"\nAmbrose: {response}")


if __name__ == "__main__":
    # Example usage
    agent = AmbroseAgent(debug=True)
    agent.run_interactive()
