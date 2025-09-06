#!/bin/bash

# Claude Code slash command for video transcription
# Usage: /transcribe {path to video} {output folder}

VIDEO_PATH="$1"
OUTPUT_DIR="${2:-.}"  # Default to current directory if not specified

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
	echo -e "${2}${1}${NC}"
}

# Check if video path is provided
if [ -z "$VIDEO_PATH" ]; then
	print_message "Error: No video file specified" "$RED"
	echo "Usage: /transcribe <video_path> [output_folder]"
	echo ""
	echo "Examples:"
	echo "  /transcribe video.mp4"
	echo "  /transcribe /path/to/video.mp4 /path/to/output"
	exit 1
fi

# Expand tilde in paths
VIDEO_PATH="${VIDEO_PATH/#\~/$HOME}"
OUTPUT_DIR="${OUTPUT_DIR/#\~/$HOME}"

# Check if video file exists
if [ ! -f "$VIDEO_PATH" ]; then
	print_message "Error: Video file not found: $VIDEO_PATH" "$RED"
	exit 1
fi

# Create output directory if it doesn't exist
if [ ! -d "$OUTPUT_DIR" ]; then
	print_message "Creating output directory: $OUTPUT_DIR" "$YELLOW"
	mkdir -p "$OUTPUT_DIR"
fi

# Get the base name without extension
BASENAME=$(basename "$VIDEO_PATH" | sed 's/\.[^.]*$//')
TEMP_AUDIO="${OUTPUT_DIR}/${BASENAME}_temp_audio.wav"

print_message "🎬 Starting transcription process..." "$GREEN"
echo "Video: $VIDEO_PATH"
echo "Output folder: $OUTPUT_DIR"
echo ""

# Step 1: Extract audio
print_message "📢 Extracting audio from video..." "$YELLOW"
ffmpeg -i "$VIDEO_PATH" -vn -acodec pcm_s16le -ar 16000 -ac 1 "$TEMP_AUDIO" -y -loglevel error

if [ $? -ne 0 ]; then
	print_message "Error: Failed to extract audio from video" "$RED"
	exit 1
fi

# Step 2: Transcribe with Whisper
print_message "🎯 Transcribing audio with Whisper (base model)..." "$YELLOW"
echo "This may take a few minutes depending on video length..."

# Run Whisper with multiple output formats
cd "$OUTPUT_DIR"
whisper "$TEMP_AUDIO" \
	--model base \
	--output_format txt \
	--output_format srt \
	--output_format json \
	--output_dir "$OUTPUT_DIR" \
	--verbose False

if [ $? -eq 0 ]; then
	print_message "✅ Transcription complete!" "$GREEN"
	echo ""

	# Rename files to match original video name
	for ext in txt srt json; do
		if [ -f "${OUTPUT_DIR}/${BASENAME}_temp_audio.$ext" ]; then
			mv "${OUTPUT_DIR}/${BASENAME}_temp_audio.$ext" "${OUTPUT_DIR}/${BASENAME}.$ext"
		fi
	done

	# Step 3: Create paragraph-formatted version from JSON
	if [ -f "${OUTPUT_DIR}/${BASENAME}.json" ]; then
		print_message "📝 Creating paragraph-formatted transcript..." "$YELLOW"

		# Use the improved formatter if available, otherwise use inline version
		if [ -f "/Users/william/format-transcription.py" ]; then
			python3 /Users/william/format-transcription.py "${OUTPUT_DIR}/${BASENAME}.json"
		else
			python3 -c "
import json
from datetime import timedelta
from pathlib import Path

def format_timestamp(seconds):
	td = timedelta(seconds=seconds)
	hours = int(td.total_seconds() // 3600)
	minutes = int((td.total_seconds() % 3600) // 60)
	seconds = int(td.total_seconds() % 60)
	if hours > 0:
		return f'{hours:02d}:{minutes:02d}:{seconds:02d}'
	else:
		return f'{minutes:02d}:{seconds:02d}'

def create_paragraphs(json_file, min_words=50, max_words=200):
	with open(json_file, 'r') as f:
		data = json.load(f)

	segments = data.get('segments', [])
	if not segments:
		return []

	paragraphs = []
	current_paragraph = []
	current_words = 0
	paragraph_start = segments[0]['start']

	for i, segment in enumerate(segments):
		text = segment['text'].strip()
		word_count = len(text.split())

		current_paragraph.append(text)
		current_words += word_count

		should_break = False

		if current_words >= min_words:
			if text.rstrip().endswith(('.', '!', '?')):
				should_break = True
			elif current_words >= max_words:
				should_break = True

		if i < len(segments) - 1:
			next_segment = segments[i + 1]
			pause = next_segment['start'] - segment['end']
			if pause > 1.0 and current_words >= min_words // 2:
				should_break = True

		if should_break or i == len(segments) - 1:
			if current_paragraph:
				paragraph_text = ' '.join(current_paragraph)
				paragraphs.append({
					'start': paragraph_start,
					'end': segment['end'],
					'text': paragraph_text
				})

				if i < len(segments) - 1:
					current_paragraph = []
					current_words = 0
					paragraph_start = segments[i + 1]['start']

	return paragraphs

# Process file
json_file = Path('${OUTPUT_DIR}/${BASENAME}.json')
paragraphs = create_paragraphs(str(json_file))

# Write formatted output
formatted_file = '${OUTPUT_DIR}/${BASENAME}_formatted.txt'
with open(formatted_file, 'w') as f:
	f.write('# Transcription: ${BASENAME}\\n\\n')
	for para in paragraphs:
		timestamp = f\"[{format_timestamp(para['start'])} - {format_timestamp(para['end'])}]\"
		f.write(f\"{timestamp}\\n{para['text']}\\n\\n\")

# Write clean output
clean_file = '${OUTPUT_DIR}/${BASENAME}_clean.txt'
with open(clean_file, 'w') as f:
	f.write('# Transcription: ${BASENAME}\\n\\n')
	for para in paragraphs:
		f.write(f\"{para['text']}\\n\\n\")

print(f'Created: {formatted_file}')
print(f'Created: {clean_file}')
print(f'Total paragraphs: {len(paragraphs)}')
"
		fi

		if [ $? -eq 0 ]; then
			print_message "✅ Paragraph formatting complete!" "$GREEN"
		fi
	fi

	# Clean up temporary audio file
	rm -f "$TEMP_AUDIO"

	echo ""
	echo "Generated files:"
	echo "  📄 ${OUTPUT_DIR}/${BASENAME}.txt (raw)"
	echo "  📄 ${OUTPUT_DIR}/${BASENAME}_formatted.txt (with timestamps)"
	echo "  📄 ${OUTPUT_DIR}/${BASENAME}_clean.txt (paragraphs only)"
	echo "  📄 ${OUTPUT_DIR}/${BASENAME}.srt (subtitles)"
	echo "  📄 ${OUTPUT_DIR}/${BASENAME}.json (detailed)"

	echo ""
	print_message "📝 Preview of formatted transcription:" "$YELLOW"
	echo "----------------------------------------"
	if [ -f "${OUTPUT_DIR}/${BASENAME}_formatted.txt" ]; then
		head -n 20 "${OUTPUT_DIR}/${BASENAME}_formatted.txt"
		echo "..."
		echo "(Full transcription saved to ${OUTPUT_DIR}/${BASENAME}_formatted.txt)"
	fi
else
	print_message "Error: Transcription failed" "$RED"
	rm -f "$TEMP_AUDIO"
	exit 1
fi