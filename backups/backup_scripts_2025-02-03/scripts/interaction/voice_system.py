import os
import sys
import time
import threading
import tempfile
from typing import Optional, List, Dict, Any

# Try to import speech recognition libraries
try:
    import speech_recognition as sr
except ImportError:
    print("Warning: speech_recognition module not found. Install with: pip install SpeechRecognition")
    sr = None

# Try to import text-to-speech libraries
try:
    import pyttsx3
except ImportError:
    print("Warning: pyttsx3 module not found. Install with: pip install pyttsx3")
    pyttsx3 = None

try:
    from gtts import gTTS
except ImportError:
    print("Warning: gTTS module not found. Install with: pip install gTTS")
    gTTS = None

# Import Godot integration if available
try:
    import godot_bridge
except ImportError:
    print("Warning: godot_bridge module not found. Running in standalone mode.")
    godot_bridge = None

class VoiceSystem:
    """
    Voice System for Ambrose
    
    Handles speech-to-text and text-to-speech functionality for the Ambrose agent.
    Supports multiple TTS and STT engines with fallbacks.
    """
    
    def __init__(self, 
                 voice_id: str = "medieval_male",
                 use_godot_audio: bool = True,
                 debug: bool = False):
        """Initialize the Voice System"""
        self.debug = debug
        self.voice_id = voice_id
        self.use_godot_audio = use_godot_audio and godot_bridge is not None
        
        # Initialize speech recognition
        self.recognizer = sr.Recognizer() if sr else None
        
        # Initialize text-to-speech
        self.tts_engine = None
        if pyttsx3:
            try:
                self.tts_engine = pyttsx3.init()
                self._configure_tts_voice()
            except Exception as e:
                print(f"Error initializing pyttsx3: {e}")
                self.tts_engine = None
        
        if self.debug:
            print(f"Voice System initialized with voice_id: {voice_id}")
            print(f"Speech recognition available: {self.recognizer is not None}")
            print(f"Text-to-speech available: {self.tts_engine is not None or gTTS is not None}")
            print(f"Using Godot audio: {self.use_godot_audio}")
    
    def _configure_tts_voice(self):
        """Configure the text-to-speech voice"""
        if not self.tts_engine:
            return
        
        try:
            # Get available voices
            voices = self.tts_engine.getProperty('voices')
            
            # Set voice based on voice_id
            if self.voice_id == "medieval_male":
                # Try to find a deep male voice
                for voice in voices:
                    if "male" in voice.name.lower():
                        self.tts_engine.setProperty('voice', voice.id)
                        break
            
            # Set speech rate (slower for medieval feel)
            self.tts_engine.setProperty('rate', 150)  # Default is 200
            
        except Exception as e:
            print(f"Error configuring TTS voice: {e}")
    
    def listen(self, timeout: int = 5) -> Optional[str]:
        """Listen for speech and convert to text"""
        if not self.recognizer:
            print("Speech recognition not available")
            return None
        
        try:
            with sr.Microphone() as source:
                if self.debug:
                    print("Adjusting for ambient noise...")
                self.recognizer.adjust_for_ambient_noise(source, duration=1)
                
                if self.debug:
                    print("Listening...")
                audio = self.recognizer.listen(source, timeout=timeout)
                
                if self.debug:
                    print("Recognizing...")
                
                # Try Google's speech recognition first
                try:
                    text = self.recognizer.recognize_google(audio)
                    return text
                except:
                    # If Google fails, try other recognizers
                    try:
                        text = self.recognizer.recognize_sphinx(audio)
                        return text
                    except:
                        if self.debug:
                            print("Could not recognize speech")
                        return None
        
        except Exception as e:
            if self.debug:
                print(f"Error in speech recognition: {e}")
            return None
    
    def speak(self, text: str) -> bool:
        """Convert text to speech and play it"""
        if self.use_godot_audio:
            return self._speak_godot(text)
        else:
            return self._speak_local(text)
    
    def _speak_local(self, text: str) -> bool:
        """Use local TTS engine to speak text"""
        # Try pyttsx3 first
        if self.tts_engine:
            try:
                self.tts_engine.say(text)
                self.tts_engine.runAndWait()
                return True
            except Exception as e:
                if self.debug:
                    print(f"Error with pyttsx3: {e}")
        
        # Fall back to gTTS if available
        if gTTS:
            try:
                # Create a temporary file for the audio
                with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as temp_file:
                    temp_filename = temp_file.name
                
                # Generate the speech audio file
                tts = gTTS(text=text, lang='en', slow=True)  # Slow for medieval feel
                tts.save(temp_filename)
                
                # Play the audio file (platform dependent)
                if sys.platform == 'darwin':  # macOS
                    os.system(f"afplay {temp_filename}")
                elif sys.platform == 'win32':  # Windows
                    os.system(f"start {temp_filename}")
                else:  # Linux and others
                    os.system(f"mpg123 {temp_filename}")
                
                # Clean up the temporary file
                os.unlink(temp_filename)
                
                return True
            
            except Exception as e:
                if self.debug:
                    print(f"Error with gTTS: {e}")
                
                # Clean up the temporary file if it exists
                try:
                    if 'temp_filename' in locals():
                        os.unlink(temp_filename)
                except:
                    pass
        
        if self.debug:
            print("No text-to-speech engine available")
        
        return False
    
    def _speak_godot(self, text: str) -> bool:
        """Use Godot's audio system to speak text"""
        if not godot_bridge:
            return self._speak_local(text)
        
        try:
            # If using gTTS, generate the audio file and pass it to Godot
            if gTTS:
                # Create a temporary file for the audio
                with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as temp_file:
                    temp_filename = temp_file.name
                
                # Generate the speech audio file
                tts = gTTS(text=text, lang='en', slow=True)  # Slow for medieval feel
                tts.save(temp_filename)
                
                # Tell Godot to play the audio file
                godot_bridge.call_method("play_audio_file", temp_filename)
                
                # Don't delete the file immediately, as Godot needs to access it
                # Schedule deletion after a delay
                def delete_file():
                    time.sleep(60)  # Wait for 60 seconds
                    try:
                        os.unlink(temp_filename)
                    except:
                        pass
                
                threading.Thread(target=delete_file).start()
                
                return True
            
            # If no gTTS, fall back to sending the text to Godot for TTS
            else:
                godot_bridge.call_method("speak_text", text, self.voice_id)
                return True
        
        except Exception as e:
            if self.debug:
                print(f"Error with Godot TTS: {e}")
            
            # Fall back to local TTS
            return self._speak_local(text)
    
    def set_voice(self, voice_id: str) -> bool:
        """Change the voice used for text-to-speech"""
        self.voice_id = voice_id
        
        if self.tts_engine:
            self._configure_tts_voice()
        
        if self.debug:
            print(f"Voice changed to: {voice_id}")
        
        return True


if __name__ == "__main__":
    # Example usage
    voice_system = VoiceSystem(debug=True)
    
    # Test speech recognition
    print("Say something...")
    text = voice_system.listen()
    if text:
        print(f"You said: {text}")
        
        # Test text-to-speech
        print("Speaking response...")
        voice_system.speak(f"You said: {text}")
    else:
        print("Could not recognize speech")
        voice_system.speak("I could not hear what you said.")
