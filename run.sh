#!/bin/bash

# GameLab Build and Run Script
# This script builds the project, rotates display, and runs the application
#
# Usage:
#   ./run.sh                    # Use default resolution from gladis.ini
#   ./run.sh 1024 600           # Set resolution to 1024x600
#   ./run.sh 1920 1080          # Set resolution to 1920x1080
#   ./run.sh 1024 600 nobuild   # Run with 1024x600 without rebuilding

set -e  # Exit on error

# Parse arguments
WIDTH=${1:-""}
HEIGHT=${2:-""}
SKIP_BUILD=${3:-""}

# Check if we should skip build
if [[ "$WIDTH" == "nobuild" ]] || [[ "$HEIGHT" == "nobuild" ]] || [[ "$SKIP_BUILD" == "nobuild" ]]; then
    SKIP_BUILD="true"
else
    SKIP_BUILD="false"
fi

# Update resolution BEFORE building
RESOLUTION_PARAMS=""
if [[ -n "$WIDTH" && -n "$HEIGHT" && "$WIDTH" != "nobuild" && "$HEIGHT" != "nobuild" ]]; then
    echo ""
    echo "=== Setting custom resolution: ${WIDTH}x${HEIGHT} ==="

    # Update local gladis.ini with custom resolution
    if [[ -f "gladis.ini" ]]; then
        sed -i "s/^render_window = .*/render_window = ${WIDTH};${HEIGHT}/" gladis.ini
        echo "Updated gladis.ini with resolution ${WIDTH}x${HEIGHT}"
    fi

    # Also update live config if it exists
    LIVE_CONFIG="/dev/shm/app/gladis.ini"
    if [[ -f "$LIVE_CONFIG" ]]; then
        sudo sed -i "s/^render_window = .*/render_window = ${WIDTH};${HEIGHT}/" "$LIVE_CONFIG" 2>/dev/null || \
        sed -i "s/^render_window = .*/render_window = ${WIDTH};${HEIGHT}/" "$LIVE_CONFIG" 2>/dev/null || \
        echo "Note: Could not update $LIVE_CONFIG (no permissions or file doesn't exist)"
    fi
else
    echo ""
    echo "=== Using default resolution from gladis.ini ==="
fi

# Build the project
if [[ "$SKIP_BUILD" == "false" ]]; then
    echo ""
    echo "=== Building GLADIS ==="
    cd build-local/
    cmake ..
    make -j$(nproc)

    echo ""
    echo "=== Copying binary to parent directory ==="
    cp bin/GLADIS ../ 2>/dev/null || cp GLADIS ../ 2>/dev/null || true

    cd ..
else
    echo "=== Skipping build ==="
fi

echo ""
echo "=== Rotating display to portrait mode ==="
xrandr --output Virtual1 --rotate left 2>/dev/null || echo "warning: output Virtual1 not found; ignoring"

echo ""
echo "=== Running GLADIS ==="
./GLADIS

echo ""
echo "=== Restoring display rotation ==="
xrandr --output Virtual1 --rotate normal 2>/dev/null || true

echo ""
echo "=== Done ==="
