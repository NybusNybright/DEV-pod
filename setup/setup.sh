#!/bin/bash

bash -c '

mkdir -p /workspace/setup/touch
SCRIPT_DIR="/workspace/setup/scripts"

echo "🔧 Starting setup sequence..."
bash $SCRIPT_DIR/setup_ssh_config.sh
bash $SCRIPT_DIR/install_packages.sh

# Enable Hugging Face accelerated transfer
export HF_HUB_ENABLE_HF_TRANSFER=1

bash $SCRIPT_DIR/setup_comfy.sh
bash $SCRIPT_DIR/setup_sd_webui.sh
bash $SCRIPT_DIR/setup_symlinks.sh
bash $SCRIPT_DIR/launch_services.sh

touch /workspace/setup_done

echo "✅ Setup complete!"
'
