#!/bin/bash

# GameLab Build and Run Script
# This script builds the project, rotates display, and runs the application

set -e  # Exit on error

echo "=== Building GLADIS ==="
cd build-local/
cmake ..
make -j$(nproc)

echo ""
echo "=== Copying binary to parent directory ==="
cp bin/GLADIS ../ 2>/dev/null || cp GLADIS ../ 2>/dev/null || true

cd ..

echo ""
echo "=== Rotating display to portrait mode ==="
xrandr --output Virtual1 --rotate left

echo ""
echo "=== Running GLADIS ==="
./GLADIS

echo ""
echo "=== Restoring display rotation ==="
xrandr --output Virtual1 --rotate normal

echo ""
echo "=== Done ==="
