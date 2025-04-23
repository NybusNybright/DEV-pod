#!/bin/bash


echo "🧱 Installing Comfy CLI and ComfyUI..."

# Enable Hugging Face accelerated transfer for this session
export HF_HUB_ENABLE_HF_TRANSFER=1

# Create touch directory
mkdir -p /workspace/setup/touch

# Clone ComfyUI
if [ ! -f /workspace/setup/touch/comfyui-clone ]; then
    echo "📥 Cloning ComfyUI repo..."
    git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI
    touch /workspace/setup/touch/comfyui-clone
else
    echo "📁 ComfyUI repo already cloned — skipping."
fi

# Clone ComfyUI custom nodes
if [ ! -f /workspace/setup/touch/comfyui-nodes ]; then
    echo "🧩 Installing ComfyUI nodes and LLM tools..."
    cd /workspace/ComfyUI/custom_nodes

    # General & UI Enhancements
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
    git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
    git clone https://github.com/LucianoCirino/efficiency-nodes-comfyui.git

    # Prompt & LLM Enhancers
    git clone https://github.com/prodogape/ComfyUI-clip-interrogator.git
    git clone https://github.com/inflamously/comfyui-prompt-enhancer.git
    git clone https://github.com/SeargeDP/ComfyUI_Searge_LLM.git

    # SDXL / Advanced workflows
    git clone https://github.com/SeargeDP/SeargeSDXL.git
    git clone https://github.com/thecooltechguy/ComfyUI-Stable-Video-Diffusion.git
    git clone https://github.com/Ling-APE/ComfyUI-All-in-One-FluxDev-Workflow.git

    touch /workspace/setup/touch/comfyui-nodes
else
    echo "📁 ComfyUI custom nodes already installed — skipping."
fi

mkdir -p /workspace/ComfyUI/scripts

# Clone ComfyUI scripts
if [ ! -f /workspace/setup/touch/comfyui-scripts ]; then
    echo "📜 Installing ComfyUI script tools..."
    cd /workspace/ComfyUI/scripts
    git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
    touch /workspace/setup/touch/comfyui-scripts
else
    echo "📁 ComfyUI scripts already installed — skipping."
fi

# Install ComfyUI dependencies
if [ ! -f /workspace/setup/touch/comfyui-install ]; then
    echo "📦 Installing ComfyUI Python dependencies..."
    cd /workspace/ComfyUI
    uv pip install -r requirements.txt --system
    touch /workspace/setup/touch/comfyui-install
else
    echo "📁 ComfyUI requirements already installed — skipping."
fi

mkdir -p /workspace/ComfyUI/workflows

# Install SDXL workflow packs
if [ ! -f /workspace/setup/touch/comfyui-workflows ]; then
    echo "📂 Cloning SDXL workflow packs..."
    cd /workspace/ComfyUI/workflows
    git clone https://github.com/cubiq/ComfyUI_Workflows.git
    git clone https://github.com/LostDiffusion/ComfyUI-Workflows.git
    
    touch /workspace/setup/touch/comfyui-workflows
else
    echo "📁 SDXL workflow packs already present — skipping."
fi

echo "✅ Comfy CLI + UI + custom nodes + workflows + scripts setup complete."
