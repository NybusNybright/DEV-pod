#!/bin/bash


echo "🚀 Launching services..."

# Get pod ID and IP
POD_ID=$(printenv RUNPOD_POD_ID)
IP=$(printenv RUNPOD_PUBLIC_IP)
# PORT=$(printenv RUNPOD_PUBLIC_IP) 

# Flask WebUI
echo "🧪 Starting Flask launcher on port 5555..."
python /workspace/setup/launcher.py \
  --host=0.0.0.0 \
  --port=5555 > /workspace/launcher.log 2>&1 &

# Wait a few seconds for server to start
sleep 3

# Proxy-URL output
echo "🔍 Checking service status..."

if lsof -i :5555 | grep LISTEN > /dev/null; then
    echo "✅ Flask running: https://${POD_ID}-5555.proxy.runpod.net"
else
    echo "❌ Flask failed — logs:"
    tail -n 20 /workspace/launcher.log
fi

# Just check if built-in Jupyter is running
if lsof -i :8888 | grep LISTEN > /dev/null; then
    echo "✅ Jupyter running: https://${POD_ID}-8888.proxy.runpod.net/lab"
else
    echo "⚠️  Jupyter not detected — it may be using a different port or failed to start."
fi
