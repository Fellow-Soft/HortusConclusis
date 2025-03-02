#!/usr/bin/env python3
"""
Create enhanced medieval-style background music tracks for the Hortus Conclusus project
with different moods for different times of day
"""

import numpy as np
from scipy.io import wavfile
import os
import random

# Create directory if it doesn't exist
os.makedirs("HortusConclusis/assets/music", exist_ok=True)

class MedievalMusicGenerator:
    """Class to generate medieval-style music with different moods and scales"""
    
    def __init__(self, sample_rate=44100):
        self.sample_rate = sample_rate
        
        # Define medieval modes/scales
        self.scales = {
            # Dorian mode (minor with raised 6th) - contemplative, balanced
            "dorian": np.array([
                220.0,  # A3
                246.94, # B3
                261.63, # C4
                293.66, # D4
                329.63, # E4
                349.23, # F4
                392.0,  # G4
                440.0   # A4
            ]),
            
            # Lydian mode (major with raised 4th) - bright, mystical
            "lydian": np.array([
                261.63, # C4
                293.66, # D4
                329.63, # E4
                349.23, # F4
                392.0,  # G4
                440.0,  # A4
                493.88, # B4
                523.25  # C5
            ]),
            
            # Phrygian mode (minor with lowered 2nd) - tense, exotic
            "phrygian": np.array([
                329.63, # E4
                349.23, # F4
                392.0,  # G4
                440.0,  # A4
                493.88, # B4
                523.25, # C5
                587.33, # D5
                659.26  # E5
            ]),
            
            # Mixolydian mode (major with lowered 7th) - pastoral, relaxed
            "mixolydian": np.array([
                293.66, # D4
                329.63, # E4
                369.99, # F#4
                392.0,  # G4
                440.0,  # A4
                493.88, # B4
                523.25, # C5
                587.33  # D5
            ]),
            
            # Aeolian mode (natural minor) - melancholic, serious
            "aeolian": np.array([
                440.0,  # A4
                493.88, # B4
                523.25, # C5
                587.33, # D5
                659.26, # E5
                698.46, # F5
                783.99, # G5
                880.0   # A5
            ])
        }
        
        # Instrument timbres (harmonic content)
        self.instruments = {
            "flute": [1.0, 0.6, 0.1, 0.05, 0.02],
            "lute": [1.0, 0.5, 0.3, 0.2, 0.1, 0.05],
            "recorder": [1.0, 0.7, 0.2, 0.1],
            "viol": [1.0, 0.8, 0.6, 0.4, 0.2, 0.1],
            "harp": [1.0, 0.4, 0.2, 0.1, 0.05]
        }
    
    def generate_note(self, frequency, duration, amplitude=0.3, instrument="flute"):
        """Generate a single note with the given frequency, duration, and instrument timbre"""
        # Create time array for this note
        t = np.linspace(0, duration, int(self.sample_rate * duration), False)
        
        # Initialize the note signal
        note_signal = np.zeros_like(t)
        
        # Add harmonics based on the instrument timbre
        harmonics = self.instruments.get(instrument, self.instruments["flute"])
        for i, harmonic_amp in enumerate(harmonics):
            harmonic = (i + 1)
            harmonic_signal = amplitude * harmonic_amp * np.sin(2 * np.pi * frequency * harmonic * t)
            note_signal += harmonic_signal
        
        # Create note envelope (attack, decay, sustain, release)
        note_samples = len(t)
        attack = int(note_samples * 0.1)
        decay = int(note_samples * 0.1)
        release = int(note_samples * 0.2)
        sustain_level = 0.7
        
        # Create envelope
        envelope = np.ones(note_samples)
        # Attack
        envelope[:attack] = np.linspace(0, 1, attack)
        # Decay
        envelope[attack:attack+decay] = np.linspace(1, sustain_level, decay)
        # Release
        envelope[-release:] = np.linspace(sustain_level, 0, release)
        
        # Apply envelope
        note_signal *= envelope
        
        return note_signal
    
    def generate_melody(self, scale, notes, durations, instrument="flute", amplitude=0.3):
        """Generate a melody using the given scale, note indices, and durations"""
        # Calculate total duration
        total_duration = sum(durations)
        
        # Create time array
        t = np.linspace(0, total_duration, int(self.sample_rate * total_duration), False)
        
        # Initialize audio signal
        audio_signal = np.zeros_like(t)
        
        # Add melody to the audio signal
        current_time = 0
        for note, duration in zip(notes, durations):
            # Handle rests (negative note indices)
            if note < 0:
                current_time += duration
                continue
                
            # Get frequency from scale
            freq = scale[note % len(scale)]
            
            # Calculate sample indices
            start_idx = int(current_time * self.sample_rate)
            end_idx = int((current_time + duration) * self.sample_rate)
            
            # Generate note
            note_signal = self.generate_note(freq, duration, amplitude, instrument)
            
            # Add to audio signal
            audio_signal[start_idx:end_idx] += note_signal
            
            current_time += duration
        
        return audio_signal
    
    def generate_drone(self, scale, duration, root_index=0, fifth_index=4, instrument="viol"):
        """Generate a drone bass using the root and fifth of the scale"""
        # Create time array
        t = np.linspace(0, duration, int(self.sample_rate * duration), False)
        
        # Initialize audio signal
        audio_signal = np.zeros_like(t)
        
        # Get root and fifth frequencies
        root_freq = scale[root_index]
        fifth_freq = scale[fifth_index % len(scale)]
        
        # Add drone to the audio signal
        for freq, amp in [(root_freq, 0.2), (fifth_freq, 0.1)]:
            for i, harmonic_amp in enumerate(self.instruments.get(instrument, self.instruments["viol"])):
                harmonic = (i + 1)
                harmonic_signal = amp * harmonic_amp * np.sin(2 * np.pi * freq * harmonic * t)
                audio_signal += harmonic_signal
        
        return audio_signal
    
    def generate_counterpoint(self, scale, melody_notes, melody_durations, offset=0.5, instrument="recorder"):
        """Generate a counterpoint melody that complements the main melody"""
        # Create counterpoint notes based on the melody (typically in thirds or sixths)
        counterpoint_notes = []
        for note in melody_notes:
            if note < 0:  # Rest
                counterpoint_notes.append(-1)
            else:
                # Add a third or sixth above/below
                interval = random.choice([2, 5])  # Third or sixth
                direction = random.choice([1, -1])  # Above or below
                counterpoint_notes.append((note + interval * direction) % len(scale))
        
        # Offset the counterpoint by a fraction of the first note duration
        counterpoint_durations = melody_durations.copy()
        
        # Generate the counterpoint melody
        total_duration = sum(melody_durations)
        t = np.linspace(0, total_duration, int(self.sample_rate * total_duration), False)
        audio_signal = np.zeros_like(t)
        
        # Add offset
        offset_samples = int(offset * self.sample_rate)
        
        # Generate counterpoint
        current_time = offset
        for note, duration in zip(counterpoint_notes, counterpoint_durations):
            if note < 0:  # Rest
                current_time += duration
                continue
                
            freq = scale[note]
            start_idx = int(current_time * self.sample_rate)
            end_idx = int((current_time + duration) * self.sample_rate)
            
            if end_idx > len(audio_signal):
                end_idx = len(audio_signal)
            
            if start_idx < len(audio_signal):
                note_signal = self.generate_note(freq, duration, 0.2, instrument)
                note_samples = len(note_signal)
                
                if start_idx + note_samples > len(audio_signal):
                    note_samples = len(audio_signal) - start_idx
                
                audio_signal[start_idx:start_idx + note_samples] += note_signal[:note_samples]
            
            current_time += duration
        
        return audio_signal
    
    def generate_percussion(self, duration, pattern, tempo=1.0):
        """Generate a simple percussion track with the given pattern"""
        # Create time array
        t = np.linspace(0, duration, int(self.sample_rate * duration), False)
        
        # Initialize audio signal
        audio_signal = np.zeros_like(t)
        
        # Define percussion sounds
        def drum_hit(t, frequency=80, decay=0.1):
            return np.exp(-t / decay) * np.sin(2 * np.pi * frequency * t)
        
        def tambourine_hit(t, frequency=800, decay=0.05):
            noise = np.random.normal(0, 1, len(t))
            return np.exp(-t / decay) * (0.7 * noise + 0.3 * np.sin(2 * np.pi * frequency * t))
        
        # Pattern length in seconds
        pattern_duration = len(pattern) * tempo
        
        # Repeat pattern to fill duration
        for i in range(int(duration / pattern_duration) + 1):
            pattern_start = i * pattern_duration
            
            for j, hit in enumerate(pattern):
                if hit == 0:
                    continue
                    
                hit_time = pattern_start + j * tempo
                hit_samples = int(0.2 * self.sample_rate)  # 200ms hit
                
                start_idx = int(hit_time * self.sample_rate)
                end_idx = start_idx + hit_samples
                
                if end_idx > len(audio_signal):
                    break
                
                hit_t = np.linspace(0, 0.2, hit_samples, False)
                
                if hit == 1:  # Drum
                    hit_signal = 0.15 * drum_hit(hit_t)
                elif hit == 2:  # Tambourine
                    hit_signal = 0.1 * tambourine_hit(hit_t)
                
                audio_signal[start_idx:end_idx] += hit_signal
        
        return audio_signal
    
    def create_morning_music(self, duration=180):
        """Create bright, uplifting morning music in Lydian mode"""
        print("Generating morning music...")
        
        # Use Lydian mode for bright, mystical feeling
        scale = self.scales["lydian"]
        
        # Create time array
        t = np.linspace(0, duration, int(self.sample_rate * duration), False)
        
        # Initialize audio signal
        audio_signal = np.zeros_like(t)
        
        # Morning melody - bright, ascending patterns
        melody1_notes = [0, 1, 2, 3, 4, 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1, 0]
        melody1_durations = [1.0, 0.5, 0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5, 0.5, 1.0, 0.5, 1.0, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0]
        
        # Second melody section
        melody2_notes = [4, 5, 6, 7, 6, 5, 4, 3, 4, 5, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 0, 1, 2, 3, 4]
        melody2_durations = [0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 1.0, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0]
        
        # Combine melodies and repeat to fill duration
        melody_notes = melody1_notes + melody2_notes + melody1_notes + melody2_notes + melody1_notes
        melody_durations = melody1_durations + melody2_durations + melody1_durations + melody2_durations + melody1_durations
        
        # Generate melody with flute sound
        melody_signal = self.generate_melody(scale, melody_notes, melody_durations, "flute", 0.3)
        audio_signal += melody_signal
        
        # Add counterpoint with recorder sound
        counterpoint_signal = self.generate_counterpoint(scale, melody_notes, melody_durations, 0.25, "recorder")
        audio_signal += counterpoint_signal
        
        # Add drone bass
        drone_signal = self.generate_drone(scale, duration, 0, 4, "viol")
        audio_signal += drone_signal * 0.7  # Reduce drone volume for morning
        
        # Add light percussion
        percussion_pattern = [1, 0, 2, 0, 1, 0, 2, 0]  # 1=drum, 2=tambourine
        percussion_signal = self.generate_percussion(duration, percussion_pattern, 0.5)
        audio_signal += percussion_signal
        
        # Normalize and save
        audio_signal = audio_signal / np.max(np.abs(audio_signal))
        audio_signal_16bit = (audio_signal * 32767).astype(np.int16)
        wavfile.write("HortusConclusis/assets/music/medieval_morning.wav", self.sample_rate, audio_signal_16bit)
        
        return "medieval_morning.wav"
    
    def create_midday_music(self, duration=180):
        """Create lively, active midday music in Mixolydian mode"""
        print("Generating midday music...")
        
        # Use Mixolydian mode for pastoral, relaxed feeling
        scale = self.scales["mixolydian"]
        
        # Create time array
        t = np.linspace(0, duration, int(self.sample_rate * duration), False)
        
        # Initialize audio signal
        audio_signal = np.zeros_like(t)
        
        # Midday melody - lively, active
        melody1_notes = [0, 2, 4, 2, 0, 2, 4, 5, 4, 2, 0, -1, 0, 2, 4, 5, 7, 5, 4, 2, 4, 5, 4, 2, 0]
        melody1_durations = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0]
        
        # Second melody section
        melody2_notes = [7, 5, 4, 5, 7, 5, 4, 2, 0, 2, 4, 2, 0, -1, 0, 2, 4, 5, 4, 2, 0, 2, 0, -1, 0]
        melody2_durations = [0.5, 0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5, 1.0]
        
        # Combine melodies and repeat to fill duration
        melody_notes = melody1_notes + melody2_notes + melody1_notes + melody2_notes + melody1_notes
        melody_durations = melody1_durations + melody2_durations + melody1_durations + melody2_durations + melody1_durations
        
        # Generate melody with recorder sound
        melody_signal = self.generate_melody(scale, melody_notes, melody_durations, "recorder", 0.3)
        audio_signal += melody_signal
        
        # Add counterpoint with lute sound
        counterpoint_signal = self.generate_counterpoint(scale, melody_notes, melody_durations, 0.25, "lute")
        audio_signal += counterpoint_signal
        
        # Add drone bass
        drone_signal = self.generate_drone(scale, duration, 0, 4, "viol")
        audio_signal += drone_signal * 0.6
        
        # Add more active percussion
        percussion_pattern = [1, 2, 1, 0, 1, 2, 1, 2]  # More frequent hits
        percussion_signal = self.generate_percussion(duration, percussion_pattern, 0.4)
        audio_signal += percussion_signal
        
        # Normalize and save
        audio_signal = audio_signal / np.max(np.abs(audio_signal))
        audio_signal_16bit = (audio_signal * 32767).astype(np.int16)
        wavfile.write("HortusConclusis/assets/music/medieval_midday.wav", self.sample_rate, audio_signal_16bit)
        
        return "medieval_midday.wav"
    
    def create_afternoon_music(self, duration=180):
        """Create warm, relaxed afternoon music in Dorian mode"""
        print("Generating afternoon music...")
        
        # Use Dorian mode for contemplative, balanced feeling
        scale = self.scales["dorian"]
        
        # Create time array
        t = np.linspace(0, duration, int(self.sample_rate * duration), False)
        
        # Initialize audio signal
        audio_signal = np.zeros_like(t)
        
        # Afternoon melody - relaxed, flowing
        melody1_notes = [0, 2, 3, 5, 3, 2, 0, 2, 3, 2, 0, -1, 0, 2, 3, 5, 7, 5, 3, 2, 3, 2, 0]
        melody1_durations = [1.0, 0.5, 0.5, 1.0, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5, 1.0, 0.5, 1.0, 0.5, 0.5, 1.0, 1.0, 0.5, 0.5, 0.5, 0.5, 0.5, 1.5]
        
        # Second melody section
        melody2_notes = [5, 7, 5, 3, 5, 3, 2, 0, 2, 3, 5, 3, 2, 0, -1, 0, 2, 3, 2, 0]
        melody2_durations = [1.0, 1.0, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 1.0, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5, 0.5, 0.5, 1.5]
        
        # Combine melodies and repeat to fill duration
        melody_notes = melody1_notes + melody2_notes + melody1_notes + melody2_notes + melody1_notes
        melody_durations = melody1_durations + melody2_durations + melody1_durations + melody2_durations + melody1_durations
        
        # Generate melody with lute sound
        melody_signal = self.generate_melody(scale, melody_notes, melody_durations, "lute", 0.3)
        audio_signal += melody_signal
        
        # Add counterpoint with flute sound
        counterpoint_signal = self.generate_counterpoint(scale, melody_notes, melody_durations, 0.25, "flute")
        audio_signal += counterpoint_signal
        
        # Add drone bass
        drone_signal = self.generate_drone(scale, duration, 0, 4, "viol")
        audio_signal += drone_signal * 0.8
        
        # Add gentle percussion
        percussion_pattern = [1, 0, 0, 2, 0, 0, 1, 0]  # Sparse pattern
        percussion_signal = self.generate_percussion(duration, percussion_pattern, 0.6)
        audio_signal += percussion_signal * 0.7
        
        # Normalize and save
        audio_signal = audio_signal / np.max(np.abs(audio_signal))
        audio_signal_16bit = (audio_signal * 32767).astype(np.int16)
        wavfile.write("HortusConclusis/assets/music/medieval_afternoon.wav", self.sample_rate, audio_signal_16bit)
        
        return "medieval_afternoon.wav"
    
    def create_evening_music(self, duration=180):
        """Create contemplative, peaceful evening music in Aeolian mode"""
        print("Generating evening music...")
        
        # Use Aeolian mode for melancholic, serious feeling
        scale = self.scales["aeolian"]
        
        # Create time array
        t = np.linspace(0, duration, int(self.sample_rate * duration), False)
        
        # Initialize audio signal
        audio_signal = np.zeros_like(t)
        
        # Evening melody - contemplative, descending
        melody1_notes = [7, 5, 4, 2, 0, 2, 4, 2, 0, -1, 0, 2, 0, -1, 0, 2, 4, 2, 0]
        melody1_durations = [1.5, 0.5, 0.5, 0.5, 1.5, 0.5, 0.5, 0.5, 1.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5, 1.5]
        
        # Second melody section
        melody2_notes = [4, 5, 7, 5, 4, 2, 4, 2, 0, 2, 0, -1, 0, 2, 0]
        melody2_durations = [0.5, 0.5, 1.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.5, 0.5, 0.5, 0.5, 1.0, 0.5, 1.5]
        
        # Combine melodies and repeat to fill duration
        melody_notes = melody1_notes + melody2_notes + melody1_notes + melody2_notes + melody1_notes
        melody_durations = melody1_durations + melody2_durations + melody1_durations + melody2_durations + melody1_durations
        
        # Generate melody with harp sound
        melody_signal = self.generate_melody(scale, melody_notes, melody_durations, "harp", 0.25)
        audio_signal += melody_signal
        
        # Add counterpoint with viol sound
        counterpoint_signal = self.generate_counterpoint(scale, melody_notes, melody_durations, 0.5, "viol")
        audio_signal += counterpoint_signal * 0.7
        
        # Add drone bass
        drone_signal = self.generate_drone(scale, duration, 0, 4, "viol")
        audio_signal += drone_signal * 0.9
        
        # Add minimal percussion
        percussion_pattern = [1, 0, 0, 0, 0, 0, 0, 0]  # Very sparse
        percussion_signal = self.generate_percussion(duration, percussion_pattern, 0.8)
        audio_signal += percussion_signal * 0.5
        
        # Normalize and save
        audio_signal = audio_signal / np.max(np.abs(audio_signal))
        audio_signal_16bit = (audio_signal * 32767).astype(np.int16)
        wavfile.write("HortusConclusis/assets/music/medieval_evening.wav", self.sample_rate, audio_signal_16bit)
        
        return "medieval_evening.wav"
    
    def create_night_music(self, duration=180):
        """Create mysterious, ethereal night music in Phrygian mode"""
        print("Generating night music...")
        
        # Use Phrygian mode for tense, exotic feeling
        scale = self.scales["phrygian"]
        
        # Create time array
        t = np.linspace(0, duration, int(self.sample_rate * duration), False)
        
        # Initialize audio signal
        audio_signal = np.zeros_like(t)
        
        # Night melody - mysterious, sparse
        melody1_notes = [0, 1, 3, 1, 0, -1, 0, 1, 3, 5, 3, 1, 0, -1, 0, 1, 0]
        melody1_durations = [1.5, 0.5, 1.0, 0.5, 1.5, 0.5, 1.0, 0.5, 1.0, 1.5, 0.5, 0.5, 1.5, 0.5, 1.0, 0.5, 2.0]
        
        # Second melody section
        melody2_notes = [5, 7, 5, 3, 1, 0, 1, 3, 1, 0, -1, 0, 1, 0]
        melody2_durations = [1.0, 1.5, 0.5, 1.0, 0.5, 1.5, 0.5, 1.0, 0.5, 1.5, 0.5, 1.0, 0.5, 2.0]
        
        # Combine melodies and repeat to fill duration
        melody_notes = melody1_notes + melody2_notes + melody1_notes + melody2_notes + melody1_notes
        melody_durations = melody1_durations + melody2_durations + melody1_durations + melody2_durations + melody1_durations
        
        # Generate melody with flute sound (ethereal)
        melody_signal = self.generate_melody(scale, melody_notes, melody_durations, "flute", 0.2)
        audio_signal += melody_signal
        
        # Add sparse counterpoint with harp sound
        counterpoint_signal = self.generate_counterpoint(scale, melody_notes, melody_durations, 0.75, "harp")
        audio_signal += counterpoint_signal * 0.6
        
        # Add drone bass (more prominent at night)
        drone_signal = self.generate_drone(scale, duration, 0, 4, "viol")
        audio_signal += drone_signal * 1.0
        
        # No percussion for night music - just ambient sounds
        
        # Normalize and save
        audio_signal = audio_signal / np.max(np.abs(audio_signal))
        audio_signal_16bit = (audio_signal * 32767).astype(np.int16)
        wavfile.write("HortusConclusis/assets/music/medieval_night.wav", self.sample_rate, audio_signal_16bit)
        
        return "medieval_night.wav"
    
    def create_background_music(self, duration=180):
        """Create the original background music for backward compatibility"""
        print("Generating background music...")
        
        # Use Dorian mode
        scale = self.scales["dorian"]
        
        # Create time array
        t = np.linspace(0, duration, int(self.sample_rate * duration), False)
        
        # Initialize audio signal
        audio_signal = np.zeros_like(t)
        
        # Create a simple melody
        melody_notes = [0, 2, 4, 3, 2, 1, 0, 4, 2, 3, 1, 2, 0]
        melody_durations = [2, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1, 2]
        
        # Extend the melody to fill the duration
        melody_notes = melody_notes * 10
        melody_durations = melody_durations * 10
        
        # Generate melody
        melody_signal = self.generate_melody(scale, melody_notes, melody_durations, "recorder", 0.3)
        audio_signal += melody_signal
        
        # Add drone bass
        drone_signal = self.generate_drone(scale, duration, 0, 4, "viol")
        audio_signal += drone_signal
        
        # Add some harmonics for a richer sound
        for i in range(2, 5):
            harmonic_signal = (0.1 / i) * np.sin(2 * np.pi * i * scale[0] * t)
            audio_signal += harmonic_signal
        
        # Normalize and save
        audio_signal = audio_signal / np.max(np.abs(audio_signal))
        audio_signal_16bit = (audio_signal * 32767).astype(np.int16)
        wavfile.write("HortusConclusis/assets/music/medieval_background.wav", self.sample_rate, audio_signal_16bit)
        
        return "medieval_background.wav"

def create_all_medieval_music():
    """Create all medieval music tracks"""
    generator = MedievalMusicGenerator()
    
    # Create all tracks with 3-minute duration
    duration = 180
    
    # Create the original background music for backward compatibility
    generator.create_background_music(duration)
    
    # Create time-of-day specific tracks
    generator.create_morning_music(duration)
    generator.create_midday_music(duration)
    generator.create_afternoon_music(duration)
    generator.create_evening_music(duration)
    generator.create_night_music(duration)
    
    print("All medieval music tracks created successfully!")

if __name__ == "__main__":
    create_all_medieval_music()
