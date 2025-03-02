#!/usr/bin/env python3
"""
Test script for Ambrose Agent

This script provides a simple command-line interface to test the Ambrose agent
without needing to run the full Godot game. It allows for basic text-to-text
interaction with Ambrose.

Usage:
    python test_ambrose.py

Requirements:
    - Python 3.6+
    - requests library (pip install requests)
"""

import os
import sys
import time
import argparse

# Add the project root to the path so we can import our modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

# Import the Ambrose agent
from scripts.ai.ambrose_agent import AmbroseAgent
from scripts.ai.config import DEBUG_MODE

def clear_screen():
    """Clear the terminal screen"""
    os.system('cls' if os.name == 'nt' else 'clear')

def print_header():
    """Print the Ambrose test header"""
    clear_screen()
    print("╔══════════════════════════════════════════════════════════════════════════════╗")
    print("║                                                                              ║")
    print("║                 🏰 Ambrose - The Gardener of Hortus Conclusus 🏰            ║")
    print("║                                                                              ║")
    print("╚══════════════════════════════════════════════════════════════════════════════╝")
    print()
    print("Welcome to the Hortus Conclusus. Ambrose is here to tend the garden and assist you.")
    print("Type your messages to converse with Ambrose. Type 'exit' to quit.")
    print()

def format_message(role, message):
    """Format a message for display"""
    if role == "user":
        return f"\033[94mYou:\033[0m {message}"
    else:
        return f"\033[92mAmbrose:\033[0m {message}"

def run_interactive_test(debug=DEBUG_MODE):
    """Run an interactive test session with Ambrose"""
    print_header()
    
    # Initialize the Ambrose agent
    print("Initializing Ambrose...")
    ambrose = AmbroseAgent(debug=debug)
    
    # Send an initial greeting to Ambrose
    print("Sending initial greeting...")
    response = ambrose.send_message("Hello Ambrose, please introduce yourself.")
    
    # Print the response
    print(format_message("assistant", response))
    
    # Main interaction loop
    while True:
        # Get user input
        user_input = input("\n\033[94mYou:\033[0m ")
        
        # Check for exit command
        if user_input.lower() in ["exit", "quit", "bye"]:
            print("\nFarewell from the garden.")
            break
        
        # Send the message to Ambrose
        print("\nAmbrose is thinking...")
        response = ambrose.send_message(user_input)
        
        # Print the response
        print(format_message("assistant", response))

def run_automated_test(debug=DEBUG_MODE):
    """Run an automated test with predefined messages"""
    print_header()
    
    # Initialize the Ambrose agent
    print("Initializing Ambrose...")
    ambrose = AmbroseAgent(debug=debug)
    
    # Define test messages
    test_messages = [
        "Hello Ambrose, please introduce yourself.",
        "What is a Hortus Conclusus?",
        "Can you tell me about medieval gardens?",
        "What plants would be found in a medieval garden?",
        "Can you create a rose garden for me?",
        "Tell me about the symbolism of the enclosed garden."
    ]
    
    # Send each message and print the response
    for message in test_messages:
        print(format_message("user", message))
        print("\nAmbrose is thinking...")
        
        # Send the message to Ambrose
        start_time = time.time()
        response = ambrose.send_message(message)
        end_time = time.time()
        
        # Print the response and timing
        print(format_message("assistant", response))
        print(f"\nResponse time: {end_time - start_time:.2f} seconds")
        print("\n" + "-" * 80 + "\n")
        
        # Pause between messages
        time.sleep(1)
    
    print("\nAutomated test completed.")

if __name__ == "__main__":
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Test the Ambrose agent")
    parser.add_argument("--automated", action="store_true", help="Run automated test with predefined messages")
    parser.add_argument("--debug", action="store_true", help="Enable debug output")
    args = parser.parse_args()
    
    # Run the appropriate test
    if args.automated:
        run_automated_test(debug=args.debug)
    else:
        run_interactive_test(debug=args.debug)
