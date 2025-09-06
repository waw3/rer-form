---
allowed-tools: all
argument-hint: <video_file> [output_directory]
description: Extract audio from video files and transcribe using OpenAI's Whisper model
---

# Video Transcription

Extract audio from video files and transcribe using OpenAI's Whisper model with automatic formatting and multiple output formats.

## Usage

Transcribe video files by extracting audio and processing with Whisper:

```bash
# Basic usage
/transcribe:video <video_file_path>

# Specify output directory
/transcribe:video <video_file_path> <output_directory>

# With output folder (relative or absolute path)
/transcribe:video <video_file_path> ./transcriptions/
```

## Examples

```bash
# Example 1: Simple video transcription
/transcribe:video recording.mp4

# Example 2: Transcribe to specific folder
/transcribe:video meeting.mov ~/Documents/transcriptions/

# Example 3: Webinar with output directory
/transcribe:video webinar.mkv ./output/

# Example 4: Screen recording transcription
/transcribe:video screen_capture.mov
```

## Command Execution

```bash
bash .claude/commands/transcribe/scripts/video.sh "$@"
```

## Parameters

### Required Parameters
- `<video_file_path>`: Path to the video file to transcribe

### Optional Parameters
- `[output_directory]`: Directory for output files (default: same as video file)

### Environment Variables
- `WHISPER_MODEL`: Override default model (base)
- `WHISPER_LANGUAGE`: Force specific language detection

## Features

- **Universal Video Support**: MP4, MOV, AVI, MKV, WebM, and 50+ formats via FFmpeg
- **Automatic Audio Extraction**: Extracts audio track from any video
- **Multiple Output Formats**: Text, SRT subtitles, JSON, formatted paragraphs
- **Smart Paragraph Formatting**: Groups text based on natural speech pauses
- **Timestamp Preservation**: Maintains sync with original video
- **Clean Text Version**: Paragraph-only version for documentation
- **Progress Indication**: Real-time status updates during processing

## Process Steps

1. **Audio Extraction**: FFmpeg extracts audio track from video
2. **Audio Processing**: Converts to 16kHz mono WAV format
3. **Transcription**: Whisper model processes the audio
4. **Format Generation**: Creates multiple output formats
5. **Paragraph Formatting**: Intelligent text grouping
6. **Cleanup**: Removes temporary audio files

## Options/Configuration

### Whisper Models (currently uses base)
- `tiny`: Fastest, least accurate (39M parameters)
- `base`: Balanced speed/accuracy (74M parameters) - **default**
- `small`: Better accuracy (244M parameters)
- `medium`: Good accuracy (769M parameters)
- `large`: Best accuracy, slowest (1550M parameters)

### Supported Video Formats
- **Common**: MP4, MOV, AVI, MKV, WebM
- **Professional**: ProRes, DNxHD, HEVC
- **Legacy**: FLV, WMV, MPEG, 3GP
- **Any format supported by FFmpeg**

## Requirements/Dependencies

### System Requirements
- Python 3.8 or higher
- FFmpeg for video/audio processing
- 2-8 GB RAM depending on video length
- Disk space for temporary audio extraction

### Installation

#### FFmpeg (Required)
```bash
# macOS
brew install ffmpeg

# Ubuntu/Debian
sudo apt-get install ffmpeg

# Verify installation
ffmpeg -version
```

#### Whisper
Already installed via pipx at `/Users/william/.local/bin/whisper`

```bash
# Verify installation
whisper --help

# Reinstall if needed
pipx install openai-whisper
```

#### Python Formatter (Optional)
```bash
# If formatter script is missing
pip install datetime pathlib json
```

## Output

### Output Files Generated
- `[filename].txt`: Raw transcript without formatting
- `[filename]_formatted.txt`: Paragraphs with timestamps [MM:SS - MM:SS]
- `[filename]_clean.txt`: Clean paragraphs without timestamps
- `[filename].srt`: Subtitle file for video players
- `[filename].json`: Detailed transcription with word-level timing

### Console Output
```
🎬 Starting transcription process...
Video: /path/to/video.mp4
Output folder: /path/to/output

📢 Extracting audio from video...
🎯 Transcribing audio with Whisper (base model)...
This may take a few minutes depending on video length...
✅ Transcription complete!

📝 Creating paragraph-formatted transcript...
✅ Paragraph formatting complete!

Generated files:
  📄 video.txt (raw)
  📄 video_formatted.txt (with timestamps)
  📄 video_clean.txt (paragraphs only)
  📄 video.srt (subtitles)
  📄 video.json (detailed)
```

## Advanced Usage

### Batch Processing
```bash
# Transcribe all videos in a directory
for video in *.mp4; do
  /transcribe:video "$video" ./transcriptions/
done
```

### Integration with Subtitles
```bash
# Generate subtitles for video player
/transcribe:video movie.mp4
# Use movie.srt in VLC, QuickTime, or other players
```

### Creating Documentation from Videos
```bash
# Extract clean text for documentation
/transcribe:video tutorial.mp4
cat tutorial_clean.txt >> documentation.md
```

## Notes

- Processing time: ~2-5 minutes per hour of video (depending on model)
- First run downloads Whisper model (50MB-1.5GB)
- Temporary audio files (~100MB per hour) are auto-deleted
- The FP16 warning on CPU is normal and expected
- Video resolution doesn't affect transcription (only audio is used)
- Multiple audio tracks: uses the primary/default track
- Works with screen recordings, meetings, lectures, etc.

## Troubleshooting

### Common Issues

**Issue 1: FFmpeg not found**
- Solution: Install FFmpeg using package manager (see Installation section)
- Verify: Run `ffmpeg -version` in terminal

**Issue 2: No audio track in video**
- Solution: Verify video has audio: `ffmpeg -i video.mp4 2>&1 | grep Audio`
- Some screen recordings may not include audio

**Issue 3: Out of disk space**
- Solution: Ensure enough space for temporary audio extraction
- ~100MB needed per hour of video

**Issue 4: Transcription takes too long**
- Solution: Video length directly affects processing time
- Consider splitting long videos or using cloud services

**Issue 5: Permission denied**
- Solution: Check write permissions for output directory
- Make script executable: `chmod +x .claude/commands/transcribe/scripts/video.sh`

## Special Features

### Paragraph Formatting Logic
- Groups text into paragraphs of 50-200 words
- Breaks on sentence endings when possible
- Detects natural pauses (>1 second) in speech
- Preserves timestamps for video synchronization

### Multiple Output Formats
- **Raw**: Direct Whisper output
- **Formatted**: Human-readable with timestamps
- **Clean**: Perfect for documentation/notes
- **SRT**: Industry-standard subtitle format
- **JSON**: Programmatic access with detailed timing

## Related Commands

- `/transcribe:audio`: Transcribe audio files directly
- `/translate`: Translate transcribed text to other languages
- `/summarize`: Create summary from transcription