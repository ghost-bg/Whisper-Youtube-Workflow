FROM nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04

RUN apt update && apt install -y \
    python3 python3-pip ffmpeg mkvtoolnix rclone git parallel \
    && pip3 install --upgrade pip

RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip install faster-whisper yt-dlp

WORKDIR /app
COPY . /app

CMD ["bash"]
