import os
import sys
import time
import inspect
from typing import Dict, List, Any, Optional, Callable, Tuple

# Import Godot integration if available
try:
    import godot_bridge
except ImportError:
    print("Warning: godot_bridge module not found. Running in standalone mode.")
    godot_bridge = None

class CommandExecutor:
    """
    Command Executor for Ambrose
    
    Handles the execution of commands requested by the Ambrose agent.
    Provides a registry of available commands and their implementations.
    """
    
    def __init__(self, debug: bool = False):
        """Initialize the Command Executor"""
        self.debug = debug
        self.commands = {}  # Dictionary of registered commands
        
        if self.debug:
            print("Command Executor initialized")
    
    def register_command(self, 
                         command_name: str, 
                         command_func: Callable, 
                         description: str = "", 
                         required_args: List[str] = None,
                         optional_args: List[str] = None) -> bool:
        """Register a command with the executor"""
        if command_name in self.commands:
            if self.debug:
                print(f"Command '{command_name}' already registered, overwriting")
        
        self.commands[command_name] = {
            "function": command_func,
            "description": description,
            "required_args": required_args or [],
            "optional_args": optional_args or [],
            "signature": inspect.signature(command_func)
        }
        
        if self.debug:
            print(f"Registered command: {command_name}")
        
        return True
    
    def execute_command(self, command_name: str, *args, **kwargs) -> Dict[str, Any]:
        """Execute a registered command"""
        if command_name not in self.commands:
            error_message = f"Command '{command_name}' not found"
            if self.debug:
                print(error_message)
            return {"success": False, "message": error_message}
        
        command = self.commands[command_name]
        
        try:
            # Check if we have the required arguments
            signature = command["signature"]
            bound_args = signature.bind_partial(*args, **kwargs)
            
            # Check for missing required arguments
            missing_args = []
            for param_name in command["required_args"]:
                if param_name not in bound_args.arguments:
                    missing_args.append(param_name)
            
            if missing_args:
                error_message = f"Missing required arguments for '{command_name}': {', '.join(missing_args)}"
                if self.debug:
                    print(error_message)
                return {"success": False, "message": error_message}
            
            # Execute the command
            if self.debug:
                print(f"Executing command: {command_name}")
                print(f"Arguments: {args}")
                print(f"Keyword arguments: {kwargs}")
            
            result = command["function"](*args, **kwargs)
            
            # If the result is already a dictionary with success/message, return it
            if isinstance(result, dict) and "success" in result:
                return result
            
            # Otherwise, wrap the result
            return {"success": True, "result": result, "message": f"Command '{command_name}' executed successfully"}
        
        except Exception as e:
            error_message = f"Error executing command '{command_name}': {str(e)}"
            if self.debug:
                print(error_message)
            return {"success": False, "message": error_message}
    
    def get_command_help(self, command_name: str = None) -> str:
        """Get help information for commands"""
        if command_name:
            # Get help for a specific command
            if command_name not in self.commands:
                return f"Command '{command_name}' not found"
            
            command = self.commands[command_name]
            help_text = f"Command: {command_name}\n"
            help_text += f"Description: {command['description']}\n"
            
            # Add required arguments
            if command["required_args"]:
                help_text += "Required arguments:\n"
                for arg in command["required_args"]:
                    help_text += f"  - {arg}\n"
            
            # Add optional arguments
            if command["optional_args"]:
                help_text += "Optional arguments:\n"
                for arg in command["optional_args"]:
                    help_text += f"  - {arg}\n"
            
            return help_text
        
        else:
            # List all available commands
            help_text = "Available commands:\n"
            for cmd_name, cmd_info in self.commands.items():
                help_text += f"  - {cmd_name}: {cmd_info['description']}\n"
            
            help_text += "\nUse get_command_help(command_name) for detailed help on a specific command."
            return help_text
    
    def list_commands(self) -> List[Dict[str, Any]]:
        """Get a list of all available commands and their metadata"""
        command_list = []
        
        for cmd_name, cmd_info in self.commands.items():
            command_list.append({
                "name": cmd_name,
                "description": cmd_info["description"],
                "required_args": cmd_info["required_args"],
                "optional_args": cmd_info["optional_args"]
            })
        
        return command_list


# Example command implementations for testing
def _test_echo(message: str) -> Dict[str, Any]:
    """Echo a message back"""
    return {"success": True, "message": message}

def _test_add(a: float, b: float) -> Dict[str, Any]:
    """Add two numbers"""
    result = a + b
    return {"success": True, "result": result, "message": f"The sum of {a} and {b} is {result}"}

def _test_create_item(item_type: str, name: str, properties: Dict[str, Any] = None) -> Dict[str, Any]:
    """Create a new item"""
    properties = properties or {}
    return {
        "success": True,
        "item_id": f"item_{int(time.time())}",
        "message": f"Created {item_type} named '{name}' with properties: {properties}"
    }


if __name__ == "__main__":
    # Example usage
    executor = CommandExecutor(debug=True)
    
    # Register some test commands
    executor.register_command(
        "echo", 
        _test_echo, 
        "Echo a message back", 
        ["message"]
    )
    
    executor.register_command(
        "add", 
        _test_add, 
        "Add two numbers", 
        ["a", "b"]
    )
    
    executor.register_command(
        "create_item", 
        _test_create_item, 
        "Create a new item", 
        ["item_type", "name"], 
        ["properties"]
    )
    
    # Print available commands
    print(executor.get_command_help())
    
    # Execute some commands
    print("\nExecuting commands:")
    print(executor.execute_command("echo", "Hello, world!"))
    print(executor.execute_command("add", 5, 7))
    print(executor.execute_command("create_item", "weapon", "Excalibur", {"damage": 100, "legendary": True}))
    
    # Try a command with missing arguments
    print("\nTesting error handling:")
    print(executor.execute_command("create_item", "weapon"))
