#!/bin/bash


export HF_HUB_ENABLE_HF_TRANSFER=1

echo "🔥 Installing Stable Diffusion WebUI (SD WebUI)..."

mkdir -p /workspace/setup/touch

# Clone SD WebUI repo if it doesn't exist
if [ ! -f /workspace/setup/touch/sd-webui-clone ]; then
    echo "📥 Cloning SD WebUI repo..."
    git clone --recurse-submodules https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /workspace/sd-webui
    touch /workspace/setup/touch/sd-webui-clone
else
    echo "📁 SD WebUI repo already cloned — skipping."
fi

EXT_DIR="/workspace/sd-webui/extensions"

if [ ! -f /workspace/setup/touch/sd-webui-extensions ]; then
    echo "🧩 Cloning SD WebUI extensions..."
    mkdir -p "$EXT_DIR"
    cd "$EXT_DIR"

    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-wildcards.git
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-aesthetic-gradients.git
    git clone https://github.com/BlafKing/sd-civitai-browser-plus.git
    git clone https://github.com/KohakuBlueleaf/a1111-sd-webui-locon.git
    git clone https://github.com/Bing-su/adetailer.git
    git clone https://github.com/deforum-art/sd-webui-deforum.git
    git clone https://github.com/zanllp/sd-webui-infinite-image-browsing.git
    git clone https://github.com/Uminosachi/sd-webui-inpaint-anything.git
    git clone https://github.com/mcmonkeyprojects/sd-dynamic-thresholding.git
    git clone https://github.com/Mikubill/sd-webui-controlnet.git
    git clone https://github.com/civitai/sd_civitai_extension.git

    touch /workspace/setup/touch/sd-webui-extensions
else
    echo "📁 WebUI extensions already installed — skipping."
fi

# Navigate to the WebUI directory
cd /workspace/sd-webui

# Install Python dependencies using uv
if [ ! -f /workspace/setup/touch/sd-webui-install ]; then
    echo "📦 Installing SD WebUI Python dependencies..."
    uv pip install -r requirements_versions.txt --system
    touch /workspace/setup/touch/sd-webui-install
else
    echo "📁 SD WebUI dependencies already installed — skipping."
fi

echo "✅ SD WebUI setup complete."
