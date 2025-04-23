#!/bin/bash


echo "🔑 Setting up SSH config..."

# Get pod IP and SSH port from environment
IP=$(printenv RUNPOD_PUBLIC_IP)
PORT=$(printenv RUNPOD_TCP_PORT_22)

# Create the internal SSH config directory if it doesn't exist
mkdir -p /workspace/setup/ssh_config

# Write the SSH config file
cat <<EOF > /workspace/setup/ssh_config/config
Host runpod
  HostName $IP
  User root
  Port $PORT
  IdentityFile ~/.ssh/id_ed25519
EOF

echo "📁 SSH config written to /workspace/setup/ssh_config/config"

# Only commit the new SSH config if there's a change
cd /workspace/setup

# Ensure that the correct repo is set up for git operations
git config user.name "${GIT_USER}"
git config user.email "${GIT_EMAIL}"

# Stage and commit only the SSH config file
git add ssh_config/config
git commit -m "Update SSH config for pod $IP:$PORT" || echo "No changes to commit"

# Push only if there are new commits
git push origin main

echo "✅ SSH config successfully updated and pushed to GitHub."


