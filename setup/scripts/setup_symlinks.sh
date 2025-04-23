#!/bin/bash

mkdir -p /workspace/models/{checkpoints,vae,lora,controlnet,embeddings,hypernetworks,upscalers,lycoris}

#SD WebUI Links
ln -sfn /workspace/models/checkpoints     /workspace/sd-webui/models/Stable-diffusion
ln -sfn /workspace/models/vae             /workspace/sd-webui/models/VAE
ln -sfn /workspace/models/lora            /workspace/sd-webui/models/Lora
ln -sfn /workspace/models/embeddings      /workspace/sd-webui/embeddings
ln -sfn /workspace/models/hypernetworks   /workspace/sd-webui/models/hypernetworks
ln -sfn /workspace/models/upscalers       /workspace/sd-webui/models/ESRGAN
ln -sfn /workspace/models/lycoris         /workspace/sd-webui/models/LyCORIS
ln -sfn /workspace/models/controlnet      /workspace/sd-webui/extensions/sd-webui-controlnet/models

#ComfyUI Links
ln -sfn /workspace/models/checkpoints     /workspace/ComfyUI/models/checkpoints
ln -sfn /workspace/models/vae             /workspace/ComfyUI/models/vae
ln -sfn /workspace/models/lora            /workspace/ComfyUI/models/lora
ln -sfn /workspace/models/controlnet      /workspace/ComfyUI/models/controlnet
ln -sfn /workspace/models/embeddings      /workspace/ComfyUI/models/embeddings
ln -sfn /workspace/models/hypernetworks   /workspace/ComfyUI/models/hypernetworks
ln -sfn /workspace/models/upscalers       /workspace/ComfyUI/models/upscalers
ln -sfn /workspace/models/lycoris         /workspace/ComfyUI/models/lycoris


 echo "✅ Symlinks created:"

