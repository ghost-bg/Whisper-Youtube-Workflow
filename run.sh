#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/ghost-bg/Whisper-Youtube-Workflow.git"
REPO_DIR="Whisper-Youtube-Workflow"
IMAGE_NAME="whisper-pipeline"

USE_CPU=false

# Allow user to force CPU mode
if [[ "${1:-}" == "--cpu" ]]; then
  USE_CPU=true
fi

# Clone repo if missing
if [ ! -d "$REPO_DIR" ]; then
    echo "[INFO] Cloning repository..."
    git clone "$REPO_URL"
fi

cd "$REPO_DIR"

# Ensure Docker is installed
if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker not found. Please install Docker manually."
    exit 1
fi

# Determine GPU usage
if [ "$USE_CPU" = false ]; then
    if docker info 2>/dev/null | grep -q 'Runtimes: nvidia'; then
        GPU_FLAG="--gpus all"
        echo "[INFO] NVIDIA GPU detected. Using GPU mode."
    else
        echo "[WARN] GPU requested but NVIDIA runtime not available. Falling back to CPU."
        USE_CPU=true
        GPU_FLAG=""
    fi
else
    GPU_FLAG=""
    echo "[INFO] Forced CPU mode enabled."
fi

# Choose Dockerfile
if [ "$USE_CPU" = true ]; then
    DOCKERFILE="Dockerfile.cpu"
else
    DOCKERFILE="Dockerfile.gpu"
fi

# Validate Dockerfile
if [ ! -f "$DOCKERFILE" ]; then
    echo "[ERROR] $DOCKERFILE not found!"
    exit 1
fi

# Detect TTY
if [ -t 1 ]; then
    TTY_FLAG="-it"
else
    TTY_FLAG=""
    echo "[WARN] No TTY detected. Running without -it."
fi

# Build image
echo "[INFO] Building Docker image from $DOCKERFILE..."
docker build -f "$DOCKERFILE" -t "$IMAGE_NAME" .

# Run container
echo "[INFO] Starting container..."
docker run --rm $GPU_FLAG -v "$PWD":/app -w /app $TTY_FLAG "$IMAGE_NAME" ./process_youtube.sh
