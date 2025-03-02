# Ambrose Agent Setup and Usage Guide

This guide explains how to set up and use Ambrose, the AI-powered gardener of Hortus Conclusus.

## Quick Start

1. Make sure you have Python 3.6+ installed
2. Install required dependencies:
   ```
   pip install requests
   ```
3. Run the test script to interact with Ambrose:
   ```
   cd HortusConclusis
   python scripts/ai/test_ambrose.py
   ```

## Configuration

The Ambrose agent is configured through the `scripts/ai/config.py` file. The key settings are:

- `CLAUDE_API_KEY`: Your Claude API key (already configured)
- `CLAUDE_MODEL`: The Claude model to use (default: claude-3-sonnet-20240229)
- `USE_VOICE`: Whether to enable voice interaction (default: False)
- `DEBUG_MODE`: Whether to enable debug output (default: True)

## Testing Ambrose

### Interactive Mode

The default mode allows you to have a conversation with Ambrose:

```
python scripts/ai/test_ambrose.py
```

Type your messages and press Enter to send them to Ambrose. Type 'exit' to quit.

### Automated Test

You can run an automated test with predefined messages:

```
python scripts/ai/test_ambrose.py --automated
```

This will send a series of test messages to Ambrose and display the responses.

### Debug Mode

To see detailed debug information during testing:

```
python scripts/ai/test_ambrose.py --debug
```

## Integrating with Godot

To use Ambrose in the Godot game:

1. Add the `ambrose_interface.tscn` scene to your main scene:
   ```gdscript
   var ambrose_interface = preload("res://scenes/ambrose_interface.tscn").instantiate()
   add_child(ambrose_interface)
   ```

2. The interface includes a chat panel for text interaction and buttons for voice interaction.

## Voice Interaction (Optional)

To enable voice interaction:

1. Install additional dependencies:
   ```
   pip install SpeechRecognition pyttsx3
   ```

2. For Google Speech Recognition, you may need:
   ```
   pip install google-api-python-client
   ```

3. Set `USE_VOICE = True` in `config.py`

## Troubleshooting

### API Key Issues

If you see "Error communicating with Claude API", check:
- Your internet connection
- The API key in `config.py`
- Your Claude API usage limits

### Model Name Issues

If you see a 404 error when trying to communicate with the Claude API, check:
- The model name in `config.py` - it should be "claude-3-sonnet-20240229" (not "claude-3-7-sonnet-20240229")
- The API endpoint URL in `config.py` - it should be "https://api.anthropic.com/v1/messages"
- The authentication header format - it should use "x-api-key" without the "Bearer" prefix

You can use the `test_claude_api.py` script to test the API connection directly:
```
python scripts/ai/test_claude_api.py
```

### Import Errors

If you see import errors:
- Make sure you're running the script from the project root directory
- Check that all required packages are installed

### Voice Recognition Issues

If voice recognition isn't working:
- Check that your microphone is connected and working
- Install the required voice packages
- Try running with `--debug` to see detailed error messages

## Extending Ambrose

### Adding New Commands

To add new commands that Ambrose can execute:

1. Add a new command method to the `AmbroseAgent` class in `ambrose_agent.py`:
   ```python
   def _my_new_command(self, param1, param2=None):
       # Command implementation
       return {"success": True, "message": "Command executed"}
   ```

2. Register the command in the `_register_commands` method:
   ```python
   self.executor.register_command(
       "my_new_command",
       self._my_new_command,
       "Description of the command",
       ["param1"],  # Required parameters
       ["param2"]   # Optional parameters
   )
   ```

3. Update the command extraction logic in `_extract_and_execute_command` to detect when Ambrose should execute your new command.

### Customizing Ambrose's Personality

Ambrose's personality and knowledge are defined in the `CUSTOM_INSTRUCTION.md` file in the project root. You can edit this file to change how Ambrose responds and what knowledge he has.

## Advanced Usage

### Running Ambrose as a Standalone Service

You can run Ambrose as a standalone service that the Godot game can connect to:

```
python scripts/ai/ambrose_agent.py
```

This will start an interactive session with Ambrose that you can use for testing or demonstration purposes.

### Batch Processing

For batch processing of messages:

```python
from scripts.ai.ambrose_agent import AmbroseAgent

ambrose = AmbroseAgent()
messages = ["Hello", "Tell me about medieval gardens", "What plants should I grow?"]
responses = [ambrose.send_message(msg) for msg in messages]
```

## Credits

Ambrose is powered by Claude 3.7 from Anthropic. The character and philosophy of Ambrose are defined in the `GARDENER_PERSONA.md` file.
