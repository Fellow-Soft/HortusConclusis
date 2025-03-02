#!/usr/bin/env python3
"""
Simple test script for the Claude API

This script tests the Claude API directly without the Ambrose agent.
"""

import requests
import json
import sys

# API key
API_KEY = "YOUR_API_KEY_HERE"  # Replace with your actual API key when using

# API endpoint
API_URL = "https://api.anthropic.com/v1/messages"

# Model name
MODEL = "claude-3-sonnet-20240229"  # Try a different model name

def test_claude_api():
    """Test the Claude API with a simple message"""
    print("Testing Claude API...")
    
    # Headers
    headers = {
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
        "x-api-key": API_KEY
    }
    
    # Data
    data = {
        "model": MODEL,
        "messages": [
            {
                "role": "user",
                "content": "Hello, Claude! Please introduce yourself briefly."
            }
        ],
        "max_tokens": 1000
    }
    
    print(f"Making API request to {API_URL}")
    print(f"Headers: {headers}")
    print(f"Data: {json.dumps(data, indent=2)}")
    
    try:
        # Make the API request
        response = requests.post(API_URL, headers=headers, json=data)
        
        print(f"Response status code: {response.status_code}")
        print(f"Response headers: {response.headers}")
        
        # Print the response text (first 500 characters)
        print(f"Response text: {response.text[:500]}...")
        
        # Check if the request was successful
        if response.status_code == 200:
            # Parse the JSON response
            response_data = response.json()
            
            # Extract the assistant's message
            assistant_message = response_data["content"][0]["text"]
            
            print(f"\nClaude's response: {assistant_message}")
            return True
        else:
            print(f"Error: {response.status_code}")
            print(response.text)
            return False
    
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    success = test_claude_api()
    sys.exit(0 if success else 1)
