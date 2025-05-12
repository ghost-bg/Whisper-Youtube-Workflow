#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/ghost-bg/Whisper-Youtube-Workflow.git"
REPO_DIR="Whisper-Youtube-Workflow"
IMAGE_NAME="whisper-pipeline"

USE_CPU=false

if [[ "${1:-}" == "--cpu" ]]; then
  USE_CPU=true
fi

if [ ! -d "$REPO_DIR" ]; then
    echo "[INFO] Cloning repository..."
    git clone "$REPO_URL"
fi

cd "$REPO_DIR"

if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker not found. Please install Docker manually."
    exit 1
fi

if [ "$USE_CPU" = false ] && docker info | grep -q 'Runtimes: nvidia'; then
    GPU_FLAG="--gpus all"
    echo "[INFO] NVIDIA GPU detected. Using GPU mode."
else
    GPU_FLAG=""
    echo "[INFO] Using CPU mode."
fi

if [ "$USE_CPU" = true ]; then
  DOCKERFILE="Dockerfile.cpu"
else
  DOCKERFILE="Dockerfile"
fi

if [ -t 1 ]; then
    TTY_FLAG="-it"
else
    TTY_FLAG=""
    echo "[WARN] No TTY detected. Running without -it."
fi

echo "[INFO] Building Docker image..."
docker build -t "$IMAGE_NAME" .

echo "[INFO] Starting container..."
docker run --rm $GPU_FLAG -v "$PWD":/app -w /app $TTY_FLAG "$IMAGE_NAME" ./process_youtube.sh
