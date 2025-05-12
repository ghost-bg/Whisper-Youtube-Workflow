from pathlib import Path

def format_timestamp(seconds):
    seconds = float(seconds)
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    millis = int((seconds - int(seconds)) * 1000)
    return f"{hours:02}:{minutes:02}:{secs:02},{millis:03}"

def fix_srt_file(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    fixed_lines = []
    for line in lines:
        if '-->' in line:
            try:
                start_raw, end_raw = line.strip().split('-->')
                start = format_timestamp(start_raw.strip().replace(',', '.'))
                end = format_timestamp(end_raw.strip().replace(',', '.'))
                fixed_lines.append(f"{start} --> {end}\n")
            except Exception:
                fixed_lines.append(line)
        else:
            fixed_lines.append(line)

    with open(file_path, "w", encoding="utf-8") as f:
        f.writelines(fixed_lines)

    print(f"[FIXED] {file_path}")

if __name__ == "__main__":
    srt_dir = Path("temp")
    for srt_file in srt_dir.glob("*.srt"):
        fix_srt_file(srt_file)
