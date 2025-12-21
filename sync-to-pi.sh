#!/bin/bash
# Bash script to sync GLADIS project to Raspberry Pi
# Usage: ./sync-to-pi.sh

PI_IP="192.168.1.87"
PI_USER="pi"  # Change this if your username is different
PI_DEST="~/gladis"

echo "Syncing GLADIS project to Raspberry Pi at $PI_IP..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Ensure the destination directory exists on the Pi
ssh "${PI_USER}@${PI_IP}" "mkdir -p ${PI_DEST}"

# Use rsync to sync the project, excluding build artifacts
rsync -avz --progress \
    --exclude 'build/' \
    --exclude 'build-*/' \
    --exclude 'cmake-build-*/' \
    --exclude 'deploy/' \
    --exclude '*-bundle/' \
    --exclude '*.AppImage' \
    --exclude '*.tar.gz' \
    --exclude '*.tar.xz' \
    --exclude '*.zip' \
    --exclude '.git/' \
    --exclude '.vscode/' \
    --exclude '.idea/' \
    --exclude '*.o' \
    --exclude '*.so' \
    --exclude '*.a' \
    --exclude '*.log' \
    "$SCRIPT_DIR/" "${PI_USER}@${PI_IP}:${PI_DEST}/"

if [ $? -eq 0 ]; then
    echo ""
    echo "Sync completed successfully!"
    echo "Project copied to: ${PI_USER}@${PI_IP}:${PI_DEST}"
else
    echo ""
    echo "Sync failed!"
    exit 1
fi
