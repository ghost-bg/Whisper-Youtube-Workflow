import sys
from faster_whisper import WhisperModel

def format_timestamp(seconds: float) -> str:
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    millis = int((seconds - int(seconds)) * 1000)
    return f"{hours:02}:{minutes:02}:{secs:02},{millis:03}"

if len(sys.argv) != 3:
    print("Usage: python3 faster_transcribe.py <input_video> <output_srt>")
    sys.exit(1)

input_video = sys.argv[1]
output_srt = sys.argv[2]

print(f"[INFO] Loading model...")
model = WhisperModel("large-v2", device="cuda", compute_type="float16")

print(f"[INFO] Transcribing: {input_video}")
segments, _ = model.transcribe(input_video, language="ja")
segments = list(segments)

if not segments:
    print("[ERROR] No segments generated. Exiting.")
    sys.exit(1)

print(f"[INFO] Writing subtitles to: {output_srt}")
with open(output_srt, "w", encoding="utf-8") as f:
    for i, segment in enumerate(segments, 1):
        start = format_timestamp(segment.start)
        end = format_timestamp(segment.end)
        f.write(f"{i}\n{start} --> {end}\n{segment.text.strip()}\n\n")

print("[INFO] Subtitle writing complete.")
