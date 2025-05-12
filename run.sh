#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/ghost-bg/Whisper-Youtube-Workflow.git"
REPO_DIR="Whisper-Youtube-Workflow"
IMAGE_NAME="whisper-pipeline"

if [ ! -d "$REPO_DIR" ]; then
    echo "[INFO] Cloning repository..."
    git clone "$REPO_URL"
fi

cd "$REPO_DIR"

if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker not found. Please install Docker manually first."
    exit 1
fi

if ! docker info | grep -q 'Runtimes: nvidia'; then
    echo "[WARNING] NVIDIA Docker runtime not found or GPU not available."
    echo "Please install NVIDIA Container Toolkit: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
fi

echo "[INFO] Building Docker image..."
docker build -t "$IMAGE_NAME" .

echo "[INFO] Starting container..."
docker run --gpus all -it -v $(pwd):/app "$IMAGE_NAME"
