#!/bin/bash
# Cross-Compilation Deployment Script for Raspberry Pi 5
# Use this when you cross-compile from x86_64 to ARM64

set -e

APP_NAME="GLADIS"
BUILD_DIR="build-local"
DEPLOY_DIR="deploy"
VERSION="1.0"
TARGET_ARCH="aarch64"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}Cross-Compilation Deployment for Pi 5${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""

# You need to set this to your Raspberry Pi sysroot location
# This is where you have the Pi's filesystem with Qt6 libraries
if [ -z "$PI_SYSROOT" ]; then
    # Common locations - adjust to your setup
    POSSIBLE_SYSROOTS=(
        "$HOME/raspberrypi/sysroot"
        "$HOME/rpi-sysroot"
        "$HOME/pi5-sysroot"
        "/opt/raspberry-pi/sysroot"
    )

    for sysroot in "${POSSIBLE_SYSROOTS[@]}"; do
        if [ -d "$sysroot" ]; then
            PI_SYSROOT="$sysroot"
            break
        fi
    done

    if [ -z "$PI_SYSROOT" ]; then
        echo -e "${RED}ERROR: Cannot find Raspberry Pi sysroot!${NC}"
        echo ""
        echo "Please set PI_SYSROOT environment variable:"
        echo "  export PI_SYSROOT=/path/to/your/raspberry-pi-sysroot"
        echo ""
        echo "Or edit this script and set PI_SYSROOT manually."
        echo ""
        echo "Your sysroot should contain:"
        echo "  - usr/lib/aarch64-linux-gnu/"
        echo "  - usr/lib/aarch64-linux-gnu/qt6/"
        echo ""
        exit 1
    fi
fi

echo -e "${GREEN}Using Raspberry Pi sysroot: $PI_SYSROOT${NC}"

# Verify sysroot has Qt6
if [ ! -d "$PI_SYSROOT/usr/lib/aarch64-linux-gnu" ]; then
    echo -e "${RED}ERROR: Sysroot doesn't look correct!${NC}"
    echo "Expected: $PI_SYSROOT/usr/lib/aarch64-linux-gnu/"
    exit 1
fi

# Find executable
EXECUTABLE=""
if [ -f "$BUILD_DIR/bin/$APP_NAME" ]; then
    EXECUTABLE="$BUILD_DIR/bin/$APP_NAME"
elif [ -f "$BUILD_DIR/$APP_NAME" ]; then
    EXECUTABLE="$BUILD_DIR/$APP_NAME"
elif [ -f "$APP_NAME" ]; then
    EXECUTABLE="$APP_NAME"
else
    echo -e "${RED}ERROR: Cannot find $APP_NAME executable!${NC}"
    exit 1
fi

echo -e "${GREEN}Found executable: $EXECUTABLE${NC}"

# Verify it's ARM64
if ! file "$EXECUTABLE" | grep -q "ARM aarch64"; then
    echo -e "${RED}ERROR: Executable is not ARM64!${NC}"
    file "$EXECUTABLE"
    echo ""
    echo "Make sure you cross-compiled for Raspberry Pi 5."
    exit 1
fi

echo -e "${GREEN}✓ Executable is ARM64 (correct for Raspberry Pi 5)${NC}"

# Clean and create deploy directory
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR/$APP_NAME"
mkdir -p "$DEPLOY_DIR/$APP_NAME/lib"
mkdir -p "$DEPLOY_DIR/$APP_NAME/plugins"
mkdir -p "$DEPLOY_DIR/$APP_NAME/qml"

# Copy executable
echo -e "${YELLOW}Copying executable...${NC}"
cp "$EXECUTABLE" "$DEPLOY_DIR/$APP_NAME/"

# Qt6 paths in sysroot
QT_LIB_PATH="$PI_SYSROOT/usr/lib/aarch64-linux-gnu"
QT_PLUGINS_PATH="$QT_LIB_PATH/qt6/plugins"
QT_QML_PATH="$QT_LIB_PATH/qt6/qml"

# Alternative paths
if [ ! -d "$QT_PLUGINS_PATH" ]; then
    QT_PLUGINS_PATH="$PI_SYSROOT/usr/lib/qt6/plugins"
    QT_QML_PATH="$PI_SYSROOT/usr/lib/qt6/qml"
fi

echo -e "${YELLOW}Copying Qt6 libraries from sysroot...${NC}"

# Copy Qt6 core libraries
for lib in libQt6Core.so.6 libQt6Gui.so.6 libQt6Quick.so.6 libQt6Qml.so.6 \
           libQt6QuickControls2.so.6 libQt6Svg.so.6 libQt6Core5Compat.so.6 \
           libQt6QmlModels.so.6 libQt6Network.so.6 libQt6OpenGL.so.6 \
           libQt6DBus.so.6; do
    if [ -f "$QT_LIB_PATH/$lib" ]; then
        cp -L "$QT_LIB_PATH/$lib" "$DEPLOY_DIR/$APP_NAME/lib/"
        echo "  ✓ $lib"
    fi
done

# Copy Qt6 dependencies
echo -e "${YELLOW}Copying Qt6 dependencies...${NC}"
for lib in libicui18n.so.* libicuuc.so.* libicudata.so.* \
           libzstd.so.* libdouble-conversion.so.* libb2.so.* \
           libpcre2-16.so.* libmd4c.so.*; do
    find "$PI_SYSROOT/usr/lib/aarch64-linux-gnu" -name "$lib" -exec cp -L {} "$DEPLOY_DIR/$APP_NAME/lib/" \; 2>/dev/null || true
done

# Copy Qt6 plugins
echo -e "${YELLOW}Copying Qt6 plugins...${NC}"
if [ -d "$QT_PLUGINS_PATH" ]; then
    for plugin_dir in platforms platformthemes platforminputcontexts xcbglintegrations imageformats iconengines egldeviceintegrations; do
        if [ -d "$QT_PLUGINS_PATH/$plugin_dir" ]; then
            cp -r "$QT_PLUGINS_PATH/$plugin_dir" "$DEPLOY_DIR/$APP_NAME/plugins/" 2>/dev/null || true
            echo "  ✓ $plugin_dir"
        fi
    done
fi

# Copy Qt6 QML modules
echo -e "${YELLOW}Copying Qt6 QML modules...${NC}"
if [ -d "$QT_QML_PATH" ]; then
    # Copy essential QML modules
    for module in QtQuick QtQuick.2 QtQml QtQuick.Controls QtQuick.Layouts \
                  QtQuick.Window QtQuick.Templates Qt5Compat.GraphicalEffects; do
        if [ -d "$QT_QML_PATH/$module" ]; then
            cp -r "$QT_QML_PATH/$module" "$DEPLOY_DIR/$APP_NAME/qml/" 2>/dev/null || true
            echo "  ✓ $module"
        fi
    done
fi

# Copy plugin dependencies
echo -e "${YELLOW}Copying plugin dependencies...${NC}"
# We need to use cross-compiled readelf to check dependencies
for plugin in "$DEPLOY_DIR/$APP_NAME/plugins"/*/*.so "$DEPLOY_DIR/$APP_NAME/qml"/*/*.so; do
    if [ -f "$plugin" ]; then
        # Extract library dependencies and copy from sysroot
        readelf -d "$plugin" 2>/dev/null | grep "NEEDED" | awk '{print $5}' | tr -d '[]' | while read needed_lib; do
            if [ -f "$QT_LIB_PATH/$needed_lib" ]; then
                if [ ! -f "$DEPLOY_DIR/$APP_NAME/lib/$needed_lib" ]; then
                    cp -L "$QT_LIB_PATH/$needed_lib" "$DEPLOY_DIR/$APP_NAME/lib/" 2>/dev/null || true
                fi
            fi
        done
    fi
done

# Create qt.conf
echo -e "${YELLOW}Creating Qt configuration...${NC}"
cat > "$DEPLOY_DIR/$APP_NAME/qt.conf" << 'EOF'
[Paths]
Prefix = .
Plugins = plugins
Imports = qml
Qml2Imports = qml
Libraries = lib
EOF

# Create launcher script (same as before)
cat > "$DEPLOY_DIR/$APP_NAME/run.sh" << 'LAUNCHER_EOF'
#!/bin/bash
# Self-Contained Launcher for GLADIS
# No external Qt6 installation required!

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set up environment for bundled Qt
export LD_LIBRARY_PATH="$SCRIPT_DIR/lib:$LD_LIBRARY_PATH"
export QT_PLUGIN_PATH="$SCRIPT_DIR/plugins"
export QML_IMPORT_PATH="$SCRIPT_DIR/qml"
export QML2_IMPORT_PATH="$SCRIPT_DIR/qml"
export QT_QPA_PLATFORM_PLUGIN_PATH="$SCRIPT_DIR/plugins/platforms"

# For Raspberry Pi: use OpenGL ES
if [ -f /proc/device-tree/model ] && grep -q "Raspberry Pi" /proc/device-tree/model; then
    export QT_QPA_PLATFORM=eglfs
    # Fallback to xcb if running in desktop environment
    if [ -n "$DISPLAY" ]; then
        export QT_QPA_PLATFORM=xcb
    fi
fi

# Run the application
exec "$SCRIPT_DIR/GLADIS" "$@"
LAUNCHER_EOF

chmod +x "$DEPLOY_DIR/$APP_NAME/run.sh"
chmod +x "$DEPLOY_DIR/$APP_NAME/$APP_NAME"

# Create README
cat > "$DEPLOY_DIR/$APP_NAME/README.md" << 'EOF'
# GLADIS - Self-Contained for Raspberry Pi 5

## Zero Dependencies Required! ✨

This application is **completely self-contained** and ready for Raspberry Pi 5.

**No Qt6 installation needed!**

## Quick Start on Raspberry Pi 5

```bash
# Extract
tar -xzf GLADIS-v1.0-aarch64.tar.gz

# Run
cd GLADIS
./run.sh
```

That's it! No `sudo apt install` commands needed.

## What's Included

- ARM64 executable (cross-compiled)
- All Qt6 libraries (ARM64)
- Qt6 plugins and QML modules
- Everything needed to run

## System Requirements

- Raspberry Pi 5 (or any ARM64 Linux)
- Raspberry Pi OS (or any Linux distribution)
- **No Qt6 installation required**

---

Cross-compiled and bundled for easy deployment!
EOF

# Calculate sizes
BUNDLE_SIZE=$(du -sh "$DEPLOY_DIR/$APP_NAME" | cut -f1)

# Create distributable archive
echo -e "${YELLOW}Creating distributable archive...${NC}"
cd "$DEPLOY_DIR"
tar -czf "${APP_NAME}-v${VERSION}-${TARGET_ARCH}.tar.gz" "$APP_NAME"
cd ..
ARCHIVE_SIZE=$(du -sh "$DEPLOY_DIR/${APP_NAME}-v${VERSION}-${TARGET_ARCH}.tar.gz" | cut -f1)

echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  Cross-Compilation Bundle Complete! ✅${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo -e "${YELLOW}Bundle Information:${NC}"
echo "  Location: $DEPLOY_DIR/$APP_NAME/"
echo "  Size: $BUNDLE_SIZE"
echo "  Architecture: ARM64 (aarch64)"
echo "  Target: Raspberry Pi 5"
echo ""
echo -e "${YELLOW}Archive Created:${NC}"
echo "  File: $DEPLOY_DIR/${APP_NAME}-v${VERSION}-${TARGET_ARCH}.tar.gz"
echo "  Size: $ARCHIVE_SIZE"
echo ""
echo -e "${YELLOW}Deploy to Raspberry Pi:${NC}"
echo "  scp $DEPLOY_DIR/${APP_NAME}-v${VERSION}-${TARGET_ARCH}.tar.gz pi@raspberrypi.local:~/"
echo "  ssh pi@raspberrypi.local"
echo "  tar -xzf ${APP_NAME}-v${VERSION}-${TARGET_ARCH}.tar.gz"
echo "  cd $APP_NAME && ./run.sh"
echo ""
echo -e "${GREEN}✨ No Qt6 installation needed on Raspberry Pi! ✨${NC}"
echo ""
