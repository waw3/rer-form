---
allowed-tools: all
argument-hint: <audio_file> [--model size] [--language code]
description: Transcribe audio files using OpenAI's Whisper model
---

# Audio Transcription

Transcribe audio files to text using OpenAI's Whisper model with automatic formatting and multiple output formats.

## Usage

Transcribe audio files with various options for accuracy and language:

```bash
# Basic usage
/transcribe:audio <audio_file_path>

# With model size option
/transcribe:audio <audio_file_path> --model small

# With language option
/transcribe:audio <audio_file_path> --language en

# Combined options
/transcribe:audio <audio_file_path> --model large --language es
```

## Examples

```bash
# Example 1: Simple transcription
/transcribe:audio recording.mp3

# Example 2: High accuracy transcription
/transcribe:audio meeting.wav --model medium

# Example 3: Transcribe Spanish audio
/transcribe:audio spanish_audio.mp3 --language es

# Example 4: Best quality for important content
/transcribe:audio interview.m4a --model large
```

## Command Execution

```bash
python3 .claude/commands/transcribe/scripts/audio.py "$@"
```

## Parameters

### Required Parameters
- `<audio_file_path>`: Path to the audio file to transcribe

### Optional Parameters
- `--model [size]`: Whisper model size (tiny|base|small|medium|large) - default: base
- `--language [code]`: Language code for transcription (e.g., en, es, fr) - default: auto-detect

## Features

- **Multiple Format Support**: MP3, WAV, M4A, FLAC, OGG, WebM, and more
- **Automatic Language Detection**: Detects language automatically or specify manually
- **Model Selection**: Choose accuracy vs speed tradeoff
- **Smart Output**: Saves transcription alongside original file
- **Progress Indication**: Shows transcription progress
- **Error Recovery**: Handles corrupted audio gracefully

## Options/Configuration

### Available Models
- `tiny`: Fastest, least accurate (39M parameters)
- `base`: Balanced speed/accuracy (74M parameters) - **default**
- `small`: Better accuracy (244M parameters)
- `medium`: Good accuracy (769M parameters)
- `large`: Best accuracy, slowest (1550M parameters)

### Language Codes
- Automatic detection by default
- Common codes: en (English), es (Spanish), fr (French), de (German), zh (Chinese), ja (Japanese)
- Full list: 99+ languages supported

## Requirements/Dependencies

### System Requirements
- Python 3.8 or higher
- 1-8 GB RAM depending on model size
- FFmpeg for audio processing

### Installation

Whisper is already installed via pipx at `/Users/william/.local/bin/whisper`

```bash
# Verify installation
whisper --help

# Reinstall if needed
pipx install openai-whisper

# Install FFmpeg if missing (macOS)
brew install ffmpeg
```

## Output

### Output Files
- `[filename]_transcription.txt`: Plain text transcription
- Location: Same directory as input file

### Console Output
```
Detected language: English
Transcribing with base model...
[00:00:30] Processing audio...
Transcription complete!
Saved to: recording_transcription.txt
```

## Advanced Usage

### Batch Processing
```bash
# Transcribe multiple files
for file in *.mp3; do
  /transcribe:audio "$file" --model small
done
```

### Integration with Other Tools
```bash
# Transcribe and search for keywords
/transcribe:audio meeting.mp3 && grep "action items" meeting_transcription.txt
```

## Notes

- Processing time varies: ~1 minute of audio takes 10-60 seconds depending on model
- First run downloads the model (50MB-1.5GB depending on size)
- The FP16 warning on CPU is normal and doesn't affect functionality
- Larger models provide better accuracy but require more memory and time
- Audio is temporarily converted to 16kHz for processing

## Troubleshooting

### Common Issues

**Issue 1: Command not found**
- Solution: Ensure Python script exists at `.claude/commands/transcribe/scripts/audio.py`

**Issue 2: Whisper not installed**
- Solution: Run `pipx install openai-whisper`

**Issue 3: Out of memory error**
- Solution: Use a smaller model with `--model tiny` or `--model base`

**Issue 4: Unsupported audio format**
- Solution: Install FFmpeg: `brew install ffmpeg` (macOS) or `apt install ffmpeg` (Linux)

## Related Commands

- `/transcribe:video`: Transcribe video files (extracts audio first)
- `/translate`: Translate transcribed text to other languages