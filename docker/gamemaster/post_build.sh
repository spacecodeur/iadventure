#!/bin/bash

echo "alias ll='ls -all'" >> /home/appuser/.bashrc

# Automatic download of EVA Qwen2.5-72B model
echo "🔍 Checking and downloading EVA Qwen2.5-72B model..."
python3 /app/docker/gamemaster/download_model.py

# Make status check script executable
chmod +x /app/docker/gamemaster/check_download_status.sh

tail -f /dev/null # keep the container running after build