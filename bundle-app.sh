#!/bin/bash
# Qt6 Application Bundler for Raspberry Pi 5
# Creates a self-contained package with all Qt dependencies

set -e

APP_NAME="GLADIS"
BUNDLE_DIR="${APP_NAME}-bundle"

echo "Creating self-contained bundle for ${APP_NAME}..."

# Find the executable (check multiple locations)
EXECUTABLE=""
if [ -f "build/$APP_NAME" ]; then
    EXECUTABLE="build/$APP_NAME"
elif [ -f "build/bin/$APP_NAME" ]; then
    EXECUTABLE="build/bin/$APP_NAME"
elif [ -f "$APP_NAME" ]; then
    EXECUTABLE="$APP_NAME"
else
    echo "ERROR: Cannot find $APP_NAME executable!"
    echo "Please build the application first with:"
    echo "  mkdir -p build && cd build && cmake .. && make && cd .."
    exit 1
fi

echo "Found executable: $EXECUTABLE"

# Verify it's a valid executable
if ! file "$EXECUTABLE" | grep -q "ELF"; then
    echo "ERROR: $EXECUTABLE is not a valid ELF executable!"
    exit 1
fi

# Clean previous bundle
rm -rf "$BUNDLE_DIR"

# Create directory structure
mkdir -p "$BUNDLE_DIR/lib"
mkdir -p "$BUNDLE_DIR/plugins/Qt6"

# Copy the executable
echo "Copying executable..."
cp "$EXECUTABLE" "$BUNDLE_DIR/"

# Find and copy Qt shared libraries
echo "Copying Qt libraries..."
ldd "$EXECUTABLE" | grep -i qt | awk '{print $3}' | while read lib; do
    if [ -f "$lib" ]; then
        cp -L "$lib" "$BUNDLE_DIR/lib/"
    fi
done

# Copy other required libraries (excluding system libraries)
echo "Copying additional dependencies..."
ldd "$EXECUTABLE" | grep -v 'linux-vdso\|libc.so\|libm.so\|libdl.so\|libpthread.so\|librt.so\|ld-linux' | awk '{print $3}' | grep -v '^$' | while read lib; do
    if [ -f "$lib" ]; then
        cp -L "$lib" "$BUNDLE_DIR/lib/" 2>/dev/null || true
    fi
done

# Copy Qt6 QML plugins
echo "Copying QML plugins..."
QML_PLUGINS_PATH="/usr/lib/aarch64-linux-gnu/qt6/qml"
if [ -d "$QML_PLUGINS_PATH" ]; then
    cp -r "$QML_PLUGINS_PATH"/* "$BUNDLE_DIR/plugins/" 2>/dev/null || true
fi

# Alternative QML path
QML_PLUGINS_PATH2="/usr/lib/qt6/qml"
if [ -d "$QML_PLUGINS_PATH2" ]; then
    cp -r "$QML_PLUGINS_PATH2"/* "$BUNDLE_DIR/plugins/" 2>/dev/null || true
fi

# Copy Qt6 plugins (platform, imageformats, etc.)
echo "Copying Qt platform plugins..."
QT_PLUGINS_PATH="/usr/lib/aarch64-linux-gnu/qt6/plugins"
if [ -d "$QT_PLUGINS_PATH" ]; then
    mkdir -p "$BUNDLE_DIR/plugins/platforms"
    mkdir -p "$BUNDLE_DIR/plugins/imageformats"
    mkdir -p "$BUNDLE_DIR/plugins/iconengines"

    cp -r "$QT_PLUGINS_PATH"/platforms/* "$BUNDLE_DIR/plugins/platforms/" 2>/dev/null || true
    cp -r "$QT_PLUGINS_PATH"/imageformats/* "$BUNDLE_DIR/plugins/imageformats/" 2>/dev/null || true
    cp -r "$QT_PLUGINS_PATH"/iconengines/* "$BUNDLE_DIR/plugins/iconengines/" 2>/dev/null || true
fi

# Create qt.conf to help Qt find plugins
cat > "$BUNDLE_DIR/qt.conf" << 'EOF'
[Paths]
Plugins = plugins
Qml2Imports = plugins
EOF

# Create launcher script
cat > "$BUNDLE_DIR/run.sh" << 'EOF'
#!/bin/bash
# Launcher script for GLADIS

# Get the directory where this script is located
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set library paths
export LD_LIBRARY_PATH="$DIR/lib:$LD_LIBRARY_PATH"

# Set QML import paths
export QML_IMPORT_PATH="$DIR/plugins"
export QML2_IMPORT_PATH="$DIR/plugins"

# Set Qt plugin path
export QT_PLUGIN_PATH="$DIR/plugins"

# Set Qt configuration
export QT_QPA_PLATFORM_PLUGIN_PATH="$DIR/plugins/platforms"

# For Raspberry Pi: detect if X11 is running and set platform accordingly
if [ -f /proc/device-tree/model ] && grep -q "Raspberry Pi" /proc/device-tree/model; then
    # Check if X11 is running (look for X server process or socket)
    if pgrep -x "X" > /dev/null || pgrep -x "Xorg" > /dev/null || [ -S /tmp/.X11-unix/X0 ]; then
        # X11 is running - use xcb platform
        export QT_QPA_PLATFORM=xcb
        # If DISPLAY is not set (e.g., running over SSH), set it to :0
        if [ -z "$DISPLAY" ]; then
            export DISPLAY=:0
            echo "X11 detected, setting DISPLAY=:0"
        fi
    else
        # No X11 - use EGLFS for direct framebuffer rendering
        export QT_QPA_PLATFORM=eglfs
        echo "No X11 detected, using EGLFS (direct framebuffer)"
    fi
fi

# Run the application
exec "$DIR/GLADIS" "$@"
EOF

chmod +x "$BUNDLE_DIR/run.sh"
chmod +x "$BUNDLE_DIR/$APP_NAME"

# Create README
cat > "$BUNDLE_DIR/README.txt" << 'EOF'
GLADIS - Self-Contained Bundle
===============================

This package contains everything needed to run the application
without installing Qt6 or other dependencies on the system.

To run:
-------
./run.sh

OR copy the entire folder to any location and run from there.

What's included:
----------------
- GLADIS: The main executable
- lib/: All Qt6 and required shared libraries
- plugins/: Qt6 QML modules and platform plugins
- run.sh: Launcher script that sets up the environment
- qt.conf: Qt configuration file

No system-wide Qt6 installation required!

EOF

# Calculate bundle size
BUNDLE_SIZE=$(du -sh "$BUNDLE_DIR" | cut -f1)

echo ""
echo "Bundle created successfully!"
echo "Location: $BUNDLE_DIR/"
echo "Size: $BUNDLE_SIZE"
echo ""
echo "To run the application:"
echo "  cd $BUNDLE_DIR"
echo "  ./run.sh"
echo ""
echo "To create a distributable archive:"
echo "  tar -czf ${APP_NAME}-bundle.tar.gz $BUNDLE_DIR"
echo ""
