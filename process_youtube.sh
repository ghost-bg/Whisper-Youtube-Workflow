#!/bin/bash
set -euo pipefail

INPUT_FILE="urls.txt"
TEMP_DIR="temp"
OUTPUT_DIR="output"
JOBS=1

mkdir -p "$TEMP_DIR" "$OUTPUT_DIR"
shopt -s nullglob

process_video() {
    local VIDEO_PATH="$1"
    local BASENAME
    local BASENAME_NOEXT
    local SRT_PATH
    local MKV_PATH

    BASENAME=$(basename "$VIDEO_PATH")
    BASENAME_NOEXT="${BASENAME%.*}"
    SRT_PATH="$TEMP_DIR/$BASENAME_NOEXT.srt"
    MKV_PATH="$OUTPUT_DIR/$BASENAME_NOEXT.mkv"

    echo "[INFO] Processing: $BASENAME"

    if [ -s "$SRT_PATH" ]; then
        echo "[INFO] Subtitle already exists, skipping transcription: $SRT_PATH"
    else
        echo "[INFO] Transcribing: $BASENAME"
        python3 faster_transcribe.py "$VIDEO_PATH" "$SRT_PATH"
        python3 fix_srt_format.py
    fi

    if [ ! -s "$SRT_PATH" ]; then
        echo "[ERROR] Subtitle file not found or empty: $SRT_PATH"
        return
    fi

    echo "[INFO] Attaching subtitles..."
    LC_ALL=C.UTF-8 mkvmerge -o "$MKV_PATH" "$VIDEO_PATH" \
        --language "0:jpn" \
        --track-name "0:Japanese Subtitles" \
        "$SRT_PATH"

    echo "[INFO] Completed: $BASENAME"
}

export -f process_video
export TEMP_DIR OUTPUT_DIR

while IFS= read -r URL || [ -n "$URL" ]; do
    echo "[INFO] Downloading: $URL"
    yt-dlp -f "bv[height<=1080]+ba/best" -o "$TEMP_DIR/%(title)s.%(ext)s" "$URL"
done < "$INPUT_FILE"

for f in "$TEMP_DIR"/*.{webm,mp4,mkv}; do
    [ -f "$f" ] && process_video "$f"
done
