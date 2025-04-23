#!/bin/bash


echo "📦 Installing system packages..."

# apt update && apt install -y \
#   git wget curl nano zip tar \
#   ffmpeg p7zip-full lsof \
#   libsm6 libxext6 psmisc

pip install --upgrade pip
pip install uv

echo "📦 Installing Python packages..."

uv pip install flask "huggingface_hub[hf_transfer]" --system

echo "✅ Python packages complete."
