#!/usr/bin/env python3
"""
Transcribe audio files using OpenAI's Whisper model
"""
import sys
import os
import warnings
import argparse
import subprocess

def transcribe_audio(file_path, model_size="base", language=None):
    """Transcribe audio file using Whisper"""
    # Check if we can import whisper directly, otherwise use pipx version
    try:
        import whisper
        use_command = False
    except ImportError:
        # Check if whisper command is available via pipx
        whisper_path = "/Users/william/.local/bin/whisper"
        if not os.path.exists(whisper_path):
            print("Error: Whisper is not installed.")
            print("Please install it with: pipx install openai-whisper")
            return 1
        use_command = True
    
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found")
        return 1
    
    if use_command:
        # Use whisper command-line tool via pipx
        print(f"Using Whisper {model_size} model...")
        print(f"Transcribing '{os.path.basename(file_path)}'...")
        
        cmd = [whisper_path, file_path, "--model", model_size]
        if language:
            cmd.extend(["--language", language])
            print(f"Using language: {language}")
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                print("\n" + "="*50)
                print("TRANSCRIPTION")
                print("="*50)
                print(result.stdout)
                print("="*50 + "\n")
                return 0
            else:
                print(f"Error: {result.stderr}")
                return 1
        except Exception as e:
            print(f"Error running whisper command: {e}")
            return 1
    else:
        # Use Python module directly
        # Suppress FP16 warning on CPU
        warnings.filterwarnings("ignore", message="FP16 is not supported on CPU")
        
        try:
            print(f"Loading Whisper {model_size} model...")
            model = whisper.load_model(model_size)
            
            print(f"Transcribing '{os.path.basename(file_path)}'...")
            
            # Transcribe with optional language parameter
            kwargs = {}
            if language:
                kwargs['language'] = language
                print(f"Using language: {language}")
            
            result = model.transcribe(file_path, **kwargs)
            
            print("\n" + "="*50)
            print("TRANSCRIPTION")
            print("="*50)
            print(result["text"].strip())
            print("="*50 + "\n")
            
            # Optionally save to file
            output_file = file_path.rsplit('.', 1)[0] + '_transcription.txt'
            with open(output_file, 'w') as f:
                f.write(result["text"].strip())
            print(f"Transcription saved to: {output_file}")
            
            return 0
        except Exception as e:
            print(f"Error during transcription: {e}")
            return 1

def main():
    parser = argparse.ArgumentParser(description='Transcribe audio files using Whisper')
    parser.add_argument('file', help='Path to audio file')
    parser.add_argument('--model', '-m', default='base',
                        choices=['tiny', 'base', 'small', 'medium', 'large'],
                        help='Whisper model size (default: base)')
    parser.add_argument('--language', '-l', default=None,
                        help='Language code (e.g., en, es, fr)')
    
    args = parser.parse_args()
    
    return transcribe_audio(args.file, args.model, args.language)

if __name__ == "__main__":
    sys.exit(main())